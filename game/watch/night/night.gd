## The night screen (AD-2, AD-30): builds the night's NightSim and its views, ticks the sim once
## per physics tick and hands every tick's events, in order, to each consumer. It holds no rule.
## The scene is thin (AD-62): the warden (with its camera), a light and the environment;
## everything on the span is built in code and placed by asking SpanGeometry.
##
## Each tick (architecture, Novel Pattern 3): the warden's move wish and view go in, the sim
## advances, and the consumers read what came out: the span view, the warden's node, which
## follows the sim's position through its TickBlend, then the forearm (HandsView). Between ticks,
## each night button's press and release goes in as a NightCommand: button states, never
## meanings (the sim decides what a press does). Gray boxes, plain light and a black sky (gaps
## read as the abyss) until epics 2 and 7.
extends Node3D

var _session: WatchSession
var _faults: WatchFaults
var _sim: NightSim
var _consumers: Array[Callable] = []
var _warden: Warden
var _hands: HandsView


## Called by Main before the screen is added to the tree.
func setup(session: WatchSession, def: NightDef, night_seed: int) -> void:
	_session = session
	_faults = WatchFaults.new()
	_sim = NightSim.new(def, night_seed, _faults)
	var span_view: SpanView = SpanView.new()
	span_view.name = "SpanView"
	add_child(span_view)
	add_consumer(span_view.on_tick)
	_warden = $Warden as Warden
	_warden.start_at(_sim)
	add_consumer(_warden.on_tick)
	_hands = HandsView.new()
	_hands.name = "Hands"
	$Warden/Camera3D.add_child(_hands)
	add_consumer(_hands.on_tick)


## A consumer is `(events: Array[NightEvent], sim: NightSim)`, called after every tick in the
## order added. It reads state and never calls the sim while handling events.
func add_consumer(consumer: Callable) -> void:
	_consumers.append(consumer)


## Opened without setup() (the scene run on its own from the editor): nothing to tick.
func _ready() -> void:
	if _sim == null:
		push_warning("night.no_setup: the night screen was opened without setup(); start it with --start=night")
		set_physics_process(false)


func _physics_process(_delta: float) -> void:
	_sim.set_move(_warden.move_direction())
	_sim.set_view(_warden.yaw(), _warden.pitch())
	var events: Array[NightEvent] = _sim.advance()
	for consumer: Callable in _consumers:
		consumer.call(events, _sim)


## Architecture, Novel Pattern 3: input becomes a command, nothing more. Only once setup() has
## run. The warden's node sees an event first (a child, in reverse tree order): the click that
## takes the mouse back is handled there (story 1.3 D2) and never reaches this. Nothing here is
## marked handled. A key's echo is not a press (is_action_pressed ignores echoes).
func _unhandled_input(event: InputEvent) -> void:
	if _sim == null:
		return
	for input: NightTypes.HandInput in InputActions.NIGHT_INPUTS:
		var action: StringName = InputActions.action_of(input)
		if event.is_action_pressed(action):
			_sim.command(NightCommand.press(input))
		elif event.is_action_released(action):
			_sim.command(NightCommand.release(input))
