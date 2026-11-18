## Finds the cry clips for each level under res://audio/cries/<level>/ at runtime.
## Only `.wav` files are used. Other audio files are skipped with a warning; everything
## else (CREDITS.md, .import files, sub-folders) is ignored. Every listed `.wav` is loaded
## once here, so a level never offers a clip that would play as silence.
##
## ResourceLoader.list_directory() only lists files Godot has imported, so outside exported
## builds the raw files in each folder are compared with it: a `.wav` dropped in but not
## imported is reported, as is a listed clip that doesn't load (a fresh clone that was never
## imported). Both are `problems`, which keep Start disabled until
## `godot --headless --path game --import` (or opening the editor) fixes them.
extends RefCounted

const TrialPlan := preload("res://scripts/trial_plan.gd")

const DEFAULT_ROOT: String = "res://audio/cries"
## Audio formats that are reported (not used) when found beside the clips.
const OTHER_AUDIO_EXTENSIONS: Array[String] = ["ogg", "mp3", "flac", "aif", "aiff", "opus", "m4a", "wma"]
## Synthesized stand-ins written by tools/make_placeholder_cries.py.
const PLACEHOLDER_PREFIX: String = "placeholder_"
const IMPORT_COMMAND: String = "godot --headless --path game --import"
const MEASURE_COMMAND: String = "godot --headless --path game -s res://tools/measure_loudness.gd -- --write"

var root: String = DEFAULT_ROOT
## Non-blocking notes from the last discover() (skipped audio, mixed placeholders).
## Already printed with push_warning().
var warnings: PackedStringArray = []
## Clips that aren't imported or don't load, from the last discover(). Any problem keeps
## Start disabled. Already printed with push_warning().
var problems: PackedStringArray = []
## Compare the raw files with the imported ones (exported builds have no raw files).
var check_raw_files: bool = not OS.has_feature("template")
## Lists one folder like ResourceLoader.list_directory(). The tests swap in fakes.
var list_folder: Callable = ResourceLoader.list_directory
## Lists the raw file names in one folder. Empty means DirAccess.get_files_at(); tests swap it.
var list_raw_files: Callable = Callable()
## Loads one clip path. Empty means load(); the tests swap in fakes.
var load_clip: Callable = Callable()
## The per-trial loudness table (TrialPlan.LOUDNESS_TABLE_PATH); "" skips the check (tests).
var loudness_table_path: String = TrialPlan.LOUDNESS_TABLE_PATH
## clip resource path -> {level: emitter gain in dB}, from the loudness table.
var loudness_gains: Dictionary = {}
var _clips: Dictionary = {}  # level -> PackedStringArray of resource paths
var _streams: Dictionary = {}  # resource path -> AudioStream (only clips that loaded)


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


## True when a folder's clip names mix placeholder_*.wav with real clips.
static func mixes_placeholders(clip_names: PackedStringArray) -> bool:
	var placeholders: int = 0
	for file_name: String in clip_names:
		if file_name.to_lower().begins_with(PLACEHOLDER_PREFIX):
			placeholders += 1
	return placeholders > 0 and placeholders < clip_names.size()


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
	problems.clear()
	_clips.clear()
	_streams.clear()
	loudness_gains.clear()
	for level: String in TrialPlan.LEVELS:
		var folder: String = folder_for(level)
		var listing: PackedStringArray = list_folder.call(folder)
		var split: Dictionary = filter_clip_names(listing)
		var clip_names: PackedStringArray = split["clips"]
		var paths: PackedStringArray = []
		var unloadable: PackedStringArray = []
		for file_name: String in clip_names:
			var path: String = folder.path_join(file_name)
			var loaded: Variant = load_clip.call(path) if load_clip.is_valid() else load(path)
			if loaded is AudioStream:
				paths.append(path)
				_streams[path] = loaded
			else:
				unloadable.append(file_name)
		_clips[level] = paths
		var not_imported: PackedStringArray = []
		if check_raw_files:
			for raw_name: String in filter_clip_names(_raw_files(folder))["clips"]:
				if not clip_names.has(raw_name):
					not_imported.append(raw_name)
		for file_name: String in split["skipped_audio"]:
			_warn("skipped %s (only .wav clips are used)" % folder.path_join(file_name))
		if not not_imported.is_empty():
			_problem("not imported yet: %s in %s. Run  %s  and restart."
					% [", ".join(not_imported), folder, IMPORT_COMMAND])
		if not unloadable.is_empty():
			_problem("could not load %s in %s. Run  %s  and restart."
					% [", ".join(unloadable), folder, IMPORT_COMMAND])
		if mixes_placeholders(clip_names + not_imported):
			_warn("placeholders mixed with real clips in %s: delete the %s*.wav files there."
					% [folder, PLACEHOLDER_PREFIX])
	_check_loudness()


