## The temporary aim aid (DW-41; Sonlm, 2026-11-21): a debug mark at the centre of the night view.
## Its reading must never drift from the rules: it says "a button would start a hold" exactly
## when a press of that button, taken on the next tick, emits HOLD_STARTED. Also: the word for
## what is in reach, the ring's progress, that it takes no input, and that Main adds it to a night
## only when the debug tools are there. What it looks like, and that the dot sits on the view
## line, are checked on screen.
## Spec values written literally: GD-19: strip a plank 2 s = 120 ticks, a rail 3 s = 180.
extends WatchTest

const MainScript := preload("res://watch/main.gd")
const NightScreen := preload("res://watch/night/night.gd")
const NightScene := preload("res://watch/night/night.tscn")

const HAMMER: NightTypes.HandInput = NightTypes.HandInput.HAMMER
const ROPE: NightTypes.HandInput = NightTypes.HandInput.ROPE
const USE: NightTypes.HandInput = NightTypes.HandInput.USE
const FOREARM: NightTypes.HandInput = NightTypes.HandInput.FOREARM
const INPUTS: Array[NightTypes.HandInput] = [HAMMER, ROPE, USE]
## Looking down at the deck ahead (test_hands.gd): the line lands 0.622 m ahead, inside the reach.
const DOWN: float = -1.2
## From x -2.2 facing -X, aimed at the left rope's centre (test_look.gd).
const AT_RAIL: float = -1.107
## Above the horizon: nothing in reach.
const SKY: float = 0.5


## A 6-section night with `planks` taken off at the start (into the hand), the warden at `along`,
## walked `sideways` ticks toward -X, then aimed and ticked once so the aim is in place.
func _ready_at(along: float, planks: Dictionary[int, int] = {}, yaw: float = 0.0, pitch: float = DOWN,
		sideways: int = 0) -> NightSim:
	var start: StartState = StartState.new()
	start.warden_along = along
	start.planks = planks
	var sim: NightSim = _sim_with(_def_with(start), 1)
	for i: int in sideways:
		sim.set_move(Vector2(-1.0, 0.0))
		sim.advance()
	sim.set_move(Vector2.ZERO)
	sim.set_view(yaw, pitch)
	sim.advance()
	return sim


func _at_rail(along: float, planks: Dictionary[int, int] = {}) -> NightSim:
	return _ready_at(along, planks, PI / 2.0, AT_RAIL, 60)


func _press(sim: NightSim, input: NightTypes.HandInput) -> void:
	sim.command(NightCommand.press(input))


func _starts(sim: NightSim, input: NightTypes.HandInput) -> bool:
	_press(sim, input)
	for event: NightEvent in sim.advance():
		if event.kind == NightEvent.Kind.HOLD_STARTED:
			return true
	return false


## The named situations the aid is checked in. Each call builds a fresh sim, so one copy can be
## read and its twin pressed.
func _cases() -> Dictionary[String, Callable]:
	return {
		"a full deck, nothing in hand": func() -> NightSim: return _ready_at(17.5),
		"a full deck, a plank in hand": func() -> NightSim: return _ready_at(17.5, {2: 7}),
		"a deck with room, a plank in hand": func() -> NightSim: return _ready_at(17.5, {4: 7}),
		"a bare deck, its 8 planks in hand": func() -> NightSim: return _ready_at(20.4, {4: 0}),
		"the town section at its last 4, planks in hand": func() -> NightSim: return _ready_at(27.5, {6: 4}),
		"a standing rail": func() -> NightSim: return _at_rail(17.5),
		"a standing rail, a plank in hand": func() -> NightSim: return _at_rail(17.5, {2: 7}),
		"the sky": func() -> NightSim: return _ready_at(17.5, {}, 0.0, SKY),
		"the sky, a plank in hand": func() -> NightSim: return _ready_at(17.5, {2: 7}, 0.0, SKY),
		"the forearm up over a full deck": func() -> NightSim:
			var sim: NightSim = _ready_at(17.5)
			_press(sim, FOREARM)
			sim.advance()
			return sim,
		"a hold running": func() -> NightSim:
			var sim: NightSim = _ready_at(17.5, {2: 7})
			_press(sim, HAMMER)
			_advance(sim, 10)
			return sim,
		"Press once, inside the grace of a strip": func() -> NightSim: return _after_a_press_once_strip(5),
		"Press once, the last tick of the grace": func() -> NightSim: return _after_a_press_once_strip(14),
		"Press once, the tick after the grace": func() -> NightSim: return _after_a_press_once_strip(15),
		"Hold mode, just after a strip": func() -> NightSim:
			var sim: NightSim = _ready_at(17.5)
			_press(sim, HAMMER)
			_advance(sim, 121)
			return sim,
	}


