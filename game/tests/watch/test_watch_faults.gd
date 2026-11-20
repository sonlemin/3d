## WatchFaults (AD-28, AD-36): the one fault channel. It reports the first occurrence of each
## code with push_error and counts every occurrence. Each provoked error sits in an expect
## window, so the logger proves "first time only".
extends TestCase


func _test_first_report_logs_once() -> void:
	var faults: WatchFaults = WatchFaults.new()
	_expect_begin()
	faults.report(&"test.code", "first")
	faults.report(&"test.code", "second")
	faults.report(&"test.code", "third")
	_expect_end("faults: three reports of one code", [["ERROR", "test.code: first", 1]])
	_check("faults: the code was counted three times", faults.count(&"test.code") == 3, str(faults.count(&"test.code")))
	_check("faults: total is 3", faults.total() == 3, str(faults.total()))


func _test_each_code_logs_once() -> void:
	var faults: WatchFaults = WatchFaults.new()
	_expect_begin()
	faults.report(&"test.one", "a")
	faults.report(&"test.two", "b")
	faults.report(&"test.one", "c")
	_expect_end("faults: two codes", [["ERROR", "test.one: a", 1], ["ERROR", "test.two: b", 1]])
	_check("faults: counts per code", faults.count(&"test.one") == 2 and faults.count(&"test.two") == 1)
	_check("faults: total over codes", faults.total() == 3, str(faults.total()))
	_check("faults: codes in order of first report", faults.codes() == [&"test.one", &"test.two"], str(faults.codes()))


func _test_fresh_channel_is_empty() -> void:
	var faults: WatchFaults = WatchFaults.new()
	_check("faults: a new channel has no faults",
			faults.total() == 0 and faults.codes().is_empty() and faults.count(&"test.code") == 0)


func _test_channels_are_separate() -> void:
	# One object per night (AD-36): a new night reports a code again the first time.
	var first_night: WatchFaults = WatchFaults.new()
	var second_night: WatchFaults = WatchFaults.new()
	_expect_begin()
	first_night.report(&"test.code", "night 1")
	second_night.report(&"test.code", "night 2")
	_expect_end("faults: each night reports its first", [["ERROR", "test.code: night 1", 1],
			["ERROR", "test.code: night 2", 1]])
	_check("faults: counts stay per night", first_night.total() == 1 and second_night.total() == 1)
