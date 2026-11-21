## The night screen (AD-2, AD-30): builds the night's NightSim and its views, ticks the sim once
## per physics tick and hands every tick's events, in order, to each consumer. It holds no rule.
## The scene is thin (AD-62): the warden (with its camera), a light and the environment;
## everything on the span is built in code and placed by asking SpanGeometry.
##
## Each tick (architecture, Novel Pattern 3): the warden's move wish and view go in, the sim
## advances, and the consumers read what came out: the span view, then the warden's node, which
## follows the sim's position through its TickBlend. Gray boxes, plain light and a black sky (gaps
## read as the abyss) until epics 2 and 7.
extends Node3D

var _session: WatchSession
var _faults: WatchFaults
var _sim: NightSim
var _consumers: Array[Callable] = []
var _warden: Warden


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
