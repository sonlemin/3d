## Headless test runner, no framework:
##     godot --headless --path game -s res://tests/run_tests.gd
## Prints one PASS/FAIL line per test and a summary; exits 1 if anything failed.
##
## A Logger (LogCounter) sees every engine error, script error and warning during the run.
## Any that a test didn't ask for fails the suite. A test that triggers some on purpose wraps
## that call in _expect_begin() / _expect_end(..., [[kind, text, count], ...]): exactly those
## entries may appear in the window, each the stated number of times; anything else logged
## there fails too. The engine still prints the expected lines.
##
## The real scene's state machine is driven with advance() and a fake clock, so no real time
## passes. What can't be checked headless (actual sound, panning by ear, mouse capture) is the
## manual check in EAR_TEST.md.
extends SceneTree

const TrialPlan := preload("res://scripts/trial_plan.gd")
const CryLibrary := preload("res://scripts/cry_library.gd")
const ResultsLog := preload("res://scripts/results_log.gd")
const EarTest := preload("res://scripts/ear_test.gd")
const EarTestScene := preload("res://scenes/ear_test.tscn")

const SCRATCH_DIR: String = "user://ear_test_selftest"
const SEEDS: int = 200
const TIMESTAMP: String = "20261112-101500"
const FOCUS_OUT: int = Node.NOTIFICATION_APPLICATION_FOCUS_OUT
## Design Notes bus FX, written out literally (not read from TrialPlan.BUS_FX). Every level
## bus also plays unmuted, unbypassed, not solo, into the Shadow bus, at its loudness-matching
## volume_db.
const DESIGN_NOTES_BUS_FX: Dictionary = {
	&"Above": {"filter": "AudioEffectHighPassFilter", "cutoff_hz": 1000.0, "volume_db": 1.3,
		"room_size": 0.25, "damping": 0.5, "wet": 0.06, "dry": 1.0, "predelay_msec": 10.0},
	&"Inside": {"filter": "AudioEffectLowPassFilter", "cutoff_hz": 650.0, "volume_db": 4.8,
		"room_size": 0.08, "damping": 0.95, "wet": 0.45, "dry": 1.0, "predelay_msec": 3.0},
	&"Below": {"filter": "AudioEffectLowPassFilter", "cutoff_hz": 2500.0, "volume_db": -9.3,
		"room_size": 1.0, "damping": 0.15, "wet": 0.7, "dry": 0.6, "predelay_msec": 120.0},
}


