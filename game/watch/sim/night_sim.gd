## One night (AD-1, AD-2, AD-32): every rule and all state, node-free. Into it go only the move
## wish, the view and button commands; out of it come the events of each tick and state read
## through its fields. Only the sim changes night state: the fields below are read-only outside
## watch/sim/.
##
## advance() runs the 13 steps of AD-34 for the current tick, then adds 1: the first call is
## tick 0 (AD-33), and its events carry t = 0.0. Begun on tick T and lasting N ticks means done
## on tick T + N.
class_name NightSim
extends RefCounted

## AD-67: a move wish a little over length 1 from float rounding is not a fault.
const MOVE_SLACK: float = 0.00001

var def: NightDef
var geometry: SpanGeometry
var span: SpanState
## The night's one generator (AD-33), seeded once; used only inside the sim.
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var faults: WatchFaults
## The tick advance() runs next.
var tick: int = 0
## This tick's move wish: world X/Z, length <= 1. No rule reads it yet (walking is story 1.3).
var move_wish: Vector2 = Vector2.ZERO
## This tick's view in radians: yaw 0 faces -Z, positive turns left; pitch 0 is level, positive up.
var yaw: float = 0.0
var pitch: float = 0.0
## The commands taken this tick, in arrival order. No rule reads them yet (hands are story 1.4).
var commands: Array[NightCommand] = []

## The 13 steps of AD-34, in order.
var _steps: Array[Callable] = []
var _next_move: Vector2 = Vector2.ZERO
var _next_yaw: float = 0.0
var _next_pitch: float = 0.0
var _queued: Array[NightCommand] = []
## This tick's events, handed out by advance().
var _events: Array[NightEvent] = []
## Set by the ending step's rule (none yet); after it advance() returns nothing.
var _ended: bool = false


## A full span of `night`, then its StartState applied through the parts ledger. Nothing is
## emitted while building; NIGHT_STARTED comes on the first tick.
func _init(night: NightDef, night_seed: int, night_faults: WatchFaults) -> void:
	def = night
	faults = night_faults
	rng.seed = night_seed
	geometry = SpanGeometry.new(def, faults)
	span = SpanState.new(def.section_count, def.planks_per_section, faults)
	_apply_start(def.start)
	_steps = [
		_step_inputs, _step_holds, _step_rigs, _step_consequences_of_actions, _step_clock,
		_step_dead, _step_loads, _step_consequences_of_loads, _step_crossings_and_windows,
		_step_lanterns, _step_wounds_and_name, _step_voices_and_ally, _step_ending,
	]


## The move wish for the next tick (AD-67). Longer than 1 is a fault, clamped.
func set_move(direction: Vector2) -> void:
	if direction.length() > 1.0 + MOVE_SLACK:
		faults.report(&"sim.move_too_long", "length %.3f" % direction.length())
	_next_move = direction.limit_length(1.0)


## The view for the next tick, in radians.
func set_view(view_yaw: float, view_pitch: float) -> void:
	_next_yaw = view_yaw
	_next_pitch = view_pitch


## Queued for the next advance(), in arrival order.
func command(cmd: NightCommand) -> void:
	_queued.append(cmd)


## Runs one tick and returns its events in order.
func advance() -> Array[NightEvent]:
	if _ended:
		return []
	for step: Callable in _steps:
		step.call()
	tick += 1
	var out: Array[NightEvent] = _events
	_events = []
	return out


## How a rule reports what happened (AD-67): stamps the time and keeps the event for advance().
func emit(event: NightEvent) -> void:
	event.t = float(tick) / NightTicks.TICKS_PER_SECOND
	_events.append(event)


## A hash of the tick, every part count and the generator's state (AD-37): the determinism
## test now, the replay check in epic 6.
func checksum() -> int:
	var values: Array = [tick, rng.state]
	values.append_array(span.counts())
	return hash(values)


## 1. Inputs (AD-34): take this tick's move wish and view, and drain the commands in arrival order.
func _step_inputs() -> void:
	move_wish = _next_move
	yaw = _next_yaw
	pitch = _next_pitch
	commands = _queued
	_queued = []


## 2. Holds (AD-34): progress and complete holds. No rule yet (story 1.4).
func _step_holds() -> void:
	pass


## 3. Rigs (AD-34): springing and resetting rigs. No rule yet (epic 4).
func _step_rigs() -> void:
	pass


## 4. Consequences of actions (AD-34): settle what the warden's actions changed. No rule yet (story 1.5).
func _step_consequences_of_actions() -> void:
	pass


## 5. The night clock (AD-34): tolls and the timetable. Tick 0 is the night's first toll (AD-33).
func _step_clock() -> void:
	if tick == 0:
		var started: NightEvent = NightEvent.make(NightEvent.Kind.NIGHT_STARTED)
		started.id = def.name
		emit(started)


## 6. The dead (AD-34): warnings, climbing, walking, falling. No rule yet (epic 3).
func _step_dead() -> void:
	pass


## 7. Loads (AD-34): weight on each section. No rule yet (story 1.5).
func _step_loads() -> void:
	pass


## 8. Consequences of loads (AD-34): creaks, groans and collapses. No rule yet (story 1.5).
func _step_consequences_of_loads() -> void:
	pass


## 9. Crossings and windows (AD-34): the dead reaching the town. No rule yet (epic 3).
func _step_crossings_and_windows() -> void:
	pass


## 10. Lanterns (AD-34): oil and light. No rule yet (epic 4).
func _step_lanterns() -> void:
	pass


## 11. Wounds and the name (AD-34). No rule yet (epics 4 and 5).
func _step_wounds_and_name() -> void:
	pass


## 12. Voices and the ally (AD-34): cry slots and the ally's calls. No rule yet (epic 2).
func _step_voices_and_ally() -> void:
	pass


## 13. Ending (AD-34): dawn, or the night lost; dawn wins a tie. No rule yet: nothing ends a
## night in this story.
func _step_ending() -> void:
	pass


## Moves what `start` takes off the span into the warden's hand. A section outside 1 to n, or
## a count outside 0 to the planks per section, is `span.bad_start`: skipped or clamped.
func _apply_start(start: StartState) -> void:
	for section: int in start.planks:
		var left: int = start.planks[section]
		if section < 1 or section > def.section_count:
			faults.report(&"span.bad_start", "planks of section %d (1 to %d)" % [section, def.section_count])
			continue
		if left < 0 or left > def.planks_per_section:
			faults.report(&"span.bad_start", "section %d at %d planks (0 to %d)"
					% [section, left, def.planks_per_section])
			left = clampi(left, 0, def.planks_per_section)
		SpanRules.move_parts(NightTypes.Part.PLANK, def.planks_per_section - left,
				PartPlace.deck(section), PartPlace.hand(), self)
	for rail: Vector2i in start.stripped_rails:
		if rail.x < 1 or rail.x > def.section_count or not NightTypes.Side.values().has(rail.y):
			faults.report(&"span.bad_start", "stripped rail %s" % rail)
			continue
		SpanRules.move_parts(NightTypes.Part.ROPE, 1, PartPlace.rail(rail.x, rail.y as NightTypes.Side),
				PartPlace.hand(), self)
