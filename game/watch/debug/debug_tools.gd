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


## `--show=list`: one line per setup.
func print_show_list() -> void:
	for show_name: String in ShowSetups.names():
		print(ShowSetups.list_line(StringName(show_name)))


## The trace consumer for the night screen (`--trace`).
func make_trace() -> Callable:
	return _trace.on_tick
