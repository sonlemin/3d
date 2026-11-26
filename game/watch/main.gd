## The game's main scene: the flow between screens and nothing else (AD-59). It parses the
## launch switches, registers the input actions, collects the setup problems found at start,
## makes the one WatchSession (there are no autoloads, AD-10) and opens the first screen: the
## title, the night (`--start=night`), planning (`--start=planning`) or a show-me setup
## (`--show=<name>`), which opens the night or planning as the setup says.
## It holds no rule of play and draws nothing; screens report back to it with signals.
##
## The debug tools are loaded by path, never named (boundary 4), and only when run from source
## or in a playtest build, before any screen (AD-25: no load() during play).
extends Node

const TitleScreen := preload("res://watch/screens/title_screen.gd")
const TitleScene := preload("res://watch/screens/title_screen.tscn")
const NightScreen := preload("res://watch/night/night.gd")
const NightScene := preload("res://watch/night/night.tscn")
const PlanningScreen := preload("res://watch/planning/planning.gd")
const PlanningScene := preload("res://watch/planning/planning.tscn")
const DEBUG_TOOLS_PATH: String = "res://watch/debug/debug_tools.gd"
## `--show=list` lists the show-me setups and quits.
const SHOW_LIST: StringName = &"list"

## What a launch opens (choose()).
const OPEN_TITLE: StringName = &"title"
const OPEN_NIGHT: StringName = &"night"
const OPEN_PLANNING: StringName = &"planning"
const OPEN_LIST: StringName = &"list"


## What choose() decided: the screen to open, its night if any, and the problems the choice
## added (the switches' own problems and the debug load's are Main's).
class Choice extends RefCounted:
	var open: StringName = OPEN_TITLE
	var def: NightDef = null
	var problems: PackedStringArray = []


var _session: WatchSession
## The loaded debug tools, or null when debug is not allowed. Kept for the whole run: the
## trace's Callable lives in it.
var _debug: Object = null


func _ready() -> void:
	var options: LaunchOptions = LaunchOptions.from_command_line()
	var problems: PackedStringArray = options.problems.duplicate()
	problems.append_array(InputActions.register())
	var debug_allowed: bool = OS.has_feature("playtest") or OS.has_feature("editor")
	if debug_allowed:
		# A build that left watch/debug/ out has no file to load: a setup problem, not a crash.
		var tools: GDScript = load(DEBUG_TOOLS_PATH) as GDScript if ResourceLoader.exists(DEBUG_TOOLS_PATH) else null
		if tools != null:
			_debug = tools.new()
		else:
			problems.append("launch.no_debug: the debug tools (%s) are missing from this build" % DEBUG_TOOLS_PATH)
	var choice: Choice = choose(options, _debug, debug_allowed)
	problems.append_array(choice.problems)
	if choice.open == OPEN_LIST:
		_debug.call(&"print_show_list")

	_session = WatchSession.new(options, problems)
	# Each setup problem is reported once, here; smoke runs fail on any warning (AD-28).
	for problem: String in problems:
		push_warning(problem)
	if choice.open == OPEN_LIST:
		# The list was asked for, not a screen: quit, failing when the launch had a problem.
		get_tree().quit(0 if problems.is_empty() else 1)
		return
	# Screen changes happen at the end of the frame (AD-51).
	if choice.open == OPEN_NIGHT:
		_show_night.call_deferred(choice.def, options.seed if options.seed_given else _fresh_seed())
	elif choice.open == OPEN_PLANNING:
		# --seed is accepted and unused: nothing in planning is random.
		_show_planning.call_deferred(choice.def)
	else:
		_show_title.call_deferred()


## Which screen the launch opens (DW-30: a test can call this). `debug` is the loaded debug
## tools or null; `debug_allowed` is whether this run may have them (from source or a playtest
## build). --show wins over --start; without the debug tools --show is only a problem and
## --start still stands; an unknown show opens the title. A show-me setup names its screen
## (story 1.7): the debug tools say whether it opens the night or planning. Logs nothing; Main
## reports the problems.
static func choose(options: LaunchOptions, debug: Object, debug_allowed: bool) -> Choice:
	var choice: Choice = Choice.new()
	if not debug_allowed and (not options.show.is_empty() or options.trace):
		choice.problems.append("launch.no_debug: --show and --trace work only from source and in playtest builds")
	var show_name: StringName = options.show if debug != null and debug_allowed else &""
	if not show_name.is_empty() and options.start != &"":
		choice.problems.append("launch.conflict: --show=%s and --start=%s were both given; --show wins"
				% [show_name, options.start])
	if show_name == SHOW_LIST:
		choice.open = OPEN_LIST
	elif not show_name.is_empty():
		var found: Variant = debug.call(&"show_def", show_name)
		if found is NightDef:
			choice.def = found
			choice.open = OPEN_PLANNING if debug.call(&"show_screen", show_name) == OPEN_PLANNING else OPEN_NIGHT
		else:
			choice.problems.append("launch.show: '%s' is not a show-me setup (known: %s)"
					% [show_name, ", ".join(debug.call(&"show_names") as PackedStringArray)])
	elif options.start == &"night":
		choice.def = NightDefs.one_night()
		choice.open = OPEN_NIGHT
	elif options.start == &"planning":
		choice.def = NightDefs.one_night()
		choice.open = OPEN_PLANNING
	return choice


## A seed for a night started without --seed: 0 to 2^32 - 1, so NIGHT_STARTED's seed can be
## typed back as --seed=N (AD-3). A new generator starts from a random state.
static func _fresh_seed() -> int:
	var picker: RandomNumberGenerator = RandomNumberGenerator.new()
	return picker.randi()


func _show_title() -> void:
	EngineGlobals.enter_screen(get_tree(), EngineGlobals.ScreenKind.MENU)
	var title: TitleScreen = TitleScene.instantiate() as TitleScreen
	title.session = _session
	add_child(title)


## The night screen: first person, the mouse captured for mouse look (story 1.3).
func _show_night(def: NightDef, night_seed: int) -> void:
	EngineGlobals.enter_screen(get_tree(), EngineGlobals.ScreenKind.FIRST_PERSON)
	var night: NightScreen = NightScene.instantiate() as NightScreen
	night.setup(_session, def, night_seed)
	add_debug_parts(night, _debug, _session.options)
	add_child(night)


## The planning screen (story 1.7: the overhead read-out of `def`'s span). A menu screen: the
## mouse is visible. It has no debug parts: no trace (nothing ticks) and no aim aid.
func _show_planning(def: NightDef) -> void:
	EngineGlobals.enter_screen(get_tree(), EngineGlobals.ScreenKind.MENU)
	var planning: PlanningScreen = PlanningScene.instantiate() as PlanningScreen
	planning.setup(_session, def)
	add_child(planning)


## The debug tools' parts of a night, asked for by call and never by name (boundary 4): the
## trace with `--trace`, and the temporary aim aid (DW-41, until epic 4's hands) on every night
## that has the tools. `debug` is the loaded debug tools or null. After the night's own
## consumers, so each reads the tick the views have already shown.
static func add_debug_parts(night: NightScreen, debug: Object, options: LaunchOptions) -> void:
	if debug == null:
		return
	if options.trace:
		var trace: Variant = debug.call(&"make_trace")
		if trace is Callable:
			night.add_consumer(trace)
	var aid: Variant = debug.call(&"make_aim_aid")
	if aid is Node:
		night.add_child(aid as Node)
		night.add_consumer(Callable(aid as Node, &"on_tick"))
