## Headless test runner, no framework:
##     godot --headless --path game -s res://tests/run_tests.gd
## Prints one PASS/FAIL line per test and a summary; exits 1 if anything failed.
##
## Pause/replay, the full session (CSV row counts) and head-turn geometry are driven through
## the real scene's state machine with advance(), so no real time passes. What can't be
## checked headless (actual sound, panning by ear, mouse capture) is the manual check in
## EAR_TEST.md.
extends SceneTree

const TrialPlan := preload("res://scripts/trial_plan.gd")
const CryLibrary := preload("res://scripts/cry_library.gd")
const ResultsLog := preload("res://scripts/results_log.gd")
const EarTest := preload("res://scripts/ear_test.gd")
const EarTestScene := preload("res://scenes/ear_test.tscn")

const SCRATCH_DIR: String = "user://ear_test_selftest"
const SEEDS: int = 200
const PENDING_LABEL: String = "FAIL (awaiting Sonlm's build_scored_order)"

var _passed: int = 0
var _failed: int = 0
var _pending: int = 0


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	_remove_tree(SCRATCH_DIR)
	_test_combinations()
	_test_practice_order()
	_test_scored_order_counts()
	_test_scored_order_never_adjacent()
	_test_scored_order_varies_with_seed()
	_test_source_positions()
	_test_scoring_correct_answer()
	_test_scoring_half_right()
	_test_score_excludes_practice()
	_test_pass_mark()
	_test_tester_id()
	_test_clip_name_filter()
	_test_clip_discovery()
	_test_empty_levels()
	_test_results_log_writes()
	_test_results_log_write_failure()
	_test_bus_layout()
	_test_scene()
	_remove_tree(SCRATCH_DIR)

	print("")
	var summary: String = "%d passed, %d failed" % [_passed, _failed + _pending]
	if _pending > 0:
		summary += " (%d awaiting Sonlm's build_scored_order)" % _pending
	print(summary)
	quit(0 if _failed + _pending == 0 else 1)


# ------------------------------------------------------------------ helpers

func _check(test_name: String, ok: bool, detail: String = "") -> void:
	if ok:
		_passed += 1
		print("PASS  " + test_name)
	else:
		_failed += 1
		print("FAIL  %s%s" % [test_name, "" if detail.is_empty() else "  -- " + detail])


## For the one test that waits on Sonlm's implementation.
func _check_pending(test_name: String, ok: bool, detail: String) -> void:
	if ok:
		_passed += 1
		print("PASS  " + test_name)
	else:
		_pending += 1
		print("%s  %s  -- %s" % [PENDING_LABEL, test_name, detail])


func _seeded(seed_value: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _count(items: Array, wanted: Variant) -> int:
	var n: int = 0
	for item: Variant in items:
		if item == wanted:
			n += 1
	return n


func _remove_tree(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	for sub: String in DirAccess.get_directories_at(path):
		_remove_tree(path.path_join(sub))
	for file_name: String in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file_name))
	DirAccess.remove_absolute(path)


func _read_lines(path: String) -> PackedStringArray:
	var text: String = FileAccess.get_file_as_string(path)
	var lines: PackedStringArray = []
	for line: String in text.split("\n"):
		if not line.strip_edges().is_empty():
			lines.append(line)
	return lines


# ------------------------------------------------------------------ trial plan: order

func _test_combinations() -> void:
	var combos: Array = TrialPlan.all_combinations()
	var ok: bool = combos.size() == 12
	for level: String in TrialPlan.LEVELS:
		for direction: String in TrialPlan.DIRECTIONS:
			ok = ok and _count(combos, TrialPlan.make_combo(direction, level)) == 1
	_check("combinations: 4 directions x 3 levels, each once", ok)


