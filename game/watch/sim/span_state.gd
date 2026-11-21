## The span's base facts (AD-35): planks per deck, the rope of each rail, and the parts in hand
## and lost; since story 1.5 also the test weights on each section, the lifts still to come
## (decision D1), whether a section has fallen, and its creak and groan (a phase and a countdown,
## architecture State Patterns: needed to emit an event on the tick one starts or stops).
## Strength, "open" and load are computed when needed, never stored here.
## Part counts change only through add_at(), which only SpanRules.move_parts() calls (Novel
## Pattern 1; a test checks). A plank on a rail or a rope on a deck is a fault, not a crash.
## The load facts are set by SpanRules and ConsequenceRules, and by NightSim._apply_start() while
## the night is built.
class_name SpanState
extends RefCounted

## Section (1 to n) -> planks on its deck.
var _planks: Dictionary[int, int] = {}
## (section, side) -> 1 when the rail's rope is up, 0 when it is down.
var _ropes: Dictionary[Vector2i, int] = {}
var _hand: Dictionary[NightTypes.Part, int] = {NightTypes.Part.PLANK: 0, NightTypes.Part.ROPE: 0}
var _lost: Dictionary[NightTypes.Part, int] = {NightTypes.Part.PLANK: 0, NightTypes.Part.ROPE: 0}
## The most planks a deck holds; a rail holds one rope.
var _planks_per_section: int = 0
var _faults: WatchFaults
## Story 1.5: section -> true once it has fallen; a gap for the rest of the night. Stored, since a
## section with no planks may be open or fallen.
var _fallen: Dictionary[int, bool] = {}
## Section -> true while it creaks (its load equals its strength, above 0).
var _creaking: Dictionary[int, bool] = {}
## Section -> ticks its groan has left before it falls; 0 when not groaning.
var _groan_left: Dictionary[int, int] = {}
## Section -> test weights standing on it.
var _weights: Dictionary[int, int] = {}
## Decision D1: the lifts still to come, each Vector2i(section, tick), in StartState order.
var _lifts: Array[Vector2i] = []


## A full span: every deck at `planks_per_section`, every rail up, nothing in hand.
func _init(sections: int, planks_per_section: int, faults: WatchFaults) -> void:
	_faults = faults
	_planks_per_section = planks_per_section
	for n: int in range(1, sections + 1):
		_planks[n] = planks_per_section
		_ropes[Vector2i(n, NightTypes.Side.LEFT)] = 1
		_ropes[Vector2i(n, NightTypes.Side.RIGHT)] = 1
		_fallen[n] = false
		_creaking[n] = false
		_groan_left[n] = 0
		_weights[n] = 0


func section_count() -> int:
	return _planks.size()


func planks(section: int) -> int:
	if not _planks.has(section):
		_faults.report(&"span.bad_section", "planks(%d)" % section)
		return 0
	return _planks[section]


## Story 1.5: true once section `n` has fallen.
func fallen(n: int) -> bool:
	if not _fallen.has(n):
		_faults.report(&"span.bad_section", "fallen(%d)" % n)
		return false
	return _fallen[n]


func creaking(n: int) -> bool:
	if not _creaking.has(n):
		_faults.report(&"span.bad_section", "creaking(%d)" % n)
		return false
	return _creaking[n]


## Ticks the groan of section `n` has left; 0 when it is not groaning.
func groan_left(n: int) -> int:
	if not _groan_left.has(n):
		_faults.report(&"span.bad_section", "groan_left(%d)" % n)
		return 0
	return _groan_left[n]


## Test weights standing on section `n`.
func weights(n: int) -> int:
	if not _weights.has(n):
		_faults.report(&"span.bad_section", "weights(%d)" % n)
		return 0
	return _weights[n]


## Decision D1: the lifts still to come, each Vector2i(section, tick). A copy.
func lifts() -> Array[Vector2i]:
	return _lifts.duplicate()


func set_fallen(n: int) -> void:
	if _check(n, "set_fallen"):
		_fallen[n] = true


func set_creaking(n: int, on: bool) -> void:
	if _check(n, "set_creaking"):
		_creaking[n] = on


func set_groan_left(n: int, ticks: int) -> void:
	if _check(n, "set_groan_left"):
		_groan_left[n] = maxi(ticks, 0)


## Puts `count` more test weights on section `n` (the StartState).
func add_weights(n: int, count: int) -> void:
	if _check(n, "add_weights"):
		_weights[n] = maxi(_weights[n] + count, 0)


## One weight leaves section `n` (a lift of D1). None there: nothing happens.
func take_weight(n: int) -> void:
	if _check(n, "take_weight"):
		_weights[n] = maxi(_weights[n] - 1, 0)


## Every weight on section `n` is gone (it fell with the section).
func clear_weights(n: int) -> void:
	if _check(n, "clear_weights"):
		_weights[n] = 0


