## Bot paths (AD-63): scripted nights that drive a sim with inputs and ticks, calling
## `each_tick(events, sim)` after every tick so tests can check the invariants on every tick
## (parts conserved, no fault) and that every event kind is produced. Every story adds a path
## to its own situation.
class_name NightBot
extends RefCounted

## How long each path runs: 10 s of night (AD-33: 60 ticks a second).
const PATH_TICKS: int = 600
## Story 1.3's walk: 40 s. The scripted part takes the first 23 s (WALK_SCRIPT); the wander has
## the rest. Section 1 is open with the far pier beyond it (story 1.6), so the bot stops at its edge
## and no push begins an edging there (those limits are checked in test_warden.gd).
const WALK_TICKS: int = 2400
## The walk's scripted part: [the tick it ends before, the move wish]. Toward the far pier until
## open section 1 stops it (along 5.3, about 458 ticks from the landing, then about 140 ticks of
## pushing that begin nothing: story 1.6 AC 9); into the left rail, the right rail; a diagonal; then
## back past the landing's back edge, pushing into it. A wander follows.
const WALK_SCRIPT: Array[Array] = [
	[600, Vector2(0.0, -1.0)],
	[720, Vector2(-1.0, 0.0)],
	[840, Vector2(1.0, 0.0)],
	[960, Vector2(-0.70710678, 0.70710678)],
	[1380, Vector2(0.0, 1.0)],
]
## The wander picks a new wish this often, in ticks.
const WANDER_EVERY: int = 30
## Story 1.4's strip path: the wander after its script, in ticks.
const STRIP_WANDER_TICKS: int = 600
## Closer than this to a walk's goal, in metres, the bot has arrived.
const ARRIVED: float = 0.0005
## The most ticks one walk of the script may take before the bot gives up on it (a guard: the
## script never needs more than a span's length at walking speed).
const WALK_GUARD: int = 1200
## Story 1.4's strip path needs this many sections: the town, `a` two before it and `b` three
## before it are three different sections.
const STRIP_MIN_SECTIONS: int = 4
## Story 1.5's overload path: the wander after its script, in ticks.
const OVERLOAD_WANDER_TICKS: int = 300
## Story 1.5's overload path: section b's two lifts (decision D1), on these ticks. Its 4 weights
## on 3 planks groan from tick 0; the first lift (3 on 3) holds it and it creaks, the second
## (2 on 3) ends the creak. Both well before the 120 ticks of the groan run out.
const OVERLOAD_LIFTS: Array[int] = [60, 90]
## Story 1.6's gaps and beams paths: the wander after their scripts, in ticks.
const MOVES_WANDER_TICKS: int = 300
## Story 1.6's gaps path: section 1 open under 2 test weights (the side beams' load: it creaks for
## the whole path and never falls), when the def has a section 1 apart from the path's four.
const GAPS_BEAM_WEIGHTS: int = 2
## Story 1.6's beams path: test weights on its open section `a`, over the side beams' 2: it groans
## from tick 0 and falls 2 s later, under the warden edging along it.
const BEAMS_WEIGHTS: int = 3


## Every path, each `(def, seed, faults, each_tick) -> NightSim`: it builds its night on `def`
## (the one night or a shorter test def), runs it and returns the sim.
static func paths() -> Array[Callable]:
	return [NightBot.span_counts, NightBot.walk, NightBot.strip, NightBot.overload, NightBot.gaps, NightBot.beams]


