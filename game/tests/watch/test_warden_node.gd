## The warden's node (AD-44, AD-52, AD-67; story 1.3 AC 1, 4, 6): mouse look turns the view at
## once, with no bob and no roll; the move wish is the keys turned by the yaw; the node follows
## the sim through a TickBlend and never decides where the warden stands. The feel and the "no
## visible step" are M1 (Sonlm's), not checked here.
extends WatchTest

const NightScreen := preload("res://watch/night/night.gd")
const NightScene := preload("res://watch/night/night.tscn")


## A night screen set up on a test def and added under `root`. Free it with free().
func _night(start: StartState = StartState.new()) -> NightScreen:
	var night: NightScreen = NightScene.instantiate() as NightScreen
	night.setup(WatchSession.new(LaunchOptions.new(), PackedStringArray()), _def_with(start), 1)
	root.add_child(night)
	# Ticks are driven by the test, not by the tree.
	night.set_physics_process(false)
	return night


func _warden_of(night: NightScreen) -> Warden:
	return night.get_node("Warden") as Warden


func _camera_of(night: NightScreen) -> Camera3D:
	return night.get_node("Warden/Camera3D") as Camera3D


func _test_starts_on_the_landing() -> void:
	var night: NightScreen = _night()
	var warden: Warden = _warden_of(night)
	var camera: Camera3D = _camera_of(night)
	# AC 1: the one landing's centre is (0, 0, 2) on 6 sections; facing the far pier (-Z).
	_check("node: the warden's node starts at the landing's centre", warden.position.is_equal_approx(Vector3(0.0, 0.0, 2.0)),
			str(warden.position))
	_check("node: yaw and pitch 0", warden.yaw() == 0.0 and warden.pitch() == 0.0)
	_check("node: the camera faces -Z", (-camera.global_basis.z).is_equal_approx(Vector3(0.0, 0.0, -1.0)),
			str(-camera.global_basis.z))
	# D2 of story 1.2: the eye 1.6 m above the feet.
	_check("node: the camera sits 1.6 m above the feet", camera.position.is_equal_approx(Vector3(0.0, 1.6, 0.0)),
			str(camera.position))
	_check("node: the camera is the current one", camera.current)
	night.free()


func _test_look_at_once() -> void:
	var night: NightScreen = _night()
	var warden: Warden = _warden_of(night)
	var camera: Camera3D = _camera_of(night)
	var before: Vector3 = -camera.global_basis.z
	warden.look(Vector2(100.0, 0.0))
	var after: Vector3 = -camera.global_basis.z
	# AC 4: no tick in between. 100 px right at 0.0025 rad/px is 0.25 rad to the right (yaw -0.25).
	_check("node: a mouse move turns the view before any tick", not after.is_equal_approx(before), str(after))
	_check("node: 100 px right is yaw -0.25 (0.0025 rad per pixel, the ear test's)",
			is_equal_approx(warden.yaw(), -0.25), str(warden.yaw()))
	_check("node: turned right, the view leans to +X", after.x > 0.0, str(after))
	# AD-67: yaw positive turns left; the node's own rotation.y has the same sign.
	_check("node: yaw() is the node's rotation.y", is_equal_approx(warden.rotation.y, warden.yaw()))
	warden.look(Vector2(0.0, -100000.0))
	_check("node: looking far up clamps pitch to 80 degrees", is_equal_approx(warden.pitch(), deg_to_rad(80.0)),
			str(rad_to_deg(warden.pitch())))
	warden.look(Vector2(0.0, 100000.0))
	_check("node: and far down to -80 degrees", is_equal_approx(warden.pitch(), deg_to_rad(-80.0)),
			str(rad_to_deg(warden.pitch())))
	warden.look(Vector2(0.0, 20.0))
	_check("node: pitch is the camera's rotation.x", is_equal_approx(camera.rotation.x, warden.pitch()))
	for i: int in 40:
		warden.look(Vector2(1000.0, 37.0))
	_check("node: yaw stays within -pi to pi", warden.yaw() >= -PI and warden.yaw() <= PI, str(warden.yaw()))
	_check("node: no roll after any looks", camera.rotation.z == 0.0 and warden.rotation.z == 0.0 and warden.rotation.x == 0.0)
	_check("node: no bob: the camera is still at (0, 1.6, 0)", camera.position.is_equal_approx(Vector3(0.0, 1.6, 0.0)),
			str(camera.position))
	night.free()


