## The warden's node (AD-44, AD-52, AD-67; story 1.3 AC 1, 4, 6): mouse look turns the view at
## once, with no bob and no roll; the move wish is the keys turned by the yaw; the node follows
## the sim through a TickBlend and never decides where the warden stands. The feel and the "no
## visible step" are M1 (Sonlm's), not checked here. Also: the night screen's own loop (the wish
## and the view go in, the warden follows what comes out), and decision D2's Esc and click, fed
## as events through the tree.
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


func _test_the_climb_cuts_and_the_step_back_blends() -> void:
	# Story 1.5 D3: WARDEN_CAUGHT and WARDEN_CLIMBED snap the blend (the view cuts); D2's step back is
	# blended. Section 4 (3 planks under 4 test weights, GD-19) falls on tick 120.
	var night: NightScreen = _night()
	var warden: Warden = _warden_of(night)
	var start: StartState = StartState.new()
	start.planks = {4: 3}
	start.weights = {4: 4}
	start.warden_along = 17.5
	var sim: NightSim = _sim_with(_def_with(start), 1)
	warden.start_at(sim)
	for i: int in 120:
		warden.on_tick(sim.advance(), sim)
	var caught: Array[NightEvent] = sim.advance()
	warden.on_tick(caught, sim)
	_check("node: on WARDEN_CAUGHT the blend snaps to the hang point (no slide through the gap)",
			_has(caught, NightEvent.Kind.WARDEN_CAUGHT) and warden.blend().value(0.0).is_equal_approx(sim.warden.position)
			and warden.blend().value(1.0).is_equal_approx(sim.warden.position), str(warden.blend().value(0.0)))
	for i: int in 299:
		warden.on_tick(sim.advance(), sim)
	var up: Array[NightEvent] = sim.advance()
	warden.on_tick(up, sim)
	_check("node: on WARDEN_CLIMBED it snaps to the deck",
			_has(up, NightEvent.Kind.WARDEN_CLIMBED) and warden.blend().value(0.0).is_equal_approx(sim.warden.position),
			str(warden.blend().value(0.0)))
	# D2: on section 5 at along 20.1 when section 4 falls: stepped back 0.2 m, blended.
	start = StartState.new()
	start.planks = {4: 3}
	start.weights = {4: 4}
	start.warden_along = 20.1
	sim = _sim_with(_def_with(start), 1)
	warden.start_at(sim)
	for i: int in 120:
		warden.on_tick(sim.advance(), sim)
	warden.on_tick(sim.advance(), sim)
	_check("node: D2's step back blends from where they stood (along 20.1) to 20.3",
			warden.blend().value(0.0).is_equal_approx(Vector3(0.0, 0.0, -9.9))
			and warden.blend().value(1.0).is_equal_approx(Vector3(0.0, 0.0, -9.7)), str(warden.blend().value(0.0)))
	night.free()


