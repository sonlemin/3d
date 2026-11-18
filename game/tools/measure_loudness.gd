extends SceneTree
## Measures how loud every clip comes out through every level, and writes the per-trial
## loudness table that evens them out:
##
##     godot --headless --path game -s res://tools/measure_loudness.gd              (measure only)
##     godot --headless --path game -s res://tools/measure_loudness.gd -- --write   (save the table)
##     godot --headless --path game -s res://tools/measure_loudness.gd -- --verify  (check it)
##
## Plays each clip through each level's real bus chain (the actual ear-test scene, from the far
## bank, facing it) for the whole cry window, records the Master output and measures it as
## ITU-R BS.1770 integrated loudness (K-weighted, gated, both ears summed, LUFS). --write saves
## TrialPlan.LOUDNESS_TABLE_PATH: for each clip and level, the emitter gain that brings it to the
## average of all measurements. --verify plays every cry with its gain and fails (exit 1) if any
## lands more than VERIFY_TOLERANCE_LU from the target. Real time: about 6.5 s per clip per
## level. Re-run --write after changing the clips or BUS_FX; the setup screen lists any clip
## without an entry.

const TrialPlan := preload("res://scripts/trial_plan.gd")
const CryLibrary := preload("res://scripts/cry_library.gd")

## Long enough for the previous level's reverb tail (below: a cave) to die away.
const SETTLE_S: float = 2.5
## Measured from the start of each cry: the whole window a trial plays.
const RECORD_S: float = TrialPlan.CRY_WINDOW_S
const VERIFY_TOLERANCE_LU: float = 1.0

var _scene: Node
var _capture: AudioEffectCapture


func _initialize() -> void:
	_scene = (load("res://scenes/ear_test.tscn") as PackedScene).instantiate()
	root.add_child(_scene)
	_capture = AudioEffectCapture.new()
	_capture.buffer_length = RECORD_S + 1.0
	AudioServer.add_bus_effect(0, _capture)
	_run.call_deferred()


func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var verify: bool = args.has("--verify")
	var library: CryLibrary = _scene.get("library")
	var clips: PackedStringArray = []
	for kind: String in TrialPlan.LEVELS:
		clips.append_array(library.clips_for(kind))
	if clips.is_empty():
		printerr("measure_loudness: no clips found under %s" % CryLibrary.DEFAULT_ROOT)
		quit(1)
		return
	var table: Dictionary = {}
	if verify:
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(TrialPlan.LOUDNESS_TABLE_PATH))
		if not parsed is Dictionary:
			printerr("measure_loudness: no table at %s to verify; run with --write first" % TrialPlan.LOUDNESS_TABLE_PATH)
			quit(1)
			return
		table = parsed
	print("%s %d clips x %d levels (about %d s)..." % ["Verifying" if verify else "Measuring", clips.size(),
			TrialPlan.LEVELS.size(), roundi(clips.size() * 3 * (SETTLE_S + RECORD_S))])
	var measured: Dictionary = {}
	var all: Array = []
	for clip: String in clips:
		measured[clip] = {}
		for level: String in TrialPlan.LEVELS:
			var gain: float = library.gain_db(clip, level) if verify else 0.0
			var lufs: float = await _measure(library.stream_for(clip), level, gain)
			measured[clip][level] = snappedf(lufs, 0.1)
			all.append(lufs)
			print("  %-40s %-7s %6.1f LUFS%s" % [clip.trim_prefix(CryLibrary.DEFAULT_ROOT + "/"), level, lufs,
					("  (gain %+.1f dB)" % gain) if verify else ""])

	if verify:
		var target: float = table.get("target_lufs", 0.0)
		var worst: float = 0.0
		for lufs: float in all:
			worst = maxf(worst, absf(lufs - target))
		var ok: bool = worst <= VERIFY_TOLERANCE_LU
		print("\nTarget %.1f LUFS; every cry within %.2f LU of it (tolerance %.1f): %s"
				% [target, worst, VERIFY_TOLERANCE_LU, "OK" if ok else "FAIL"])
		quit(0 if ok else 1)
		return

	var target: float = 0.0
	for lufs: float in all:
		target += lufs / all.size()
	var gains: Dictionary = {}
	for clip: String in clips:
		gains[clip] = {}
		for level: String in TrialPlan.LEVELS:
			gains[clip][level] = snappedf(target - measured[clip][level], 0.1)
	print("\nTarget (mean of all) %.1f LUFS; gains from %+.1f to %+.1f dB."
			% [target, target - all.max(), target - all.min()])
	if args.has("--write"):
		var file: FileAccess = FileAccess.open(TrialPlan.LOUDNESS_TABLE_PATH, FileAccess.WRITE)
		file.store_string(JSON.stringify({
			"about": "Per-trial loudness matching for the ear test, written by tools/measure_loudness.gd -- --write. gains_db: the emitter gain for each clip and level. measured_lufs: loudness through each level's buses at 0 dB gain.",
			"target_lufs": snappedf(target, 0.1),
			"gains_db": gains,
			"measured_lufs": measured,
		}, "\t", true) + "\n")
		file.close()
		print("Wrote %s" % TrialPlan.LOUDNESS_TABLE_PATH)
	quit(0)


