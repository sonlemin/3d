## EngineGlobals (AD-51, AD-59): the one owner of engine state that outlives a screen. Headless,
## the tree pause can be checked, and what was asked of the mouse (mouse_captured()); the mode
## the engine really sets is a manual check (M1).
extends TestCase


func _after_all() -> void:
	# Never leave the runner's tree paused, whatever a failed check left behind.
	root.get_tree().paused = false


func _test_set_paused() -> void:
	var tree: SceneTree = root.get_tree()
	EngineGlobals.set_paused(tree, true)
	_check("globals: set_paused(true) pauses the tree", tree.paused)
	EngineGlobals.set_paused(tree, false)
	_check("globals: set_paused(false) unpauses it", not tree.paused)


func _test_enter_screen_clears_pause() -> void:
	var tree: SceneTree = root.get_tree()
	for kind: EngineGlobals.ScreenKind in [EngineGlobals.ScreenKind.MENU, EngineGlobals.ScreenKind.FIRST_PERSON]:
		EngineGlobals.set_paused(tree, true)
		EngineGlobals.enter_screen(tree, kind)
		_check("globals: entering a %s screen clears the pause" % EngineGlobals.ScreenKind.find_key(kind),
				not tree.paused)
	# Put the mouse back the way a menu has it; headless this logs nothing.
	EngineGlobals.enter_screen(tree, EngineGlobals.ScreenKind.MENU)


func _test_mouse_mode_per_kind() -> void:
	# The mapping itself, not the engine's state (that needs a display): a menu frees the mouse,
	# first person captures it (UX: mouse look at night; menus are pointed at).
	_check("globals: a menu screen wants a visible mouse",
			EngineGlobals.mouse_mode_for(EngineGlobals.ScreenKind.MENU) == Input.MOUSE_MODE_VISIBLE)
	_check("globals: a first-person screen wants a captured mouse",
			EngineGlobals.mouse_mode_for(EngineGlobals.ScreenKind.FIRST_PERSON) == Input.MOUSE_MODE_CAPTURED)


func _test_capture_mouse() -> void:
	# Story 1.3 D2: Esc frees the mouse and a click takes it back. Headless the engine's own mode
	# cannot be seen (M1); what was asked for can, and setting it must log nothing (any log line
	# outside an expect window fails the run).
	EngineGlobals.capture_mouse(true)
	_check("globals: capture_mouse(true): the mouse is captured", EngineGlobals.mouse_captured())
	EngineGlobals.capture_mouse(false)
	_check("globals: capture_mouse(false): it is free", not EngineGlobals.mouse_captured())
	var tree: SceneTree = root.get_tree()
	EngineGlobals.enter_screen(tree, EngineGlobals.ScreenKind.FIRST_PERSON)
	_check("globals: entering a first-person screen captures it", EngineGlobals.mouse_captured())
	EngineGlobals.enter_screen(tree, EngineGlobals.ScreenKind.MENU)
	_check("globals: entering a menu frees it", not EngineGlobals.mouse_captured())