func _test_practice_order() -> void:
	var combos: Array = TrialPlan.all_combinations()
	var each_once: bool = true
	var distinct: Dictionary = {}
	for seed_value: int in SEEDS:
		var order: Array = TrialPlan.build_practice_order(_seeded(seed_value))
		each_once = each_once and order.size() == combos.size()
		for combo: Dictionary in combos:
			each_once = each_once and _count(order, combo) == 1
		distinct[str(order)] = true
	_check("practice order: each combination exactly once (%d seeds)" % SEEDS, each_once)
	seed(12345)
	var first: Array = TrialPlan.build_practice_order(_seeded(7))
	seed(999)
	var second: Array = TrialPlan.build_practice_order(_seeded(7))
	_check("practice order: same seed -> same order (seeded RNG, not the global one)", first == second)
	_check("practice order: different seeds -> different orders", distinct.size() > SEEDS * 0.9,
			"%d distinct orders from %d seeds" % [distinct.size(), SEEDS])


func _test_scored_order_counts() -> void:
	var combos: Array = TrialPlan.all_combinations()
	var ok: bool = true
	var detail: String = ""
	for seed_value: int in SEEDS:
		var order: Array = TrialPlan.build_scored_order(combos, TrialPlan.SCORED_REPEATS, _seeded(seed_value))
		if order.size() != combos.size() * TrialPlan.SCORED_REPEATS:
			ok = false
			detail = "seed %d: %d trials" % [seed_value, order.size()]
			break
		for combo: Dictionary in combos:
			if _count(order, combo) != TrialPlan.SCORED_REPEATS:
				ok = false
				detail = "seed %d: %s appears %d times" % [seed_value, combo, _count(order, combo)]
		if not ok:
			break
	_check("scored order: each combination exactly %d times (%d seeds)" % [TrialPlan.SCORED_REPEATS, SEEDS], ok, detail)


func _test_scored_order_never_adjacent() -> void:
	var combos: Array = TrialPlan.all_combinations()
	var ok: bool = true
	var detail: String = ""
	for seed_value: int in SEEDS:
		var order: Array = TrialPlan.build_scored_order(combos, TrialPlan.SCORED_REPEATS, _seeded(seed_value))
		for i: int in range(1, order.size()):
			if order[i] == order[i - 1]:
				ok = false
				detail = "seed %d: %s at positions %d and %d" % [seed_value, order[i], i - 1, i]
				break
		if not ok:
			break
	_check("scored order: never the same combination twice in a row (%d seeds)" % SEEDS, ok, detail)


func _test_scored_order_varies_with_seed() -> void:
	var combos: Array = TrialPlan.all_combinations()
	var distinct: Dictionary = {}
	var tries: int = 20
	for seed_value: int in tries:
		var order: Array = TrialPlan.build_scored_order(combos, TrialPlan.SCORED_REPEATS, _seeded(seed_value))
		distinct[str(order)] = true
	_check_pending("scored order: different seeds -> different orders", distinct.size() >= tries - 2,
			"%d distinct orders from %d seeds" % [distinct.size(), tries])


# ------------------------------------------------------------------ trial plan: positions

func _test_source_positions() -> void:
	# Design Notes: 6 m along the direction; above y +5, below y -6;
	# inside = parapet at ear height for the rails (2 m), deck slab y -0.5 for town/far bank.
	var expected: Dictionary = {
		"above:town": Vector3(0, 5, 6), "above:far_bank": Vector3(0, 5, -6),
		"above:left_rail": Vector3(-6, 5, 0), "above:right_rail": Vector3(6, 5, 0),
		"inside:town": Vector3(0, -0.5, 6), "inside:far_bank": Vector3(0, -0.5, -6),
		"inside:left_rail": Vector3(-2, 1.6, 0), "inside:right_rail": Vector3(2, 1.6, 0),
		"below:town": Vector3(0, -6, 6), "below:far_bank": Vector3(0, -6, -6),
		"below:left_rail": Vector3(-6, -6, 0), "below:right_rail": Vector3(6, -6, 0),
	}
	var wrong: PackedStringArray = []
	for key: String in expected:
		var parts: PackedStringArray = key.split(":")
		var got: Vector3 = TrialPlan.source_position(parts[1], parts[0])
		if not got.is_equal_approx(expected[key]):
			wrong.append("%s=%s" % [key, got])
	_check("source positions match the Design Notes (12 combinations)", wrong.is_empty(), ", ".join(wrong))


