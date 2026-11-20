## EngineGlobals (AD-51, AD-59): the one owner of engine state that outlives a screen. Headless,
## only the tree pause can be checked; the mouse mode a screen sets is a manual check (M1).
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
