## What the warden looks at within reach this tick (AD-47): a section's deck, a standing rail, or
## nothing. A value: LookRules makes a new one every tick (AD-35: derived, never carried over), and
## a hold keeps its own copy of the one it began on.
class_name LookTarget
extends RefCounted

enum Kind { NONE, DECK, RAIL }

var kind: Kind = Kind.NONE
## 1 to n; 0 for NONE.
var section: int = 0
## The rail's side; meaningless for a deck.
var side: NightTypes.Side = NightTypes.Side.LEFT
## Metres from the eye to where the view line meets it, along the line.
var distance: float = 0.0


static func none() -> LookTarget:
	return LookTarget.new()


static func deck(n: int, at: float) -> LookTarget:
	return _make(Kind.DECK, n, NightTypes.Side.LEFT, at)


static func rail(n: int, rail_side: NightTypes.Side, at: float) -> LookTarget:
	return _make(Kind.RAIL, n, rail_side, at)


func copy() -> LookTarget:
	return _make(kind, section, side, distance)


## For NightSim.checksum(): the base facts, in a fixed order.
func values() -> Array:
	return [kind, section, side, distance]


static func _make(target_kind: Kind, n: int, target_side: NightTypes.Side, at: float) -> LookTarget:
	var target: LookTarget = LookTarget.new()
	target.kind = target_kind
	target.section = n
	target.side = target_side
	target.distance = at
	return target
