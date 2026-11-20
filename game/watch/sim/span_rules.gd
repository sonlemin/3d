## The span's rules. For now only the parts ledger (Novel Pattern 1): every plank and rope is
## always in exactly one place and moves only through move_parts().
class_name SpanRules
extends RefCounted


## Moves parts from one place to another. The only function that changes a part count.
## A place that cannot hold the part (a plank on a rail) is a fault and nothing moves, so no
## part vanishes; too few at `from` is a fault and what there is moves.
static func move_parts(kind: NightTypes.Part, count: int,
		from: PartPlace, to: PartPlace, sim: NightSim) -> void:
	if not sim.span.holds(kind, from) or not sim.span.holds(kind, to):
		sim.faults.report(&"span.bad_place", "%s from %s to %s"
				% [NightTypes.Part.find_key(kind), from.label(), to.label()])
		return
	if sim.span.count_at(kind, from) < count:
		sim.faults.report(&"span.parts_short", "%s from %s" % [NightTypes.Part.find_key(kind), from.label()])
		count = sim.span.count_at(kind, from)
	sim.span.add_at(kind, from, -count)
	sim.span.add_at(kind, to, count)
