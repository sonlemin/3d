## The debug tools Main loads by path (AD-31, boundary 4): nothing outside watch/debug/ and
## tests/ names this class, so public builds can leave the folder out. Main loads it only from
## source or in a playtest build, before any screen (AD-25).
class_name DebugTools
extends RefCounted

## Kept so the trace's Callable stays valid for the whole run.
var _trace: NightTrace = NightTrace.new()


func show_names() -> PackedStringArray:
	return ShowSetups.names()


## The show-me setup's night, or null when there is none of that name.
func show_def(show_name: StringName) -> NightDef:
	return ShowSetups.def_of(show_name)


## The screen the show-me setup opens (story 1.7): `night` or `planning`; empty when there is no
## setup of that name. Main compares it with its own screen names.
func show_screen(show_name: StringName) -> StringName:
	return ShowSetups.screen_of(show_name)


## `--show=list`: one line per setup, then `shows: <how many>` for tools/ci.sh to check.
func print_show_list() -> void:
	for show_name: String in ShowSetups.names():
		print(ShowSetups.list_line(StringName(show_name)))
	print("shows: %d" % ShowSetups.names().size())


## The trace consumer for the night screen (`--trace`).
func make_trace() -> Callable:
	return _trace.on_tick


## The temporary aim aid for the night screen (DW-41): a node to add to the night, whose
## `on_tick` is a consumer of it. A new one per night.
func make_aim_aid() -> Node:
	return AimAid.new()