## Sees what the engine logs. Called from whichever thread logs, hence the mutex.
class LogCounter extends Logger:
	const KINDS: PackedStringArray = ["ERROR", "WARNING", "SCRIPT ERROR", "SHADER ERROR"]
	var _mutex: Mutex = Mutex.new()
	var _in_window: bool = false
	var _window: Array = []  # [kind, message, where] logged inside the current window
	var _unexpected: PackedStringArray = []

	func _log_error(function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		var kind: String = KINDS[clampi(error_type, 0, KINDS.size() - 1)]
		var what: String = rationale if not rationale.is_empty() else code
		var where: String = "%s:%d %s" % [file, line, function]
		_mutex.lock()
		if _in_window:
			_window.append([kind, what, where])
		else:
			_unexpected.append("%s: %s (%s)" % [kind, what, where])
		_mutex.unlock()

	func _log_message(_message: String, _error: bool) -> void:
		pass

	func begin_window() -> void:
		_mutex.lock()
		_in_window = true
		_window = []
		_mutex.unlock()

	## The entries logged since begin_window().
	func end_window() -> Array:
		_mutex.lock()
		_in_window = false
		var entries: Array = _window
		_window = []
		_mutex.unlock()
		return entries

	func add_unexpected(text: String) -> void:
		_mutex.lock()
		_unexpected.append(text)
		_mutex.unlock()

	func unexpected() -> PackedStringArray:
		_mutex.lock()
		var copy: PackedStringArray = _unexpected.duplicate()
		_mutex.unlock()
		return copy


var _passed: int = 0
var _failed: int = 0
var _logger: LogCounter = LogCounter.new()
var _expected_total: int = 0
## The scenes' clock (TrialPlan response times); moved by _step() and by hand.
var _fake_ms: int = 100000


func _initialize() -> void:
	OS.add_logger(_logger)
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
	_test_cry_fade()
	_test_tester_id()
	_test_tester_id_unicode_spaces()
	_test_tester_id_file_name_chars()
	_test_clip_name_filter()
	_test_clip_discovery()
	_test_pick_any()
	_test_clip_discovery_problems()
	_test_empty_levels()
	_test_results_log_writes()
	_test_results_log_never_overwrites()
	_test_results_log_write_failure()
	_test_bus_layout()
	_test_bus_layout_file_matches_bus_fx()
	_test_bus_fx_problems()
	_test_bus_fx_forces_buses()
	_test_rear_amount()
	_test_loudness_meter()
	_test_shadow_bus()
	_test_shadow_bus_problems()
	_test_scene_bus_problem_from_ready()
	_test_scene_setup_gates()
	_test_scene_audio_setup()
	_test_scene_inside_rail_pylons()
	_test_scene_listener_geometry()
	_test_scene_rear_shadow()
	_test_scene_listen()
	_test_scene_trial_flow()
	_test_scene_feedback()
	_test_scene_replay()
	_test_scene_pauses()
	_test_scene_scored_pauses()
	_test_scene_close_during_feedback()
	_test_scene_full_session()
	_test_scene_write_failure()
	_test_scene_missing_stream_aborts()
	_test_scene_practice_zero()
	_test_scene_open_folder_error()
	_remove_tree(SCRATCH_DIR)

	var unexpected: PackedStringArray = _logger.unexpected()
	_check("logger: no unexpected engine/script errors or warnings during the run",
			unexpected.is_empty(), " | ".join(unexpected))
	OS.remove_logger(_logger)
	print("")
	print("%d passed, %d failed. Logger: %d unexpected errors/warnings, %d expected (triggered on purpose)."
			% [_passed, _failed, unexpected.size(), _expected_total])
	quit(0 if _failed == 0 else 1)


# ------------------------------------------------------------------ helpers

func _check(test_name: String, ok: bool, detail: String = "") -> void:
	if ok:
		_passed += 1
		print("PASS  " + test_name)
	else:
		_failed += 1
		print("FAIL  %s%s" % [test_name, "" if detail.is_empty() else "  -- " + detail])


## Starts a window for log entries a test triggers on purpose; see _expect_end().
func _expect_begin() -> void:
	_logger.begin_window()


## Ends the window. `expected` lists [kind, text, count]: exactly `count` entries of that kind
## ("ERROR", "WARNING", "SCRIPT ERROR") whose message contains `text`. Any other entry in the
## window is unexpected (it also fails the final logger check).
func _expect_end(test_name: String, expected: Array) -> void:
	var entries: Array = _logger.end_window()
	var problems: PackedStringArray = []
	for want: Array in expected:
		var hits: int = 0
		for i: int in range(entries.size() - 1, -1, -1):
			var entry: Array = entries[i]
			if entry[0] == want[0] and String(entry[1]).contains(want[1]):
				hits += 1
				entries.remove_at(i)
		_expected_total += hits
		if hits != want[2]:
			problems.append("%d x %s '%s', expected %d" % [hits, want[0], want[1], want[2]])
	for entry: Array in entries:
		var text: String = "%s: %s (%s)" % [entry[0], entry[1], entry[2]]
		problems.append("unexpected " + text)
		_logger.add_unexpected(text)
	_check(test_name + ": logged exactly the expected errors/warnings", problems.is_empty(), " | ".join(problems))


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


## The CSV's data rows as {column: value} dictionaries (quoted cells unquoted).
func _read_csv(path: String) -> Array:
	var rows: Array = []
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return rows
	var header: PackedStringArray = file.get_csv_line()
	while not file.eof_reached():
		var cells: PackedStringArray = file.get_csv_line()
		if cells.size() != header.size():
			continue
		var row: Dictionary = {}
		for i: int in header.size():
			row[header[i]] = cells[i]
		rows.append(row)
	return rows


func _fake_now() -> int:
	return _fake_ms


func _new_scene(results_subdir: String) -> EarTest:
	var scene: EarTest = EarTestScene.instantiate() as EarTest
	scene.results_dir = SCRATCH_DIR.path_join(results_subdir)
	scene.clock = _fake_now
	root.add_child(scene)
	scene.set_process(false)  # after add_child (entering the tree re-enables it): time only moves via _step()
	return scene


## Starts a session and leaves the listen screen for practice, as a tester would.
func _start(scene: EarTest, raw_id: String, mode: String) -> bool:
	return scene.start_session(raw_id, mode) and scene.start_practice()


## Moves the fake clock and the scene's state machine by the same amount.
func _step(scene: EarTest, seconds: float) -> void:
	_fake_ms += roundi(seconds * 1000.0)
	scene.advance(seconds)


func _other_level(level: String) -> String:
	return "inside" if level != "inside" else "above"


func _other_direction(direction: String) -> String:
	return "town" if direction != "town" else "far_bank"


func _pause_resume(scene: EarTest, paused_ms: int) -> void:
	scene.notification(FOCUS_OUT)
	_fake_ms += paused_ms
	scene.resume()


## Plays the session to the results screen. Practice answers are right; scored answers cycle
## right / wrong level / wrong direction / both wrong. With `pause_scored`, every scored trial
## is paused once at the answer grid for 3 s before it is answered.
func _play_to_results(scene: EarTest, pause_scored: bool = false) -> void:
	var guard: int = 0
	while scene.state != EarTest.State.RESULTS and guard < 1000:
		guard += 1
		match scene.state:
			EarTest.State.SILENCE, EarTest.State.CRY, EarTest.State.FEEDBACK:
				_step(scene, 1.0)
			EarTest.State.ROUND_BREAK:
				scene.start_scored_round()
			EarTest.State.ANSWER:
				var scored: bool = scene.round_name == TrialPlan.ROUND_SCORED
				if pause_scored and scored and scene.trial_pauses == 0:
					_pause_resume(scene, 3000)  # back at the grid; answered on the next pass
				else:
					var truth: Dictionary = scene.current_combo()
					var direction: String = truth["direction"]
					var level: String = truth["level"]
					if scored:
						var k: int = scene.trial_index % 4
						if k == 1 or k == 3:
							level = _other_level(level)
						if k == 2 or k == 3:
							direction = _other_direction(direction)
					scene.answer(direction, level)
			_:
				break


## Plays the practice round (right answers) up to the round break.
func _play_practice(scene: EarTest) -> void:
	var guard: int = 0
	while scene.state != EarTest.State.ROUND_BREAK and guard < 500:
		guard += 1
		if scene.state == EarTest.State.ANSWER:
			var truth: Dictionary = scene.current_combo()
			scene.answer(truth["direction"], truth["level"])
		else:
			_step(scene, 1.0)


## Plays one trial to the answer grid from its start (silence).
func _to_grid(scene: EarTest) -> void:
	_step(scene, TrialPlan.SILENCE_BEFORE_CRY_S)
	_step(scene, TrialPlan.CRY_WINDOW_S)


func _first_float(pattern: String, text: String, group: int = 1) -> float:
	var regex: RegEx = RegEx.create_from_string(pattern)
	var found: RegExMatch = regex.search(text)
	return -1.0 if found == null else found.get_string(group).to_float()


func _setup_ready(scene: EarTest, tester: String) -> void:
	scene._id_edit.text = tester
	scene._mode_buttons[0].button_pressed = true
	scene.refresh_setup()


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
	_check("practice order: 0 repeats -> empty order", TrialPlan.build_practice_order(_seeded(1), 0).is_empty())


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
	_check("scored order: different seeds -> different orders", distinct.size() >= tries - 2,
			"%d distinct orders from %d seeds" % [distinct.size(), tries])


# ------------------------------------------------------------------ trial plan: positions

func _test_source_positions() -> void:
	# Design Notes: 6 m along the direction; above y +5, below y -6; inside = ear height in
	# the parapet pylons for the rails (x +-1.85), deck slab y -0.5 for town/far bank.
	var expected: Dictionary = {
		"above:town": Vector3(0, 5, 6), "above:far_bank": Vector3(0, 5, -6),
		"above:left_rail": Vector3(-6, 5, 0), "above:right_rail": Vector3(6, 5, 0),
		"inside:town": Vector3(0, -0.5, 6), "inside:far_bank": Vector3(0, -0.5, -6),
		"inside:left_rail": Vector3(-1.85, 1.6, 0), "inside:right_rail": Vector3(1.85, 1.6, 0),
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
	var result: Dictionary = TrialPlan.make_result(TrialPlan.ROUND_SCORED, 3, truth, truth, 4567, 2, "x.wav")
	var row: PackedStringArray = TrialPlan.csv_row("ann", "headphones", result)
	var expected: PackedStringArray = ["ann", "headphones", "scored", "3", "left_rail", "above",
			"left_rail", "above", "1", "1", "1", "4567", "2", "0", "", "x.wav"]
	_check("scoring: correct answer -> direction 1, level 1, both 1; pauses after response_ms (CSV row)",
			row == expected and TrialPlan.CSV_COLUMNS[12] == "pauses", str(row))


func _test_scoring_half_right() -> void:
	var result: Dictionary = TrialPlan.make_result(TrialPlan.ROUND_SCORED, 1,
			TrialPlan.make_combo("town", "below"), TrialPlan.make_combo("town", "inside"), 5000, 0, "y.wav")
	var row: PackedStringArray = TrialPlan.csv_row("ann", "speakers", result)
	_check("scoring: half right (below·town answered inside·town) -> 1, 0, 0",
			row[8] == "1" and row[9] == "0" and row[10] == "0", str(row))


func _test_score_excludes_practice() -> void:
	var rows: Array = []
	var combos: Array = TrialPlan.all_combinations()
	var wrong: Dictionary = TrialPlan.make_combo("town", "above")
	for combo: Dictionary in combos:  # practice: all wrong
		var answer: Dictionary = wrong if combo != wrong else TrialPlan.make_combo("far_bank", "below")
		rows.append(TrialPlan.make_result(TrialPlan.ROUND_PRACTICE, 1, combo, answer, 4000, 0, ""))
	for combo: Dictionary in combos + combos:  # scored: all right
		rows.append(TrialPlan.make_result(TrialPlan.ROUND_SCORED, 1, combo, combo, 4000, 0, ""))
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
			rows.append(TrialPlan.make_result(TrialPlan.ROUND_SCORED, i + 1, truth, answer, 4000, 0, ""))
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


func _test_cry_fade() -> void:
	var window: float = TrialPlan.CRY_WINDOW_S
	var fade: float = TrialPlan.CRY_FADE_OUT_S
	var full: float = TrialPlan.EMITTER_VOLUME_DB
	var ok: bool = is_equal_approx(fade, 0.05) \
			and is_equal_approx(TrialPlan.cry_volume_db(0.0), full) \
			and is_equal_approx(TrialPlan.cry_volume_db(window - fade - 0.001), full) \
			and TrialPlan.cry_volume_db(window - fade * 0.5) < full - 5.0 \
			and TrialPlan.cry_volume_db(window - fade * 0.25) < TrialPlan.cry_volume_db(window - fade * 0.5) \
			and TrialPlan.cry_volume_db(window) <= full - 79.0
	_check("cry fade: full volume until the last 50 ms of the window, then down to silence", ok,
			"%s / %s / %s" % [TrialPlan.cry_volume_db(window - fade * 0.5),
				TrialPlan.cry_volume_db(window - fade * 0.25), TrialPlan.cry_volume_db(window)])


# ------------------------------------------------------------------ tester ID

func _test_tester_id() -> void:
	_check("tester ID: empty or blank -> can't start",
			not ResultsLog.is_tester_id_usable("") and not ResultsLog.is_tester_id_usable("   ")
			and not ResultsLog.is_tester_id_usable(" \t "))
	_check("tester ID: spaces at the ends trimmed; the CSV ID is otherwise exactly as typed",
			ResultsLog.clean_tester_id("  Sơn / A.1  ") == "Sơn / A.1")
	_check("tester ID: 'ann/../x' -> 'ann____x' in the file name (no separators, no dots)",
			ResultsLog.sanitize_tester_id("ann/../x") == "ann____x"
			and ResultsLog.file_name_for("ann/../x", "headphones", TIMESTAMP)
				== "ann____x_headphones_%s.csv" % TIMESTAMP,
			ResultsLog.file_name_for("ann/../x", "headphones", TIMESTAMP))
	_check("tester ID: Latin letters, digits, '-' and '_' kept; ends trimmed",
			ResultsLog.sanitize_tester_id(" Ann-01_b ") == "Ann-01_b"
			and ResultsLog.sanitize_tester_id("0123456789") == "0123456789")


func _test_tester_id_unicode_spaces() -> void:
	var trims: Dictionary = {
		" Sơn": "Sơn", "　Sơn　": "Sơn", "​Sơn​": "Sơn",
		"﻿ t01  ": "t01", "    Đức  ": "Đức",
		"Sơn A": "Sơn A",  # inside the ID: kept as typed
	}
	var wrong: PackedStringArray = []
	for raw: String in trims:
		if ResultsLog.clean_tester_id(raw) != trims[raw]:
			wrong.append("%s -> [%s]" % [raw.c_escape(), ResultsLog.clean_tester_id(raw).c_escape()])
	_check("tester ID: Unicode spaces at the ends are trimmed too (NBSP, U+3000, U+200B, BOM, ...)",
			wrong.is_empty() and ResultsLog.sanitize_tester_id("Sơn A") == "Sơn_A", ", ".join(wrong))
	var blanks: Array = [" ", "　　", "​", "   ﻿ "]
	var usable: int = 0
	for raw: String in blanks:
		if ResultsLog.is_tester_id_usable(raw):
			usable += 1
	_check("tester ID: an ID made only of Unicode spaces counts as empty", usable == 0)


func _test_tester_id_file_name_chars() -> void:
	var kept: Dictionary = {
		"Sơn": "Sơn", "Đức": "Đức", "Sân": "Sân", "Nguyễn Văn Ánh": "Nguyễn_Văn_Ánh",
		"Sơn": "Sơn",  # decomposed: o + combining horn
		"山田": "山田", "สมศักดิ์": "สมศักดิ์", "प्रिया": "प्रिया", "t٣٤": "t٣٤",
	}
	var wrong: PackedStringArray = []
	for raw: String in kept:
		if ResultsLog.sanitize_tester_id(raw) != kept[raw]:
			wrong.append("%s -> %s" % [raw, ResultsLog.sanitize_tester_id(raw)])
	_check("tester ID: letters of any script, their marks and digits stay in the file name",
			wrong.is_empty() and ResultsLog.sanitize_tester_id("Sơn") != ResultsLog.sanitize_tester_id("Sân"),
			", ".join(wrong))
	# Dots, connectors and joiners that Unicode counts as identifier characters still become '_'.
	var replaced: PackedStringArray = []
	for code: int in [0x00B7, 0x0387, 0x30FB, 0xFF65, 0x203F, 0xFF3F, 0x200D, 0x200C, 0x2040,
			0x2054, 0xFE33, 0xFE4D, 0x1369, 0x19DA]:
		var got: String = ResultsLog.sanitize_tester_id("a" + String.chr(code) + "b")
		if got != "a_b":
			replaced.append("U+%04X -> %s" % [code, got])
	var punctuation: String = ResultsLog.sanitize_tester_id("a.b c:d\\e*f?g\"h<i>j|k/l,m")
	_check("tester ID: punctuation, spaces, '/', '\\', '.', and · · ・ ･ ‿ ＿ ZWJ ZWNJ become '_'",
			replaced.is_empty() and punctuation == "a_b_c_d_e_f_g_h_i_j_k_l_m"
			and ResultsLog.sanitize_tester_id("..") == "__",
			", ".join(replaced) + " / " + punctuation)


# ------------------------------------------------------------------ clips

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
	var ok: bool = library.empty_levels().is_empty() and library.warnings.is_empty() \
			and library.problems.is_empty() and library.check_raw_files
	var detail: String = ""
	for level: String in TrialPlan.LEVELS:
		var clips: PackedStringArray = library.clips_for(level)
		detail += "%s=%s " % [level, clips]
		ok = ok and clips.size() >= 1
		for clip: String in clips:
			ok = ok and clip.begins_with("res://audio/cries/%s/" % level) and clip.ends_with(".wav") \
					and load(clip) is AudioStream and library.stream_for(clip) != null
	var picked: String = library.pick("inside", _seeded(1))
	ok = ok and library.clips_for("inside").has(picked)
	_check("clip discovery: res://audio/cries/<level>/ has loadable .wav clips for every level, no problems",
			ok, detail + str(library.problems))


## Mixed cries: pick_any draws from every cry folder, about equally often.
func _test_pick_any() -> void:
	var library: CryLibrary = CryLibrary.new()
	library.discover()
	var rng: RandomNumberGenerator = _seeded(7)
	var counts: Dictionary = {}
	var all_known: bool = true
	for _i: int in 600:
		var clip: String = library.pick_any(rng)
		var kind: String = CryLibrary.kind_of(clip)
		all_known = all_known and library.clips_for(kind).has(clip)
		counts[kind] = counts.get(kind, 0) + 1
	var balanced: bool = counts.size() == 3
	for kind: String in counts:
		balanced = balanced and counts[kind] > 150  # 200 expected each
	_check("mixed cries: pick_any draws every kind of cry about equally (MIX_CRY_KINDS on)",
			TrialPlan.MIX_CRY_KINDS and all_known and balanced
			and CryLibrary.kind_of("res://audio/cries/below/x.wav") == "below", str(counts))


## Fake listings, raw files and loader: not imported, unloadable, skipped audio, mixed placeholders.
func _test_clip_discovery_problems() -> void:
	var listings: Dictionary = {
		"above": PackedStringArray(["placeholder_above_1.wav", "shriek.wav", "x.ogg", "CREDITS.md"]),
		"inside": PackedStringArray(["placeholder_inside_1.wav", "placeholder_inside_2.wav"]),
		"below": PackedStringArray(["broken.wav", "whisper.wav"]),
	}
	var raw_files: Dictionary = {
		"above": PackedStringArray(["placeholder_above_1.wav", "placeholder_above_1.wav.import", "shriek.wav",
				"shriek.wav.import", "new_cry.wav", "x.ogg", "x.ogg.import", "CREDITS.md"]),
		"inside": PackedStringArray(["placeholder_inside_1.wav", "placeholder_inside_1.wav.import",
				"placeholder_inside_2.wav", "placeholder_inside_2.wav.import", "real_sob.WAV"]),
		"below": PackedStringArray(["broken.wav", "broken.wav.import", "whisper.wav", "whisper.wav.import"]),
	}
	var library: CryLibrary = CryLibrary.new()
	library.list_folder = func(folder: String) -> PackedStringArray:
		return listings.get(folder.trim_suffix("/").get_file(), PackedStringArray())
	library.list_raw_files = func(folder: String) -> PackedStringArray:
		return raw_files.get(folder.trim_suffix("/").get_file(), PackedStringArray())
	library.load_clip = func(path: String) -> Resource:
		return null if path.ends_with("broken.wav") else AudioStreamWAV.new()
	_expect_begin()
	library.discover()
	_expect_end("clip discovery problems", [
		["WARNING", "not imported yet: new_cry.wav in res://audio/cries/above/", 1],
		["WARNING", "not imported yet: real_sob.WAV in res://audio/cries/inside/", 1],
		["WARNING", "could not load broken.wav in res://audio/cries/below/", 1],
		["WARNING", "skipped res://audio/cries/above/x.ogg", 1],
		["WARNING", "placeholders mixed with real clips in res://audio/cries/above/", 1],
		["WARNING", "placeholders mixed with real clips in res://audio/cries/inside/", 1],
	])
	var problems: String = "\n".join(library.problems)
	var warnings: String = "\n".join(library.warnings)
	_check("clip discovery: a raw .wav that isn't imported is a problem telling to run the import",
			problems.contains("new_cry.wav") and problems.contains("real_sob.WAV")
			and problems.contains(CryLibrary.IMPORT_COMMAND)
			and not library.clips_for("above").has("res://audio/cries/above/new_cry.wav"), problems)
	_check("clip discovery: a .wav that doesn't load is left out and is a problem",
			library.clips_for("below") == PackedStringArray(["res://audio/cries/below/whisper.wav"])
			and problems.contains("broken.wav")
			and library.stream_for("res://audio/cries/below/broken.wav") == null
			and library.problems.size() == 3, problems)
	_check("clip discovery: skipped non-WAV audio and mixed placeholders (raw files counted) are warnings",
			library.warnings.size() == 3 and warnings.contains("skipped res://audio/cries/above/x.ogg")
			and warnings.contains("mixed with real clips in res://audio/cries/inside/")
			and not warnings.contains("CREDITS"), warnings)

	# A fresh clone that was never imported: the clips are listed but none loads.
	library.list_folder = ResourceLoader.list_directory
	library.list_raw_files = Callable()
	library.load_clip = func(_path: String) -> Resource: return null
	_expect_begin()
	library.discover()
	_expect_end("never imported", [["WARNING", "could not load placeholder_", 3]])
	_check("clip discovery: nothing loads (never imported) -> every level empty, problems say to import",
			library.empty_levels() == PackedStringArray(["above", "inside", "below"])
			and library.problems.size() == 3 and "\n".join(library.problems).contains(CryLibrary.IMPORT_COMMAND),
			"\n".join(library.problems))


func _test_empty_levels() -> void:
	var by_level: Dictionary = {"above": PackedStringArray(["a.wav"]), "inside": PackedStringArray()}
	_check("empty levels: empty or missing level lists are named",
			CryLibrary.find_empty_levels(by_level) == PackedStringArray(["inside", "below"]))
	# A real folder with no .wav (only notes) counts as empty, without crashing; folders that
	# don't exist at all are fine too.
	var cries_root: String = SCRATCH_DIR.path_join("cries")
	DirAccess.make_dir_recursive_absolute(cries_root.path_join("inside"))
	var notes: FileAccess = FileAccess.open(cries_root.path_join("inside/CREDITS.md"), FileAccess.WRITE)
	notes.store_string("notes")
	notes.close()
	var library: CryLibrary = CryLibrary.new()
	library.discover(cries_root)
	_check("empty levels: discovery on folders without clips reports all three",
			library.empty_levels() == PackedStringArray(["above", "inside", "below"]) and library.problems.is_empty(),
			str(library.empty_levels()))


# ------------------------------------------------------------------ results log

func _test_results_log_writes() -> void:
	var log_file: ResultsLog = ResultsLog.new()
	var err: Error = log_file.open(SCRATCH_DIR.path_join("log"), "ann/../x", "headphones", TIMESTAMP)
	var truth: Dictionary = TrialPlan.make_combo("town", "below")
	var result: Dictionary = TrialPlan.make_result(TrialPlan.ROUND_PRACTICE, 1, truth, truth, 4100, 1, "c.wav")
	var append_err: Error = log_file.append_row(TrialPlan.csv_row("ann/../x", "headphones", result))
	# Read back before close(): rows must already be on disk (flushed per row).
	var lines: PackedStringArray = _read_lines(log_file.path)
	log_file.close()
	_check("results log: header + row flushed immediately; file name sanitized, CSV keeps the ID",
			err == OK and append_err == OK
			and log_file.path.ends_with("log/ann____x_headphones_%s.csv" % TIMESTAMP)
			and lines.size() == 2 and lines[0] == ",".join(TrialPlan.CSV_COLUMNS)
			and lines[1] == "ann/../x,headphones,practice,1,town,below,town,below,1,1,1,4100,1,0,,c.wav",
			"%s %s %s" % [error_string(err), log_file.path, lines])


func _test_results_log_never_overwrites() -> void:
	var dir: String = SCRATCH_DIR.path_join("collide")
	var paths: PackedStringArray = []
	for i: int in 3:
		var log_file: ResultsLog = ResultsLog.new()
		log_file.open(dir, "ann", "speakers", TIMESTAMP)
		log_file.append_row(PackedStringArray(["row", str(i)]))
		log_file.close()
		paths.append(log_file.path.get_file())
	var base: String = "ann_speakers_%s" % TIMESTAMP
	_check("results log: an existing file is never overwritten (_2, _3 before .csv)",
			paths == PackedStringArray([base + ".csv", base + "_2.csv", base + "_3.csv"])
			and _read_lines(dir.path_join(base + ".csv"))[1] == "row,0",
			str(paths))


func _test_results_log_write_failure() -> void:
	# A file where the folder should be: the folder can't be created.
	DirAccess.make_dir_recursive_absolute(SCRATCH_DIR)
	var blocker: String = SCRATCH_DIR.path_join("not_a_folder")
	var file: FileAccess = FileAccess.open(blocker, FileAccess.WRITE)
	file.store_string("x")
	file.close()
	var log_file: ResultsLog = ResultsLog.new()
	_expect_begin()
	var err: Error = log_file.open(blocker.path_join("results"), "ann", "speakers", TIMESTAMP)
	var append_err: Error = log_file.append_row(PackedStringArray(["a", "b"]))
	_expect_end("results log write failure", [
		["ERROR", "Could not create directory", 1],
		["WARNING", "could not create the results folder", 1],
	])
	_check("results log: write failure returns an error, keeps the attempted path, no crash",
			err != OK and append_err != OK and log_file.has_error()
			and log_file.path.ends_with("not_a_folder/results/ann_speakers_%s.csv" % TIMESTAMP),
			"%s / %s / %s" % [error_string(err), log_file.error_message, log_file.path])


# ------------------------------------------------------------------ audio buses

## Problems with one bus's effects against one expected entry; empty when they match.
## `enabled[i]` is whether effect i is on.
func _bus_mismatches(bus_label: String, effects: Array, enabled: Array, want: Dictionary) -> PackedStringArray:
	var problems: PackedStringArray = []
	var filters: int = 0
	var reverbs: int = 0
	for i: int in effects.size():
		var effect: AudioEffect = effects[i]
		if not enabled[i]:
			problems.append("%s: effect %d (%s) is disabled" % [bus_label, i, effect.get_class()])
		if effect is AudioEffectFilter:
			filters += 1
			if effect.get_class() != want["filter"] \
					or not is_equal_approx((effect as AudioEffectFilter).cutoff_hz, want["cutoff_hz"]):
				problems.append("%s: %s at %s Hz" % [bus_label, effect.get_class(), (effect as AudioEffectFilter).cutoff_hz])
		elif effect is AudioEffectReverb:
			reverbs += 1
			var reverb: AudioEffectReverb = effect as AudioEffectReverb
			for key: String in TrialPlan.REVERB_KEYS:
				if not want.has(key) or not is_equal_approx(reverb.get(key), want[key]):
					problems.append("%s: reverb %s is %s, want %s" % [bus_label, key, reverb.get(key), want.get(key)])
		else:
			problems.append("%s: extra effect %s" % [bus_label, effect.get_class()])
	if filters != 1 or reverbs != 1:
		problems.append("%s: %d filters, %d reverbs" % [bus_label, filters, reverbs])
	return problems


func _test_bus_layout() -> void:
	var problems: PackedStringArray = EarTest.apply_bus_fx()
	for bus_name: StringName in DESIGN_NOTES_BUS_FX:
		var bus: int = AudioServer.get_bus_index(bus_name)
		if bus < 0:
			problems.append("%s missing" % bus_name)
			continue
		if AudioServer.get_bus_send(bus) != &"Shadow" or AudioServer.is_bus_mute(bus) \
				or AudioServer.is_bus_bypassing_effects(bus) or AudioServer.is_bus_solo(bus) \
				or not is_equal_approx(AudioServer.get_bus_volume_db(bus), DESIGN_NOTES_BUS_FX[bus_name]["volume_db"]):
			problems.append("%s: send/mute/bypass/solo/volume wrong" % bus_name)
		var effects: Array = []
		var enabled: Array = []
		for i: int in AudioServer.get_bus_effect_count(bus):
			effects.append(AudioServer.get_bus_effect(bus, i))
			enabled.append(AudioServer.is_bus_effect_enabled(bus, i))
		problems.append_array(_bus_mismatches(bus_name, effects, enabled, DESIGN_NOTES_BUS_FX[bus_name]))
	_check("audio buses: Above/Inside/Below have their filter + reverb, on, at the Design Notes values (literal table)",
			problems.is_empty(), ", ".join(problems))
	_check("audio: 3D panning strength is 1.0",
			is_equal_approx(ProjectSettings.get_setting("audio/general/3d_panning_strength"), 1.0))


## default_bus_layout.tres must not drift from TrialPlan.BUS_FX (which overwrites it at startup).
func _test_bus_layout_file_matches_bus_fx() -> void:
	# CACHE_MODE_IGNORE_DEEP: fresh effects read from disk, not the live (overwritten) ones.
	var layout: Resource = ResourceLoader.load("res://default_bus_layout.tres", "", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
	var problems: PackedStringArray = []
	var filter_classes: Dictionary = {"high_pass": "AudioEffectHighPassFilter", "low_pass": "AudioEffectLowPassFilter"}
	for level: String in TrialPlan.LEVELS:
		var bus_name: StringName = TrialPlan.LEVEL_BUSES[level]
		var fx: Dictionary = TrialPlan.BUS_FX[level]
		var want: Dictionary = fx.duplicate()
		want["filter"] = filter_classes.get(fx["filter"], "?")
		var found: bool = false
		for i: int in 16:
			if layout.get("bus/%d/name" % i) != bus_name:
				continue
			found = true
			var key: String = "bus/%d/" % i
			if layout.get(key + "mute") != false or layout.get(key + "bypass_fx") != false \
					or layout.get(key + "solo") != false or layout.get(key + "send") != &"Shadow" \
					or not is_equal_approx(layout.get(key + "volume_db"), TrialPlan.LEVEL_BUS_VOLUME_DB[level]):
				problems.append("tres %s: mute/bypass/solo/send/volume differ from the rule" % bus_name)
			var effects: Array = []
			var enabled: Array = []
			var j: int = 0
			while layout.get(key + "effect/%d/effect" % j) != null:
				effects.append(layout.get(key + "effect/%d/effect" % j))
				enabled.append(layout.get(key + "effect/%d/enabled" % j) == true)
				j += 1
			problems.append_array(_bus_mismatches("tres " + bus_name, effects, enabled, want))
		if not found:
			problems.append("tres has no bus %s" % bus_name)
	_check("audio buses: default_bus_layout.tres matches TrialPlan.BUS_FX (no drift, effects enabled)",
			layout != null and problems.is_empty(), ", ".join(problems))


func _test_bus_fx_problems() -> void:
	var bad_filter: Dictionary = TrialPlan.BUS_FX.duplicate(true)
	bad_filter["inside"]["filter"] = "band_pass"
	var filter_problems: PackedStringArray = EarTest.apply_bus_fx(bad_filter)
	var bad_buses: Dictionary = TrialPlan.LEVEL_BUSES.duplicate()
	bad_buses["below"] = &"NoSuchBus"
	var bus_problems: PackedStringArray = EarTest.apply_bus_fx(TrialPlan.BUS_FX, bad_buses)
	var restored: PackedStringArray = EarTest.apply_bus_fx()
	_check("audio buses: an unknown filter type and a missing bus are reported as problems",
			filter_problems.size() == 1 and filter_problems[0].contains("unknown filter type 'band_pass'")
			and bus_problems.size() == 1 and bus_problems[0].contains("NoSuchBus")
			and restored.is_empty(),
			"%s / %s / %s" % [filter_problems, bus_problems, restored])


## Editor changes to a level bus are overwritten; an effect BUS_FX doesn't describe is a problem.
func _test_bus_fx_forces_buses() -> void:
	var inside: int = AudioServer.get_bus_index(&"Inside")
	AudioServer.set_bus_effect_enabled(inside, 0, false)
	AudioServer.set_bus_effect_enabled(inside, 1, false)
	AudioServer.set_bus_mute(inside, true)
	AudioServer.set_bus_bypass_effects(inside, true)
	AudioServer.set_bus_solo(inside, true)
	AudioServer.set_bus_volume_db(inside, -12.0)
	AudioServer.add_bus_effect(inside, AudioEffectCompressor.new())
	var problems: PackedStringArray = EarTest.apply_bus_fx()
	var forced: bool = AudioServer.is_bus_effect_enabled(inside, 0) and AudioServer.is_bus_effect_enabled(inside, 1) \
			and not AudioServer.is_bus_mute(inside) and not AudioServer.is_bus_bypassing_effects(inside) \
			and not AudioServer.is_bus_solo(inside) \
			and is_equal_approx(AudioServer.get_bus_volume_db(inside), TrialPlan.LEVEL_BUS_VOLUME_DB["inside"])
	AudioServer.remove_bus_effect(inside, AudioServer.get_bus_effect_count(inside) - 1)
	var after: PackedStringArray = EarTest.apply_bus_fx()
	_check("audio buses: effects forced on, bus unmuted/unbypassed/not solo at its volume; an extra effect is a problem",
			forced and problems.size() == 1 and problems[0].contains("extra effect AudioEffectCompressor")
			and after.is_empty(), "%s / %s" % [problems, after])


func _test_rear_amount() -> void:
	var ahead: Vector3 = Vector3(0.0, 0.0, -1.0)  # facing the far bank
	var cases: Dictionary = {
		"ahead": [Vector3(0.0, 0.0, -6.0), 0.0],
		"behind": [Vector3(0.0, 0.0, 6.0), 1.0],
		"left": [Vector3(-6.0, 0.0, 0.0), 0.5],
		"right": [Vector3(6.0, 0.0, 0.0), 0.5],
		"behind and high (height ignored)": [Vector3(0.0, 5.0, 6.0), 1.0],
		"ahead-left 45 deg": [Vector3(-1.0, 0.0, -1.0), (1.0 - cos(PI / 4.0)) * 0.5],
		"straight overhead (no direction)": [Vector3(0.0, 5.0, 0.0), 0.0],
	}
	var wrong: PackedStringArray = []
	for case_name: String in cases:
		var got: float = TrialPlan.rear_amount(ahead, cases[case_name][0])
		if not is_equal_approx(got, cases[case_name][1]):
			wrong.append("%s=%s" % [case_name, got])
	_check("rear shadow: 0 ahead, 0.5 at either side, 1 behind, smooth between, height ignored",
			wrong.is_empty(), ", ".join(wrong))


## tools/measure_loudness.gd: BS.1770's reference reading, a full-scale 1 kHz sine in one
## channel is -3.01 LUFS; and the K-weighting (+4 dB shelf) makes 4 kHz read louder than 1 kHz.
func _test_loudness_meter() -> void:
	var meter: GDScript = load("res://tools/measure_loudness.gd")
	var rate: float = 48000.0
	var sine_1k: PackedVector2Array = []
	var sine_4k: PackedVector2Array = []
	for i: int in int(rate):
		sine_1k.append(Vector2(sin(TAU * 1000.0 * i / rate), 0.0))
		sine_4k.append(Vector2(sin(TAU * 4000.0 * i / rate), 0.0))
	var at_1k: float = meter.k_weighted_lufs(sine_1k, rate)
	var at_4k: float = meter.k_weighted_lufs(sine_4k, rate)
	_check("loudness meter: full-scale 1 kHz sine in one channel reads -3.01 LUFS (BS.1770); 4 kHz reads ~4 dB louder",
			absf(at_1k + 3.01) < 0.1 and at_4k - at_1k > 3.0 and at_4k - at_1k < 5.0,
			"1 kHz %.2f, 4 kHz %.2f" % [at_1k, at_4k])


## The Shadow bus sits before the level buses, goes to Master and holds one high shelf.
func _test_shadow_bus() -> void:
	var problems: PackedStringArray = EarTest.apply_bus_fx()
	var shadow: int = AudioServer.get_bus_index(&"Shadow")
	var ok: bool = problems.is_empty() and shadow > 0 and AudioServer.get_bus_send(shadow) == &"Master" \
			and AudioServer.get_bus_effect_count(shadow) == 1 \
			and AudioServer.get_bus_effect(shadow, 0) is AudioEffectHighShelfFilter \
			and AudioServer.is_bus_effect_enabled(shadow, 0) \
			and is_equal_approx((AudioServer.get_bus_effect(shadow, 0) as AudioEffectFilter).cutoff_hz, 2000.0) \
			and TrialPlan.SHADOW_BUS == &"Shadow"
	for level: String in TrialPlan.LEVELS:
		ok = ok and AudioServer.get_bus_index(TrialPlan.LEVEL_BUSES[level]) > shadow
	var layout: Resource = ResourceLoader.load("res://default_bus_layout.tres", "", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
	var tres_ok: bool = layout.get("bus/1/name") == &"Shadow" and layout.get("bus/1/send") == &"Master" \
			and layout.get("bus/1/effect/0/effect") is AudioEffectHighShelfFilter \
			and layout.get("bus/1/effect/0/enabled") == true and layout.get("bus/1/effect/1/effect") == null \
			and is_equal_approx((layout.get("bus/1/effect/0/effect") as AudioEffectFilter).cutoff_hz,
					TrialPlan.REAR_SHADOW_CUTOFF_HZ) \
			and layout.get("bus/1/mute") == false and layout.get("bus/1/bypass_fx") == false
	_check("rear shadow: Shadow bus comes before the level buses, sends to Master, one high shelf at 2000 Hz (live and .tres)",
			ok and tres_ok, str(problems))


## A missing Shadow bus, an extra effect on it, or the wrong bus order are setup problems.
func _test_shadow_bus_problems() -> void:
	var missing: PackedStringArray = EarTest.apply_bus_fx(TrialPlan.BUS_FX, TrialPlan.LEVEL_BUSES, &"NoShadow")
	var shadow: int = AudioServer.get_bus_index(&"Shadow")
	AudioServer.add_bus_effect(shadow, AudioEffectCompressor.new())
	var extra: PackedStringArray = EarTest.apply_bus_fx()
	AudioServer.remove_bus_effect(shadow, 1)
	AudioServer.move_bus(shadow, AudioServer.bus_count)  # to the very end (move_bus inserts before the index)
	var order: PackedStringArray = EarTest.apply_bus_fx()
	AudioServer.move_bus(AudioServer.get_bus_index(&"Shadow"), shadow)
	var restored: PackedStringArray = EarTest.apply_bus_fx()
	_check("rear shadow: missing Shadow bus, an extra effect on it, or Shadow after a level bus is a problem",
			missing.size() == 1 and missing[0].contains("'NoShadow' (rear shadow) is missing")
			and extra.size() == 1 and extra[0].contains("extra effect AudioEffectCompressor")
			and order.size() == 3 and order[0].contains("must come after 'Shadow'")
			and restored.is_empty() and AudioServer.get_bus_index(&"Shadow") == shadow,
			"%s / %s / %s / %s" % [missing, extra, order, restored])


## _ready() wires apply_bus_fx() into the setup gate: a broken bus disables Start.
func _test_scene_bus_problem_from_ready() -> void:
	var inside: int = AudioServer.get_bus_index(&"Inside")
	AudioServer.set_bus_name(inside, &"InsideRenamed")
	_expect_begin()
	var scene: EarTest = _new_scene("bus_ready")
	_expect_end("scene with a missing bus", [["ERROR", "audio bus 'Inside' for inside is missing", 1]])
	AudioServer.set_bus_name(inside, &"Inside")
	_setup_ready(scene, "ann")
	_check("setup: a bus problem found at startup is listed and Start is disabled",
			scene.bus_problems.size() == 1 and scene._start_button.disabled and scene._problem_label.visible
			and scene._problem_label.text.contains("audio bus 'Inside' for inside is missing")
			and EarTest.apply_bus_fx().is_empty(), scene._problem_label.text)
	scene.free()


# ------------------------------------------------------------------ the scene

func _test_scene_setup_gates() -> void:
	var scene: EarTest = _new_scene("setup")
	_check("setup: blank tester ID can't start", not scene.start_session("  ", "headphones")
			and scene.state == EarTest.State.SETUP)
	scene._id_edit.text = " 　"
	scene._mode_buttons[0].button_pressed = true
	var unicode_blank_disabled: bool = scene._start_button.disabled
	scene._mode_buttons[0].button_pressed = false
	scene._id_edit.text = "ann"
	scene.refresh_setup()
	var no_mode_disabled: bool = scene._start_button.disabled
	scene._mode_buttons[0].button_pressed = true
	_check("setup: Start needs a non-blank ID (Unicode spaces count as blank) and an output mode",
			unicode_blank_disabled and no_mode_disabled and not scene._start_button.disabled,
			scene._library_label.text)
	_check("setup: tester ID field is limited to %d characters" % TrialPlan.TESTER_ID_MAX_LENGTH,
			scene._id_edit.max_length == 64 and TrialPlan.TESTER_ID_MAX_LENGTH == 64)
	scene.notification(FOCUS_OUT)
	_check("setup: focus loss on the setup screen doesn't pause", scene.state == EarTest.State.SETUP)

	# Empty level folder.
	scene.library.list_folder = func(folder: String) -> PackedStringArray:
		return PackedStringArray() if folder.ends_with("/inside/") else ResourceLoader.list_directory(folder)
	scene.library.list_raw_files = func(folder: String) -> PackedStringArray:
		return PackedStringArray() if folder.ends_with("/inside/") else DirAccess.get_files_at(folder)
	scene.library.discover()
	scene.refresh_setup()
	_check("setup: an empty level folder is named and Start is disabled",
			scene._library_label.text.contains("No usable .wav clips in res://audio/cries/inside/")
			and scene._start_button.disabled, scene._library_label.text)

	# One unloadable clip (the level still has others) and one skipped audio file.
	scene.library.list_folder = func(folder: String) -> PackedStringArray:
		var names: PackedStringArray = ResourceLoader.list_directory(folder)
		if folder.ends_with("/below/"):
			names.append_array(PackedStringArray(["placeholder_below_9.wav", "extra.ogg"]))
		return names
	scene.library.list_raw_files = Callable()
	scene.library.load_clip = func(path: String) -> Resource:
		return null if path.ends_with("placeholder_below_9.wav") else load(path)
	_expect_begin()
	scene.library.discover()
	_expect_end("setup with one unloadable clip", [
		["WARNING", "could not load placeholder_below_9.wav in res://audio/cries/below/", 1],
		["WARNING", "skipped res://audio/cries/below/extra.ogg", 1],
	])
	scene.refresh_setup()
	_check("setup: any clip that doesn't load disables Start (problem shown); skipped audio is a warning",
			scene._problem_label.text.contains("placeholder_below_9.wav")
			and scene._problem_label.text.contains(CryLibrary.IMPORT_COMMAND)
			and scene._library_label.text.contains("skipped res://audio/cries/below/extra.ogg")
			and scene.library.clips_for("below").size() == 2 and scene._start_button.disabled,
			scene._problem_label.text + " / " + scene._library_label.text)

	# A .wav dropped into a folder but not imported yet.
	scene.library.list_folder = ResourceLoader.list_directory
	scene.library.load_clip = Callable()
	scene.library.list_raw_files = func(folder: String) -> PackedStringArray:
		var names: PackedStringArray = DirAccess.get_files_at(folder)
		if folder.ends_with("/inside/"):
			names.append("fresh_sob.wav")
		return names
	_expect_begin()
	scene.library.discover()
	_expect_end("setup with a clip not imported", [
		["WARNING", "not imported yet: fresh_sob.wav in res://audio/cries/inside/", 1],
		["WARNING", "placeholders mixed with real clips in res://audio/cries/inside/", 1],
	])
	scene.refresh_setup()
	_check("setup: a .wav not imported yet is named with the import command and disables Start",
			scene._start_button.disabled and scene._problem_label.text.contains("fresh_sob.wav")
			and scene._problem_label.text.contains(CryLibrary.IMPORT_COMMAND), scene._problem_label.text)

	# Never imported: nothing loads.
	scene.library.list_raw_files = Callable()
	scene.library.load_clip = func(_path: String) -> Resource: return null
	_expect_begin()
	scene.library.discover()
	_expect_end("setup never imported", [["WARNING", "could not load placeholder_", 3]])
	scene.refresh_setup()
	_check("setup: no loadable clips (never imported) -> Start disabled, import command shown",
			scene._start_button.disabled and scene._library_label.text.contains(CryLibrary.IMPORT_COMMAND))

	# Audio bus problem (the UI side; _test_scene_bus_problem_from_ready covers _ready()).
	scene.library.load_clip = Callable()
	scene.library.discover()
	scene.refresh_setup()
	var clean_enabled: bool = not scene._start_button.disabled
	scene.bus_problems = PackedStringArray(["audio bus 'Inside' has no reverb"])
	scene.refresh_setup()
	_check("setup: an audio bus problem is listed and disables Start",
			clean_enabled and scene._start_button.disabled and scene._problem_label.visible
			and scene._problem_label.text.contains("audio bus 'Inside' has no reverb")
			and not scene.start_session("ann", "headphones"), scene._problem_label.text)
	scene.free()


func _test_scene_audio_setup() -> void:
	var scene: EarTest = _new_scene("audio")
	var emitter: AudioStreamPlayer3D = scene.emitter
	var distances: Array = []
	for combo: Dictionary in TrialPlan.all_combinations():
		distances.append(TrialPlan.source_position(combo["direction"], combo["level"]).length())
	var bus_volumes: Array = []
	for level: String in TrialPlan.LEVELS:
		bus_volumes.append(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(TrialPlan.LEVEL_BUSES[level])))
	_check("emitter: no distance attenuation, so all 12 sources (%.2f to %.2f m) play at the same level; level buses at their matching volumes"
			% [distances.min(), distances.max()],
			TrialPlan.EMITTER_ATTENUATION_MODEL == AudioStreamPlayer3D.ATTENUATION_DISABLED
			and emitter.attenuation_model == AudioStreamPlayer3D.ATTENUATION_DISABLED
			and is_zero_approx(emitter.max_distance) and not emitter.emission_angle_enabled
			and is_equal_approx(emitter.volume_db, TrialPlan.EMITTER_VOLUME_DB)
			and emitter.max_db >= emitter.volume_db
			and is_equal_approx(bus_volumes[0], TrialPlan.LEVEL_BUS_VOLUME_DB["above"])
			and is_equal_approx(bus_volumes[1], TrialPlan.LEVEL_BUS_VOLUME_DB["inside"])
			and is_equal_approx(bus_volumes[2], TrialPlan.LEVEL_BUS_VOLUME_DB["below"]),
			"model %d, bus volumes %s" % [emitter.attenuation_model, bus_volumes])
	_check("emitter: does not filter by distance",
			is_equal_approx(emitter.attenuation_filter_db, TrialPlan.EMITTER_ATTENUATION_FILTER_DB)
			and is_zero_approx(emitter.attenuation_filter_db))
	scene.free()


func _test_scene_inside_rail_pylons() -> void:
	var scene: EarTest = _new_scene("pylons")
	var ok: bool = true
	var detail: String = ""
	for side: String in ["left_rail", "right_rail"]:
		var source: Vector3 = TrialPlan.source_position(side, "inside")
		var pylon: MeshInstance3D = scene.get_node("Span/PylonLeft" if side == "left_rail" else "Span/PylonRight")
		var bounds: AABB = pylon.global_transform * pylon.get_aabb()
		ok = ok and bounds.has_point(source) and bounds.end.y > TrialPlan.EAR_HEIGHT
		detail += "%s %s in %s; " % [side, source, bounds]
	var parapet: MeshInstance3D = scene.get_node("Span/ParapetLeft")
	var parapet_top: float = (parapet.global_transform * parapet.get_aabb()).end.y
	_check("scene: each inside-rail source sits inside its parapet pylon; the parapet stays 1.2 m",
			ok and is_equal_approx(parapet_top, 1.2), detail + "parapet top %s" % parapet_top)
	scene.free()


## The Shadow bus follows the cry as the listener turns: behind is duller and quieter.
func _test_scene_rear_shadow() -> void:
	var scene: EarTest = _new_scene("shadow")
	var bus: int = AudioServer.get_bus_index(TrialPlan.SHADOW_BUS)
	var shelf: AudioEffectFilter = AudioServer.get_bus_effect(bus, 0) as AudioEffectFilter
	_start(scene, "shadow", "headphones")
	scene.emitter.global_position = TrialPlan.source_position("town", "above")
	scene.listener.reset_facing()  # facing the far bank: town is straight behind
	_step(scene, 0.1)
	var behind: Array = [scene.rear_shadow, shelf.gain, AudioServer.get_bus_volume_db(bus)]
	scene.listener.rotation.y = PI / 2.0  # facing the left rail: town is to the right
	_step(scene, 0.1)
	var side: Array = [scene.rear_shadow, shelf.gain, AudioServer.get_bus_volume_db(bus)]
	scene.listener.rotation.y = PI  # facing town
	_step(scene, 0.1)
	var facing: Array = [scene.rear_shadow, shelf.gain, AudioServer.get_bus_volume_db(bus)]
	# Shelf gain g cuts the treble by 40*log10(g) dB (measured), so -10 dB is g = 10^(-10/40).
	_check("rear shadow: behind -10 dB treble and -2 dB, side half, facing it none; updated every frame",
			is_equal_approx(behind[0], 1.0) and is_equal_approx(behind[1], pow(10.0, -10.0 / 40.0))
			and is_equal_approx(behind[2], -2.0)
			and is_equal_approx(side[0], 0.5) and is_equal_approx(side[1], pow(10.0, -5.0 / 40.0))
			and is_equal_approx(side[2], -1.0)
			and is_zero_approx(facing[0]) and is_equal_approx(facing[1], 1.0) and is_zero_approx(facing[2]),
			"behind %s, side %s, facing %s" % [behind, side, facing])
	scene.free()


func _test_scene_listener_geometry() -> void:
	var scene: EarTest = _new_scene("geometry")
	# Facing the left rail puts a left-rail cry straight ahead (centre pan); facing the far
	# bank puts it hard left.
	var left_source: Vector3 = TrialPlan.source_position("left_rail", "above")
	var cam: Camera3D = scene.listener.camera
	var at_start: Vector3 = cam.global_transform.affine_inverse() * left_source
	scene.listener.rotation.y = PI / 2.0
	var turned: Vector3 = cam.global_transform.affine_inverse() * left_source
	scene.listener.reset_facing()
	_check("listener: turning to face the left rail centres a left-rail cry",
			at_start.x < -5.0 and absf(turned.x) < 0.001 and turned.z < 0.0, "%s -> %s" % [at_start, turned])
	scene.free()


func _test_scene_trial_flow() -> void:
	var scene: EarTest = _new_scene("flow")
	_start(scene, "flow", "headphones")
	var silence_ok: bool = scene.state == EarTest.State.SILENCE and not scene.listener.look_enabled \
			and scene.listener.rotation.is_zero_approx()
	scene.listener.look(Vector2(300.0, -120.0))  # however the view got turned before the cry...
	_step(scene, TrialPlan.SILENCE_BEFORE_CRY_S)
	_check("trial: mouse-look off in the silence; the cry starts facing the far bank with look on",
			silence_ok and scene.state == EarTest.State.CRY and scene.listener.look_enabled
			and scene.listener.rotation.is_zero_approx() and scene.listener.camera.rotation.is_zero_approx()
			and scene.emitter.playing and is_equal_approx(scene.emitter.volume_db, TrialPlan.EMITTER_VOLUME_DB))
	_step(scene, TrialPlan.CRY_WINDOW_S - TrialPlan.CRY_FADE_OUT_S * 0.5)
	var fading_db: float = scene.emitter.volume_db
	var still_cry: bool = scene.state == EarTest.State.CRY
	_step(scene, TrialPlan.CRY_FADE_OUT_S)
	_check("trial: the cry fades out over the last 50 ms, then the grid appears; volume restored",
			still_cry and fading_db < TrialPlan.EMITTER_VOLUME_DB - 5.0 and scene.state == EarTest.State.ANSWER
			and not scene.emitter.playing and not scene.listener.look_enabled
			and is_equal_approx(scene.emitter.volume_db, TrialPlan.EMITTER_VOLUME_DB),
			"fading at %s dB" % fading_db)
	scene.free()


func _test_scene_feedback() -> void:
	var scene: EarTest = _new_scene("feedback")
	_start(scene, "feedback", "speakers")
	_to_grid(scene)
	var truth: Dictionary = scene.current_combo()
	scene.answer(truth["direction"], truth["level"])
	var correct_ok: bool = scene.state == EarTest.State.FEEDBACK and scene._feedback_label.text == "Correct" \
			and scene._answer_panel.visible and scene._answer_buttons[0].disabled
	_step(scene, TrialPlan.PRACTICE_FEEDBACK_S - 0.1)
	var held: bool = scene.state == EarTest.State.FEEDBACK and scene.trial_index == 0
	_step(scene, 0.1)
	_check("practice feedback: 'Correct' for 2 s, then the next trial",
			correct_ok and held and is_equal_approx(TrialPlan.PRACTICE_FEEDBACK_S, 2.0)
			and scene.state == EarTest.State.SILENCE and scene.trial_index == 1
			and scene.results.size() == 1 and scene.results[0]["round"] == TrialPlan.ROUND_PRACTICE)
	_to_grid(scene)
	var truth2: Dictionary = scene.current_combo()
	scene.answer(truth2["direction"], _other_level(truth2["level"]))
	_check("practice feedback: a wrong answer shows 'It was: <true combination>'",
			scene._feedback_label.text == "It was: " + TrialPlan.combo_label(truth2), scene._feedback_label.text)
	scene.free()


## True when the scene is paused the way every pause must look: neutral text, no cry, mouse free.
func _is_paused(scene: EarTest) -> bool:
	return scene.state == EarTest.State.PAUSED and not scene.listener.look_enabled \
			and not scene.emitter.playing and scene._pause_panel.visible \
			and scene._pause_label.text == EarTest.PAUSE_TEXT


## Practice: Replay at the grid plays the same cry again and counts in the replays column.
## Scored: no Replay button, and replay_cry() does nothing.
## Setup -> listen screen: the same clip from straight ahead at each level, nothing logged.
func _test_scene_listen() -> void:
	var scene: EarTest = _new_scene("listen")
	var started: bool = scene.start_session("listen", "headphones")
	var clip_total: int = 0
	for level: String in TrialPlan.LEVELS:
		clip_total += scene.library.clips_for(level).size()
	_check("listen: Start opens the listen screen (no trial yet, mouse free, every clip offered)",
			started and scene.state == EarTest.State.LISTEN and scene._listen_panel.visible
			and not scene._answer_panel.visible and not scene.listener.look_enabled
			and scene._demo_clips.size() == clip_total and scene._demo_label.text == "Cry 1 of %d" % clip_total,
			scene._demo_label.text)

	var played: Dictionary = {}
	var clip: String = scene._demo_clips[0]
	var same_clip: bool = true
	for level: String in TrialPlan.LEVELS:
		var ok: bool = scene.play_demo(level)
		played[level] = ok and scene.emitter.playing \
				and scene.emitter.bus == TrialPlan.LEVEL_BUSES[level] \
				and scene.emitter.global_position.is_equal_approx(TrialPlan.source_position("far_bank", level)) \
				and scene._demo_now_label.text == "Playing: " + String(TrialPlan.LEVEL_LABELS[level])
		same_clip = same_clip and scene.emitter.stream == scene.library.stream_for(clip)
	_check("listen: each level button plays the same clip from the far bank through that level's bus",
			played.values().all(func(v: bool) -> bool: return v) and same_clip
			and TrialPlan.LISTEN_DIRECTION == "far_bank", str(played))

	_step(scene, TrialPlan.CRY_WINDOW_S * 0.5)
	var mid: bool = scene.emitter.playing and scene._demo_playing
	_step(scene, TrialPlan.CRY_WINDOW_S * 0.5 + 0.01)
	_check("listen: a demo plays for the cry window, then stops by itself",
			mid and not scene.emitter.playing and not scene._demo_playing
			and scene._demo_now_label.text.strip_edges().is_empty())

	scene.play_demo("above")
	var paused: bool = scene.pause()
	_check("listen: Esc or focus loss just stops the sound (no pause screen)",
			not paused and scene.state == EarTest.State.LISTEN and not scene.emitter.playing
			and not scene._pause_panel.visible)

	var cycled: bool = true
	for i: int in clip_total:
		cycled = cycled and scene.next_demo_clip()
	scene.next_demo_clip()
	_check("listen: Another cry steps through every clip and wraps around",
			cycled and scene._demo_index == 1 and scene._demo_label.text == "Cry 2 of %d" % clip_total,
			scene._demo_label.text)

	scene.play_demo("inside")
	var practice: bool = scene.start_practice()
	_check("listen: Start practice stops the demo and begins trial 1; the listen screen logged nothing",
			practice and scene.state == EarTest.State.SILENCE and scene.trial_index == 0
			and scene.round_name == TrialPlan.ROUND_PRACTICE and not scene._demo_playing
			and scene.results.is_empty() and _read_lines(scene.results_log.path).size() == 1)
	_check("listen: refused outside the listen screen (play, another cry, start practice)",
			not scene.play_demo("below") and not scene.next_demo_clip() and not scene.start_practice()
			and scene.state == EarTest.State.SILENCE)
	scene.free()


func _test_scene_replay() -> void:
	var scene: EarTest = _new_scene("replay")
	_start(scene, "replay", "headphones")
	var first: Dictionary = scene.current_combo()
	var clip: String = scene.current_clip
	_to_grid(scene)
	var shown: bool = scene._replay_button.visible and not scene._replay_button.disabled
	scene.listener.rotation.y = 1.0
	var replayed: bool = scene.replay_cry()
	_check("replay: practice grid shows Replay; pressing it replays the same cry from the silence, facing reset",
			shown and replayed and scene.state == EarTest.State.SILENCE and scene.trial_index == 0
			and scene.current_combo() == first and scene.current_clip == clip
			and scene.listener.rotation.is_zero_approx() and scene.results.is_empty())
	_to_grid(scene)
	scene.replay_cry()
	_to_grid(scene)
	_step(scene, 1.5)  # 1.5 s at the grid after the last cry
	scene.answer(first["direction"], first["level"])
	var blocked_in_feedback: bool = not scene.replay_cry() and scene._replay_button.disabled
	_step(scene, TrialPlan.PRACTICE_FEEDBACK_S)
	var row: Dictionary = scene.results[0]
	var expected_ms: int = roundi((TrialPlan.CRY_WINDOW_S + 1.5) * 1000.0)
	_check("replay: 2 replays logged; response_ms counts from the last cry; no replay during feedback",
			blocked_in_feedback and row["replays"] == 2 and row["response_ms"] == expected_ms
			and _read_csv(scene.results_log.path)[0]["replays"] == "2", str(row))
	_to_grid(scene)
	var second: Dictionary = scene.current_combo()
	scene.answer(second["direction"], second["level"])
	_step(scene, TrialPlan.PRACTICE_FEEDBACK_S)
	_check("replay: the count resets for the next trial", scene.results[1]["replays"] == 0)
	scene.free()

	scene = _new_scene("replay_scored")
	_start(scene, "replay", "speakers")
	_play_practice(scene)
	scene.start_scored_round()
	_to_grid(scene)
	var refused: bool = not scene.replay_cry()
	_check("replay: none in the scored round (button hidden, replay_cry() refused, state unchanged)",
			refused and not scene._replay_button.visible and scene.state == EarTest.State.ANSWER
			and scene.trial_replays == 0)
	scene.free()


func _test_scene_pauses() -> void:
	var scene: EarTest = _new_scene("pauses")
	_start(scene, "pauses", "headphones")
	var first: Dictionary = scene.current_combo()
	var clip: String = scene.current_clip

	# 1. In the silence -> replay.
	_step(scene, 0.5)
	scene.notification(FOCUS_OUT)
	var paused: bool = _is_paused(scene)
	scene.resume()
	_check("pause: focus loss in the silence -> resume replays the trial (same combination and clip)",
			paused and scene.state == EarTest.State.SILENCE and scene.trial_index == 0
			and scene.current_combo() == first and scene.current_clip == clip)

	# 2. Early in the cry (< 1 s heard) -> replay.
	_step(scene, TrialPlan.SILENCE_BEFORE_CRY_S)
	_step(scene, TrialPlan.REPLAY_IF_PAUSED_BEFORE_S * 0.5)
	var was_crying: bool = scene.state == EarTest.State.CRY and scene.emitter.playing
	scene.notification(FOCUS_OUT)
	paused = _is_paused(scene)
	scene.resume()
	_check("pause: focus loss 0.5 s into the cry -> the cry stops; resume replays from the silence",
			was_crying and paused and scene.state == EarTest.State.SILENCE
			and scene.current_combo() == first and scene.current_clip == clip
			and scene.listener.rotation.is_zero_approx())

	# 3. Later in the cry -> back to the grid, no replay; the paused time doesn't count.
	_step(scene, TrialPlan.SILENCE_BEFORE_CRY_S)
	_step(scene, 2.0)
	scene.notification(FOCUS_OUT)
	paused = _is_paused(scene)
	_fake_ms += 7000
	scene.resume()
	_step(scene, TrialPlan.SILENCE_BEFORE_CRY_S + TrialPlan.CRY_WINDOW_S)  # would replay if it were wrong
	_check("pause: focus loss 2 s into the cry -> resume goes to the grid, no replay",
			paused and scene.state == EarTest.State.ANSWER and not scene.emitter.playing
			and scene.trial_index == 0 and scene.results.is_empty())

	# 4. At the grid -> back to the grid.
	scene.notification(FOCUS_OUT)
	paused = _is_paused(scene)
	_fake_ms += 5000
	scene.resume()
	var back_at_grid: bool = scene.state == EarTest.State.ANSWER and scene._answer_panel.visible
	scene.answer(first["direction"], first["level"])
	_check("pause: focus loss at the answer grid -> resume returns to the grid", paused and back_at_grid)

	# 5. During practice feedback -> the next trial.
	scene.notification(FOCUS_OUT)
	paused = _is_paused(scene)
	scene.resume()
	_check("pause: focus loss during practice feedback -> resume goes on to the next trial",
			paused and scene.state == EarTest.State.SILENCE and scene.trial_index == 1)

	# Response time: 2 s of cry + 1 + 4 s waiting at the grid, without the 7 s + 5 s paused.
	var row: Dictionary = scene.results[0]
	_check("pause: response_ms excludes the time paused (late in the cry and at the grid)",
			row["response_ms"] == 7000, "response_ms %d" % row["response_ms"])

	# The trial after: no pause. Esc toggles pause and resume.
	_to_grid(scene)
	var second: Dictionary = scene.current_combo()
	scene.answer(second["direction"], second["level"])
	_step(scene, TrialPlan.PRACTICE_FEEDBACK_S)
	var esc: InputEventAction = InputEventAction.new()
	esc.action = &"ui_cancel"
	esc.pressed = true
	scene._input(esc)
	var esc_paused: bool = _is_paused(scene)
	scene._input(esc)
	_check("pause: Esc pauses and Esc resumes; the pause screen says only 'Paused.' every time",
			esc_paused and scene.state == EarTest.State.SILENCE and EarTest.PAUSE_TEXT == "Paused.")

	var csv: Array = _read_csv(scene.results_log.path)
	_check("pause: the pauses column counts every pause in the trial (5, then 0, then pending 1)",
			csv.size() == 2 and csv[0]["pauses"] == "5" and csv[1]["pauses"] == "0"
			and csv[0]["response_ms"] == "7000" and scene.trial_pauses == 1,
			str(csv))
	scene.free()


## The same pause rules in the scored round (no feedback there).
func _test_scene_scored_pauses() -> void:
	var scene: EarTest = _new_scene("scored_pauses")
	_start(scene, "scored", "speakers")
	_play_practice(scene)
	scene.start_scored_round()
	var first: Dictionary = scene.current_combo()
	var clip: String = scene.current_clip

	_step(scene, TrialPlan.SILENCE_BEFORE_CRY_S)
	_step(scene, TrialPlan.REPLAY_IF_PAUSED_BEFORE_S * 0.5)
	scene.notification(FOCUS_OUT)
	var paused_early: bool = _is_paused(scene)
	scene.resume()
	_check("scored pause: 0.5 s into the cry -> replay from the silence (same combination and clip)",
			paused_early and scene.state == EarTest.State.SILENCE and scene.round_name == TrialPlan.ROUND_SCORED
			and scene.trial_index == 0 and scene.current_combo() == first and scene.current_clip == clip)

	_step(scene, TrialPlan.SILENCE_BEFORE_CRY_S)
	_step(scene, 2.0)
	scene.notification(FOCUS_OUT)
	var paused_late: bool = _is_paused(scene)
	_fake_ms += 7000
	scene.resume()
	_step(scene, TrialPlan.SILENCE_BEFORE_CRY_S + TrialPlan.CRY_WINDOW_S)  # would replay if it were wrong
	_check("scored pause: 2 s into the cry -> resume goes to the grid, no replay",
			paused_late and scene.state == EarTest.State.ANSWER and not scene.emitter.playing
			and scene.trial_index == 0)

	scene.notification(FOCUS_OUT)
	var paused_grid: bool = _is_paused(scene)
	_fake_ms += 5000
	scene.resume()
	_step(scene, TrialPlan.SILENCE_BEFORE_CRY_S + TrialPlan.CRY_WINDOW_S)
	_check("scored pause: at the answer grid -> resume returns to the grid, no replay",
			paused_grid and scene.state == EarTest.State.ANSWER and not scene.emitter.playing
			and scene.trial_index == 0)
	scene.answer(first["direction"], first["level"])

	var scored_rows: Array = []
	for row: Dictionary in _read_csv(scene.results_log.path):
		if row["round"] == TrialPlan.ROUND_SCORED:
			scored_rows.append(row)
	# Response: 2 s of cry + 5 s + 5 s waiting at the grid, without the 7 s + 5 s paused.
	_check("scored pause: the row is written at once with pauses 3 and the paused time excluded",
			scene.trial_index == 1 and scored_rows.size() == 1 and scored_rows[0]["pauses"] == "3"
			and scored_rows[0]["response_ms"] == "12000", str(scored_rows))
	scene.free()


## Closing the window during practice feedback still logs the answer (via _exit_tree).
func _test_scene_close_during_feedback() -> void:
	var scene: EarTest = _new_scene("close_feedback")
	_start(scene, "close", "headphones")
	_to_grid(scene)
	var truth: Dictionary = scene.current_combo()
	scene.answer(truth["direction"], truth["level"])
	var path: String = scene.results_log.path
	var before: int = _read_csv(path).size()
	root.remove_child(scene)
	var rows: Array = _read_csv(path)
	_check("close: leaving the tree during practice feedback writes that practice row",
			before == 0 and rows.size() == 1 and rows[0]["round"] == TrialPlan.ROUND_PRACTICE
			and rows[0]["pauses"] == "0", str(rows))
	scene.free()

	scene = _new_scene("close_paused")
	_start(scene, "close-paused", "headphones")
	_to_grid(scene)
	truth = scene.current_combo()
	scene.answer(truth["direction"], _other_level(truth["level"]))
	scene.notification(FOCUS_OUT)
	path = scene.results_log.path
	scene.free()
	rows = _read_csv(path)
	_check("close: freeing the scene while paused in feedback writes that row with its pause",
			rows.size() == 1 and rows[0]["pauses"] == "1" and rows[0]["both_correct"] == "0", str(rows))


func _test_scene_full_session() -> void:
	var scene: EarTest = _new_scene("session")
	# Through the setup UI, with a Vietnamese ID that has a path in it and spaces at the ends.
	var raw_id: String = "  Sơn/../x, Đức  "
	_setup_ready(scene, raw_id)
	scene._on_start_pressed()
	var at_listen: bool = scene.state == EarTest.State.LISTEN and scene._listen_panel.visible
	scene.start_practice()
	var started: bool = at_listen and scene.state == EarTest.State.SILENCE
	_play_to_results(scene, true)
	var path: String = scene.results_log.path
	var csv: Array = _read_csv(path)
	var practice: int = 0
	var scored: int = 0
	var both: int = 0
	var direction: int = 0
	var level: int = 0
	var min_response: int = 1 << 30
	var ids_raw: bool = true
	var pause_rows_ok: bool = true
	var per_level_trials: Dictionary = {}
	var per_level_both: Dictionary = {}
	for row: Dictionary in csv:
		ids_raw = ids_raw and row["tester_id"] == "Sơn/../x, Đức"
		min_response = mini(min_response, int(row["response_ms"]))
		if row["round"] == TrialPlan.ROUND_PRACTICE:
			practice += 1
			pause_rows_ok = pause_rows_ok and row["pauses"] == "0"
			continue
		scored += 1
		# Each scored trial was paused once at the grid for 3 s, answered right after the cry.
		pause_rows_ok = pause_rows_ok and row["pauses"] == "1" and row["response_ms"] == "4000"
		both += int(row["both_correct"])
		direction += int(row["direction_correct"])
		level += int(row["level_correct"])
		per_level_trials[row["true_level"]] = per_level_trials.get(row["true_level"], 0) + 1
		per_level_both[row["true_level"]] = per_level_both.get(row["true_level"], 0) + int(row["both_correct"])
	var kinds_ok: bool = true
	var kind_differs: int = 0
	var kinds_per_level: Dictionary = {}
	for row: Dictionary in csv:
		var kind: String = row["cry_kind"]
		kinds_ok = kinds_ok and kind in TrialPlan.LEVELS \
				and scene.library.clips_for(kind).has("res://audio/cries/%s/%s" % [kind, row["clip"]])
		if kind != row["true_level"]:
			kind_differs += 1
		var seen: Dictionary = kinds_per_level.get(row["true_level"], {})
		seen[kind] = true
		kinds_per_level[row["true_level"]] = seen
	var mixed_everywhere: bool = kinds_per_level.size() == 3
	for seen_level: String in kinds_per_level:
		mixed_everywhere = mixed_everywhere and kinds_per_level[seen_level].size() >= 2
	_check("session: cry_kind is logged and not tied to the level (the kind of cry doesn't give the level away)",
			kinds_ok and kind_differs >= 12 and mixed_everywhere,
			"%d of %d rows differ; %s" % [kind_differs, csv.size(), kinds_per_level])
	_check("session: CSV has 12 practice + 24 scored rows",
			started and scene.state == EarTest.State.RESULTS and practice == 12 and scored == 24
			and not scene.results_log.has_error(),
			"%d practice, %d scored" % [practice, scored])
	_check("session: file name keeps the letters, CSV keeps the trimmed ID as typed",
			path.get_file().begins_with("Sơn____x__Đức_headphones_") and ids_raw, path.get_file())
	_check("session: response_ms is at least the cry window when answering after it",
			min_response >= int(TrialPlan.CRY_WINDOW_S * 1000.0), "min %d" % min_response)
	_check("session: scored pauses at the grid are counted (1 each) and their time excluded (4000 ms)",
			pause_rows_ok)

	# AC2: the results screen's figures match the CSV.
	var text: String = scene._results_label.text
	var screen_ok: bool = true
	var detail: String = ""
	var figures: Dictionary = {
		"Both correct": both, "Direction correct, any level": direction, "Level correct, any direction": level,
	}
	for caption: String in figures:
		var pattern: String = caption + ": ([\\d.]+)%\\s+\\((\\d+) / (\\d+)\\)"
		var pct: float = _first_float(pattern, text, 1)
		var count: float = _first_float(pattern, text, 2)
		var total: float = _first_float(pattern, text, 3)
		var want_pct: float = 100.0 * figures[caption] / scored
		if count != figures[caption] or total != scored or absf(pct - want_pct) > 0.05:
			screen_ok = false
			detail += "%s: screen %s%% %s/%s vs CSV %d/%d; " % [caption, pct, count, total, figures[caption], scored]
	for level_name: String in TrialPlan.LEVELS:
		var pct: float = _first_float(TrialPlan.LEVEL_LABELS[level_name] + " ([\\d.]+)%", text)
		var want: float = 100.0 * per_level_both.get(level_name, 0) / per_level_trials.get(level_name, 1)
		if absf(pct - want) > 0.05:
			screen_ok = false
			detail += "%s: screen %s vs CSV %s; " % [level_name, pct, want]
	var verdict_ok: bool = scene._verdict_label.text == ("PASS" if both * 100 >= TrialPlan.PASS_PERCENT * scored else "FAIL")
	_check("session: results screen both/direction/level/per-level figures match the CSV (%d/%d both)" % [both, scored],
			screen_ok and verdict_ok and both == 6 and direction == 12 and level == 12, detail + text)

	scene.new_session()
	_check("session: New session keeps the ID, clears the output mode, shows the last session",
			scene.state == EarTest.State.SETUP and scene._id_edit.text == raw_id
			and scene._selected_mode().is_empty() and scene._start_button.disabled
			and scene._last_session_label.visible
			and scene._last_session_label.text == "Last session: Sơn/../x, Đức · headphones",
			scene._last_session_label.text)
	scene.free()


func _test_scene_write_failure() -> void:
	DirAccess.make_dir_recursive_absolute(SCRATCH_DIR)
	var blocker: String = SCRATCH_DIR.path_join("blocked")
	var file: FileAccess = FileAccess.open(blocker, FileAccess.WRITE)
	file.store_string("x")
	file.close()
	var scene: EarTest = _new_scene("")
	scene.results_dir = blocker.path_join("results")
	_expect_begin()
	_start(scene, "wf", "speakers")
	_expect_end("session write failure", [
		["ERROR", "Could not create directory", 1],
		["WARNING", "could not create the results folder", 1],
	])
	var banner_ok: bool = scene._save_banner.visible and scene.results_log.has_error() \
			and scene._save_banner_label.text == "Results are NOT being saved: " + scene.results_log.error_message
	_check("write failure: a red banner says results are NOT being saved, at once",
			banner_ok, scene._save_banner_label.text)
	_play_to_results(scene)
	var summary: Dictionary = TrialPlan.score(scene.results)
	_check("write failure: results screen still shows the scores, the error and the attempted path",
			scene.state == EarTest.State.RESULTS and summary["scored_trials"] == 24
			and scene._results_label.text.contains("Both correct: %.1f%%" % summary["both_pct"])
			and scene._results_path_label.text.contains(scene.results_log.error_message)
			and scene._results_path_label.text.contains("Attempted path: " + scene.results_log.global_path())
			and scene._save_banner.visible,
			scene._results_path_label.text)
	scene.new_session()
	_check("write failure: the banner goes away with New session", not scene._save_banner.visible)
	scene.free()


func _test_scene_missing_stream_aborts() -> void:
	var scene: EarTest = _new_scene("abort")
	scene.library._streams.clear()  # clips listed but no stream: must never become a silent trial
	_expect_begin()
	var started: bool = _start(scene, "abort", "speakers")
	_expect_end("missing stream", [["ERROR", "No playable clip", 1]])
	_check("missing stream: the session stops back at setup with the error shown, nothing logged",
			not started and scene.state == EarTest.State.SETUP
			and scene._problem_label.visible and scene._problem_label.text.contains("No playable clip")
			and scene.results.is_empty() and _read_lines(scene.results_log.path).size() == 1,
			scene._problem_label.text)
	scene.free()


func _test_scene_practice_zero() -> void:
	var scene: EarTest = _new_scene("zero")
	_start(scene, "zero", "headphones")
	scene._begin_round(TrialPlan.ROUND_PRACTICE, [])  # what PRACTICE_REPEATS = 0 produces
	var at_break: bool = scene.state == EarTest.State.ROUND_BREAK and scene._break_panel.visible
	scene.start_scored_round()
	_check("session: an empty practice order goes straight to the round break",
			at_break and scene.state == EarTest.State.SILENCE and scene.round_name == TrialPlan.ROUND_SCORED)
	scene.free()


func _test_scene_open_folder_error() -> void:
	var scene: EarTest = _new_scene("folder")
	scene.show_open_folder_result(ERR_CANT_OPEN, "/nowhere")
	scene.show_open_folder_result(ERR_CANT_OPEN, "/nowhere")
	var text: String = scene._folder_error_label.text
	scene.show_open_folder_result(OK, "/nowhere")
	_check("results: 'Open results folder' errors replace each other instead of piling up",
			text.count("Could not open") == 1 and not scene._folder_error_label.visible, text)
	scene.free()