## Story 1.2: the span_counts show's StartState, then 600 ticks with a changing move wish,
## view and button presses. Since story 1.3 the warden walks: the turning wish takes it round a
## small circle on the landing and into the landing's back edge. Since story 1.4 its USE presses
## meet the hand rules: the view never looks within 2 m of a deck, so each is refused.
static func span_counts(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	def.start = ShowSetups.span_counts_start(def.section_count)
	var sim: NightSim = NightSim.new(def, night_seed, faults)
	for i: int in PATH_TICKS:
		sim.set_move(Vector2.from_angle(i * 0.05) * 0.9)
		sim.set_view(i * 0.02, sin(i * 0.03) * 0.5)
		if i % 120 == 0:
			sim.command(NightCommand.press(NightTypes.HandInput.USE))
		elif i % 120 == 60:
			sim.command(NightCommand.release(NightTypes.HandInput.USE))
		each_tick.call(sim.advance(), sim)
	return sim


## Story 1.3: the warden walks. Section 1 is open (story 1.6: the bot meets a plankless edge with the
## far pier beyond, so its push begins nothing), the rest are full. WALK_SCRIPT first, then a wander driven by the bot's own generator, seeded from
## the night's seed (a consumer owns its own generator, AD-33): a new wish every WANDER_EVERY ticks,
## any direction, a length-1 diagonal or standing still, and the view changing too.
static func walk(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	var start: StartState = StartState.new()
	start.planks = {1: 0}
	def.start = start
	var sim: NightSim = NightSim.new(def, night_seed, faults)
	var wander: RandomNumberGenerator = RandomNumberGenerator.new()
	wander.seed = night_seed
	var wish: Vector2 = Vector2.ZERO
	var script_end: int = WALK_SCRIPT[WALK_SCRIPT.size() - 1][0]
	for i: int in WALK_TICKS:
		if i < script_end:
			for row: Array in WALK_SCRIPT:
				if i < row[0]:
					wish = row[1]
					break
		elif (i - script_end) % WANDER_EVERY == 0:
			match wander.randi_range(0, 2):
				0:
					wish = Vector2.from_angle(wander.randf_range(-PI, PI)) * wander.randf_range(0.2, 1.0)
				1:
					wish = Vector2(1.0 if wander.randi_range(0, 1) == 0 else -1.0,
							1.0 if wander.randi_range(0, 1) == 0 else -1.0).normalized()
				_:
					wish = Vector2.ZERO
			sim.set_view(wander.randf_range(-PI, PI), wander.randf_range(-1.3, 1.3))
		sim.set_move(wish)
		each_tick.call(sim.advance(), sim)
	return sim


## Story 1.4 (AD-63): the warden strips, re-lays, is refused, cancels and reads the forearm, on a
## full span with an empty hand, starting on the landing. Every section number comes from the def:
## `a` is the town's third section toward the far pier (section 4 of 6, 2 of 4) and `b` the next
## one (3 of 6, 1 of 4). The bot aims by working out yaw and pitch from the eye to a point that
## SpanGeometry gives; the sim is never asked where to look. In order:
## - at mid a: the hammer at the sky (NO_ACTION_HERE); E at the deck with nothing in hand
##   (NO_PLANK_IN_HAND); Tab held, walked with, a hammer press ignored, lowered; a strip;
## - at mid b: E at its full deck (DECK_FULL); cancels by letting go, by walking 0.6 m, and by a
##   second press in Press once;
## - back at a: a re-lay; at b: all 8 of b's planks stripped from where the warden stands, the last
##   one underfoot: on its side beam at once, edging toward the town onto a (story 1.6, GD-68);
## - from a's edge, looking back at bare b: the hammer (NO_PLANKS_LEFT), then a re-lay onto it;
## - at mid town: stripped down to its floor of 4, once more (LAST_SECTION_MINIMUM), then its right
##   rail stripped at 4 planks (right, so the events' side is not the field's default);
## - a wander (the bot's own generator, as in walk) with taps of random buttons: each is refused
##   or starts a hold the release cancels at once, so the script's work stands.
## Each hold lasts what sim.ticks says and one tick more, so its completion lands while the button
## is still down. A def with fewer than STRIP_MIN_SECTIONS sections is `bot.bad_def`: the night is
## built and returned, and nothing is run on it.
static func strip(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	var sim: NightSim = strip_script(def, night_seed, faults, each_tick)
	if def.section_count >= STRIP_MIN_SECTIONS:
		_wander(sim, night_seed, STRIP_WANDER_TICKS, each_tick)
	return sim


## strip's scripted part alone, with no wander after it: for the test that checks the script
## really reaches each case it is written for (the wander's random taps could reach some by luck).
static func strip_script(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	def.start = StartState.new()
	var sim: NightSim = NightSim.new(def, night_seed, faults)
	if def.section_count < STRIP_MIN_SECTIONS:
		faults.report(&"bot.bad_def", "strip needs %d sections, the def has %d" % [STRIP_MIN_SECTIONS,
				def.section_count])
		return sim
	var g: SpanGeometry = sim.geometry
	var town: int = def.section_count
	var a: int = town - 2
	var b: int = town - 3
	var mid_a: float = g.section_start(a) + SpanConstants.SECTION_LENGTH / 2.0
	var mid_b: float = g.section_start(b) + SpanConstants.SECTION_LENGTH / 2.0
	var mid_town: float = g.section_start(town) + SpanConstants.SECTION_LENGTH / 2.0
	var hammer: NightTypes.HandInput = NightTypes.HandInput.HAMMER
	var use: NightTypes.HandInput = NightTypes.HandInput.USE
	var forearm: NightTypes.HandInput = NightTypes.HandInput.FOREARM
	# At mid a.
	_go_to(sim, 0.0, mid_a, each_tick)
	_look(sim, 0.0, 0.5, each_tick)
	_tap(sim, hammer, each_tick)
	_aim_at_deck(sim, mid_a - 0.6, each_tick)
	_tap(sim, use, each_tick)
	sim.command(NightCommand.press(forearm))
	_ticks(sim, 1, each_tick)
	for i: int in 20:
		sim.set_move(Vector2(0.0, -1.0))
		_ticks(sim, 1, each_tick)
	sim.set_move(Vector2.ZERO)
	_tap(sim, hammer, each_tick)
	sim.command(NightCommand.release(forearm))
	_ticks(sim, 1, each_tick)
	_go_to(sim, 0.0, mid_a, each_tick)
	_aim_at_deck(sim, mid_a - 0.6, each_tick)
	_hold(sim, hammer, sim.ticks.strip_plank, each_tick)
	# At mid b.
	_go_to(sim, 0.0, mid_b, each_tick)
	_aim_at_deck(sim, mid_b - 0.6, each_tick)
	_tap(sim, use, each_tick)
	sim.command(NightCommand.press(hammer))
	_ticks(sim, 30, each_tick)
	sim.command(NightCommand.release(hammer))
	_ticks(sim, 1, each_tick)
	sim.command(NightCommand.press(hammer))
	for i: int in 11:
		sim.set_move(Vector2(0.0, -1.0))
		_ticks(sim, 1, each_tick)
	sim.set_move(Vector2.ZERO)
	sim.command(NightCommand.release(hammer))
	_go_to(sim, 0.0, mid_b, each_tick)
	sim.command(NightCommand.set_option(NightTypes.Option.HOLDS, NightTypes.Holds.PRESS_ONCE))
	_aim_at_deck(sim, mid_b - 0.6, each_tick)
	sim.command(NightCommand.press(hammer))
	_ticks(sim, 30, each_tick)
	sim.command(NightCommand.press(hammer))
	_ticks(sim, 1, each_tick)
	sim.command(NightCommand.set_option(NightTypes.Option.HOLDS, NightTypes.Holds.HOLD))
	# A re-lay at a, then b stripped bare from where the warden stands: the last plank puts them on its
	# side beam, edging toward the town (GD-68), and _go_to waits for the edging to end.
	_go_to(sim, 0.0, mid_a, each_tick)
	_aim_at_deck(sim, mid_a - 0.6, each_tick)
	_hold(sim, use, sim.ticks.relay_plank, each_tick)
	_go_to(sim, 0.0, mid_b, each_tick)
	_aim_at_deck(sim, mid_b - 0.6, each_tick)
	for i: int in def.planks_per_section:
		_hold(sim, hammer, sim.ticks.strip_plank, each_tick)
	_go_to(sim, 0.0, mid_a, each_tick)
	# From a's edge, looking back at bare b.
	var edge: float = g.section_start(a) + 0.4
	_go_to(sim, 0.0, edge, each_tick)
	_aim_at_deck(sim, g.section_end(b) - 0.4, each_tick)
	_tap(sim, hammer, each_tick)
	_hold(sim, use, sim.ticks.relay_plank, each_tick)
	# The town section down to its floor, once more, then its right rail.
	_go_to(sim, 0.0, mid_town, each_tick)
	_aim_at_deck(sim, mid_town - 0.6, each_tick)
	for i: int in def.planks_per_section - SpanConstants.LAST_SECTION_MIN_PLANKS:
		_hold(sim, hammer, sim.ticks.strip_plank, each_tick)
	_tap(sim, hammer, each_tick)
	var rope: Vector3 = g.rail_box(town, NightTypes.Side.RIGHT).get_center()
	_go_to(sim, rope.x - WardenConstants.CLEARANCE, mid_town, each_tick)
	_aim(sim, Vector3(rope.x, rope.y, sim.warden.position.z), each_tick)
	_hold(sim, NightTypes.HandInput.ROPE, sim.ticks.strip_rail, each_tick)
	return sim


## The end of strip and overload: a wander like walk's, with a tap (press, then release on the next
## tick) of a random night button every WANDER_EVERY ticks, for `ticks` ticks.
static func _wander(sim: NightSim, night_seed: int, ticks: int, each_tick: Callable) -> void:
	var wander: RandomNumberGenerator = RandomNumberGenerator.new()
	wander.seed = night_seed
	for i: int in ticks:
		if i % WANDER_EVERY == 0:
			sim.set_move(Vector2.from_angle(wander.randf_range(-PI, PI)) * wander.randf_range(0.0, 1.0))
			sim.set_view(wander.randf_range(-PI, PI), wander.randf_range(-1.3, 1.3))
			sim.command(NightCommand.press(wander.randi_range(0, NightTypes.HandInput.size() - 1) as NightTypes.HandInput))
		elif i % WANDER_EVERY == 1:
			for input: int in NightTypes.HandInput.size():
				sim.command(NightCommand.release(input as NightTypes.HandInput))
		each_tick.call(sim.advance(), sim)
	sim.set_move(Vector2.ZERO)


## Story 1.5 (AD-63): sections carry weight, creak, groan and fall; a hold on a section that falls
## is cancelled on the next tick; the warden steps back from a gap, falls with a section, climbs
## back, and is refused at a gap. Every section number comes from the def: the town, `c` one before
## it, `a` two before, `b` three before (6, 5, 4, 3 of 6; 4, 3, 2, 1 of 4). Its StartState: `b` at
## 3 planks with 4 weights and two lifts (OVERLOAD_LIFTS); `a` and `c` at 4 planks with 3 weights;
## the town full with 5 weights. From the landing:
## - at section_start(c) + 0.1 (0.1 m from a, D2's band): a stripped twice (creak, then groan); a
##   third strip begun the tick after, so it would complete the tick after a falls: cancelled
##   then; a falls with nobody on it, and the warden steps back to 0.3 m from the gap;
## - at mid c: its own deck stripped twice (creak, then groan), Tab pressed and held, so the forearm
##   is up when c falls under the warden; caught, lowered the next tick; during the climb every
##   button and Tab tapped and a move wish pushed, all ignored; climbed onto the town section;
## - at mid town: stripped to 4 (5 weights: creak at 5, groan at 4), and stayed on: it falls, and
##   the warden climbs onto the landing;
## - from the landing, aimed into the town section's gap: the hammer and E, NO_ACTION_HERE;
## - a short wander, as strip's, on the landing.
## A def with fewer than STRIP_MIN_SECTIONS sections is `bot.bad_def`: built, returned, not run.
static func overload(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	var sim: NightSim = overload_script(def, night_seed, faults, each_tick)
	if def.section_count >= STRIP_MIN_SECTIONS:
		_wander(sim, night_seed, OVERLOAD_WANDER_TICKS, each_tick)
	return sim


## overload's scripted part alone, with no wander after it (for the test that checks the script
## reaches each case it is written for).
static func overload_script(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	var town: int = def.section_count
	var c: int = town - 1
	var a: int = town - 2
	var b: int = town - 3
	var start: StartState = StartState.new()
	if def.section_count >= STRIP_MIN_SECTIONS:
		start.planks = {b: 3, a: 4, c: 4}
		start.weights = {b: 4, a: 3, c: 3, town: 5}
		for tick: int in OVERLOAD_LIFTS:
			start.lifts.append(Vector2i(b, tick))
	def.start = start
	var sim: NightSim = NightSim.new(def, night_seed, faults)
	if def.section_count < STRIP_MIN_SECTIONS:
		faults.report(&"bot.bad_def", "overload needs %d sections, the def has %d" % [STRIP_MIN_SECTIONS,
				def.section_count])
		return sim
	var g: SpanGeometry = sim.geometry
	var hammer: NightTypes.HandInput = NightTypes.HandInput.HAMMER
	var forearm: NightTypes.HandInput = NightTypes.HandInput.FOREARM
	var c_edge: float = g.section_start(c) + 0.1
	var mid_c: float = g.section_start(c) + SpanConstants.SECTION_LENGTH / 2.0
	var mid_town: float = g.section_start(town) + SpanConstants.SECTION_LENGTH / 2.0
	# a, from just inside c: creak, groan, then a third strip that the fall cancels.
	_go_to(sim, 0.0, c_edge, each_tick)
	_aim_at_deck(sim, c_edge - 0.6, each_tick)
	_hold(sim, hammer, sim.ticks.strip_plank, each_tick)
	_hold(sim, hammer, sim.ticks.strip_plank, each_tick)
	sim.command(NightCommand.press(hammer))
	_ticks(sim, sim.ticks.groan + 2, each_tick)
	sim.command(NightCommand.release(hammer))
	_ticks(sim, 1, each_tick)
	# c, under the warden, with the forearm up.
	_go_to(sim, 0.0, mid_c, each_tick)
	_aim_at_deck(sim, mid_c - 0.6, each_tick)
	_hold(sim, hammer, sim.ticks.strip_plank, each_tick)
	_hold(sim, hammer, sim.ticks.strip_plank, each_tick)
	sim.command(NightCommand.press(forearm))
	_until_climbing(sim, each_tick)
	_ticks(sim, 1, each_tick)
	for input: int in NightTypes.HandInput.size():
		_tap(sim, input as NightTypes.HandInput, each_tick)
	sim.command(NightCommand.release(forearm))
	sim.set_move(Vector2(0.0, -1.0))
	_ticks(sim, 30, each_tick)
	sim.set_move(Vector2.ZERO)
	_until_walking(sim, each_tick)
	# The town section, under the warden, down to 4.
	_go_to(sim, 0.0, mid_town, each_tick)
	_aim_at_deck(sim, mid_town - 0.6, each_tick)
	for i: int in def.planks_per_section - SpanConstants.LAST_SECTION_MIN_PLANKS:
		_hold(sim, hammer, sim.ticks.strip_plank, each_tick)
	_until_climbing(sim, each_tick)
	_until_walking(sim, each_tick)
	# From the landing, into the gap where the town section was.
	_aim_at_deck(sim, g.length() - 0.6 + WardenConstants.CLEARANCE, each_tick)
	_tap(sim, hammer, each_tick)
	_tap(sim, NightTypes.HandInput.USE, each_tick)
	return sim


## Story 1.6 (AD-63): crossing gaps. Every section number comes from the def: the town, `c` one
## before it, `a` two before, `b` three before. Its StartState: `a` and `c` fallen from the start (two
## gaps side by side, floors on both sides); on a def with a section 1 apart from those four, section
## 1 open under GAPS_BEAM_WEIGHTS test weights (it creaks throughout). From the landing:
## - at the stop before `c`: 30 ticks of pushing, then a tick without (D1: nothing begins);
## - aimed back at the town section's own deck, the hammer pressed and held, then pushing until the
##   crossing of `c` begins: the hold is cancelled on that tick; `c` then `a` crossed, 8 s each, onto
##   `b`;
## - from `b`, pushing back toward the town: `a`, then `c`, onto the town section;
## - a short wander, as strip's.
## A def with fewer than STRIP_MIN_SECTIONS sections is `bot.bad_def`: built, returned, not run.
static func gaps(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	var sim: NightSim = gaps_script(def, night_seed, faults, each_tick)
	if def.section_count >= STRIP_MIN_SECTIONS:
		_wander(sim, night_seed, MOVES_WANDER_TICKS, each_tick)
	return sim


## gaps' scripted part alone, with no wander after it.
static func gaps_script(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	var town: int = def.section_count
	var c: int = town - 1
	var a: int = town - 2
	var b: int = town - 3
	var start: StartState = StartState.new()
	if def.section_count >= STRIP_MIN_SECTIONS:
		start.fallen = [a, c]
		if b > 1:
			start.planks = {1: 0}
			start.weights = {1: GAPS_BEAM_WEIGHTS}
	def.start = start
	var sim: NightSim = NightSim.new(def, night_seed, faults)
	if def.section_count < STRIP_MIN_SECTIONS:
		faults.report(&"bot.bad_def", "gaps needs %d sections, the def has %d" % [STRIP_MIN_SECTIONS, def.section_count])
		return sim
	var g: SpanGeometry = sim.geometry
	var stop: float = g.section_start(town) + WardenConstants.CLEARANCE
	var toward_pier: Vector2 = Vector2(0.0, -1.0)
	# At the stop before c: a push too short to begin anything.
	_go_to(sim, 0.0, stop, each_tick)
	_ticks(sim, 1, each_tick)
	_push(sim, toward_pier, sim.ticks.push_to_cross, each_tick)
	_ticks(sim, 1, each_tick)
	# A hold on the town section's own deck, cancelled when the crossing of c begins.
	_aim_at_deck(sim, stop + 0.6, each_tick)
	sim.command(NightCommand.press(NightTypes.HandInput.HAMMER))
	_until_moving(sim, toward_pier, each_tick)
	sim.command(NightCommand.release(NightTypes.HandInput.HAMMER))
	_until_walking(sim, each_tick)
	# From b, back over a and c onto the town section.
	_until_moving(sim, Vector2(0.0, 1.0), each_tick)
	_until_walking(sim, each_tick)
	return sim


## Story 1.6 (AD-63): open sections and the side beams. Section numbers as gaps'. Its StartState: `c`
## at 1 plank; `a` open under BEAMS_WEIGHTS test weights (over the side beams' 2: it groans from tick
## 0 and falls 2 s later); `b` full; the warden at the stop before `a` (section_start(c) + 0.3):
## - pushing toward the far pier from tick 0: the edging of `a` begins (D1), `a` falls under it, and
##   the warden is caught and climbs back onto `c` (AC 10);
## - at mid `c`, its last plank stripped underfoot: on its beam, edging toward the town (GD-68) onto
##   the town section;
## - from the town section's stop, a plank re-laid on `c` (GD-69); walked over `c` to its far end and
##   back; from 0.1 m inside the town section, `c`'s last plank stripped again: the warden steps back
##   to 0.3 m from it (D3);
## - pushing toward the far pier: edging `c`, then crossing `a` (chained), onto `b`; pushing back:
##   crossing `a`, edging `c`, onto the town section;
## - a short wander, as strip's.
## A def with fewer than STRIP_MIN_SECTIONS sections is `bot.bad_def`: built, returned, not run.
static func beams(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	var sim: NightSim = beams_script(def, night_seed, faults, each_tick)
	if def.section_count >= STRIP_MIN_SECTIONS:
		_wander(sim, night_seed, MOVES_WANDER_TICKS, each_tick)
	return sim


## beams' scripted part alone, with no wander after it.
static func beams_script(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	var town: int = def.section_count
	var c: int = town - 1
	var a: int = town - 2
	var start: StartState = StartState.new()
	if def.section_count >= STRIP_MIN_SECTIONS:
		start.planks = {c: 1, a: 0}
		start.weights = {a: BEAMS_WEIGHTS}
		start.warden_along = (c - 1) * SpanConstants.SECTION_LENGTH + WardenConstants.CLEARANCE
	def.start = start
	var sim: NightSim = NightSim.new(def, night_seed, faults)
	if def.section_count < STRIP_MIN_SECTIONS:
		faults.report(&"bot.bad_def", "beams needs %d sections, the def has %d" % [STRIP_MIN_SECTIONS, def.section_count])
		return sim
	var g: SpanGeometry = sim.geometry
	var hammer: NightTypes.HandInput = NightTypes.HandInput.HAMMER
	var toward_pier: Vector2 = Vector2(0.0, -1.0)
	var mid_c: float = g.section_start(c) + SpanConstants.SECTION_LENGTH / 2.0
	var town_stop: float = g.section_start(town) + WardenConstants.CLEARANCE
	# Edging a, which falls under the beam: caught, climbed back onto c.
	_until_moving(sim, toward_pier, each_tick)
	_until_climbing(sim, each_tick)
	_until_walking(sim, each_tick)
	# c's last plank underfoot: edging toward the town (GD-68).
	_go_to(sim, 0.0, mid_c, each_tick)
	_aim_at_deck(sim, mid_c - 0.6, each_tick)
	_hold(sim, hammer, sim.ticks.strip_plank, each_tick)
	_until_walking(sim, each_tick)
	# Re-laid from the town section's stop, walked over, stripped again from beside it: a step back.
	_go_to(sim, 0.0, town_stop, each_tick)
	_aim_at_deck(sim, town_stop - 0.7, each_tick)
	_hold(sim, NightTypes.HandInput.USE, sim.ticks.relay_plank, each_tick)
	_go_to(sim, 0.0, g.section_start(c) + WardenConstants.CLEARANCE, each_tick)
	_go_to(sim, 0.0, g.section_start(town) + 0.1, each_tick)
	_aim_at_deck(sim, g.section_start(town) - 0.5, each_tick)
	_hold(sim, hammer, sim.ticks.strip_plank, each_tick)
	_ticks(sim, 1, each_tick)
	# Over c and a toward the far pier, onto b; and back.
	_until_moving(sim, toward_pier, each_tick)
	_until_walking(sim, each_tick)
	_until_moving(sim, Vector2(0.0, 1.0), each_tick)
	_until_walking(sim, each_tick)
	return sim


## Pushes `wish` for `ticks` ticks, then lets go (the wish back to none).
static func _push(sim: NightSim, wish: Vector2, ticks: int, each_tick: Callable) -> void:
	sim.set_move(wish)
	_ticks(sim, ticks, each_tick)
	sim.set_move(Vector2.ZERO)


## Pushes `wish` until a timed move begins (an edging or a crossing, story 1.6 D1), at most
## WALK_GUARD ticks, then lets go; none by then is `bot.walk_lost`.
static func _until_moving(sim: NightSim, wish: Vector2, each_tick: Callable) -> void:
	sim.set_move(wish)
	for i: int in WALK_GUARD:
		if not WardenRules.walking(sim):
			sim.set_move(Vector2.ZERO)
			return
		_ticks(sim, 1, each_tick)
	sim.set_move(Vector2.ZERO)
	if WardenRules.walking(sim):
		sim.faults.report(&"bot.walk_lost", "no move began pushing %s at %s" % [wish, sim.warden.position])


## Ticks until the warden is climbing (caught by a fall), at most WALK_GUARD; not caught by then
## is `bot.walk_lost`: the script's later steps are not where it thinks.
static func _until_climbing(sim: NightSim, each_tick: Callable) -> void:
	for i: int in WALK_GUARD:
		if not WardenRules.walking(sim):
			return
		_ticks(sim, 1, each_tick)
	sim.faults.report(&"bot.walk_lost", "no fall under the warden at %s" % sim.warden.position)


## Ticks until the warden walks again (a climb, an edging or a crossing ended), at most WALK_GUARD.
static func _until_walking(sim: NightSim, each_tick: Callable) -> void:
	for i: int in WALK_GUARD:
		if WardenRules.walking(sim):
			return
		_ticks(sim, 1, each_tick)
	sim.faults.report(&"bot.walk_lost", "the timed move never ended at %s" % sim.warden.position)


static func _ticks(sim: NightSim, count: int, each_tick: Callable) -> void:
	for i: int in count:
		each_tick.call(sim.advance(), sim)


## Press, one tick, release, one tick.
static func _tap(sim: NightSim, input: NightTypes.HandInput, each_tick: Callable) -> void:
	sim.command(NightCommand.press(input))
	_ticks(sim, 1, each_tick)
	sim.command(NightCommand.release(input))
	_ticks(sim, 1, each_tick)


## Holds `input` for `ticks` and one tick more (the completion's tick), then lets go.
static func _hold(sim: NightSim, input: NightTypes.HandInput, ticks: int, each_tick: Callable) -> void:
	sim.command(NightCommand.press(input))
	_ticks(sim, ticks + 1, each_tick)
	sim.command(NightCommand.release(input))


## Walks the feet to (x, along) at up to full speed, the last step shortened to land on it.
## Not there after WALK_GUARD ticks (something is in the way) is `bot.walk_lost`: the script goes
## on from where the warden stands, and the fault says its later steps are not where it thinks.
## Since story 1.6 the wish pushes straight at the goal, so a walk across an open section or a gap
## with a floor beyond edges or crosses it (the wish is ignored meanwhile).
static func _go_to(sim: NightSim, x: float, along: float, each_tick: Callable) -> void:
	var goal: Vector2 = Vector2(x, sim.geometry.world_z(along))
	var arrived: bool = false
	for i: int in WALK_GUARD:
		var delta: Vector2 = goal - Vector2(sim.warden.position.x, sim.warden.position.z)
		if delta.length() < ARRIVED:
			arrived = true
			break
		sim.set_move((delta / sim.walk_step).limit_length(1.0))
		_ticks(sim, 1, each_tick)
	sim.set_move(Vector2.ZERO)
	if not arrived:
		sim.faults.report(&"bot.walk_lost", "no way to x %.3f, along %.3f from %s" % [x, along,
				sim.warden.position])


## Looks at `yaw`, `pitch` for one tick.
static func _look(sim: NightSim, yaw: float, pitch: float, each_tick: Callable) -> void:
	sim.set_view(yaw, pitch)
	_ticks(sim, 1, each_tick)


## Looks from the eye at `point` (world) for one tick: yaw and pitch of AD-67 worked out here.
static func _aim(sim: NightSim, point: Vector3, each_tick: Callable) -> void:
	var to: Vector3 = point - (sim.warden.position + Vector3(0.0, WardenConstants.EYE_HEIGHT, 0.0))
	_look(sim, atan2(-to.x, -to.z), atan2(to.y, Vector2(to.x, to.z).length()), each_tick)


## Aims at the middle of the deck's thickness at `along`, straight ahead along the span.
static func _aim_at_deck(sim: NightSim, along: float, each_tick: Callable) -> void:
	_aim(sim, Vector3(sim.warden.position.x, -SpanGeometry.PLANK_THICKNESS / 2.0, sim.geometry.world_z(along)),
			each_tick)
