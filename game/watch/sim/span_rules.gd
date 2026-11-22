## The span's rules: the parts ledger (Novel Pattern 1: every plank and rope is always in exactly
## one place and moves only through move_parts()), and since story 1.5 load against strength
## (GD-19, GDD Game Mechanics 2): a section whose load equals its strength creaks; above it, it
## groans for 2 s and then falls for good, unless the load drops back first. Strength and load are
## worked out when asked (AD-35); the creak and the groan's ticks left are stored, as a phase and a
## countdown. What follows a fall is ConsequenceRules'.
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


## Pure (AD-35): a section's strength, never stored: its planks while it has any (0 to the planks
## per section), and SpanConstants.SIDE_BEAM_LOAD (2) once it is open: its side beams still carry
## that much (story 1.6, GDD Game Mechanics 2). Decision D4, as the GDD is written: a section at 1
## plank is weaker than an open one, so taking its last plank can stop a groan. A fallen section
## has none (0); nothing asks.
static func strength(section: int, span: SpanState) -> int:
	if open(section, span):
		return SpanConstants.SIDE_BEAM_LOAD
	return span.planks(section)


## Pure (AD-35, story 1.6): a section is open when it has no planks and has not fallen. Computed,
## never stored; epic 4 adds a trapdoor that is down.
static func open(section: int, span: SpanState) -> bool:
	return span.planks(section) == 0 and not span.fallen(section)


## Pure (AD-35): the load on a section, worked out each time: its test weights, each
## SpanConstants.TEST_WEIGHT_LOAD. The warden is never part of it (story 1.5 AC 9); the dead join
## in epic 3. A float, every value a multiple of 0.5 (exact in binary), so == with a strength holds.
static func load_on(section: int, span: SpanState) -> float:
	return span.weights(section) * SpanConstants.TEST_WEIGHT_LOAD


## Pure: a section at its limit creaks: its load equals its strength and is above 0 (a section
## with nothing on it is not at its limit, story 1.5).
static func creaks(load: float, section_strength: int) -> bool:
	return load > 0.0 and load == section_strength


## Pure: more load than strength: the section groans, then falls.
static func overloaded(load: float, section_strength: int) -> bool:
	return load > section_strength


## Step 7 of the tick (AD-34): every standing section, 1 to n in order, against its load. A groan
## counts down from sim.ticks.groan, begun on the first tick of overload (AD-33) and not restarted
## by more load: on the tick it reaches 0 the section falls (SECTION_FELL). A load back at or under
## the strength before then stops it (GROAN_STOPPED), and the creak is worked out again on that
## same tick. A section that begins to groan stops creaking first. On one section a stop always
## comes before a start.
static func tick_loads(sim: NightSim) -> void:
	for n: int in range(1, sim.def.section_count + 1):
		if sim.span.fallen(n):
			continue
		var load: float = load_on(n, sim.span)
		var held: int = strength(n, sim.span)
		if sim.span.groan_left(n) > 0:
			if not overloaded(load, held):
				sim.span.set_groan_left(n, 0)
				_emit(NightEvent.Kind.GROAN_STOPPED, n, sim)
			else:
				sim.span.set_groan_left(n, sim.span.groan_left(n) - 1)
				if sim.span.groan_left(n) == 0:
					sim.span.set_fallen(n)
					sim.span.set_creaking(n, false)
					_emit(NightEvent.Kind.SECTION_FELL, n, sim)
				continue
		elif overloaded(load, held):
			if sim.span.creaking(n):
				sim.span.set_creaking(n, false)
				_emit(NightEvent.Kind.CREAK_STOPPED, n, sim)
			# At least 1 tick: groan_left above 0 is also what says "groaning", so a GROAN_S tuned
			# under half a tick would otherwise start a new groan every tick and never fall.
			sim.span.set_groan_left(n, maxi(sim.ticks.groan, 1))
			_emit(NightEvent.Kind.GROAN_STARTED, n, sim)
			continue
		var creaking: bool = creaks(load, held)
		if creaking != sim.span.creaking(n):
			sim.span.set_creaking(n, creaking)
			_emit(NightEvent.Kind.CREAK_STARTED if creaking else NightEvent.Kind.CREAK_STOPPED, n, sim)


## Step 6 of the tick (AD-34; story 1.5 decision D1): each lift due this tick takes one test weight
## off its section (WEIGHT_LIFTED), in StartState order; a lift whose section has no weight left
## does nothing (on a fallen section the weights fell with it, and ConsequenceRules dropped the
## lift already). A lift is used up on its tick either way.
static func take_lifts(sim: NightSim) -> void:
	for lift: Vector2i in sim.span.lifts():
		if lift.y != sim.tick:
			continue
		if not sim.span.fallen(lift.x) and sim.span.weights(lift.x) > 0:
			sim.span.take_weight(lift.x)
			_emit(NightEvent.Kind.WEIGHT_LIFTED, lift.x, sim)
	sim.span.drop_lifts(func(lift: Vector2i) -> bool: return lift.y == sim.tick)


static func _emit(kind: NightEvent.Kind, section: int, sim: NightSim) -> void:
	var event: NightEvent = NightEvent.make(kind)
	event.section = section
	sim.emit(event)
