## The game's main scene: the flow between screens and nothing else (AD-59). It parses the
## launch switches, registers the input actions, collects the setup problems found at start,
## makes the one WatchSession (there are no autoloads, AD-10) and opens the first screen: the
## title, the night (`--start=night`) or a show-me setup (`--show=<name>`).
## It holds no rule of play and draws nothing; screens report back to it with signals.
##
## The debug tools are loaded by path, never named (boundary 4), and only when run from source
## or in a playtest build, before any screen (AD-25: no load() during play).
extends Node

const TitleScreen := preload("res://watch/screens/title_screen.gd")
const TitleScene := preload("res://watch/screens/title_screen.tscn")
const NightScene := preload("res://watch/night/night.tscn")
const DEBUG_TOOLS_PATH: String = "res://watch/debug/debug_tools.gd"
## `--show=list` lists the show-me setups and quits.
const SHOW_LIST: StringName = &"list"

var _session: WatchSession
## The loaded debug tools, or null when debug is not allowed. Kept for the whole run: the
## trace's Callable lives in it.
var _debug: Object = null


func _ready() -> void:
	var options: LaunchOptions = LaunchOptions.from_command_line()
	var problems: PackedStringArray = options.problems.duplicate()
	problems.append_array(InputActions.register())
	if OS.has_feature("playtest") or OS.has_feature("editor"):
		_debug = (load(DEBUG_TOOLS_PATH) as GDScript).new()
	elif not options.show.is_empty() or options.trace:
		problems.append("launch.no_debug: --show and --trace work only from source and in playtest builds")

	if _debug != null and options.show == SHOW_LIST:
		_debug.call(&"print_show_list")
		get_tree().quit(0)
		return

	var def: NightDef = null
	if _debug != null and not options.show.is_empty():
		if options.start != &"":
			problems.append("launch.conflict: --show=%s and --start=%s were both given; --show wins"
					% [options.show, options.start])
		var found: Variant = _debug.call(&"show_def", options.show)
		if found is NightDef:
			def = found
		else:
			problems.append("launch.show: '%s' is not a show-me setup (known: %s)"
					% [options.show, ", ".join(_debug.call(&"show_names") as PackedStringArray)])
	elif options.show.is_empty() and options.start == &"night":
		def = NightDefs.one_night()

	_session = WatchSession.new(options, problems)
	# Each setup problem is reported once, here; smoke runs fail on any warning (AD-28).
	for problem: String in problems:
		push_warning(problem)
	# Screen changes happen at the end of the frame (AD-51).
	if def != null:
		var night_seed: int = options.seed if options.seed_given else RandomNumberGenerator.new().seed
		_show_night.call_deferred(def, night_seed)
	else:
		_show_title.call_deferred()


func _show_title() -> void:
	EngineGlobals.enter_screen(get_tree(), EngineGlobals.ScreenKind.MENU)
	var title: TitleScreen = TitleScene.instantiate() as TitleScreen
	title.session = _session
	add_child(title)


## The night screen. The mouse stays free until mouse look arrives in story 1.3, which makes
## this a FIRST_PERSON screen.
func _show_night(def: NightDef, night_seed: int) -> void:
	EngineGlobals.enter_screen(get_tree(), EngineGlobals.ScreenKind.MENU)
	var night: Node3D = NightScene.instantiate() as Node3D
	night.call(&"setup", _session, def, night_seed)
	if _debug != null and _session.options.trace:
		night.call(&"add_consumer", _debug.call(&"make_trace"))
	add_child(night)
