## project.godot and the export presets after the game moved in beside the ear test (story 1.1,
## AD-12, AD-43, AD-69). Values are written literally from the story; both files are read as
## text through ConfigFile, so the `.eartest` overrides are checked as written, not as applied.
extends TestCase

const PROJECT_PATH: String = "res://project.godot"
const PRESETS_PATH: String = "res://export_presets.cfg"


func _project() -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(PROJECT_PATH)
	_check("project: project.godot parses", err == OK, error_string(err))
	return config


func _test_game_is_the_main_scene() -> void:
	var config: ConfigFile = _project()
	# Story 1.1 Dev Notes, "project.godot: the exact lines".
	_check("project: main scene is res://watch/main.tscn",
			config.get_value("application", "run/main_scene", "") == "res://watch/main.tscn")
	_check("project: name is The Mourning Watch",
			config.get_value("application", "config/name", "") == "The Mourning Watch")


func _test_ear_test_overrides() -> void:
	var config: ConfigFile = _project()
	# AD-43: the ear test's builds (feature `eartest`) keep their name, scene and user folder.
	_check("project: name.eartest is Ear Test",
			config.get_value("application", "config/name.eartest", "") == "Ear Test")
	_check("project: main_scene.eartest is the ear test's scene",
			config.get_value("application", "run/main_scene.eartest", "") == "res://scenes/ear_test.tscn")
	var custom_off: Variant = config.get_value("application", "config/use_custom_user_dir.eartest", "missing")
	_check("project: use_custom_user_dir.eartest is false (app_userdata/Ear Test as before)",
			custom_off is bool and custom_off == false, str(custom_off))


func _test_user_folder_pinned() -> void:
	var config: ConfigFile = _project()
	# Decision with Sonlm, 2026-11-20: the folder is `mourning_watch`, not the working title.
	var custom_on: Variant = config.get_value("application", "config/use_custom_user_dir", "missing")
	_check("project: use_custom_user_dir is true", custom_on is bool and custom_on == true, str(custom_on))
	_check("project: custom_user_dir_name is mourning_watch",
			config.get_value("application", "config/custom_user_dir_name", "") == "mourning_watch")


func _test_physics_ticks() -> void:
	var config: ConfigFile = _project()
	# AD-52: the physics tick is only the simulation's clock, 60 per second.
	_check("project: physics_ticks_per_second is 60 in the file",
			config.get_value("physics", "common/physics_ticks_per_second", 0) == 60)
	_check("project: the engine runs 60 physics ticks per second", Engine.physics_ticks_per_second == 60)


func _test_canvas_untouched() -> void:
	var config: ConfigFile = _project()
	# AD-69: 1280x720, canvas_items, expand. Never change those lines.
	_check("project: viewport 1280x720",
			config.get_value("display", "window/size/viewport_width", 0) == 1280
			and config.get_value("display", "window/size/viewport_height", 0) == 720)
	_check("project: stretch mode canvas_items",
			config.get_value("display", "window/stretch/mode", "") == "canvas_items")
	_check("project: stretch aspect expand",
			config.get_value("display", "window/stretch/aspect", "") == "expand")


func _test_ear_test_lines_kept() -> void:
	var config: ConfigFile = _project()
	# The ear test's project.godot as of commit 555918b; every one of these lines is kept.
	_check("project: description kept", config.get_value("application", "config/description", "")
			== "Private gray-box test: can players place a cry's direction and level by ear?")
	_check("project: features 4.7 / Forward Plus kept",
			config.get_value("application", "config/features", PackedStringArray())
			== PackedStringArray(["4.7", "Forward Plus"]))
	_check("project: 3d_panning_strength 1.0 kept",
			config.get_value("audio", "general/3d_panning_strength", 0.0) == 1.0)
	_check("project: default bus layout kept",
			config.get_value("audio", "buses/default_bus_layout", "") == "res://default_bus_layout.tres")
	_check("project: untyped_declaration is an error (2)",
			config.get_value("debug", "gdscript/warnings/untyped_declaration", 0) == 2)
	var wav: Variant = config.get_value("importer_defaults", "wav", {})
	_check("project: WAVs import as mono", wav is Dictionary and (wav as Dictionary).get("force/mono", false) == true)
	_check("project: renderer forward_plus kept",
			config.get_value("rendering", "renderer/rendering_method", "") == "forward_plus")


func _test_no_autoload_no_input_section() -> void:
	var config: ConfigFile = _project()
	# AD-10: no autoloads. AD-20: the input map is registered in code, never in project.godot.
	_check("project: no [autoload] section", not config.has_section("autoload"))
	_check("project: no [input] section", not config.has_section("input"))


func _test_ear_test_presets() -> void:
	var presets: ConfigFile = ConfigFile.new()
	var err: Error = presets.load(PRESETS_PATH)
	_check("presets: export_presets.cfg parses", err == OK, error_string(err))
	# Story 1.1 AC 3: the ear test's two presets, names kept, feature `eartest` added,
	# include filter kept (the ear test's own test counts that line).
	var expected: Dictionary[String, String] = {"preset.0": "Linux", "preset.1": "Windows"}
	for section: String in expected:
		var preset_name: String = expected[section]
		_check("presets: %s is named %s" % [section, preset_name],
				presets.get_value(section, "name", "") == preset_name)
		_check("presets: %s has custom_features eartest" % preset_name,
				presets.get_value(section, "custom_features", "") == "eartest")
		_check("presets: %s keeps its include filter" % preset_name,
				presets.get_value(section, "include_filter", "") == "audio/cries/loudness.json")
		_check("presets: %s still excludes tests and tools" % preset_name,
				presets.get_value(section, "exclude_filter", "") == "tests/*, tools/*")
	_check("presets: no third preset yet (game presets come in epic 2)", not presets.has_section("preset.2"))
