## A night's content (AD-9): plain data built in code by NightDefs, never a `.tres`. Every count
## of the span comes from here (AD-42: no literal 6 or 30 outside night_defs.gd and tests).
class_name NightDef
extends RefCounted

## Names the night in NIGHT_STARTED, the trace and the playtest log.
var name: StringName = &""
var section_count: int = 0
var planks_per_section: int = 0
var start: StartState = StartState.new()
