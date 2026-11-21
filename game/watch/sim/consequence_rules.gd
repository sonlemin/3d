## What follows when the span changes (AD-48, AD-64; Novel Pattern 5): a rule that changes the span
## changes only the span, and settle() decides what follows, as a fixed list of small named steps
## in AD-64's order (the footing of the dead, rigs, lanterns, parts, hooks, the warden). A new
## consequence is a new step, never a branch in an old one. Each step looks at the whole state, so
## a second settle() in the same tick changes nothing. Run at steps 4 and 8 of the tick (AD-34).
##
## Story 1.5 settles a fall: the test weights on a fallen section fall with it, its planks and
## ropes are lost through the ledger, a warden on it catches the edge and climbs back toward the
## town (decision D3), a warden beside it steps back from the gap (decision D2), and a warden
## already hanging from it catches the next edge.
class_name ConsequenceRules
extends RefCounted


## The steps, in order (a test compares the list literally).
static func steps() -> Array[Callable]:
	return [ConsequenceRules.weights_fall, ConsequenceRules.parts_lost, ConsequenceRules.warden_footing]


static func settle(sim: NightSim) -> void:
	for step: Callable in steps():
		step.call(sim)


## The footing of the dead; for now the test weights that stand in for them (story 1.5): every
## weight on a fallen section is gone, and so is every lift still to come there.
static func weights_fall(sim: NightSim) -> void:
	for n: int in range(1, sim.def.section_count + 1):
		if not sim.span.fallen(n):
			continue
		if sim.span.weights(n) > 0:
			sim.span.clear_weights(n)
		sim.span.drop_lifts(func(lift: Vector2i) -> bool: return lift.x == n)


## Parts (GDD Game Mechanics 2: "the planks and rail ropes still on it are lost"): every plank and
## rope still on a fallen section moves to lost through the ledger, so the totals stay whole.
static func parts_lost(sim: NightSim) -> void:
	for n: int in range(1, sim.def.section_count + 1):
		if not sim.span.fallen(n):
			continue
		var planks: int = sim.span.planks(n)
		if planks > 0:
			SpanRules.move_parts(NightTypes.Part.PLANK, planks, PartPlace.deck(n), PartPlace.lost(), sim)
		for side: NightTypes.Side in [NightTypes.Side.LEFT, NightTypes.Side.RIGHT]:
			if sim.span.rail_standing(n, side):
				SpanRules.move_parts(NightTypes.Part.ROPE, 1, PartPlace.rail(n, side), PartPlace.lost(), sim)


## The warden. Walking: feet on a section that fell, and on no standing floor, catch the edge and
## the climb back begins (decision D3); feet beside a gap, within the clearance of it, step back
## from it (decision D2), and a running hold is not charged for that step. Climbing: the edge hung
## from may itself have gone, so the hang point is worked out again (code review 2026-11-22).
static func warden_footing(sim: NightSim) -> void:
	if not WardenRules.walking(sim):
		WardenRules.hang_on(sim)
		return
	var under: int = WardenRules.fell_from(sim)
	if under > 0:
		WardenRules.start_climb(under, sim)
		return
	var before: Vector3 = sim.warden.position
	WardenRules.step_back(sim)
	HoldRules.feet_moved(sim.warden.position - before, sim)