## Every loaded clip needs a loudness gain for every level, or its trials would play louder
## or quieter than the rest (a level giveaway). Missing entries are a problem.
func _check_loudness() -> void:
	if loudness_table_path.is_empty():
		return
	var table: Variant = null
	if FileAccess.file_exists(loudness_table_path):
		table = JSON.parse_string(FileAccess.get_file_as_string(loudness_table_path))
	if not table is Dictionary or not (table as Dictionary).get("gains_db") is Dictionary:
		_problem("no loudness table at %s. Run  %s  and restart." % [loudness_table_path, MEASURE_COMMAND])
		return
	loudness_gains = table["gains_db"]
	var missing: PackedStringArray = []
	for level: String in TrialPlan.LEVELS:
		for path: String in _clips.get(level, PackedStringArray()):
			var gains: Variant = loudness_gains.get(path)
			for each: String in TrialPlan.LEVELS:
				if not gains is Dictionary or not (gains as Dictionary).has(each):
					missing.append(path.get_file())
					break
	if not missing.is_empty():
		_problem("loudness not measured for %s. Run  %s  and restart." % [", ".join(missing), MEASURE_COMMAND])


## The emitter gain (dB) that brings `clip_path` played through `level` to the common loudness.
func gain_db(clip_path: String, level: String) -> float:
	var gains: Variant = loudness_gains.get(clip_path)
	return float((gains as Dictionary).get(level, 0.0)) if gains is Dictionary else 0.0


func folder_for(level: String) -> String:
	return root.path_join(level) + "/"


func clips_for(level: String) -> PackedStringArray:
	return _clips.get(level, PackedStringArray())


func empty_levels() -> PackedStringArray:
	return find_empty_levels(_clips)


## The stream loaded for `clip_path` by discover(), or null if it has none.
func stream_for(clip_path: String) -> AudioStream:
	return _streams.get(clip_path, null) as AudioStream


## One random clip for `level`, or "" if the level has none.
func pick(level: String, rng: RandomNumberGenerator) -> String:
	var clips: PackedStringArray = clips_for(level)
	if clips.is_empty():
		return ""
	return clips[rng.randi_range(0, clips.size() - 1)]


## One random clip from any cry folder: a folder with clips is picked first (each equally
## likely, however many clips it holds), then a clip in it. "" if no folder has clips.
func pick_any(rng: RandomNumberGenerator) -> String:
	var kinds: PackedStringArray = []
	for level: String in TrialPlan.LEVELS:
		if not clips_for(level).is_empty():
			kinds.append(level)
	if kinds.is_empty():
		return ""
	return pick(kinds[rng.randi_range(0, kinds.size() - 1)], rng)


## The cry folder (kind of cry) a clip path came from, e.g. "below".
static func kind_of(clip_path: String) -> String:
	return clip_path.get_base_dir().get_file()


func _raw_files(folder: String) -> PackedStringArray:
	if list_raw_files.is_valid():
		return list_raw_files.call(folder)
	if not DirAccess.dir_exists_absolute(folder):
		return PackedStringArray()
	return DirAccess.get_files_at(folder)


func _warn(text: String) -> void:
	var message: String = "Ear test: " + text
	warnings.append(message)
	push_warning(message)


func _problem(text: String) -> void:
	var message: String = "Ear test: " + text
	problems.append(message)
	push_warning(message)
