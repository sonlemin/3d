## LaunchOptions (AD-61): the switches after `--` are parsed once, by one table, into a value.
## A bad switch is a setup problem (AD-28): listed, never a crash, and parse() itself logs
## nothing (Main reports the problems), so every case here runs outside an expect window.
extends TestCase


func _parse(args: Array[String]) -> LaunchOptions:
	return LaunchOptions.parse(PackedStringArray(args))


## True when exactly one problem was found and it starts with `prefix`.
func _one_problem(options: LaunchOptions, prefix: String) -> bool:
	return options.problems.size() == 1 and options.problems[0].begins_with(prefix)


func _test_no_switches() -> void:
	var options: LaunchOptions = _parse([])
	_check("launch: no switches -> no problems, no seed, start page, no trace, no show",
			options.problems.is_empty() and not options.seed_given and options.start == &""
			and not options.trace and options.show == &"",
			"%s %s '%s'" % [options.problems, options.seed_given, options.start])


func _test_seed() -> void:
	var options: LaunchOptions = _parse(["--seed=42"])
	_check("launch: --seed=42 gives seed 42", options.problems.is_empty() and options.seed_given
			and options.seed == 42, "%s %d" % [options.problems, options.seed])
	options = _parse(["--seed=-7"])
	_check("launch: --seed=-7 gives seed -7", options.problems.is_empty() and options.seed_given
			and options.seed == -7, "%s %d" % [options.problems, options.seed])


func _test_bad_seed() -> void:
	for arg: String in ["--seed=abc", "--seed=1.5", "--seed=", "--seed", "--seed=12x",
			"--seed=99999999999999999999"]:
		var options: LaunchOptions = _parse([arg])
		_check("launch: %s is one launch.seed problem and no seed" % arg,
				_one_problem(options, "launch.seed:") and not options.seed_given, str(options.problems))


func _test_start_values_so_far() -> void:
	# Story 1.2: `night` is the one --start value (planning in 1.7; lesson and round in epic 2).
	_check("launch: the --start values are night", LaunchOptions.START_VALUES == [&"night"],
			str(LaunchOptions.START_VALUES))
	var options: LaunchOptions = _parse(["--start=night"])
	_check("launch: --start=night is accepted", options.problems.is_empty() and options.start == &"night",
			str(options.problems))


func _test_bad_start() -> void:
	# An unknown value never starts anything.
	for arg: String in ["--start=nowhere", "--start=", "--start", "--start=NIGHT", "--start=night2"]:
		var options: LaunchOptions = _parse([arg])
		_check("launch: %s is one launch.start problem and the start page" % arg,
				_one_problem(options, "launch.start:") and options.start == &"", str(options.problems))


func _test_trace() -> void:
	var options: LaunchOptions = _parse(["--trace"])
	_check("launch: --trace turns the trace on", options.problems.is_empty() and options.trace, str(options.problems))
	_check("launch: no --trace, no trace", not _parse([]).trace)


func _test_bad_trace() -> void:
	# --trace is a flag: any value is a problem, and the trace stays off.
	for arg: String in ["--trace=x", "--trace=", "--trace=1"]:
		var options: LaunchOptions = _parse([arg])
		_check("launch: %s is one launch.trace problem, trace off" % arg,
				_one_problem(options, "launch.trace:") and not options.trace, str(options.problems))


func _test_show() -> void:
	# Any non-empty lower-snake name; whether the setup exists is the debug tools' check.
	for value: String in ["span_counts", "list", "a1_b", "x"]:
		var options: LaunchOptions = _parse(["--show=" + value])
		_check("launch: --show=%s is taken" % value,
				options.problems.is_empty() and options.show == StringName(value), str(options.problems))


func _test_bad_show() -> void:
	for arg: String in ["--show", "--show=", "--show=Span", "--show=a-b", "--show=a b", "--show=é"]:
		var options: LaunchOptions = _parse([arg])
		_check("launch: %s is one launch.show problem and no show" % arg,
				_one_problem(options, "launch.show:") and options.show == &"", str(options.problems))


func _test_unknown_switch() -> void:
	for arg: String in ["--bogus=1", "--bogus", "bogus", "-seed=1", "--Seed=1"]:
		var options: LaunchOptions = _parse([arg])
		_check("launch: %s is one launch.unknown problem" % arg,
				_one_problem(options, "launch.unknown:") and not options.seed_given, str(options.problems))


func _test_repeated_switch() -> void:
	# A switch given twice is a problem; the first value stands.
	var options: LaunchOptions = _parse(["--seed=1", "--seed=2"])
	_check("launch: --seed twice is one launch.repeated problem, first value kept",
			_one_problem(options, "launch.repeated:") and options.seed == 1, "%s %d" % [options.problems, options.seed])


func _test_bad_then_good_switch() -> void:
	# A bad value is not "the first": the good one after it is taken, and only the bad is listed.
	var options: LaunchOptions = _parse(["--seed=abc", "--seed=5"])
	_check("launch: --seed=abc --seed=5 is one launch.seed problem and seed 5",
			_one_problem(options, "launch.seed:") and options.seed_given and options.seed == 5,
			"%s %d" % [options.problems, options.seed])
	options = _parse(["--seed=5", "--seed=abc"])
	_check("launch: --seed=5 --seed=abc is one launch.repeated problem and seed 5",
			_one_problem(options, "launch.repeated:") and options.seed == 5, "%s %d" % [options.problems, options.seed])
	options = _parse(["--seed=abc", "--seed=5", "--seed=6"])
	_check("launch: a third --seed after a good one is repeated; seed stays 5",
			options.problems.size() == 2 and options.problems[0].begins_with("launch.seed:")
			and options.problems[1].begins_with("launch.repeated:") and options.seed == 5, str(options.problems))


func _test_misplaced_switch() -> void:
	# Typed before `--`, a switch reaches the engine, not the game: say so instead of ignoring it.
	var found: PackedStringArray = LaunchOptions.misplaced(PackedStringArray(["--path", "game", "--seed=3", "--start", "--trace"]))
	_check("launch: --seed=3, --start and --trace before -- are three launch.misplaced problems",
			found.size() == 3 and found[0].begins_with("launch.misplaced: '--seed=3'")
			and found[1].begins_with("launch.misplaced: '--start'")
			and found[2].begins_with("launch.misplaced: '--trace'"), str(found))
	found = LaunchOptions.misplaced(PackedStringArray(["--headless", "--path", "game", "-s", "res://tests/run_tests.gd"]))
	_check("launch: engine arguments alone are no problem", found.is_empty(), str(found))


func _test_problems_do_not_stop_the_rest() -> void:
	var options: LaunchOptions = _parse(["--bogus", "--seed=3", "--start=nowhere", "--trace"])
	_check("launch: good switches still apply beside bad ones",
			options.seed_given and options.seed == 3 and options.trace and options.problems.size() == 2
			and options.problems[0].begins_with("launch.unknown:")
			and options.problems[1].begins_with("launch.start:"), str(options.problems))


func _test_every_row_is_a_switch() -> void:
	# AD-61: one table, one row per switch; story 1.2 has exactly these four.
	var names: Array[String] = []
	for switch_name: String in LaunchOptions.SWITCHES:
		names.append(switch_name)
	names.sort()
	_check("launch: the table has --seed, --show, --start and --trace",
			names == ["--seed", "--show", "--start", "--trace"], str(names))