func _test_the_catch_turns_the_view_to_the_edge() -> void:
	# Code review of 2026-11-22 (Sonlm): at the catch the view cuts to face the edge caught: toward
	# the town (yaw pi; yaw 0 faces the far pier), level, so the deck is at eye height (D3). The
	# player looks freely after it. Section 4 (3 planks, 4 weights, GD-19) falls on tick 120; section
	# 5 (4 planks, 4 weights, one stripped by tick 120) falls on tick 240, during the climb.
	var night: NightScreen = _night()
	var warden: Warden = _warden_of(night)
	var start: StartState = StartState.new()
	start.planks = {4: 3, 5: 4}
	start.weights = {4: 4, 5: 4}
	start.warden_along = 19.6
	var sim: NightSim = _sim_with(_def_with(start), 1)
	warden.start_at(sim)
	sim.set_view(PI, -1.2)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	for i: int in 120:
		warden.on_tick(sim.advance(), sim)
	warden.look(Vector2(200.0, 300.0))
	_check("node: before the catch the player looks right and down (yaw -0.5, pitch -0.75)",
			is_equal_approx(warden.yaw(), -0.5) and is_equal_approx(warden.pitch(), -0.75), "%f %f" % [warden.yaw(), warden.pitch()])
	var caught: Array[NightEvent] = sim.advance()
	warden.on_tick(caught, sim)
	_check("node: on WARDEN_CAUGHT the view faces the town, level (yaw pi, pitch 0)", _has(caught, NightEvent.Kind.WARDEN_CAUGHT)
			and is_equal_approx(absf(warden.yaw()), PI) and warden.pitch() == 0.0, "%f %f" % [warden.yaw(), warden.pitch()])
	_check("node: the node and its camera are turned with it, no roll", is_equal_approx(absf(warden.rotation.y), PI)
			and warden.get_node("Camera3D").rotation.is_equal_approx(Vector3.ZERO), str(warden.rotation))
	# The player looks away during the climb; the edge hung from falls on tick 240.
	warden.look(Vector2(-40.0, 80.0))
	var yaw: float = warden.yaw()
	var pitch: float = warden.pitch()
	_check("node: the player can look away while hanging", not is_equal_approx(absf(yaw), PI) and is_equal_approx(pitch, -0.2),
			"%f %f" % [yaw, pitch])
	for i: int in 119:
		warden.on_tick(sim.advance(), sim)
	var before: Vector3 = sim.warden.position
	var gone: Array[NightEvent] = sim.advance()
	warden.on_tick(gone, sim)
	_check("node: tick 240: the edge hung from fell and the feet cut 5 m to the next one",
			_kinds(gone) == [NightEvent.Kind.SECTION_FELL] and sim.warden.position.is_equal_approx(before + Vector3(0.0, 0.0, 5.0)),
			str(sim.warden.position))
	_check("node: the blend snaps there (a cut, no slide)", warden.blend().value(0.0).is_equal_approx(sim.warden.position)
			and warden.blend().value(1.0).is_equal_approx(sim.warden.position), str(warden.blend().value(0.0)))
	_check("node: and the player's view is left alone", warden.yaw() == yaw and warden.pitch() == pitch,
			"%f %f" % [warden.yaw(), warden.pitch()])
	for i: int in 179:
		warden.on_tick(sim.advance(), sim)
	var up: Array[NightEvent] = sim.advance()
	warden.on_tick(up, sim)
	_check("node: WARDEN_CLIMBED does not turn the view either", _has(up, NightEvent.Kind.WARDEN_CLIMBED)
			and warden.yaw() == yaw and warden.pitch() == pitch)
	night.free()


func _test_edging_blends_and_a_crossing_cuts() -> void:
	# Story 1.6 D2: an edging moves the feet steadily at deck height, blended tick by tick (no
	# judder above 60 Hz); a crossing cuts down at its start and up at its end (CROSSING_STARTED,
	# CROSSING_ENDED), blended in between. Section 3 open, section 2 fallen; placed at along 15.3
	# pushing toward the far pier: edging of 3 from tick 30 to 270, crossing of 2 from 270 to 750.
	var night: NightScreen = _night()
	var warden: Warden = _warden_of(night)
	var start: StartState = StartState.new()
	start.planks = {3: 0}
	start.fallen = [2]
	start.warden_along = 15.3
	var sim: NightSim = _sim_with(_def_with(start), 1)
	warden.start_at(sim)
	var blended: bool = true
	var edged: int = 0
	var last: Vector3 = sim.warden.position
	var cut_at: Array[int] = []
	var slid: bool = true
	for i: int in 760:
		sim.set_move(Vector2(0.0, -1.0))
		var events: Array[NightEvent] = sim.advance()
		warden.on_tick(events, sim)
		var tick: int = sim.tick - 1
		var snapped: bool = warden.blend().value(0.0).is_equal_approx(warden.blend().value(1.0))
		if sim.warden.move == WardenState.Move.EDGING and not _has(events, NightEvent.Kind.EDGING_STARTED):
			# One tick's share of the edging: blended from where the feet were the tick before.
			edged += 1
			blended = blended and warden.blend().value(0.0).is_equal_approx(last) \
					and warden.blend().value(1.0).is_equal_approx(sim.warden.position) and not snapped
		if _has(events, NightEvent.Kind.CROSSING_STARTED) or _has(events, NightEvent.Kind.CROSSING_ENDED):
			if snapped and warden.blend().value(1.0).is_equal_approx(sim.warden.position):
				cut_at.append(tick)
		elif sim.warden.move == WardenState.Move.CROSSING and snapped:
			slid = false
		last = sim.warden.position
	_check("node: every tick of the edging but its first is blended from the tick before", blended and edged == 239,
			"%s %d" % [blended, edged])
	_check("node: the crossing's start (270) and end (750) are cuts", cut_at == [270, 750], str(cut_at))
	_check("node: the ticks between are blended", slid)
	night.free()