# ------------------------------------------------------------------ trial plan: scoring

func _test_scoring_correct_answer() -> void:
	var truth: Dictionary = TrialPlan.make_combo("left_rail", "above")
	var result: Dictionary = TrialPlan.make_result(TrialPlan.ROUND_SCORED, 3, truth, truth, 4567, "x.wav")
	var row: PackedStringArray = TrialPlan.csv_row("ann", "headphones", result)
	var expected: PackedStringArray = ["ann", "headphones", "scored", "3", "left_rail", "above",
			"left_rail", "above", "1", "1", "1", "4567", "x.wav"]
	_check("scoring: correct answer -> direction 1, level 1, both 1 (CSV row)", row == expected, str(row))


func _test_scoring_half_right() -> void:
	var result: Dictionary = TrialPlan.make_result(TrialPlan.ROUND_SCORED, 1,
			TrialPlan.make_combo("town", "below"), TrialPlan.make_combo("town", "inside"), 5000, "y.wav")
	var row: PackedStringArray = TrialPlan.csv_row("ann", "speakers", result)
	_check("scoring: half right (below·town answered inside·town) -> 1, 0, 0",
			row[8] == "1" and row[9] == "0" and row[10] == "0", str(row))


func _test_score_excludes_practice() -> void:
	var rows: Array = []
	var combos: Array = TrialPlan.all_combinations()
	var wrong: Dictionary = TrialPlan.make_combo("town", "above")
	for combo: Dictionary in combos:  # practice: all wrong
		var answer: Dictionary = wrong if combo != wrong else TrialPlan.make_combo("far_bank", "below")
		rows.append(TrialPlan.make_result(TrialPlan.ROUND_PRACTICE, 1, combo, answer, 4000, ""))
	for combo: Dictionary in combos + combos:  # scored: all right
		rows.append(TrialPlan.make_result(TrialPlan.ROUND_SCORED, 1, combo, combo, 4000, ""))
	var summary: Dictionary = TrialPlan.score(rows)
	_check("scoring: practice rows are excluded from the score",
			summary["scored_trials"] == 24 and is_equal_approx(summary["both_pct"], 100.0) and summary["passed"],
			str(summary))


func _test_pass_mark() -> void:
	var combos: Array = TrialPlan.all_combinations()
	var scored: Array = combos + combos
	var summaries: Array = []
	for right: int in [20, 19]:
		var rows: Array = []
		for i: int in scored.size():
			var truth: Dictionary = scored[i]
			# Wrong answers keep the direction and miss the level.
			var other_level: String = "below" if truth["level"] != "below" else "above"
			var answer: Dictionary = truth if i < right else TrialPlan.make_combo(truth["direction"], other_level)
			rows.append(TrialPlan.make_result(TrialPlan.ROUND_SCORED, i + 1, truth, answer, 4000, ""))
		summaries.append(TrialPlan.score(rows))
	var s20: Dictionary = summaries[0]
	var s19: Dictionary = summaries[1]
	_check("pass mark: 20/24 both correct passes, 19/24 fails (>= 80%)",
			s20["passed"] and not s19["passed"], "%s / %s" % [s20["both_pct"], s19["both_pct"]])
	# 19 right out of combos + combos (level-major, 4 per level per pass):
	# above 8/8, inside 7/8, below 4/8.
	var per_level: Dictionary = s19["per_level_both_pct"]
	_check("scoring: direction-only %, level-only % and per-level both %",
			is_equal_approx(s19["direction_pct"], 100.0)
			and is_equal_approx(s19["level_pct"], 100.0 * 19 / 24)
			and is_equal_approx(per_level["above"], 100.0)
			and is_equal_approx(per_level["inside"], 87.5)
			and is_equal_approx(per_level["below"], 50.0),
			str(s19))


