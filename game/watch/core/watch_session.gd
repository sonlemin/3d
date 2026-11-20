## What lasts for one run of the game, from start to quit (AD-10: there are no autoloads).
## Main makes it once and hands it to every screen; screens read it and never keep their own
## globals. Settings, the journal's hints, the last NightPlan and the PlaytestLog join it in
## later epics.
class_name WatchSession
extends RefCounted

## The launch switches, parsed once.
var options: LaunchOptions
## Everything found wrong at start (AD-28), one line each, shown on the title.
var setup_problems: PackedStringArray


func _init(launch_options: LaunchOptions, problems: PackedStringArray) -> void:
	options = launch_options
	setup_problems = problems
