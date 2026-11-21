## A blend helper (AD-44): a view that moves holds one and is drawn between the last two
## positions the sim produced, so the 60-a-second tick never shows as a step. The view is drawn
## one tick (16.7 ms) behind the sim, the usual price of blending. Project-wide physics
## interpolation stays off. Not a node: the fraction comes in as a parameter, so tests can run it
## headless.
class_name TickBlend
extends RefCounted

var _older: Vector3 = Vector3.ZERO
var _newest: Vector3 = Vector3.ZERO


## After a tick: the newest becomes the older one, `position` the newest.
func push(position: Vector3) -> void:
	_older = _newest
	_newest = position


## A teleport or a newly made view: no blend from where it was.
func snap(position: Vector3) -> void:
	_older = position
	_newest = position


## Where to draw at `fraction` of the way from the older tick to the newest, clamped to 0 to 1.
## The night passes Engine.get_physics_interpolation_fraction().
func value(fraction: float) -> Vector3:
	return _older.lerp(_newest, clampf(fraction, 0.0, 1.0))
