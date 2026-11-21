## A button's state, or an option that is a rule, sent into the sim (AD-2, AD-67). Nodes send
## presses and releases, never meanings: what a press does here is the sim's decision.
## set_option() carries a setting that is a rule (Holds) into a running night (Data Patterns).
class_name NightCommand
extends RefCounted

enum Kind { PRESS, RELEASE, SET_OPTION }

var kind: Kind = Kind.PRESS
## For PRESS and RELEASE.
var input: NightTypes.HandInput = NightTypes.HandInput.HAMMER
## For SET_OPTION: which option, and its value (a NightTypes.Holds for HOLDS).
var option: NightTypes.Option = NightTypes.Option.HOLDS
var value: int = 0


static func press(which: NightTypes.HandInput) -> NightCommand:
	return _make(Kind.PRESS, which)


static func release(which: NightTypes.HandInput) -> NightCommand:
	return _make(Kind.RELEASE, which)


## A value outside the option's enum is `sim.bad_input` when the sim takes it.
static func set_option(which: NightTypes.Option, to: int) -> NightCommand:
	var command: NightCommand = NightCommand.new()
	command.kind = Kind.SET_OPTION
	command.option = which
	command.value = to
	return command


static func _make(command_kind: Kind, which: NightTypes.HandInput) -> NightCommand:
	var command: NightCommand = NightCommand.new()
	command.kind = command_kind
	command.input = which
	return command
