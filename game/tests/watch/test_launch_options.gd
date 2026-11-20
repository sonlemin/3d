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
	_check("launch: no switches -> no problems, no seed, start page",
			options.problems.is_empty() and not options.seed_given and options.start == &"",
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
	# Story 1.1: no --start value exists yet (night arrives in story 1.2). Written literally.
	_check("launch: no --start value exists yet", LaunchOptions.START_VALUES.is_empty(),
			str(LaunchOptions.START_VALUES))
	for value: StringName in LaunchOptions.START_VALUES:
		var options: LaunchOptions = _parse(["--start=" + value])
		_check("launch: --start=%s is accepted" % value,
				options.problems.is_empty() and options.start == value, str(options.problems))


func _test_bad_start() -> void:
	# `night` is not a value until story 1.2; an unknown value never starts anything.
	for arg: String in ["--start=night", "--start=", "--start", "--start=NIGHT"]:
		var options: LaunchOptions = _parse([arg])
		_check("launch: %s is one launch.start problem and the start page" % arg,
				_one_problem(options, "launch.start:") and options.start == &"", str(options.problems))


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


func _test_problems_do_not_stop_the_rest() -> void:
	var options: LaunchOptions = _parse(["--bogus", "--seed=3", "--start=nowhere"])
	_check("launch: good switches still apply beside bad ones",
			options.seed_given and options.seed == 3 and options.problems.size() == 2
			and options.problems[0].begins_with("launch.unknown:")
			and options.problems[1].begins_with("launch.start:"), str(options.problems))


func _test_every_row_is_a_switch() -> void:
	# AD-61: one table, one row per switch; story 1.1 has exactly these two.
	var names: Array[String] = []
	for switch_name: String in LaunchOptions.SWITCHES:
		names.append(switch_name)
	names.sort()
	_check("launch: the table has --seed and --start", names == ["--seed", "--start"], str(names))
