## The night screen (AD-2, AD-30): builds the night's NightSim and its views, ticks the sim once
## per physics tick and hands every tick's events, in order, to each consumer. It holds no rule.
## The scene is thin (AD-62): a camera, a light and the environment; everything on the span is
## built in code and placed by asking SpanGeometry.
##
## Story 1.2: no warden yet. The camera stands still at the warden's start, at eye height,
## facing the far pier; story 1.3 replaces it with warden.gd. Gray boxes, plain light and a
## black sky (gaps read as the abyss) until epics 2 and 7.
extends Node3D

var _session: WatchSession
var _faults: WatchFaults
var _sim: NightSim
var _consumers: Array[Callable] = []


## Called by Main before the screen is added to the tree.
func setup(session: WatchSession, def: NightDef, night_seed: int) -> void:
	_session = session
	_faults = WatchFaults.new()
	_sim = NightSim.new(def, night_seed, _faults)
	var span_view: SpanView = SpanView.new()
	span_view.name = "SpanView"
	add_child(span_view)
	add_consumer(span_view.on_tick)
	var camera: Camera3D = $Camera3D
	camera.position = _sim.geometry.warden_start() + Vector3(0.0, SpanGeometry.EYE_HEIGHT, 0.0)


## A consumer is `(events: Array[NightEvent], sim: NightSim)`, called after every tick in the
## order added. It reads state and never calls the sim while handling events.
func add_consumer(consumer: Callable) -> void:
	_consumers.append(consumer)


func _physics_process(_delta: float) -> void:
	_sim.set_move(Vector2.ZERO)
	_sim.set_view(0.0, 0.0)
	var events: Array[NightEvent] = _sim.advance()
	for consumer: Callable in _consumers:
		consumer.call(events, _sim)
