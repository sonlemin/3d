## A button's state, sent into the sim (AD-2, AD-67). Nodes send presses and releases, never
## meanings: what a press does here is the sim's decision. `set_option()` arrives with Press
## once in story 1.4.
class_name NightCommand
extends RefCounted

enum Kind { PRESS, RELEASE }

var kind: Kind = Kind.PRESS
var input: NightTypes.HandInput = NightTypes.HandInput.HAMMER


static func press(which: NightTypes.HandInput) -> NightCommand:
	return _make(Kind.PRESS, which)


static func release(which: NightTypes.HandInput) -> NightCommand:
	return _make(Kind.RELEASE, which)


static func _make(command_kind: Kind, which: NightTypes.HandInput) -> NightCommand:
	var command: NightCommand = NightCommand.new()
	command.kind = command_kind
	command.input = which
	return command
