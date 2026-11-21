## Main's choice of screen (AD-59, DW-30): which screen a launch opens and the problems it adds,
## through Main.choose(), with the real debug tools or none. The side effects (warnings, quitting,
## opening a screen) stay in Main._ready() and are covered by the smoke runs.
extends TestCase

const MainScript := preload("res://watch/main.gd")


func _choose(args: PackedStringArray, debug: Object, debug_allowed: bool = true) -> MainScript.Choice:
	return MainScript.choose(LaunchOptions.parse(args), debug, debug_allowed)


func _starting(problems: PackedStringArray, prefix: String) -> int:
	return Array(problems).filter(func(p: String) -> bool: return p.begins_with(prefix)).size()


func _test_nothing_opens_the_title() -> void:
	var choice: MainScript.Choice = _choose([], DebugTools.new())
	_check("main: no switch opens the title with no problem",
			choice.open == MainScript.OPEN_TITLE and choice.def == null and choice.problems.is_empty(), str(choice.problems))


func _test_start_night() -> void:
	var choice: MainScript.Choice = _choose(["--start=night"], DebugTools.new())
	_check("main: --start=night opens the one night", choice.open == MainScript.OPEN_NIGHT and choice.def != null
			and choice.def.name == &"one_night" and choice.problems.is_empty(), str(choice.problems))


func _test_show_wins_over_start() -> void:
	var choice: MainScript.Choice = _choose(["--show=walk", "--start=night"], DebugTools.new())
	_check("main: --show and --start: the show's night opens", choice.open == MainScript.OPEN_NIGHT
			and choice.def != null and choice.def.name == &"walk", str(choice.def.name) if choice.def != null else "null")
	_check("main: with exactly one launch.conflict line", choice.problems.size() == 1
			and _starting(choice.problems, "launch.conflict: --show=walk and --start=night") == 1, str(choice.problems))


func _test_unknown_show() -> void:
	var choice: MainScript.Choice = _choose(["--show=nope"], DebugTools.new())
	_check("main: an unknown show opens the title", choice.open == MainScript.OPEN_TITLE and choice.def == null)
	# Story 1.2 and 1.3's setups, written out: the line names every one.
	var named: bool = choice.problems.size() == 1
	for known: String in ["span_counts", "walk", "walk_close"]:
		named = named and choice.problems[0].contains(known)
	_check("main: with one launch.show line naming every known setup", named
			and _starting(choice.problems, "launch.show: 'nope'") == 1, str(choice.problems))


func _test_no_debug() -> void:
	var choice: MainScript.Choice = _choose(["--show=walk", "--start=night"], null, false)
	_check("main: without the debug tools --start still stands", choice.open == MainScript.OPEN_NIGHT
			and choice.def != null and choice.def.name == &"one_night")
	_check("main: with one launch.no_debug line and no conflict", choice.problems.size() == 1
			and _starting(choice.problems, "launch.no_debug") == 1, str(choice.problems))
	choice = _choose(["--show=walk"], null, false)
	_check("main: --show alone without the tools opens the title, one launch.no_debug line",
			choice.open == MainScript.OPEN_TITLE and choice.problems.size() == 1
			and _starting(choice.problems, "launch.no_debug") == 1, str(choice.problems))
	choice = _choose(["--trace"], null, false)
	_check("main: --trace without the tools is a launch.no_debug line too",
			_starting(choice.problems, "launch.no_debug") == 1, str(choice.problems))
	# Allowed but missing from the build: Main reports that once when loading; choose adds nothing.
	choice = _choose(["--show=walk"], null, true)
	_check("main: tools allowed but missing: choose adds no second line", choice.problems.is_empty()
			and choice.open == MainScript.OPEN_TITLE, str(choice.problems))


func _test_show_list() -> void:
	var choice: MainScript.Choice = _choose(["--show=list"], DebugTools.new())
	_check("main: --show=list chooses the list", choice.open == MainScript.OPEN_LIST and choice.def == null
			and choice.problems.is_empty(), str(choice.problems))


func _test_switch_problems_stay_with_the_options() -> void:
	# A switch that is not one is LaunchOptions' problem (Main pushes those itself); choose() must
	# not repeat it.
	var options: LaunchOptions = LaunchOptions.parse(["--nope"])
	_check("main: an unknown switch is one launch.unknown problem of the options", options.problems.size() == 1
			and _starting(options.problems, "launch.unknown: '--nope'") == 1, str(options.problems))
	var choice: MainScript.Choice = MainScript.choose(options, DebugTools.new(), true)
	_check("main: and is not repeated in the choice, which is the title", choice.problems.is_empty()
			and choice.open == MainScript.OPEN_TITLE, str(choice.problems))


func _test_tools_present_but_not_allowed() -> void:
	# The tools are in the build but the build may not use them: --show is refused, not obeyed.
	var choice: MainScript.Choice = _choose(["--show=walk", "--start=night"], DebugTools.new(), false)
	_check("main: tools present but not allowed: --start stands, not the show", choice.open == MainScript.OPEN_NIGHT
			and choice.def != null and choice.def.name == &"one_night", str(choice.open))
	_check("main: with one launch.no_debug line and no conflict", choice.problems.size() == 1
			and _starting(choice.problems, "launch.no_debug") == 1, str(choice.problems))
	choice = _choose(["--show=list"], DebugTools.new(), false)
	_check("main: and --show=list opens the title, not the list", choice.open == MainScript.OPEN_TITLE
			and _starting(choice.problems, "launch.no_debug") == 1, str(choice.problems))
