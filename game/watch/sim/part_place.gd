## Where a plank or rope is (Novel Pattern 1): a section's deck, a section's rail, the warden's
## hand, or lost. Every part is in exactly one place. A rig becomes a place in epic 4.
class_name PartPlace
extends RefCounted

enum Kind { DECK, RAIL, HAND, LOST }

var kind: Kind = Kind.HAND
## 1 to n for a deck or a rail; 0 for none.
var section: int = 0
## Which rail; meaningless for the other kinds.
var side: NightTypes.Side = NightTypes.Side.LEFT


static func deck(n: int) -> PartPlace:
	return _make(Kind.DECK, n, NightTypes.Side.LEFT)


static func rail(n: int, rail_side: NightTypes.Side) -> PartPlace:
	return _make(Kind.RAIL, n, rail_side)


static func hand() -> PartPlace:
	return _make(Kind.HAND, 0, NightTypes.Side.LEFT)


static func lost() -> PartPlace:
	return _make(Kind.LOST, 0, NightTypes.Side.LEFT)


## For faults and the trace: `s3 deck`, `s3 L rail`, `hand`, `lost`.
func label() -> String:
	match kind:
		Kind.DECK:
			return "s%d deck" % section
		Kind.RAIL:
			return "s%d %s rail" % [section, "L" if side == NightTypes.Side.LEFT else "R"]
		Kind.HAND:
			return "hand"
	return "lost"


static func _make(place_kind: Kind, n: int, place_side: NightTypes.Side) -> PartPlace:
	var place: PartPlace = PartPlace.new()
	place.kind = place_kind
	place.section = n
	place.side = place_side
	return place
