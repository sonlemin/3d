## The warden's node (AD-44, AD-52, AD-67): first-person eyes on the sim's warden. It reads the
## keys and the mouse and hands the night screen a move wish and a view; where the feet may go is
## WardenRules', never this node's. Yaw turns this node, pitch its Camera3D child, as the ear
## test's listener does (nothing is shared with it).
##
## Mouse look is not a rule (AD-52): the view turns at once on mouse motion, between ticks. The
## position follows the sim through a TickBlend. No bob and no roll (EXPERIENCE.md, Accessibility
## Floor): the camera's local position is set once and its rotation.z is never written.
class_name Warden
extends Node3D

## Radians per screen pixel of mouse travel: the ear test's value (listener.gd). A setting in
## epic 5 (UX-25); a named constant until then, not a rule.
const LOOK_RADIANS_PER_PIXEL: float = 0.0025
## How far up or down the view can tilt, in degrees: the ear test's value (listener.gd).
const MAX_PITCH_DEGREES: float = 80.0
# Field of view: the camera's default 75 degrees, also the ear test's. A setting in epic 5 (UX-39).

var _blend: TickBlend = TickBlend.new()
## Radians, AD-67: yaw 0 faces -Z and positive turns left, kept in -pi to pi; pitch positive up.
var _yaw: float = 0.0
var _pitch: float = 0.0


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


## A consumer of the night (`on_tick(events, sim)`): the sim's new position joins the blend.
func on_tick(_events: Array[NightEvent], sim: NightSim) -> void:
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
## left click while it is free captures it again and goes nowhere else.
func _unhandled_input(event: InputEvent) -> void:
	var captured: bool = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and captured:
		look((event as InputEventMouseMotion).screen_relative)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"watch_pause") and captured:
		EngineGlobals.capture_mouse(false)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and not captured:
		var button: InputEventMouseButton = event as InputEventMouseButton
		if button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
			EngineGlobals.capture_mouse(true)
			get_viewport().set_input_as_handled()


func _camera() -> Camera3D:
	return $Camera3D as Camera3D
