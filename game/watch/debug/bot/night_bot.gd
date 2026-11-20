## Bot paths (AD-63): scripted nights that drive a sim with inputs and ticks, calling
## `each_tick(events, sim)` after every tick so tests can check the invariants on every tick
## (parts conserved, no fault) and that every event kind is produced. Every story adds a path
## to its own situation.
class_name NightBot
extends RefCounted

## How long each path runs: 10 s of night (AD-33: 60 ticks a second).
const PATH_TICKS: int = 600


## Every path, each `(def, seed, faults, each_tick) -> NightSim`: it builds its night on `def`
## (the one night or a shorter test def), runs it and returns the sim.
static func paths() -> Array[Callable]:
	return [NightBot.span_counts]


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
