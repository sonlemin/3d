## Headless test runner, no framework:
##     godot --headless --path game -s res://tests/run_tests.gd
## Finds every `test_*.gd` under res://tests/ (sorted by path), and in each file every method
## whose name starts with `_test_`, in declaration order. Nothing is listed by hand, so a new
## test cannot be forgotten. Each file must extend TestCase. A file with `_test_` functions
## under another name fails the run, and so does a test that stops before its end (a script
## error inside an expect window, or `await`): see TestCase._after_test.
##
## Prints one PASS/FAIL line per check, one summary line per file and a final total line
## ("N passed, M failed. ..."), which tools/ci.sh reads; exits 1 if anything failed.
##
## One logger (TestCase.LogCounter) sees every engine error, script error and warning during the
## run. Each file ends with a logger check over what was logged while it loaded and ran: any
## entry its tests did not ask for (see TestCase._expect_begin) fails that file.
extends SceneTree

const TESTS_DIR: String = "res://tests"
## The base class is not a test file, though its name matches `test_*.gd`.
const BASE_PATH: String = "res://tests/test_case.gd"
const LOGGER_CHECK: String = "logger: no unexpected engine/script errors or warnings during the run"

var _logger: TestCase.LogCounter = TestCase.LogCounter.new()
## How many of the logger's unexpected entries a file's logger check has already covered.
var _seen: int = 0
var _passed: int = 0
var _failed: int = 0
var _expected_total: int = 0


func _initialize() -> void:
	OS.add_logger(_logger)
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var paths: PackedStringArray = _find_test_files(TESTS_DIR)
	paths.sort()
	var file_lines: PackedStringArray = []
	if paths.is_empty():
		_runner_fail("no test file (test_*.gd) found under %s" % TESTS_DIR)
	for path: String in _misnamed_test_files(TESTS_DIR):
		_runner_fail("%s has _test_ functions but is not named test_*.gd, so it never runs"
				% path.trim_prefix(TESTS_DIR + "/"))
	for path: String in paths:
		file_lines.append(_run_file(path))

	var leftover: PackedStringArray = _logger.unexpected().slice(_seen)
	if not leftover.is_empty():
		_runner_fail("logged outside any test file: " + " | ".join(leftover))
	OS.remove_logger(_logger)
	print("")
	for line: String in file_lines:
		print(line)
	print("%d passed, %d failed. Logger: %d unexpected errors/warnings, %d expected (triggered on purpose)."
			% [_passed, _failed, _logger.unexpected().size(), _expected_total])
	quit(0 if _failed == 0 else 1)


## Loads one file, runs its tests and its logger check; returns its summary line.
func _run_file(path: String) -> String:
	var short: String = path.trim_prefix(TESTS_DIR + "/")
	print("")
	print("== " + short)
	var script: GDScript = load(path) as GDScript
	if script == null or not script.can_instantiate():
		_runner_fail("%s: does not load" % short)
		_seen = _logger.unexpected().size()
		return "%s: FAILED to load" % short
	if not _extends_test_case(script):
		_runner_fail("%s: does not extend TestCase" % short)
		_seen = _logger.unexpected().size()
		return "%s: FAILED, does not extend TestCase" % short

	var tests: PackedStringArray = _test_methods(script)
	var case: TestCase = script.new() as TestCase
	case.root = root
	case._logger = _logger
	if tests.is_empty():
		case._check("%s: has at least one _test_ function" % short, false)
	case._before_all()
	for method: String in tests:
		case._after_test(method, case.call(method))
	case._after_all()

	var unexpected: PackedStringArray = _logger.unexpected().slice(_seen)
	_seen += unexpected.size()
	case._check(LOGGER_CHECK, unexpected.is_empty(), " | ".join(unexpected))
	_passed += case._passed
	_failed += case._failed
	_expected_total += case._expected_total
	return "%s: %d passed, %d failed, %d expected" % [short, case._passed, case._failed, case._expected_total]


## Every `test_*.gd` below `dir`, at any depth, except the base class.
func _find_test_files(dir: String) -> PackedStringArray:
	var found: PackedStringArray = []
	for file_name: String in DirAccess.get_files_at(dir):
		var path: String = dir.path_join(file_name)
		if file_name.begins_with("test_") and file_name.ends_with(".gd") and path != BASE_PATH:
			found.append(path)
	for sub: String in DirAccess.get_directories_at(dir):
		found.append_array(_find_test_files(dir.path_join(sub)))
	return found


## Every other `.gd` below `dir` that extends TestCase and has `_test_` methods: its tests
## would never run. A base class for test files (no `_test_` method of its own) is fine.
func _misnamed_test_files(dir: String) -> PackedStringArray:
	var found: PackedStringArray = []
	for file_name: String in DirAccess.get_files_at(dir):
		var path: String = dir.path_join(file_name)
		if not file_name.ends_with(".gd") or file_name.begins_with("test_"):
			continue
		var script: GDScript = load(path) as GDScript
		if script != null and _extends_test_case(script) and not _test_methods(script).is_empty():
			found.append(path)
	for sub: String in DirAccess.get_directories_at(dir):
		found.append_array(_misnamed_test_files(dir.path_join(sub)))
	return found


## True when TestCase is somewhere in the script's chain of base scripts.
func _extends_test_case(script: Script) -> bool:
	var current: Script = script
	while current != null:
		if current.resource_path == BASE_PATH:
			return true
		current = current.get_base_script()
	return false


## The script's `_test_` methods in declaration order (get_script_method_list() keeps it;
## never sort them: the ear test's fake clock depends on the order).
func _test_methods(script: Script) -> PackedStringArray:
	var names: PackedStringArray = []
	for method: Dictionary in script.get_script_method_list():
		var method_name: String = method["name"]
		if method_name.begins_with("_test_") and not names.has(method_name):
			names.append(method_name)
	return names


func _runner_fail(text: String) -> void:
	_failed += 1
	print("FAIL  runner: " + text)