# ------------------------------------------------------------------ tester ID & clips

func _test_tester_id() -> void:
	_check("tester ID: empty or blank -> can't start",
			not ResultsLog.is_tester_id_usable("") and not ResultsLog.is_tester_id_usable("   "))
	_check("tester ID: 'ann/../x' -> 'ann____x' in the file name",
			ResultsLog.sanitize_tester_id("ann/../x") == "ann____x"
			and ResultsLog.file_name_for("ann/../x", "headphones", "20261112-101500")
				== "ann____x_headphones_20261112-101500.csv",
			ResultsLog.file_name_for("ann/../x", "headphones", "20261112-101500"))
	_check("tester ID: letters, digits, '-' and '_' kept", ResultsLog.sanitize_tester_id(" Ann-01_b ") == "Ann-01_b")


func _test_clip_name_filter() -> void:
	var names: PackedStringArray = ["b.wav", "A.WAV", "CREDITS.md", "c.ogg", "b.wav.import", "d.mp3", "sub/"]
	var split: Dictionary = CryLibrary.filter_clip_names(names)
	var clips: PackedStringArray = split["clips"]
	var skipped: PackedStringArray = split["skipped_audio"]
	_check("clip filter: only .wav kept; CREDITS.md, .import, folders ignored; .ogg/.mp3 reported",
			clips == PackedStringArray(["A.WAV", "b.wav"]) and skipped == PackedStringArray(["c.ogg", "d.mp3"]),
			"%s / %s" % [clips, skipped])


func _test_clip_discovery() -> void:
	var library: CryLibrary = CryLibrary.new()
	library.discover()
	var ok: bool = library.empty_levels().is_empty() and library.warnings.is_empty()
	var detail: String = ""
	for level: String in TrialPlan.LEVELS:
		var clips: PackedStringArray = library.clips_for(level)
		detail += "%s=%s " % [level, clips]
		ok = ok and clips.size() >= 1
		for clip: String in clips:
			ok = ok and clip.begins_with("res://audio/cries/%s/" % level) and clip.ends_with(".wav") \
					and ResourceLoader.exists(clip)
	var picked: String = library.pick("inside", _seeded(1))
	ok = ok and library.clips_for("inside").has(picked)
	_check("clip discovery: res://audio/cries/<level>/ has loadable .wav clips for every level", ok, detail)


func _test_empty_levels() -> void:
	var by_level: Dictionary = {"above": PackedStringArray(["a.wav"]), "inside": PackedStringArray()}
	_check("empty levels: empty or missing level lists are named",
			CryLibrary.find_empty_levels(by_level) == PackedStringArray(["inside", "below"]))
	# A real folder with no imported .wav (only notes) counts as empty, without crashing.
	var cries_root: String = SCRATCH_DIR.path_join("cries")
	DirAccess.make_dir_recursive_absolute(cries_root.path_join("inside"))
	var notes: FileAccess = FileAccess.open(cries_root.path_join("inside/CREDITS.md"), FileAccess.WRITE)
	notes.store_string("notes")
	notes.close()
	var library: CryLibrary = CryLibrary.new()
	library.discover(cries_root)
	_check("empty levels: discovery on folders without clips reports all three",
			library.empty_levels() == PackedStringArray(["above", "inside", "below"]),
			str(library.empty_levels()))


# ------------------------------------------------------------------ results log

