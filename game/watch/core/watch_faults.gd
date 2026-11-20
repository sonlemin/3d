## The one fault channel (AD-28, AD-36). A fault is a bug noticed at run time: the caller puts
## the value back in range and carries on, and reports it here. This is the only code that calls
## push_error for a fault. The first occurrence of each code is logged, every occurrence is
## counted, so a fault inside a tick loop cannot flood the log, and the playtest log's night
## summary (AD-60) can carry the counts. One object per night; a new night starts clean.
class_name WatchFaults
extends RefCounted

## code -> how many times it was reported. Insertion order is first-report order.
var _counts: Dictionary[StringName, int] = {}


## `code` is `system.what`, lower snake (`dead.off_span`); `detail` says what was seen.
func report(code: StringName, detail: String) -> void:
	if not _counts.has(code):
		_counts[code] = 0
		push_error("%s: %s" % [code, detail])
	_counts[code] += 1


func count(code: StringName) -> int:
	return _counts.get(code, 0)


func total() -> int:
	var sum: int = 0
	for code: StringName in _counts:
		sum += _counts[code]
	return sum


## The codes reported so far, in the order each was first reported.
func codes() -> Array[StringName]:
	var out: Array[StringName] = []
	out.assign(_counts.keys())
	return out
