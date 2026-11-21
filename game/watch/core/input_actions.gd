## The game's input actions (AD-20, AD-70): one table, registered in code at start, so
## project.godot (shared with the ear test) keeps an empty input map. Keys are bound by
## physical position (`physical_keycode`, `keycode` 0), so WASD sits in the same place on every
## layout, and are shown by the name the player's keyboard prints on that key.
## No rebinding and no gamepad in the one-night game (AD-55).
##
## Several actions share a key (1, 2, R, Esc, Space, W/A/S/D, both mouse buttons) on purpose:
## each screen reads only its own actions.
class_name InputActions
extends RefCounted

enum Device { KEY, MOUSE }

## The one table: action -> its bindings, each [Device, code]. Mouse look is not an action.
const ACTIONS: Dictionary[StringName, Array] = {
	# GDD Controls, night.
	&"watch_move_forward": [[Device.KEY, KEY_W]],
	&"watch_move_back": [[Device.KEY, KEY_S]],
	&"watch_move_left": [[Device.KEY, KEY_A]],
	&"watch_move_right": [[Device.KEY, KEY_D]],
	&"watch_hammer": [[Device.MOUSE, MOUSE_BUTTON_LEFT]],    # strike, strip plank, wedge
	&"watch_rope": [[Device.MOUSE, MOUSE_BUTTON_RIGHT]],     # strip rail, haul, re-hang, bell rope
	&"watch_use": [[Device.KEY, KEY_E]],                     # hang/take/swap, re-lay, refill (UX-36)
	&"watch_shutter": [[Device.KEY, KEY_F]],
	&"watch_build_trapdoor": [[Device.KEY, KEY_1]],          # hold 8 s
	&"watch_build_swing_beam": [[Device.KEY, KEY_2]],        # hold 12 s
	&"watch_dismantle": [[Device.KEY, KEY_R]],               # hold 4 s
	&"watch_forearm": [[Device.KEY, KEY_TAB]],               # UX-11
	&"watch_pause": [[Device.KEY, KEY_ESCAPE]],              # night and planning, UX-24
	# GDD Controls, planning.
	&"watch_plan_select": [[Device.MOUSE, MOUSE_BUTTON_LEFT]],   # strip / place
	&"watch_plan_undo": [[Device.MOUSE, MOUSE_BUTTON_RIGHT]],    # undo on that section
	&"watch_tool_trapdoor": [[Device.KEY, KEY_1]],               # UX-16
	&"watch_tool_swing_beam": [[Device.KEY, KEY_2]],
	&"watch_tool_lantern": [[Device.KEY, KEY_3]],
	&"watch_ring_bell": [[Device.KEY, KEY_SPACE]],               # hold 1 s, UX-18
	&"watch_journal": [[Device.KEY, KEY_J]],                     # UX-13
	# Menu keys (AD-70); Godot's ui_* actions are not relied on.
	&"watch_menu_up": [[Device.KEY, KEY_UP], [Device.KEY, KEY_W]],
	&"watch_menu_down": [[Device.KEY, KEY_DOWN], [Device.KEY, KEY_S]],
	&"watch_menu_left": [[Device.KEY, KEY_LEFT], [Device.KEY, KEY_A]],
	&"watch_menu_right": [[Device.KEY, KEY_RIGHT], [Device.KEY, KEY_D]],
	&"watch_menu_confirm": [[Device.KEY, KEY_ENTER], [Device.KEY, KEY_SPACE]],
	&"watch_menu_back": [[Device.KEY, KEY_ESCAPE]],
	&"watch_ring_again": [[Device.KEY, KEY_R]],                  # the left/right check
}

## Architecture, Novel Pattern 3: the warden's buttons, each sent into the sim as a press and a
## release by the night screen. Every NightTypes.HandInput once.
const NIGHT_INPUTS: Array[NightTypes.HandInput] = [
	NightTypes.HandInput.HAMMER, NightTypes.HandInput.ROPE, NightTypes.HandInput.USE,
	NightTypes.HandInput.SHUTTER, NightTypes.HandInput.BUILD_TRAPDOOR, NightTypes.HandInput.BUILD_BEAM,
	NightTypes.HandInput.DISMANTLE, NightTypes.HandInput.FOREARM,
]


