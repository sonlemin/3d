## The warden's node (AD-44, AD-52, AD-67): first-person eyes on the sim's warden. It reads the
## keys and the mouse and hands the night screen a move wish and a view; where the feet may go is
## WardenRules', never this node's. Yaw turns this node, pitch its Camera3D child, as the ear
## test's listener does (nothing is shared with it).
##
## Mouse look is not a rule (AD-52): the view turns at once on mouse motion, between ticks. The
## position follows the sim through a TickBlend. No bob and no roll (EXPERIENCE.md, Accessibility
## Floor): the camera's local position is only ever (0, EYE_HEIGHT, 0) and its roll only ever 0;
## both are written by start_at() alone, and look() turns nothing but yaw and pitch. The view is
## the player's: the one time the game turns it is the catch at a fall (on_tick()).
class_name Warden
extends Node3D

## Radians per screen pixel of mouse travel: the ear test's value (listener.gd). A setting in
## epic 5 (UX-25); a named constant until then, not a rule.
const LOOK_RADIANS_PER_PIXEL: float = 0.0025
## How far up or down the view can tilt, in degrees: the ear test's value (listener.gd).
const MAX_PITCH_DEGREES: float = 80.0
## AD-67: yaw 0 faces the far pier (-Z); this faces the town (+Z), the way a climb back goes.
const TOWN_YAW: float = PI
# Field of view: the camera's default 75 degrees, also the ear test's. A setting in epic 5 (UX-39).

var _blend: TickBlend = TickBlend.new()
## Radians, AD-67: yaw 0 faces -Z and positive turns left, kept in -pi to pi; pitch positive up.
var _yaw: float = 0.0
var _pitch: float = 0.0
## True once start_at() has run. A night scene opened on its own (no setup(), no input actions
## registered) takes no input at all, as the night screen itself does not tick.
var _started: bool = false
## True between the click that takes the mouse back and that click's release, so the release
## is swallowed with its press and no hand sees half a click.
var _swallow_release: bool = false


## Where a night starts (AC 1): on the sim's warden, facing the far pier, the blend snapped.
func start_at(sim: NightSim) -> void:
	_blend.snap(sim.warden.position)
	position = sim.warden.position
	_yaw = 0.0
	_pitch = 0.0
	rotation = Vector3.ZERO
	var camera: Camera3D = _camera()
	camera.position = Vector3(0.0, WardenConstants.EYE_HEIGHT, 0.0)
	camera.rotation = Vector3.ZERO
	_started = true
	_swallow_release = false


## A consumer of the night (`on_tick(events, sim)`): the sim's new position joins the blend. The
## catch at a fall and the end of the climb back (story 1.5 D3) are cuts, and so is every move
## while climbing (the edge hung from fell, and the feet went to the next one): the blend snaps, so
## the view jumps rather than sliding through the gap. Every other move, D2's step back too, blends.
## At the catch the view also cuts to face the edge caught (code review 2026-11-22, Sonlm): toward
## the town, level, so the deck is at eye height and not the gap. Once only: the player looks
## freely after it, and nothing else ever turns the view for them.
func on_tick(events: Array[NightEvent], sim: NightSim) -> void:
	var cut: bool = not WardenRules.walking(sim)
	for event: NightEvent in events:
		if event.kind == NightEvent.Kind.WARDEN_CAUGHT:
			_face(TOWN_YAW, 0.0)
			cut = true
		elif event.kind == NightEvent.Kind.WARDEN_CLIMBED:
			cut = true
	if cut:
		_blend.snap(sim.warden.position)
	else:
		_blend.push(sim.warden.position)


func _process(_delta: float) -> void:
	position = _blend.value(Engine.get_physics_interpolation_fraction())


## Turns the view by a mouse move in screen pixels (right and down are positive), at once.
func look(delta: Vector2) -> void:
	var limit: float = deg_to_rad(MAX_PITCH_DEGREES)
	_yaw = wrapf(_yaw - delta.x * LOOK_RADIANS_PER_PIXEL, -PI, PI)
	_pitch = clampf(_pitch - delta.y * LOOK_RADIANS_PER_PIXEL, -limit, limit)
	rotation.y = _yaw
	_camera().rotation.x = _pitch


## Sets the view outright: yaw on the node, pitch on its camera.
func _face(to_yaw: float, to_pitch: float) -> void:
	_yaw = to_yaw
	_pitch = to_pitch
	rotation.y = _yaw
	_camera().rotation.x = _pitch


func yaw() -> float:
	return _yaw


func pitch() -> float:
	return _pitch


## This tick's move wish in world X/Z, from the W A S D actions (by key position, AD-20).
func move_direction() -> Vector2:
	var keys: Vector2 = Input.get_vector(&"watch_move_left", &"watch_move_right", &"watch_move_forward",
			&"watch_move_back")
	return wish_from(keys, _yaw)


## Pure: `keys` as Input.get_vector gives them (x right, y back) turned by `yaw` into world X/Z.
## At yaw 0 forward is (0, -1); at yaw pi/2 (turned left) it is (-1, 0). Never longer than 1.
static func wish_from(keys: Vector2, yaw_now: float) -> Vector2:
	return keys.rotated(-yaw_now).limit_length(1.0)


## The blend the node is drawn from, for tests.
func blend() -> TickBlend:
	return _blend


## Mouse look while the mouse is captured. Story 1.3 decision D2, until epic 5's pause overlay
## replaces it: Esc frees the mouse (the night keeps running and walking still works), and a
## left click while it is free captures it again and goes nowhere else, press and release both.
## Whether the mouse is captured is asked of EngineGlobals (AD-51), not of the engine.
func _unhandled_input(event: InputEvent) -> void:
	if not _started:
		return
	var captured: bool = EngineGlobals.mouse_captured()
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT and not button.pressed and _swallow_release:
		_swallow_release = false
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and captured:
		look((event as InputEventMouseMotion).screen_relative)
		get_viewport().set_input_as_handled()
	elif captured and event.is_action_pressed(&"watch_pause"):
		EngineGlobals.capture_mouse(false)
		get_viewport().set_input_as_handled()
	elif button != null and not captured and button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
		EngineGlobals.capture_mouse(true)
		_swallow_release = true
		get_viewport().set_input_as_handled()


func _camera() -> Camera3D:
	return $Camera3D as Camera3D