## A lift still to come (the StartState).
func add_lift(lift: Vector2i) -> void:
	if _check(lift.x, "add_lift"):
		_lifts.append(lift)


## Drops every lift still to come that `drop` returns true for, `(lift: Vector2i) -> bool`.
func drop_lifts(drop: Callable) -> void:
	_lifts = _lifts.filter(func(lift: Vector2i) -> bool: return not drop.call(lift))


func rail_standing(section: int, side: NightTypes.Side) -> bool:
	var key: Vector2i = Vector2i(section, side)
	if not _ropes.has(key):
		_faults.report(&"span.bad_section", "rail_standing(%d, %d)" % [section, side])
		return false
	return _ropes[key] > 0


func in_hand(kind: NightTypes.Part) -> int:
	return _hand[kind]


## True when `place` can hold parts of `kind`: planks on decks, ropes on rails, both in hand
## and lost, on sections that exist. Pure; reports nothing.
func holds(kind: NightTypes.Part, place: PartPlace) -> bool:
	match place.kind:
		PartPlace.Kind.DECK:
			return kind == NightTypes.Part.PLANK and _planks.has(place.section)
		PartPlace.Kind.RAIL:
			return kind == NightTypes.Part.ROPE and _ropes.has(Vector2i(place.section, place.side))
	return true


func count_at(kind: NightTypes.Part, place: PartPlace) -> int:
	if not holds(kind, place):
		_faults.report(&"span.bad_place", "%s at %s" % [NightTypes.Part.find_key(kind), place.label()])
		return 0
	match place.kind:
		PartPlace.Kind.DECK:
			return _planks[place.section]
		PartPlace.Kind.RAIL:
			return _ropes[Vector2i(place.section, place.side)]
		PartPlace.Kind.HAND:
			return _hand[kind]
	return _lost[kind]


## How many of `count` more parts `place` has room for: a deck up to the planks per section, a
## rail one rope, the hand and lost any number. Pure; reports nothing.
func fits_at(kind: NightTypes.Part, place: PartPlace, count: int) -> int:
	if not holds(kind, place):
		return 0
	match place.kind:
		PartPlace.Kind.DECK:
			# Story 1.5: a fallen deck has no room; parts can still be moved off it (to lost).
			if _fallen[place.section]:
				return 0
			return clampi(_planks_per_section - _planks[place.section], 0, count)
		PartPlace.Kind.RAIL:
			return clampi(1 - _ropes[Vector2i(place.section, place.side)], 0, count)
	return maxi(count, 0)


## Every part of `kind` over all places; always the def's total (the ledger's proof).
func total(kind: NightTypes.Part) -> int:
	var sum: int = _hand[kind] + _lost[kind]
	if kind == NightTypes.Part.PLANK:
		for n: int in _planks:
			sum += _planks[n]
	else:
		for key: Vector2i in _ropes:
			sum += _ropes[key]
	return sum


## Changes one count. Called only by SpanRules.move_parts(), which keeps the totals.
func add_at(kind: NightTypes.Part, place: PartPlace, delta: int) -> void:
	if not holds(kind, place):
		_faults.report(&"span.bad_place", "%s at %s" % [NightTypes.Part.find_key(kind), place.label()])
		return
	match place.kind:
		PartPlace.Kind.DECK:
			_planks[place.section] += delta
		PartPlace.Kind.RAIL:
			_ropes[Vector2i(place.section, place.side)] += delta
		PartPlace.Kind.HAND:
			_hand[kind] += delta
		PartPlace.Kind.LOST:
			_lost[kind] += delta


## For NightSim.checksum(): story 1.5's facts per section (fallen, creaking, groan left, weights),
## then the lifts still to come, in a fixed order.
func values() -> Array:
	var out: Array = []
	for n: int in range(1, _planks.size() + 1):
		out.append_array([_fallen[n], _creaking[n], _groan_left[n], _weights[n]])
	out.append(_lifts.duplicate())
	return out


## For NightSim.checksum(): every count, in a fixed order.
func counts() -> Array[int]:
	var out: Array[int] = []
	for n: int in range(1, _planks.size() + 1):
		out.append(_planks[n])
		out.append(_ropes[Vector2i(n, NightTypes.Side.LEFT)])
		out.append(_ropes[Vector2i(n, NightTypes.Side.RIGHT)])
	for kind: NightTypes.Part in [NightTypes.Part.PLANK, NightTypes.Part.ROPE]:
		out.append(_hand[kind])
		out.append(_lost[kind])
	return out


## True when `n` is a section; otherwise `span.bad_section` naming `what`.
func _check(n: int, what: String) -> bool:
	if not _planks.has(n):
		_faults.report(&"span.bad_section", "%s(%d)" % [what, n])
		return false
	return true
