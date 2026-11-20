## Base of every test file. The runner (tests/run_tests.gd) finds each `test_*.gd` under
## res://tests/, makes one of these per file, sets `root` and the shared logger, then calls
## `_before_all()`, every `_test_*()` method in declaration order (each followed by
## `_after_test()`), and `_after_all()`. A test may not use `await`.
##
## Assert with _check(name, ok, detail). Any engine error, script error or warning that a test
## did not ask for fails the file's logger check. A test that triggers some on purpose wraps
## that call in _expect_begin() / _expect_end(..., [[kind, text, count], ...]): exactly those
## entries may appear in the window, each the stated number of times; anything else logged
## there fails too. The engine still prints the expected lines.
##
## `_check`, `_expect_begin`, `_expect_end` and `LogCounter` were moved here from the ear test's
## runner with their bodies unchanged, which is why the counters keep their underscore names.
## Not runtime code: no script under watch/ may name this class (architecture boundary 5).
class_name TestCase
extends RefCounted


## Sees what the engine logs. Called from whichever thread logs, hence the mutex.
## One instance is shared by every test file; the runner reads `unexpected()` per file.
class LogCounter extends Logger:
	const KINDS: PackedStringArray = ["ERROR", "WARNING", "SCRIPT ERROR", "SHADER ERROR"]
	var _mutex: Mutex = Mutex.new()
	var _in_window: bool = false
	var _window: Array = []  # [kind, message, where] logged inside the current window
	var _unexpected: PackedStringArray = []

	func _log_error(function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		var kind: String = KINDS[clampi(error_type, 0, KINDS.size() - 1)]
		var what: String = rationale if not rationale.is_empty() else code
		var where: String = "%s:%d %s" % [file, line, function]
		_mutex.lock()
		if _in_window:
			_window.append([kind, what, where])
		else:
			_unexpected.append("%s: %s (%s)" % [kind, what, where])
		_mutex.unlock()

	func _log_message(_message: String, _error: bool) -> void:
		pass

	func begin_window() -> void:
		_mutex.lock()
		_in_window = true
		_window = []
		_mutex.unlock()

	## The entries logged since begin_window().
	func end_window() -> Array:
		_mutex.lock()
		_in_window = false
		var entries: Array = _window
		_window = []
		_mutex.unlock()
		return entries

	## True between begin_window() and end_window().
	func window_open() -> bool:
		_mutex.lock()
		var open: bool = _in_window
		_mutex.unlock()
		return open

	func add_unexpected(text: String) -> void:
		_mutex.lock()
		_unexpected.append(text)
		_mutex.unlock()

	func unexpected() -> PackedStringArray:
		_mutex.lock()
		var copy: PackedStringArray = _unexpected.duplicate()
		_mutex.unlock()
		return copy


## The runner's scene root, so a test can add a real scene to the tree (root.add_child(...)).
var root: Window
## This file's counts; the runner sums them into the total line.
var _passed: int = 0
var _failed: int = 0
var _expected_total: int = 0
## Shared by every file; set by the runner before _before_all().
var _logger: LogCounter


## Called once before this file's first test. Override to clear scratch folders.
func _before_all() -> void:
	pass


## Called once after this file's last test.
func _after_all() -> void:
	pass


## Called by the runner after each test with what the call returned. A test must run to its
## end in one go; two ways of stopping early would otherwise pass in silence:
## - a script error ends the function where it stands. Inside an expect window the error is
##   held by the window, so the window is closed here and what it held becomes unexpected;
## - `await` makes the function a coroutine that returns at once, so later checks never count.
func _after_test(method: String, result: Variant) -> void:
	if result is Object and (result as Object).get_class() == "GDScriptFunctionState":
		_check("%s: a test may not use await (checks after it never run)" % method, false)
	if _logger.window_open():
		var held: PackedStringArray = []
		for entry: Array in _logger.end_window():
			var text: String = "%s: %s (%s)" % [entry[0], entry[1], entry[2]]
			held.append(text)
			_logger.add_unexpected(text)
		_check("%s: stopped inside an expect window (a script error, or no _expect_end)" % method,
				false, " | ".join(held))


func _check(test_name: String, ok: bool, detail: String = "") -> void:
	if ok:
		_passed += 1
		print("PASS  " + test_name)
	else:
		_failed += 1
		print("FAIL  %s%s" % [test_name, "" if detail.is_empty() else "  -- " + detail])


## Starts a window for log entries a test triggers on purpose; see _expect_end().
func _expect_begin() -> void:
	_logger.begin_window()


## Ends the window. `expected` lists [kind, text, count]: exactly `count` entries of that kind
## ("ERROR", "WARNING", "SCRIPT ERROR") whose message contains `text`. Any other entry in the
## window is unexpected (it also fails the final logger check).
func _expect_end(test_name: String, expected: Array) -> void:
	var entries: Array = _logger.end_window()
	var problems: PackedStringArray = []
	for want: Array in expected:
		var hits: int = 0
		for i: int in range(entries.size() - 1, -1, -1):
			var entry: Array = entries[i]
			if entry[0] == want[0] and String(entry[1]).contains(want[1]):
				hits += 1
				entries.remove_at(i)
		_expected_total += hits
		if hits != want[2]:
			problems.append("%d x %s '%s', expected %d" % [hits, want[0], want[1], want[2]])
	for entry: Array in entries:
		var text: String = "%s: %s (%s)" % [entry[0], entry[1], entry[2]]
		problems.append("unexpected " + text)
		_logger.add_unexpected(text)
	_check(test_name + ": logged exactly the expected errors/warnings", problems.is_empty(), " | ".join(problems))
