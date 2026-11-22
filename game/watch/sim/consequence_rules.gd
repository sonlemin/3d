## What follows when the span changes (AD-48, AD-64; Novel Pattern 5): a rule that changes the span
## changes only the span, and settle() decides what follows, as a fixed list of small named steps
## in AD-64's order (the footing of the dead, rigs, lanterns, parts, hooks, the warden). A new
## consequence is a new step, never a branch in an old one. Each step looks at the whole state, so
## a second settle() in the same tick changes nothing. Run at steps 4 and 8 of the tick (AD-34).
##
## Story 1.5 settles a fall: the test weights on a fallen section fall with it, its planks and
## ropes are lost through the ledger, a warden on it catches the edge and climbs back toward the
## town (decision D3), a warden beside it steps back from the gap (decision D2), and a warden
## already hanging from it catches the next edge. Story 1.6 settles a section going open: a warden
## on it is on its side beam (GD-68, warden_on_beams), a warden beside it steps back (decision D3);
## and a warden edging along a section that falls catches the edge (AC 10).
class_name ConsequenceRules
extends RefCounted


## The steps, in order (a test compares the list literally).
static func steps() -> Array[Callable]:
	return [ConsequenceRules.weights_fall, ConsequenceRules.parts_lost, ConsequenceRules.warden_footing,
			ConsequenceRules.warden_on_beams]


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


## The warden's footing. Walking: feet on a section that fell, and on no standing floor, catch the
## edge and the climb back begins (story 1.5 D3); feet on a floor that can be walked on, within the
## clearance of a section that cannot (a gap, story 1.5 D2, or an open section, story 1.6 D3), step
## back from it, and a running hold is not charged for that step (in epic 1 no hold can be running
## then: only the warden's own strip opens a section, and it has just completed; epic 3's deck hooks
## can). Climbing: the edge hung from may itself have gone, so the hang point is worked out again
## (code review 2026-11-22). Edging (story 1.6 AC 10): the section being edged fell, whichever way
## and wherever the feet are along it, and they catch the edge as from under their feet. An edging
## warden's footing is asked of the section edged, never of the feet: from the tick the edging
## begins they are on its beam. So for the 0.3 m at each end where the feet are still (or already)
## over the next section: that section falling does not catch them, and the edged section falling
## does, though the feet are over planks (story 1.6 Dev Notes; pinned by tests). Crossing: nothing
## can fall under a gap.
static func warden_footing(sim: NightSim) -> void:
	match sim.warden.move:
		WardenState.Move.CLIMBING:
			WardenRules.hang_on(sim)
			return
		WardenState.Move.EDGING:
			if sim.span.fallen(sim.warden.move_section):
				WardenRules.start_climb(sim.warden.move_section, sim)
			return
		WardenState.Move.CROSSING:
			return
	var under: int = WardenRules.fell_from(sim)
	if under > 0:
		WardenRules.start_climb(under, sim)
		return
	if not WardenRules.feet_on_floor(sim):
		return
	var before: Vector3 = sim.warden.position
	WardenRules.step_back(sim)
	HoldRules.feet_moved(sim.warden.position - before, sim)


## GD-68 (story 1.6 AC 2): a walking warden whose feet are on a section that has gone open, and on
## no floor that can be walked on, is on its side beam from this moment and edges toward the town
## (WardenRules.begin_beams()). Disjoint from warden_footing's step back (feet on a floor), so a
## second settle() finds nothing to do.
static func warden_on_beams(sim: NightSim) -> void:
	if not WardenRules.walking(sim):
		return
	var section: int = WardenRules.on_open(sim)
	if section > 0:
		WardenRules.begin_beams(section, sim)
