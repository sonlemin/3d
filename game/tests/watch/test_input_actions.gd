## InputActions (AD-20, AD-70): every action of the GDD's Controls tables (night and planning)
## and the menu keys, registered in code from one table, keys by physical position.
## The expected bindings are written here literally; they are never read from InputActions.
extends TestCase

const KEY: String = "key"
const MOUSE: String = "mouse"

## Story 1.1 Dev Notes, "InputActions": action -> its bindings as [device, code].
const EXPECTED: Dictionary[StringName, Array] = {
	# GDD Controls, night: walk.
	&"watch_move_forward": [[KEY, KEY_W]],
	&"watch_move_back": [[KEY, KEY_S]],
	&"watch_move_left": [[KEY, KEY_A]],
	&"watch_move_right": [[KEY, KEY_D]],
	# GDD night: hammer hand (strike, strip plank, wedge).
	&"watch_hammer": [[MOUSE, MOUSE_BUTTON_LEFT]],
	# GDD night: rope and lantern hand (strip rail, haul, re-hang, bell rope).
	&"watch_rope": [[MOUSE, MOUSE_BUTTON_RIGHT]],
	# GDD night: hang/take/swap, re-lay, refill (UX-36).
	&"watch_use": [[KEY, KEY_E]],
	&"watch_shutter": [[KEY, KEY_F]],
	# GDD night: build trapdoor (hold 8 s), swing beam (hold 12 s), dismantle (hold 4 s).
	&"watch_build_trapdoor": [[KEY, KEY_1]],
	&"watch_build_swing_beam": [[KEY, KEY_2]],
	&"watch_dismantle": [[KEY, KEY_R]],
	# GDD night: the forearm (UX-11).
	&"watch_forearm": [[KEY, KEY_TAB]],
	# GDD night and planning; UX-24.
	&"watch_pause": [[KEY, KEY_ESCAPE]],
	# GDD planning: strip / place; undo on that section.
	&"watch_plan_select": [[MOUSE, MOUSE_BUTTON_LEFT]],
	&"watch_plan_undo": [[MOUSE, MOUSE_BUTTON_RIGHT]],
	# GDD planning: tools (UX-16).
	&"watch_tool_trapdoor": [[KEY, KEY_1]],
	&"watch_tool_swing_beam": [[KEY, KEY_2]],
	&"watch_tool_lantern": [[KEY, KEY_3]],
	# GDD planning: ring the bell (hold 1 s, UX-18); the journal (UX-13).
	&"watch_ring_bell": [[KEY, KEY_SPACE]],
	&"watch_journal": [[KEY, KEY_J]],
	# AD-70: menu keys.
	&"watch_menu_up": [[KEY, KEY_UP], [KEY, KEY_W]],
	&"watch_menu_down": [[KEY, KEY_DOWN], [KEY, KEY_S]],
	&"watch_menu_left": [[KEY, KEY_LEFT], [KEY, KEY_A]],
	&"watch_menu_right": [[KEY, KEY_RIGHT], [KEY, KEY_D]],
	&"watch_menu_confirm": [[KEY, KEY_ENTER], [KEY, KEY_SPACE]],
	&"watch_menu_back": [[KEY, KEY_ESCAPE]],
	# AD-70: ring again on the left/right check.
	&"watch_ring_again": [[KEY, KEY_R]],
}


## One binding as text, so two lists of events compare without caring about order.
func _describe(event: InputEvent) -> String:
	if event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		return "%s:%d:%d" % [KEY, key.physical_keycode, key.keycode]
	if event is InputEventMouseButton:
		return "%s:%d" % [MOUSE, (event as InputEventMouseButton).button_index]
	return "other:" + event.as_text()


func _expected_descriptions(bindings: Array) -> Array[String]:
	var out: Array[String] = []
	for binding: Array in bindings:
		# A key is by physical position only: keycode stays 0.
		out.append("%s:%d:0" % [KEY, binding[1]] if binding[0] == KEY else "%s:%d" % [MOUSE, binding[1]])
	out.sort()
	return out


func _registered_descriptions(action: StringName) -> Array[String]:
	var out: Array[String] = []
	for event: InputEvent in InputMap.action_get_events(action):
		out.append(_describe(event))
	out.sort()
	return out


func _test_table_is_the_gdd_list() -> void:
	var names: Array[String] = []
	for action: StringName in InputActions.ACTIONS:
		names.append(String(action))
	names.sort()
	var wanted: Array[String] = []
	for action: StringName in EXPECTED:
		wanted.append(String(action))
	wanted.sort()
	_check("input: the table has exactly the GDD and AD-70 actions (%d)" % wanted.size(), names == wanted,
			"missing %s / extra %s" % [wanted.filter(func(n: String) -> bool: return not names.has(n)),
					names.filter(func(n: String) -> bool: return not wanted.has(n))])


func _test_names_start_with_watch() -> void:
	var bad: Array[String] = []
	for action: StringName in InputActions.ACTIONS:
		if not String(action).begins_with("watch_"):
			bad.append(String(action))
	_check("input: every action is named watch_...", bad.is_empty(), str(bad))


