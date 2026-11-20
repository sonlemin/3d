## The game's main scene: the flow between screens and nothing else (AD-59). It parses the
## launch switches, registers the input actions, collects the setup problems found at start,
## makes the one WatchSession (there are no autoloads, AD-10) and opens the first screen.
## It holds no rule of play and draws nothing; screens report back to it with signals.
## Today the only screen is the title; the lesson, planning, the night and dawn join later.
extends Node

const TitleScreen := preload("res://watch/screens/title_screen.gd")
const TitleScene := preload("res://watch/screens/title_screen.tscn")

var _session: WatchSession


func _ready() -> void:
	var options: LaunchOptions = LaunchOptions.from_command_line()
	var problems: PackedStringArray = options.problems.duplicate()
	problems.append_array(InputActions.register())
	_session = WatchSession.new(options, problems)
	# Each setup problem is reported once, here; smoke runs fail on any warning (AD-28).
	for problem: String in problems:
		push_warning(problem)
	# Screen changes happen at the end of the frame (AD-51).
	_show_title.call_deferred()


func _show_title() -> void:
	EngineGlobals.enter_screen(get_tree(), EngineGlobals.ScreenKind.MENU)
	var title: TitleScreen = TitleScene.instantiate() as TitleScreen
	title.session = _session
	add_child(title)