## A strip of a full deck completed in Press once, then `wait` more ticks. A press taken on the
## next tick lands `wait` + 1 ticks after the completion (the grace is 15).
func _after_a_press_once_strip(wait: int) -> NightSim:
	var sim: NightSim = _ready_at(17.5)
	sim.command(NightCommand.set_option(NightTypes.Option.HOLDS, NightTypes.Holds.PRESS_ONCE))
	_press(sim, HAMMER)
	_advance(sim, 121)
	_advance(sim, wait)
	return sim


func _test_ready_exactly_when_a_press_would_start() -> void:
	var cases: Dictionary[String, Callable] = _cases()
	var started: int = 0
	var not_started: int = 0
	for case_name: String in cases:
		for input: NightTypes.HandInput in INPUTS:
			var said: bool = AimAid.would_start(input, cases[case_name].call() as NightSim)
			var did: bool = _starts(cases[case_name].call() as NightSim, input)
			started += 1 if did else 0
			not_started += 0 if did else 1
			_check("aim: %s, %s: the aid says what the press does" % [case_name, NightTypes.HandInput.find_key(input)],
					said == did, "said %s, did %s" % [said, did])
	# The table has both answers many times over, or the check above proves little.
	_check("aim: the cases hold starts and non-starts alike", started >= 8 and not_started >= 20,
			"%d started, %d did not" % [started, not_started])
	_check("aim: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_the_grace_is_the_button_s_own() -> void:
	# Story 1.4 code review: only the button whose hold has just completed waits; E acts at once.
	var sim: NightSim = _after_a_press_once_strip(5)
	_check("aim: inside the grace the hammer would not start, E would",
			not AimAid.would_start(HAMMER, sim) and AimAid.would_start(USE, sim))
	_check("aim: so the dot stays bright", AimAid.reading(sim) == AimAid.Reading.READY)
	sim = _after_a_press_once_strip(15)
	_check("aim: after the grace the hammer would start again", AimAid.would_start(HAMMER, sim))


func _test_readings_and_words() -> void:
	var sim: NightSim = _ready_at(17.5)
	_check("aim: a full deck in reach is READY, 'deck'", AimAid.reading(sim) == AimAid.Reading.READY
			and AimAid.word_of(sim) == "deck", "%d %s" % [AimAid.reading(sim), AimAid.word_of(sim)])
	sim = _at_rail(17.5)
	_check("aim: a standing rail in reach is READY, 'rail'", AimAid.reading(sim) == AimAid.Reading.READY
			and AimAid.word_of(sim) == "rail", "%d %s" % [AimAid.reading(sim), AimAid.word_of(sim)])
	sim = _ready_at(17.5, {}, 0.0, SKY)
	_check("aim: the sky is NOTHING, no word", AimAid.reading(sim) == AimAid.Reading.NOTHING
			and AimAid.word_of(sim) == "", "%d %s" % [AimAid.reading(sim), AimAid.word_of(sim)])
	# Looking along the span from the eye (1.6 m up), the deck is met far past the 2 m reach.
	sim = _ready_at(17.5, {}, 0.0, -0.2)
	_check("aim: the deck ahead, out of reach, is NOTHING", AimAid.reading(sim) == AimAid.Reading.NOTHING
			and AimAid.word_of(sim) == "", "%d %s" % [AimAid.reading(sim), AimAid.word_of(sim)])
	# In reach with no button able to start. With no part lost, some button always can at a deck
	# (a strip, or a re-lay of what was stripped), so today only the raised forearm gives this.
	sim = _ready_at(17.5)
	_press(sim, FOREARM)
	sim.advance()
	_check("aim: with the forearm up a deck is IN_REACH, 'deck', not READY",
			AimAid.reading(sim) == AimAid.Reading.IN_REACH and AimAid.word_of(sim) == "deck",
			"%d %s" % [AimAid.reading(sim), AimAid.word_of(sim)])


func _test_a_hold_shows_its_own_target() -> void:
	# A strip of section 4's deck, then the view turns to the sky: the ring and the word stay the
	# hold's (looking around never cancels a hold).
	var sim: NightSim = _ready_at(17.5)
	_press(sim, HAMMER)
	sim.advance()
	sim.set_view(0.0, SKY)
	# 60 more ticks: half of the 120.
	_advance(sim, 60)
	_check("aim: a hold is HOLDING", AimAid.reading(sim) == AimAid.Reading.HOLDING)
	_check("aim: with the word of the hold's target, not of the sky", AimAid.word_of(sim) == "deck"
			and sim.look.kind == LookTarget.Kind.NONE, AimAid.word_of(sim))
	var aid: AimAid = AimAid.new()
	root.add_child(aid)
	aid.on_tick([], sim)
	_check("aim: the ring is half closed 60 ticks into a 120-tick strip", is_equal_approx(aid.shown_progress(), 0.5)
			and aid.shown_reading() == AimAid.Reading.HOLDING and aid.shown_word() == "deck", str(aid.shown_progress()))
	_advance(sim, 60)
	aid.on_tick([], sim)
	_check("aim: the hold done, the ring is gone and the sky shows nothing",
			aid.shown_reading() == AimAid.Reading.NOTHING and aid.shown_progress() == 0.0 and aid.shown_word() == "",
			"%d %f" % [aid.shown_reading(), aid.shown_progress()])
	aid.free()


func _controls_under(node: Node) -> Array[Control]:
	var out: Array[Control] = []
	if node is Control:
		out.append(node as Control)
	for child: Node in node.get_children():
		out.append_array(_controls_under(child))
	return out


## A night screen on a test def under `root`, ticked by the test. Free it with free().
func _night() -> NightScreen:
	var night: NightScreen = NightScene.instantiate() as NightScreen
	night.setup(WatchSession.new(LaunchOptions.new(), PackedStringArray()), _def_with(StartState.new()), 1)
	root.add_child(night)
	night.set_physics_process(false)
	return night


func _left_click(pressed: bool) -> InputEventMouseButton:
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = pressed
	return click


func _test_main_adds_it_with_the_debug_tools_only() -> void:
	InputActions.register()
	var plain: NightScreen = _night()
	var before: int = plain._consumers.size()
	MainScript.add_debug_parts(plain, null, LaunchOptions.new())
	_check("aim: without the debug tools a night gets no aid and no consumer",
			plain.get_node_or_null("AimAid") == null and plain._consumers.size() == before)
	plain.free()

	var night: NightScreen = _night()
	MainScript.add_debug_parts(night, DebugTools.new(), LaunchOptions.new())
	var aid: AimAid = night.get_node_or_null("AimAid") as AimAid
	_check("aim: with them, the night has the aid", aid != null)
	if aid != null:
		_check("aim: as its last consumer, and no trace without --trace",
				night._consumers.size() == before + 1 and night._consumers[before] == Callable(aid, &"on_tick"),
				str(night._consumers))
		var controls: Array[Control] = _controls_under(aid)
		_check("aim: none of its controls takes the mouse", not controls.is_empty()
				and controls.all(func(c: Control) -> bool: return c.mouse_filter == Control.MOUSE_FILTER_IGNORE))
		# The night's own tick drives it: the landing looks along the span, nothing in reach.
		night._physics_process(1.0 / 60.0)
		_check("aim: the night's tick reaches it", aid.shown_reading() == AimAid.Reading.NOTHING)
		# A click still reaches the hands through it.
		EngineGlobals.enter_screen(root.get_tree(), EngineGlobals.ScreenKind.FIRST_PERSON)
		root.push_input(_left_click(true))
		var sim: NightSim = night._sim
		sim.advance()
		_check("aim: a click passes the aid and is the hammer's press", sim.commands.size() == 1
				and sim.commands[0].kind == NightCommand.Kind.PRESS and sim.commands[0].input == HAMMER,
				str(sim.commands.size()))
		EngineGlobals.enter_screen(root.get_tree(), EngineGlobals.ScreenKind.MENU)
	night.free()

	var traced: NightScreen = _night()
	MainScript.add_debug_parts(traced, DebugTools.new(), LaunchOptions.parse(["--trace"]))
	_check("aim: with --trace, the trace then the aid", traced._consumers.size() == before + 2)
	traced.free()
