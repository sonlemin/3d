## TickBlend (AD-44): a moving view is drawn between the last two ticks the sim produced.
extends TestCase


func _near(a: Vector3, b: Vector3) -> bool:
	return a.distance_to(b) < 0.001


func _test_snap() -> void:
	var blend: TickBlend = TickBlend.new()
	var a: Vector3 = Vector3(1.0, 0.0, -4.0)
	blend.snap(a)
	_check("blend: after snap(a), value is a at 0, 0.5 and 1",
			_near(blend.value(0.0), a) and _near(blend.value(0.5), a) and _near(blend.value(1.0), a))


func _test_push_blends_the_last_two() -> void:
	var blend: TickBlend = TickBlend.new()
	var a: Vector3 = Vector3(0.0, 0.0, 2.0)
	var b: Vector3 = Vector3(1.0, 0.0, 1.0)
	blend.snap(a)
	blend.push(b)
	_check("blend: value(0) is the older tick", _near(blend.value(0.0), a), str(blend.value(0.0)))
	_check("blend: value(1) is the newest tick", _near(blend.value(1.0), b), str(blend.value(1.0)))
	_check("blend: value(0.5) is the midpoint", _near(blend.value(0.5), Vector3(0.5, 0.0, 1.5)), str(blend.value(0.5)))
	_check("blend: a fraction below 0 is clamped", _near(blend.value(-1.0), a), str(blend.value(-1.0)))
	_check("blend: a fraction above 1 is clamped", _near(blend.value(2.5), b), str(blend.value(2.5)))
	var c: Vector3 = Vector3(2.0, 0.0, 0.0)
	blend.push(c)
	_check("blend: the next push drops the oldest", _near(blend.value(0.0), b) and _near(blend.value(1.0), c))


func _test_same_position_twice() -> void:
	var blend: TickBlend = TickBlend.new()
	var a: Vector3 = Vector3(0.0, 0.0, -3.0)
	blend.snap(Vector3.ZERO)
	blend.push(a)
	blend.push(a)
	_check("blend: pushing the same position twice gives no movement",
			_near(blend.value(0.0), a) and _near(blend.value(0.7), a) and _near(blend.value(1.0), a))