## The night action of the table that `input` is read from (Novel Pattern 3); empty for a value
## outside the enum (no action, so nothing is read).
static func action_of(input: NightTypes.HandInput) -> StringName:
	match input:
		NightTypes.HandInput.HAMMER:
			return &"watch_hammer"
		NightTypes.HandInput.ROPE:
			return &"watch_rope"
		NightTypes.HandInput.USE:
			return &"watch_use"
		NightTypes.HandInput.SHUTTER:
			return &"watch_shutter"
		NightTypes.HandInput.BUILD_TRAPDOOR:
			return &"watch_build_trapdoor"
		NightTypes.HandInput.BUILD_BEAM:
			return &"watch_build_swing_beam"
		NightTypes.HandInput.DISMANTLE:
			return &"watch_dismantle"
		NightTypes.HandInput.FOREARM:
			return &"watch_forearm"
	return &""


## Adds every action of the table to the InputMap. Safe to call again: an action that already
## has exactly its bindings is left alone. Returns the setup problems found (AD-28), one line
## each, for Main to report; it logs nothing itself.
static func register() -> PackedStringArray:
	var problems: PackedStringArray = []
	for action: StringName in ACTIONS:
		var wanted: Array[InputEvent] = events_for(action)
		if InputMap.has_action(action):
			if not same_events(InputMap.action_get_events(action), wanted):
				problems.append("input.defined_elsewhere: %s already has other bindings (project.godot?)" % action)
			continue
		InputMap.add_action(action)
		for event: InputEvent in wanted:
			InputMap.action_add_event(action, event)
	return problems


## The events the table gives `action` (empty for an action not in the table).
static func events_for(action: StringName) -> Array[InputEvent]:
	var events: Array[InputEvent] = []
	for binding: Array in ACTIONS.get(action, []):
		events.append(_event(binding[0], binding[1]))
	return events


## True when both lists hold the same bindings, in any order.
static func same_events(a: Array[InputEvent], b: Array[InputEvent]) -> bool:
	return _signatures(a) == _signatures(b)


## The name of `action`'s first binding as the player's keyboard prints it ("W" on QWERTY,
## "Z" on AZERTY), or the mouse button's name. Empty for an action not in the table.
static func key_name(action: StringName) -> String:
	var bindings: Array = ACTIONS.get(action, [])
	if bindings.is_empty():
		return ""
	return binding_name(bindings[0])


## The printed name of one binding of the table, [Device, code]. Empty for a mouse button the
## game has no name for (it binds only the left and the right one).
static func binding_name(binding: Array) -> String:
	if binding[0] == Device.MOUSE:
		match binding[1]:
			MOUSE_BUTTON_LEFT:
				return UiText.MOUSE_LEFT
			MOUSE_BUTTON_RIGHT:
				return UiText.MOUSE_RIGHT
		return ""
	var physical: Key = binding[1]
	# The headless display server cannot read the layout and logs an error if asked.
	if DisplayServer.get_name() == "headless":
		return OS.get_keycode_string(physical)
	return OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(physical))


static func _event(device: Device, code: int) -> InputEvent:
	if device == Device.MOUSE:
		var button: InputEventMouseButton = InputEventMouseButton.new()
		button.button_index = code as MouseButton
		return button
	var key: InputEventKey = InputEventKey.new()
	key.physical_keycode = code as Key
	return key


## Each event as comparable text, sorted.
static func _signatures(events: Array[InputEvent]) -> Array[String]:
	var out: Array[String] = []
	for event: InputEvent in events:
		if event is InputEventKey:
			var key: InputEventKey = event as InputEventKey
			out.append("key:%d:%d" % [key.physical_keycode, key.keycode])
		elif event is InputEventMouseButton:
			out.append("mouse:%d" % (event as InputEventMouseButton).button_index)
		else:
			out.append(event.as_text())
	out.sort()
	return out