func _test_placed_start_is_drawn() -> void:
	# D3: a show-me setup that places the warden mid-span is drawn there from the first frame.
	var start: StartState = StartState.new()
	start.warden_along = 22.5
	var night: NightScreen = _night(start)
	_check("node: a placed start (along 22.5) is drawn at z -7.5",
			_warden_of(night).position.is_equal_approx(Vector3(0.0, 0.0, -7.5)), str(_warden_of(night).position))
	night.free()


## What a consumer added by a test saw of the last tick: [the sim].
func _spy(night: NightScreen) -> Array[NightSim]:
	var seen: Array[NightSim] = []
	night.add_consumer(func(_events: Array[NightEvent], sim: NightSim) -> void:
		seen.clear()
		seen.append(sim))
	return seen


func _test_the_night_ticks_through_the_warden() -> void:
	# Story 1.3 T5.5: each tick the night sends the warden's wish and view, advances, and the
	# warden (a consumer) follows. Driven through the night's own _physics_process.
	InputActions.register()
	var night: NightScreen = _night()
	var warden: Warden = _warden_of(night)
	var seen: Array[NightSim] = _spy(night)
	# 100 px right, 40 px up: yaw -0.25, pitch 0.1 (0.0025 rad per pixel). Two different numbers,
	# so a swapped set_view would show.
	warden.look(Vector2(100.0, -40.0))
	Input.action_press(&"watch_move_forward")
	night._physics_process(1.0 / 60.0)
	_check("night: one _physics_process is one tick", seen.size() == 1 and seen[0].tick == 1,
			str(seen[0].tick) if seen.size() == 1 else "no tick seen")
	var sim: NightSim = seen[0]
	_check("night: the sim got the warden's yaw and pitch", is_equal_approx(sim.yaw, -0.25) and is_equal_approx(sim.pitch, 0.1),
			"%s %s" % [sim.yaw, sim.pitch])
	# Forward at yaw -0.25 (turned right) is world (sin 0.25, -cos 0.25).
	var forward: Vector2 = Vector2(sin(0.25), -cos(0.25))
	_check("night: the sim got W as a wish along the view", sim.move_wish.is_equal_approx(forward), str(sim.move_wish))
	# GD-19: 3.5 m/s is 3.5 / 60 m a tick, from the landing's centre (0, 0, 2).
	var after_one: Vector3 = Vector3(0.0, 0.0, 2.0) + Vector3(forward.x, 0.0, forward.y) * (3.5 / 60.0)
	_check("night: and the warden walked one tick that way", sim.warden.position.distance_to(after_one) < 0.001,
			str(sim.warden.position))
	_check("night: the warden's node is a consumer: its blend ends at the sim's position",
			warden.blend().value(1.0).is_equal_approx(sim.warden.position), str(warden.blend().value(1.0)))
	night._physics_process(1.0 / 60.0)
	Input.action_release(&"watch_move_forward")
	# AC 6: a frame draws the node from the blend, between the last two ticks' positions by the
	# engine's fraction (whatever it is at this moment): no longer at the start.
	var after_two: Vector3 = sim.warden.position
	warden._process(0.0)
	var drawn: Vector3 = after_one.lerp(after_two, clampf(Engine.get_physics_interpolation_fraction(), 0.0, 1.0))
	_check("night: a frame draws the node from the blend, between the last two ticks",
			warden.position.distance_to(drawn) < 0.001 and warden.position.distance_to(Vector3(0.0, 0.0, 2.0)) > 0.05,
			"%s, wanted %s" % [warden.position, drawn])
	night._physics_process(1.0 / 60.0)
	_check("night: with no key held the wish is zero and the warden stands",
			sim.move_wish == Vector2.ZERO and sim.tick == 3, "%s tick %d" % [sim.move_wish, sim.tick])
	night.free()


func _left_click(pressed: bool) -> InputEventMouseButton:
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = pressed
	return click


func _mouse_move(pixels: Vector2) -> InputEventMouseMotion:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.screen_relative = pixels
	motion.relative = pixels
	return motion


func _esc() -> InputEventKey:
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = KEY_ESCAPE
	key.pressed = true
	return key


## Stands first under `root`, so unhandled input reaches it last, after the night's warden: it
## counts what the warden let through. (Viewport.is_input_handled() is no use here: headless it
## reads true for every mouse event, taken or not.)
class LetThrough:
	extends Node
	var count: int = 0

	func _unhandled_input(_event: InputEvent) -> void:
		count += 1


## Sends `event` through the tree as the engine does; true when the warden took it (nothing
## after the warden saw it).
func _send(event: InputEvent) -> bool:
	var after: LetThrough = LetThrough.new()
	root.add_child(after)
	root.move_child(after, 0)
	root.push_input(event)
	var taken: bool = after.count == 0
	after.free()
	return taken


