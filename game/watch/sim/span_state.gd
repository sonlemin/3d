## The span's base facts (AD-35): planks per deck, the rope of each rail, and the parts in hand
## and lost. Strength, "open" and load are computed when needed, never stored here.
## Counts change only through add_at(), which only SpanRules.move_parts() calls (Novel
## Pattern 1; a test checks). A plank on a rail or a rope on a deck is a fault, not a crash.
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


## A full span: every deck at `planks_per_section`, every rail up, nothing in hand.
func _init(sections: int, planks_per_section: int, faults: WatchFaults) -> void:
	_faults = faults
	_planks_per_section = planks_per_section
	for n: int in range(1, sections + 1):
		_planks[n] = planks_per_section
		_ropes[Vector2i(n, NightTypes.Side.LEFT)] = 1
		_ropes[Vector2i(n, NightTypes.Side.RIGHT)] = 1


func section_count() -> int:
	return _planks.size()


func planks(section: int) -> int:
	if not _planks.has(section):
		_faults.report(&"span.bad_section", "planks(%d)" % section)
		return 0
	return _planks[section]


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