func _test_results_log_writes() -> void:
	var log_file: ResultsLog = ResultsLog.new()
	var err: Error = log_file.open(SCRATCH_DIR.path_join("log"), "ann/../x", "headphones", "20261112-101500")
	var truth: Dictionary = TrialPlan.make_combo("town", "below")
	var result: Dictionary = TrialPlan.make_result(TrialPlan.ROUND_PRACTICE, 1, truth, truth, 4100, "c.wav")
	var append_err: Error = log_file.append_row(TrialPlan.csv_row("ann____x", "headphones", result))
	# Read back before close(): rows must already be on disk (flushed per row).
	var lines: PackedStringArray = _read_lines(log_file.path)
	log_file.close()
	_check("results log: user://ear_test_results-style CSV, header + row flushed immediately",
			err == OK and append_err == OK
			and log_file.path.ends_with("log/ann____x_headphones_20261112-101500.csv")
			and lines.size() == 2 and lines[0] == ",".join(TrialPlan.CSV_COLUMNS)
			and lines[1] == "ann____x,headphones,practice,1,town,below,town,below,1,1,1,4100,c.wav",
			"%s %s %s" % [error_string(err), log_file.path, lines])


func _test_results_log_write_failure() -> void:
	# A file where the folder should be: the folder can't be created.
	print("      (the engine ERROR/WARNING lines that follow are expected)")
	DirAccess.make_dir_recursive_absolute(SCRATCH_DIR)
	var blocker: String = SCRATCH_DIR.path_join("not_a_folder")
	var file: FileAccess = FileAccess.open(blocker, FileAccess.WRITE)
	file.store_string("x")
	file.close()
	var log_file: ResultsLog = ResultsLog.new()
	var err: Error = log_file.open(blocker.path_join("results"), "ann", "speakers", "20261112-101500")
	var append_err: Error = log_file.append_row(PackedStringArray(["a", "b"]))
	_check("results log: write failure returns an error, keeps the attempted path, no crash",
			err != OK and append_err != OK and log_file.has_error()
			and log_file.path.ends_with("not_a_folder/results/ann_speakers_20261112-101500.csv"),
			"%s / %s / %s" % [error_string(err), log_file.error_message, log_file.path])


# ------------------------------------------------------------------ audio buses

func _test_bus_layout() -> void:
	var problems: PackedStringArray = EarTest.apply_bus_fx()
	var ok: bool = problems.is_empty()
	for level: String in TrialPlan.LEVELS:
		var fx: Dictionary = TrialPlan.BUS_FX[level]
		var bus: int = AudioServer.get_bus_index(TrialPlan.LEVEL_BUSES[level])
		if bus < 0:
			ok = false
			continue
		ok = ok and AudioServer.get_bus_send(bus) == &"Master"
		for i: int in AudioServer.get_bus_effect_count(bus):
			var effect: AudioEffect = AudioServer.get_bus_effect(bus, i)
			if effect is AudioEffectFilter:
				ok = ok and is_equal_approx((effect as AudioEffectFilter).cutoff_hz, fx["cutoff_hz"])
			elif effect is AudioEffectReverb:
				var reverb: AudioEffectReverb = effect as AudioEffectReverb
				ok = ok and is_equal_approx(reverb.room_size, fx["room_size"]) \
						and is_equal_approx(reverb.damping, fx["damping"]) \
						and is_equal_approx(reverb.wet, fx["wet"])
	_check("audio buses: Above/Inside/Below have their filter + reverb at the Design Notes values",
			ok, ", ".join(problems))
	_check("audio: 3D panning strength is 1.0",
			is_equal_approx(ProjectSettings.get_setting("audio/general/3d_panning_strength"), 1.0))


# ------------------------------------------------------------------ the scene's state machine

