extends SceneTree
## Measures how loud each level plays and suggests LEVEL_BUS_VOLUME_DB trims that match them.
##
##     godot --headless --path game -s res://tools/measure_loudness.gd
##
## Plays every clip in res://audio/cries/ through every level's real bus chain (the actual
## ear-test scene, from the far bank, facing it), records the Master output and measures its
## loudness K-weighted as in ITU-R BS.1770 (LUFS). Takes about 4 s per clip per level, in real
## time. Re-run after changing BUS_FX or the clips, then copy the suggested values into
## LEVEL_BUS_VOLUME_DB in scripts/trial_plan.gd and the level buses' volume_db in
## default_bus_layout.tres (the tests check they match).

const TrialPlan := preload("res://scripts/trial_plan.gd")
const CryLibrary := preload("res://scripts/cry_library.gd")

## Long enough for the previous level's reverb tail (below: a cave) to die away.
const SETTLE_S: float = 2.5
## Measured window from the start of each cry.
const RECORD_S: float = 1.6

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
	var library: CryLibrary = _scene.get("library")
	var clips: PackedStringArray = []
	for kind: String in TrialPlan.LEVELS:
		clips.append_array(library.clips_for(kind))
	if clips.is_empty():
		printerr("measure_loudness: no clips found under %s" % CryLibrary.DEFAULT_ROOT)
		quit(1)
		return
	print("Measuring %d clips x %d levels (about %d s)..."
			% [clips.size(), TrialPlan.LEVELS.size(), roundi(clips.size() * 3 * (SETTLE_S + RECORD_S))])
	var per_level: Dictionary = {}
	for level: String in TrialPlan.LEVELS:
		per_level[level] = []
	for clip: String in clips:
		for level: String in TrialPlan.LEVELS:
			var lufs: float = await _measure(library.stream_for(clip), level)
			per_level[level].append(lufs)
			print("  %-40s %-7s %6.1f LUFS" % [clip.trim_prefix(CryLibrary.DEFAULT_ROOT + "/"), level, lufs])

	var means: Dictionary = {}
	var target: float = 0.0
	for level: String in TrialPlan.LEVELS:
		var values: Array = per_level[level]
		var total: float = 0.0
		for v: float in values:
			total += v
		means[level] = total / values.size()
		target += means[level] / TrialPlan.LEVELS.size()
	print("\nPer level (mean over all clips), and the trim that brings each to the average:")
	for level: String in TrialPlan.LEVELS:
		var values: Array = per_level[level]
		var current: float = TrialPlan.LEVEL_BUS_VOLUME_DB.get(level, 0.0)
		print("  %-7s %6.1f LUFS  (clips %.1f to %.1f)   volume_db now %+.1f -> suggested %+.1f"
				% [level, means[level], values.min(), values.max(), current, current + target - means[level]])
	quit(0)


## Plays `stream` from the far bank through `level`'s bus and returns its K-weighted loudness.
func _measure(stream: AudioStream, level: String) -> float:
	var emitter: AudioStreamPlayer3D = _scene.get("emitter")
	var listener: Node3D = _scene.get("listener")
	emitter.stop()
	emitter.stream = stream
	emitter.bus = TrialPlan.LEVEL_BUSES[level]
	emitter.global_position = TrialPlan.source_position(TrialPlan.LISTEN_DIRECTION, level)
	listener.rotation = Vector3.ZERO
	await create_timer(SETTLE_S).timeout
	_capture.clear_buffer()
	emitter.play()
	await create_timer(RECORD_S).timeout
	var frames: PackedVector2Array = _capture.get_buffer(_capture.get_frames_available())
	emitter.stop()
	return k_weighted_lufs(frames, AudioServer.get_mix_rate())


## ITU-R BS.1770 loudness of a stereo buffer (no gating: one short, continuous sound).
static func k_weighted_lufs(frames: PackedVector2Array, rate: float) -> float:
	if frames.is_empty():
		return -INF
	var shelf: PackedFloat64Array = _shelf_coeffs(rate)
	var high_pass: PackedFloat64Array = _high_pass_coeffs(rate)
	var energy: float = 0.0
	for channel: int in 2:
		var stage1: Array[float] = [0.0, 0.0, 0.0, 0.0]  # Array, not Packed: updated in place
		var stage2: Array[float] = [0.0, 0.0, 0.0, 0.0]
		for frame: Vector2 in frames:
			var x: float = frame.x if channel == 0 else frame.y
			var y: float = _biquad(shelf, stage1, x)
			var z: float = _biquad(high_pass, stage2, y)
			energy += z * z
	return -0.691 + 10.0 * log(energy / frames.size() + 1e-20) / log(10.0)


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
