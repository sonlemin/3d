## Finds the cry clips for each level under res://audio/cries/<level>/ at runtime.
## Only `.wav` files are used. Other audio files are skipped with a warning; everything
## else (CREDITS.md, .import files, sub-folders) is ignored.
##
## ResourceLoader.list_directory() only lists files Godot has imported, so a freshly
## dropped clip shows up after `godot --headless --path game --import` (or opening the editor).
extends RefCounted

const TrialPlan := preload("res://scripts/trial_plan.gd")

const DEFAULT_ROOT: String = "res://audio/cries"
## Audio formats that are reported (not used) when found beside the clips.
const OTHER_AUDIO_EXTENSIONS: Array[String] = ["ogg", "mp3", "flac", "aif", "aiff", "opus", "m4a", "wma"]

var root: String = DEFAULT_ROOT
## Warnings from the last discover(), already printed with push_warning().
var warnings: PackedStringArray = []
var _clips: Dictionary = {}  # level -> PackedStringArray of resource paths


## Splits one directory listing into usable clips and skipped audio files.
## Returns {"clips": PackedStringArray, "skipped_audio": PackedStringArray}, names only.
static func filter_clip_names(names: PackedStringArray) -> Dictionary:
	var clips: PackedStringArray = []
	var skipped: PackedStringArray = []
	for file_name: String in names:
		if file_name.ends_with("/"):
			continue
		var extension: String = file_name.get_extension().to_lower()
		if extension == "wav":
			clips.append(file_name)
		elif extension in OTHER_AUDIO_EXTENSIONS:
			skipped.append(file_name)
	clips.sort()
	return {"clips": clips, "skipped_audio": skipped}


## Levels (in TrialPlan.LEVELS order) whose clip list is missing or empty.
static func find_empty_levels(clips_by_level: Dictionary) -> PackedStringArray:
	var empty: PackedStringArray = []
	for level: String in TrialPlan.LEVELS:
		var clips: PackedStringArray = clips_by_level.get(level, PackedStringArray())
		if clips.is_empty():
			empty.append(level)
	return empty


func discover(cries_root: String = DEFAULT_ROOT) -> void:
	root = cries_root
	warnings.clear()
	_clips.clear()
	for level: String in TrialPlan.LEVELS:
		var folder: String = folder_for(level)
		var split: Dictionary = filter_clip_names(ResourceLoader.list_directory(folder))
		var paths: PackedStringArray = []
		for file_name: String in split["clips"]:
			paths.append(folder.path_join(file_name))
		_clips[level] = paths
		for file_name: String in split["skipped_audio"]:
			var message: String = "Ear test: skipped %s (only .wav clips are used)" % folder.path_join(file_name)
			warnings.append(message)
			push_warning(message)


func folder_for(level: String) -> String:
	return root.path_join(level) + "/"


func clips_for(level: String) -> PackedStringArray:
	return _clips.get(level, PackedStringArray())


func empty_levels() -> PackedStringArray:
	return find_empty_levels(_clips)


## One random clip for `level`, or "" if the level has none.
func pick(level: String, rng: RandomNumberGenerator) -> String:
	var clips: PackedStringArray = clips_for(level)
	if clips.is_empty():
		return ""
	return clips[rng.randi_range(0, clips.size() - 1)]