func _test_scene() -> void:
	var scene: EarTest = EarTestScene.instantiate() as EarTest
	scene.results_dir = SCRATCH_DIR.path_join("session")
	scene.set_process(false)  # time only moves through advance()
	root.add_child(scene)

	_check("session: blank tester ID can't start", not scene.start_session("  ", "headphones")
			and scene.state == EarTest.State.SETUP)
	_check("session: emitter does not filter by distance",
			is_equal_approx(scene.emitter.attenuation_filter_db, TrialPlan.EMITTER_ATTENUATION_FILTER_DB))

	scene.start_session("unit/test", "headphones")
	var first: Dictionary = scene.current_combo()
	var clip: String = scene.current_clip
	scene.listener.look(Vector2(300.0, -120.0))
	scene.advance(TrialPlan.SILENCE_BEFORE_CRY_S + 0.01)
	var cry_state: bool = scene.state == EarTest.State.CRY
	scene.advance(1.5)
	var did_pause: bool = scene.pause()
	_check("pause: Esc mid-cry stops the cry",
			cry_state and did_pause and scene.state == EarTest.State.PAUSED and not scene.emitter.playing)
	scene.advance(10.0)  # time passing while paused changes nothing
	scene.resume()
	_check("pause: resume replays the same trial from its start, facing the far bank",
			scene.state == EarTest.State.SILENCE and scene.trial_index == 0
			and scene.current_combo() == first and scene.current_clip == clip
			and scene.listener.rotation.is_zero_approx() and scene.listener.camera.rotation.is_zero_approx())

	# Head-turn geometry: facing the left rail puts a left-rail cry straight ahead
	# (centre pan); facing the far bank puts it hard left.
	var left_source: Vector3 = TrialPlan.source_position("left_rail", "above")
	var cam: Camera3D = scene.listener.camera
	var at_start: Vector3 = cam.global_transform.affine_inverse() * left_source
	scene.listener.rotation.y = PI / 2.0
	var turned: Vector3 = cam.global_transform.affine_inverse() * left_source
	scene.listener.reset_facing()
	_check("listener: turning to face the left rail centres a left-rail cry",
			at_start.x < -5.0 and absf(turned.x) < 0.001 and turned.z < 0.0, "%s -> %s" % [at_start, turned])

	# Play the whole session: answer right except the second half of the scored round,
	# where only the direction is right.
	var guard: int = 0
	while scene.state != EarTest.State.RESULTS and guard < 1000:
		guard += 1
		match scene.state:
			EarTest.State.SILENCE, EarTest.State.CRY, EarTest.State.FEEDBACK:
				scene.advance(1.0)
			EarTest.State.ROUND_BREAK:
				scene.start_scored_round()
			EarTest.State.ANSWER:
				var truth: Dictionary = scene.current_combo()
				var level: String = truth["level"]
				if scene.round_name == TrialPlan.ROUND_SCORED and scene.trial_index >= 12:
					level = "inside" if level != "inside" else "above"
				scene.answer(truth["direction"], level)
	var lines: PackedStringArray = _read_lines(scene.results_log.path)
	var practice_rows: int = 0
	var scored_rows: int = 0
	var csv_both: int = 0
	for line: String in lines.slice(1):
		var cells: PackedStringArray = line.split(",")
		if cells[2] == TrialPlan.ROUND_PRACTICE:
			practice_rows += 1
		elif cells[2] == TrialPlan.ROUND_SCORED:
			scored_rows += 1
			csv_both += int(cells[10])
	var summary: Dictionary = TrialPlan.score(scene.results)
	_check("session: CSV has 12 practice + 24 scored rows",
			scene.state == EarTest.State.RESULTS and practice_rows == 12 and scored_rows == 24
			and lines.size() == 37 and not scene.results_log.has_error(),
			"%d practice, %d scored, %d lines" % [practice_rows, scored_rows, lines.size()])
	_check("session: results match the CSV (12 / 24 both correct -> FAIL)",
			summary["both_correct"] == csv_both and csv_both == 12 and not summary["passed"]
			and lines[1].begins_with("unit_test,headphones,practice,1,"),
			"summary %d vs csv %d" % [summary["both_correct"], csv_both])

	scene.new_session()
	_check("session: New session returns to setup", scene.state == EarTest.State.SETUP)
	scene.free()