func _test_wish_from_keys() -> void:
	# keys = (right, back), as Input.get_vector gives them; the result is world X/Z.
	_check("node: yaw 0, forward is (0, -1)", Warden.wish_from(Vector2(0.0, -1.0), 0.0).is_equal_approx(Vector2(0.0, -1.0)),
			str(Warden.wish_from(Vector2(0.0, -1.0), 0.0)))
	_check("node: yaw 0, right is (1, 0)", Warden.wish_from(Vector2(1.0, 0.0), 0.0).is_equal_approx(Vector2(1.0, 0.0)))
	_check("node: yaw pi/2 (turned left), forward is (-1, 0)",
			Warden.wish_from(Vector2(0.0, -1.0), PI / 2.0).is_equal_approx(Vector2(-1.0, 0.0)),
			str(Warden.wish_from(Vector2(0.0, -1.0), PI / 2.0)))
	_check("node: yaw pi/2, right is (0, -1)", Warden.wish_from(Vector2(1.0, 0.0), PI / 2.0).is_equal_approx(Vector2(0.0, -1.0)),
			str(Warden.wish_from(Vector2(1.0, 0.0), PI / 2.0)))
	var diagonal: Vector2 = Warden.wish_from(Vector2(1.0, -1.0).normalized(), 0.7)
	_check("node: a diagonal of length 1 stays length 1", is_equal_approx(diagonal.length(), 1.0), str(diagonal.length()))
	_check("node: zero stays zero", Warden.wish_from(Vector2.ZERO, 1.3) == Vector2.ZERO)
	_check("node: never longer than 1", Warden.wish_from(Vector2(1.0, 1.0), 0.3).length() <= 1.0 + 0.00001)


func _test_follows_the_sim() -> void:
	# AC 6, the wiring: the warden is a consumer and pushes the sim's position into its blend.
	var night: NightScreen = _night()
	var warden: Warden = _warden_of(night)
	var sim: NightSim = _sim_with(_def_with(StartState.new()), 1)
	warden.start_at(sim)
	for i: int in 5:
		sim.set_move(Vector2(0.0, -1.0))
		sim.advance()
	warden.on_tick([], sim)
	_check("node: after a tick, the blend's newest is the sim's position",
			warden.blend().value(1.0).is_equal_approx(sim.warden.position), "%s %s" % [warden.blend().value(1.0), sim.warden.position])
	_check("node: and its older one is where the node stood", warden.blend().value(0.0).is_equal_approx(Vector3(0.0, 0.0, 2.0)),
			str(warden.blend().value(0.0)))
	warden.start_at(sim)
	_check("node: start_at snaps the blend and the node",
			warden.blend().value(0.0).is_equal_approx(sim.warden.position) and warden.position.is_equal_approx(sim.warden.position))
	_check("node: and faces the far pier again", warden.yaw() == 0.0 and warden.pitch() == 0.0)
	night.free()


func _test_placed_start_is_drawn() -> void:
	# D3: a show-me setup that places the warden mid-span is drawn there from the first frame.
	var start: StartState = StartState.new()
	start.warden_along = 22.5
	var night: NightScreen = _night(start)
	_check("node: a placed start (along 22.5) is drawn at z -7.5",
			_warden_of(night).position.is_equal_approx(Vector3(0.0, 0.0, -7.5)), str(_warden_of(night).position))
	night.free()
