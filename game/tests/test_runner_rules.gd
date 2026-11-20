## The runner's own rules (TestCase._after_test): a test that stops before its end must fail.
## Each case runs on a quiet probe with a logger of its own, so nothing here reaches the
## run's real logger or prints a FAIL line.
extends TestCase


## A TestCase whose checks are counted without printing.
class Probe extends TestCase:
	func _init() -> void:
		_logger = TestCase.LogCounter.new()

	func _check(_test_name: String, ok: bool, _detail: String = "") -> void:
		if ok:
			_passed += 1
		else:
			_failed += 1

	func plain() -> void:
		pass

	func waits(tree: SceneTree) -> void:
		await tree.process_frame


func _test_plain_test_passes() -> void:
	var probe: Probe = Probe.new()
	probe._after_test("plain", probe.call(&"plain"))
	_check("runner: a test that runs to its end adds no failure", probe._failed == 0 and probe._passed == 0,
			"%d failed, %d passed" % [probe._failed, probe._passed])


func _test_open_window_fails() -> void:
	# What a script error between _expect_begin() and _expect_end() leaves behind.
	var probe: Probe = Probe.new()
	probe._expect_begin()
	probe._logger._log_error("f", "res://x.gd", 3, "boom", "", false, 2, [])
	probe._after_test("stops", null)
	var unexpected: PackedStringArray = probe._logger.unexpected()
	_check("runner: a test that ends inside an expect window fails", probe._failed == 1, str(probe._failed))
	_check("runner: what the window held becomes unexpected",
			unexpected.size() == 1 and unexpected[0].begins_with("SCRIPT ERROR: boom"), str(unexpected))
	_check("runner: the window is closed for the next test", not probe._logger.window_open())
	probe._logger._log_error("f", "res://x.gd", 4, "later", "", false, 0, [])
	_check("runner: an error in the next test is seen again", probe._logger.unexpected().size() == 2)


func _test_await_fails() -> void:
	var probe: Probe = Probe.new()
	probe._after_test("waits", probe.call(&"waits", root.get_tree()))
	_check("runner: a test that awaits fails", probe._failed == 1, str(probe._failed))
