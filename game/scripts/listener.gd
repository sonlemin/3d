## First-person listening rig: yaw on this body, pitch on the Camera3D child (which is
## also the audio listener). The tester can only look around; there is no movement.
extends Node3D

## Radians per screen pixel of mouse travel.
@export var mouse_sensitivity: float = 0.0025
@export var max_pitch_degrees: float = 80.0

var look_enabled: bool = false

@onready var camera: Camera3D = $Camera3D


## Faces the far bank (-Z), level gaze.
func reset_facing() -> void:
	rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO


## Mouse-look on: the mouse is captured. Off: the mouse is released for the UI.
func set_look_enabled(enabled: bool) -> void:
	look_enabled = enabled
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if enabled else Input.MOUSE_MODE_VISIBLE


## Turns by a mouse delta in screen pixels (left/up = negative x/y).
func look(screen_delta: Vector2) -> void:
	rotate_y(-screen_delta.x * mouse_sensitivity)
	var limit: float = deg_to_rad(max_pitch_degrees)
	camera.rotation.x = clampf(camera.rotation.x - screen_delta.y * mouse_sensitivity, -limit, limit)


func _input(event: InputEvent) -> void:
	if not look_enabled or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	if motion != null:
		look(motion.screen_relative)