func _test_esc_frees_the_mouse_and_a_click_takes_it_back() -> void:
	# Decision D2. Whether the mouse is captured is what EngineGlobals was asked (the engine's own
	# mode never reads as captured with no display).
	InputActions.register()
	var night: NightScreen = _night()
	var warden: Warden = _warden_of(night)
	EngineGlobals.enter_screen(root.get_tree(), EngineGlobals.ScreenKind.FIRST_PERSON)
	_check("d2: a first-person screen starts with the mouse captured", EngineGlobals.mouse_captured())
	_check("d2: captured, a mouse move is taken", _send(_mouse_move(Vector2(100.0, 0.0))))
	_check("d2: and turns the view: 100 px right is yaw -0.25", is_equal_approx(warden.yaw(), -0.25), str(warden.yaw()))
	_check("d2: captured, a left click is left for the hands (story 1.4)", not _send(_left_click(true))
			and not _send(_left_click(false)) and EngineGlobals.mouse_captured())
	_check("d2: Esc is taken", _send(_esc()))
	_check("d2: and frees the mouse", not EngineGlobals.mouse_captured())
	_check("d2: free, a mouse move is not taken", not _send(_mouse_move(Vector2(100.0, 0.0))))
	_check("d2: and does not turn the view", is_equal_approx(warden.yaw(), -0.25), str(warden.yaw()))
	_check("d2: free, Esc again is not taken and changes nothing", not _send(_esc()) and not EngineGlobals.mouse_captured())
	_check("d2: free, a left click is taken", _send(_left_click(true)))
	_check("d2: and captures the mouse again", EngineGlobals.mouse_captured())
	_check("d2: that click's release is taken too (no hand sees half a click)", _send(_left_click(false)))
	_check("d2: the next click is the hands' again", not _send(_left_click(true)) and not _send(_left_click(false)))
	_check("d2: captured again, the mouse turns the view", _send(_mouse_move(Vector2(-100.0, 0.0)))
			and is_equal_approx(warden.yaw(), 0.0), str(warden.yaw()))
	EngineGlobals.enter_screen(root.get_tree(), EngineGlobals.ScreenKind.MENU)
	night.free()


func _test_a_night_opened_alone_takes_no_input() -> void:
	# night.tscn run on its own (no setup()): it warns once and does not tick; its warden must
	# not take input either. A click would capture the mouse with Esc unable to free it.
	EngineGlobals.enter_screen(root.get_tree(), EngineGlobals.ScreenKind.MENU)
	var night: NightScreen = NightScene.instantiate() as NightScreen
	_expect_begin()
	root.add_child(night)
	var taken: bool = _send(_left_click(true))
	taken = _send(_left_click(false)) or taken
	taken = _send(_esc()) or taken
	taken = _send(_mouse_move(Vector2(50.0, 0.0))) or taken
	_expect_end("night alone: only its night.no_setup warning", [["WARNING", "night.no_setup", 1]])
	_check("night alone: the warden takes no input", not taken)
	_check("night alone: and a click does not capture the mouse", not EngineGlobals.mouse_captured())
	night.free()


## Every command the night sends its sim from now on, through a spy on the sim's queue: a tick is
## run and the commands it took are read (the sim keeps them for the recording).
func _commands_after(night: NightScreen, events: Array[InputEvent]) -> Array[String]:
	for event: InputEvent in events:
		root.push_input(event)
	var sim: NightSim = night._sim
	sim.advance()
	var out: Array[String] = []
	for cmd: NightCommand in sim.commands:
		out.append("%s %s" % [NightCommand.Kind.find_key(cmd.kind), NightTypes.HandInput.find_key(cmd.input)])
	return out


func _key(code: Key, pressed: bool, echo: bool = false) -> InputEventKey:
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = code
	key.pressed = pressed
	key.echo = echo
	return key


func _right_click(pressed: bool) -> InputEventMouseButton:
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_RIGHT
	click.pressed = pressed
	return click