func _test_register_matches_table() -> void:
	var problems: PackedStringArray = InputActions.register()
	_check("input: register() finds no problem", problems.is_empty(), str(problems))
	var wrong: PackedStringArray = []
	for action: StringName in EXPECTED:
		if not InputMap.has_action(action):
			wrong.append("%s missing" % action)
			continue
		var got: Array[String] = _registered_descriptions(action)
		var want: Array[String] = _expected_descriptions(EXPECTED[action])
		if got != want:
			wrong.append("%s: %s, expected %s" % [action, got, want])
	_check("input: after register(), every action has exactly its bindings", wrong.is_empty(), " | ".join(wrong))


func _test_keys_are_physical() -> void:
	InputActions.register()
	var bad: PackedStringArray = []
	for action: StringName in EXPECTED:
		for event: InputEvent in InputMap.action_get_events(action):
			if event is InputEventKey:
				var key: InputEventKey = event as InputEventKey
				if key.physical_keycode == KEY_NONE or key.keycode != KEY_NONE:
					bad.append("%s: %s" % [action, _describe(event)])
			elif event is InputEventMouseButton:
				if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_NONE:
					bad.append("%s: mouse with no button" % action)
			else:
				bad.append("%s: %s" % [action, event.get_class()])
	_check("input: each key has a physical keycode (keycode 0), each mouse action a button",
			bad.is_empty(), " | ".join(bad))


func _test_register_twice_changes_nothing() -> void:
	InputActions.register()
	var before: Dictionary[StringName, Array] = {}
	for action: StringName in EXPECTED:
		before[action] = _registered_descriptions(action)
	var problems: PackedStringArray = InputActions.register()
	var changed: PackedStringArray = []
	for action: StringName in EXPECTED:
		if _registered_descriptions(action) != before[action]:
			changed.append(String(action))
	_check("input: a second register() changes nothing and finds no problem",
			changed.is_empty() and problems.is_empty(), "%s %s" % [changed, problems])


func _test_nothing_in_project_godot() -> void:
	var found: PackedStringArray = []
	for property: Dictionary in ProjectSettings.get_property_list():
		var property_name: String = property["name"]
		if property_name.begins_with("input/watch_"):
			found.append(property_name)
	_check("input: no watch_ action is defined in project.godot", found.is_empty(), str(found))


func _test_other_bindings_are_a_problem() -> void:
	# Two lists of bindings match only when they hold the same bindings.
	var mine: Array[InputEvent] = InputActions.events_for(&"watch_use")
	var other: InputEventKey = InputEventKey.new()
	other.physical_keycode = KEY_Q
	var others: Array[InputEvent] = [other]
	var extra: Array[InputEvent] = mine.duplicate()
	extra.append(other)
	_check("input: the same bindings match", InputActions.same_events(mine, InputActions.events_for(&"watch_use")))
	_check("input: other bindings do not match", not InputActions.same_events(mine, others))
	_check("input: an extra binding does not match", not InputActions.same_events(mine, extra))


func _test_register_reports_other_bindings() -> void:
	# An action that already exists with other bindings (from project.godot, say) is a setup
	# problem: register() must notice, not silently keep or double the bindings.
	# The one test that writes to the InputMap (decision with Sonlm at code review, 2026-11-20);
	# it puts the table's bindings back before it ends.
	InputActions.register()
	InputMap.erase_action(&"watch_use")
	InputMap.add_action(&"watch_use")
	var other: InputEventKey = InputEventKey.new()
	other.physical_keycode = KEY_Q
	InputMap.action_add_event(&"watch_use", other)
	var problems: PackedStringArray = InputActions.register()
	_check("input: register() reports watch_use bound elsewhere, and only that",
			problems.size() == 1 and problems[0].begins_with("input.defined_elsewhere: watch_use "), str(problems))
	_check("input: register() leaves the other binding as it found it",
			InputMap.action_get_events(&"watch_use").size() == 1)
	InputMap.erase_action(&"watch_use")
	problems = InputActions.register()
	_check("input: with the action gone, register() adds it back without a problem", problems.is_empty()
			and InputActions.same_events(InputMap.action_get_events(&"watch_use"), InputActions.events_for(&"watch_use")),
			str(problems))


func _test_unnamed_mouse_button() -> void:
	# The game names only the two buttons it binds; any other has no name rather than a wrong one.
	_check("input: the middle mouse button has no name",
			InputActions.binding_name([InputActions.Device.MOUSE, MOUSE_BUTTON_MIDDLE]) == "",
			InputActions.binding_name([InputActions.Device.MOUSE, MOUSE_BUTTON_MIDDLE]))


func _test_key_names() -> void:
	# Headless, a key's name is the US layout name of its physical key (the label call is not
	# supported by the headless display server). On a real display it is the player's layout.
	_check("input: key name of watch_move_forward is W", InputActions.key_name(&"watch_move_forward") == "W",
			InputActions.key_name(&"watch_move_forward"))
	_check("input: key name of watch_pause is Escape", InputActions.key_name(&"watch_pause") == "Escape",
			InputActions.key_name(&"watch_pause"))
	_check("input: watch_hammer is Left mouse", InputActions.key_name(&"watch_hammer") == "Left mouse",
			InputActions.key_name(&"watch_hammer"))
	_check("input: watch_rope is Right mouse", InputActions.key_name(&"watch_rope") == "Right mouse",
			InputActions.key_name(&"watch_rope"))
	_check("input: an unknown action has no name", InputActions.key_name(&"watch_nothing") == "")