## Plays `stream` from the far bank through `level`'s bus at `gain_db` and returns its loudness.
func _measure(stream: AudioStream, level: String, gain_db: float) -> float:
	var emitter: AudioStreamPlayer3D = _scene.get("emitter")
	var listener: Node3D = _scene.get("listener")
	emitter.stop()
	emitter.stream = stream
	emitter.bus = TrialPlan.LEVEL_BUSES[level]
	emitter.global_position = TrialPlan.source_position(TrialPlan.LISTEN_DIRECTION, level)
	emitter.volume_db = TrialPlan.EMITTER_VOLUME_DB + gain_db
	listener.rotation = Vector3.ZERO
	await create_timer(SETTLE_S).timeout
	_capture.clear_buffer()
	emitter.play()
	await create_timer(RECORD_S).timeout
	var frames: PackedVector2Array = _capture.get_buffer(_capture.get_frames_available())
	emitter.stop()
	emitter.volume_db = TrialPlan.EMITTER_VOLUME_DB
	return k_weighted_lufs(frames, AudioServer.get_mix_rate())


## ITU-R BS.1770 integrated loudness of a stereo buffer: K-weighted, both channels summed,
## over 400 ms blocks (75% overlap) gated at -70 LUFS and then 10 LU below the ungated level,
## so the gaps in a cry don't pull its loudness down. Buffers under 400 ms count as one block.
static func k_weighted_lufs(frames: PackedVector2Array, rate: float) -> float:
	if frames.is_empty():
		return -INF
	var shelf: PackedFloat64Array = _shelf_coeffs(rate)
	var high_pass: PackedFloat64Array = _high_pass_coeffs(rate)
	var power: PackedFloat64Array = PackedFloat64Array()  # K-weighted power per frame, channels summed
	power.resize(frames.size())
	for channel: int in 2:
		var stage1: Array[float] = [0.0, 0.0, 0.0, 0.0]  # Array, not Packed: updated in place
		var stage2: Array[float] = [0.0, 0.0, 0.0, 0.0]
		for i: int in frames.size():
			var x: float = frames[i].x if channel == 0 else frames[i].y
			var z: float = _biquad(high_pass, stage2, _biquad(shelf, stage1, x))
			power[i] += z * z
	var block: int = mini(int(0.4 * rate), frames.size())
	var step: int = maxi(1, block / 4)
	var prefix: PackedFloat64Array = PackedFloat64Array()
	prefix.resize(frames.size() + 1)
	for i: int in frames.size():
		prefix[i + 1] = prefix[i] + power[i]
	var blocks: PackedFloat64Array = PackedFloat64Array()
	for start: int in range(0, frames.size() - block + 1, step):
		blocks.append((prefix[start + block] - prefix[start]) / block)
	var gated: float = _mean_above(blocks, _lufs_to_power(-70.0))
	if gated <= 0.0:
		return -INF
	return _power_to_lufs(_mean_above(blocks, gated * _lufs_to_power(-10.0 + 0.691) / _lufs_to_power(0.691)))


static func _mean_above(blocks: PackedFloat64Array, threshold: float) -> float:
	var total: float = 0.0
	var count: int = 0
	for b: float in blocks:
		if b > threshold:
			total += b
			count += 1
	return total / count if count > 0 else 0.0


static func _lufs_to_power(lufs: float) -> float:
	return pow(10.0, (lufs + 0.691) / 10.0)


static func _power_to_lufs(power: float) -> float:
	return -0.691 + 10.0 * log(power + 1e-20) / log(10.0)


## Stage 1: the head's high shelf, +4 dB above ~1.7 kHz. Returns [b0, b1, b2, a1, a2].
static func _shelf_coeffs(rate: float) -> PackedFloat64Array:
	var f0: float = 1681.974450955533
	var gain_db: float = 3.999843853973347
	var q: float = 0.7071752369554196
	var k: float = tan(PI * f0 / rate)
	var vh: float = pow(10.0, gain_db / 20.0)
	var vb: float = pow(vh, 0.4996667741545416)
	var a0: float = 1.0 + k / q + k * k
	return PackedFloat64Array([(vh + vb * k / q + k * k) / a0, 2.0 * (k * k - vh) / a0,
			(vh - vb * k / q + k * k) / a0, 2.0 * (k * k - 1.0) / a0, (1.0 - k / q + k * k) / a0])


## Stage 2: the RLB high-pass at ~38 Hz. Returns [b0, b1, b2, a1, a2].
static func _high_pass_coeffs(rate: float) -> PackedFloat64Array:
	var f0: float = 38.13547087602444
	var q: float = 0.5003270373238773
	var k: float = tan(PI * f0 / rate)
	var a0: float = 1.0 + k / q + k * k
	return PackedFloat64Array([1.0, -2.0, 1.0, 2.0 * (k * k - 1.0) / a0, (1.0 - k / q + k * k) / a0])


## One sample through a biquad; `state` is [x1, x2, y1, y2] and is updated in place.
static func _biquad(c: PackedFloat64Array, state: Array[float], x: float) -> float:
	var y: float = c[0] * x + c[1] * state[0] + c[2] * state[1] - c[3] * state[2] - c[4] * state[3]
	state[1] = state[0]
	state[0] = x
	state[3] = state[2]
	state[2] = y
	return y