func _test_buttons_reach_the_sim() -> void:
	# Story 1.4 T6: a press and a release of each night button reach the sim as commands, button
	# states and nothing more (Novel Pattern 3).
	InputActions.register()
	var night: NightScreen = _night()
	EngineGlobals.enter_screen(root.get_tree(), EngineGlobals.ScreenKind.FIRST_PERSON)
	_check("input: a left click is HAMMER press, then release",
			_commands_after(night, [_left_click(true)]) == ["PRESS HAMMER"]
			and _commands_after(night, [_left_click(false)]) == ["RELEASE HAMMER"])
	_check("input: a right click is ROPE", _commands_after(night, [_right_click(true), _right_click(false)])
			== ["PRESS ROPE", "RELEASE ROPE"])
	_check("input: E is USE", _commands_after(night, [_key(KEY_E, true), _key(KEY_E, false)]) == ["PRESS USE", "RELEASE USE"])
	_check("input: Tab is FOREARM", _commands_after(night, [_key(KEY_TAB, true), _key(KEY_TAB, false)])
			== ["PRESS FOREARM", "RELEASE FOREARM"])
	_check("input: a key's echo is not a press", _commands_after(night, [_key(KEY_E, true), _key(KEY_E, true, true),
			_key(KEY_E, false)]) == ["PRESS USE", "RELEASE USE"])
	_check("input: a key no night button uses sends nothing", _commands_after(night, [_key(KEY_J, true), _key(KEY_J, false)]).is_empty())
	# The hand acts on the next tick: E at the sky (the view starts level) is refused.
	root.push_input(_key(KEY_E, true))
	var refused: NightEvent.Kind = NightEvent.Kind.NIGHT_STARTED
	var sim: NightSim = night._sim
	for event: NightEvent in sim.advance():
		refused = event.kind
	_check("input: the next tick acts on it (E at nothing: REFUSED)", refused == NightEvent.Kind.REFUSED)
	EngineGlobals.enter_screen(root.get_tree(), EngineGlobals.ScreenKind.MENU)
	night.free()


func _test_the_recapture_click_reaches_no_hand() -> void:
	# Story 1.3 D2: with the mouse free, the click that takes it back goes nowhere else, press and
	# release both: no HAMMER command at all. The warden's node sees it first.
	InputActions.register()
	var night: NightScreen = _night()
	EngineGlobals.enter_screen(root.get_tree(), EngineGlobals.ScreenKind.FIRST_PERSON)
	root.push_input(_esc())
	_check("recapture: Esc freed the mouse", not EngineGlobals.mouse_captured())
	_check("recapture: the click that takes it back sends no command",
			_commands_after(night, [_left_click(true), _left_click(false)]).is_empty())
	_check("recapture: and the mouse is captured again", EngineGlobals.mouse_captured())
	_check("recapture: the next click is the hammer's", _commands_after(night, [_left_click(true), _left_click(false)])
			== ["PRESS HAMMER", "RELEASE HAMMER"])
	# With the mouse free, the other buttons still reach the hands.
	root.push_input(_esc())
	_check("recapture: free, E still reaches the sim", _commands_after(night, [_key(KEY_E, true)]) == ["PRESS USE"])
	EngineGlobals.enter_screen(root.get_tree(), EngineGlobals.ScreenKind.MENU)
	night.free()


func _test_a_night_without_setup_sends_nothing() -> void:
	InputActions.register()
	EngineGlobals.enter_screen(root.get_tree(), EngineGlobals.ScreenKind.MENU)
	var night: NightScreen = NightScene.instantiate() as NightScreen
	_expect_begin()
	root.add_child(night)
	root.push_input(_left_click(true))
	root.push_input(_key(KEY_E, true))
	_expect_end("no setup: only its night.no_setup warning", [["WARNING", "night.no_setup", 1]])
	# With no sim there is nowhere to send a command; that the two events above broke nothing is
	# the expect window's check (only the one warning).
	_check("no setup: the night has no sim to send to", night._sim == null)
	night.free()


func _test_the_forearm_is_drawn_from_the_camera() -> void:
	# HandsView is a child of the warden's camera, after the warden among the consumers.
	InputActions.register()
	var night: NightScreen = _night()
	var hands: HandsView = night.get_node_or_null("Warden/Camera3D/Hands") as HandsView
	_check("forearm: a HandsView under the warden's camera", hands != null)
	if hands != null:
		var order: Array[Callable] = night._consumers
		_check("forearm: it reads the tick after the warden's node", order.find(hands.on_tick) > order.find(_warden_of(night).on_tick)
				and order.find(_warden_of(night).on_tick) >= 0, str(order))
		_check("forearm: down at the start", not hands.visible)
		var sim: NightSim = night._sim
		sim.command(NightCommand.press(NightTypes.HandInput.FOREARM))
		night._physics_process(1.0 / 60.0)
		_check("forearm: the night's tick shows it once raised", hands.visible)
	night.free()
