## The span's rules. For now only the parts ledger (Novel Pattern 1): every plank and rope is
## always in exactly one place and moves only through move_parts().
class_name SpanRules
extends RefCounted


## Moves parts from one place to another. The only function that changes a part count.
## Every bad call is a fault, and no part appears or vanishes:
## - a place that cannot hold the part (a plank on a rail): nothing moves;
## - a negative count: nothing moves;
## - too few at `from`: what there is moves;
## - too little room at `to` (a full deck, a rail that is up): what fits moves.
static func move_parts(kind: NightTypes.Part, count: int,
		from: PartPlace, to: PartPlace, sim: NightSim) -> void:
	if not sim.span.holds(kind, from) or not sim.span.holds(kind, to):
		sim.faults.report(&"span.bad_place", "%s from %s to %s"
				% [NightTypes.Part.find_key(kind), from.label(), to.label()])
		return
	if count < 0:
		sim.faults.report(&"span.bad_count", "%d %s from %s to %s"
				% [count, NightTypes.Part.find_key(kind), from.label(), to.label()])
		return
	if sim.span.count_at(kind, from) < count:
		sim.faults.report(&"span.parts_short", "%s from %s" % [NightTypes.Part.find_key(kind), from.label()])
		count = sim.span.count_at(kind, from)
	if sim.span.fits_at(kind, to, count) < count:
		sim.faults.report(&"span.no_room", "%d %s to %s" % [count, NightTypes.Part.find_key(kind), to.label()])
		count = sim.span.fits_at(kind, to, count)
	sim.span.add_at(kind, from, -count)
	sim.span.add_at(kind, to, count)
