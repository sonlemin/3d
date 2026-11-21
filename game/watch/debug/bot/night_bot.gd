## Bot paths (AD-63): scripted nights that drive a sim with inputs and ticks, calling
## `each_tick(events, sim)` after every tick so tests can check the invariants on every tick
## (parts conserved, no fault) and that every event kind is produced. Every story adds a path
## to its own situation.
class_name NightBot
extends RefCounted

## How long each path runs: 10 s of night (AD-33: 60 ticks a second).
const PATH_TICKS: int = 600
## Story 1.3's walk: 40 s, long enough for the span and back (about 64 m at 3.5 m/s) and a wander.
const WALK_TICKS: int = 2400
## The walk's scripted part: [the tick it ends before, the move wish]. Toward the far pier until
## the plankless section 2 stops it; into the left rail, the right rail; a diagonal; then back past
## the landing's back edge, pushing into it. A wander follows.
const WALK_SCRIPT: Array[Array] = [
	[600, Vector2(0.0, -1.0)],
	[720, Vector2(-1.0, 0.0)],
	[840, Vector2(1.0, 0.0)],
	[960, Vector2(-0.70710678, 0.70710678)],
	[1380, Vector2(0.0, 1.0)],
]
## The wander picks a new wish this often, in ticks.
const WANDER_EVERY: int = 30


## Every path, each `(def, seed, faults, each_tick) -> NightSim`: it builds its night on `def`
## (the one night or a shorter test def), runs it and returns the sim.
static func paths() -> Array[Callable]:
	return [NightBot.span_counts, NightBot.walk]


## Story 1.2: the span_counts show's StartState, then 600 ticks with a changing move wish,
## view and button presses. Inputs are taken and stored; nothing moves yet.
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


## Story 1.3: the warden walks. Section 2 has no planks (so the bot meets a plankless edge), the
## rest are full. WALK_SCRIPT first, then a wander driven by the bot's own generator, seeded from
## the night's seed (a consumer owns its own generator, AD-33): a new wish every WANDER_EVERY ticks,
## any direction, a length-1 diagonal or standing still, and the view changing too.
static func walk(def: NightDef, night_seed: int, faults: WatchFaults, each_tick: Callable) -> NightSim:
	var start: StartState = StartState.new()
	start.planks = {2: 0}
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
