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
## The seed the night was built from (AD-3); NIGHT_STARTED carries it.
var night_seed: int = 0
var geometry: SpanGeometry
var span: SpanState
## The night's one generator (AD-33), seeded once; used only inside the sim.
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var faults: WatchFaults
## The tick advance() runs next.
var tick: int = 0
## This tick's move wish: world X/Z, length <= 1. WardenRules.walk() reads it.
var move_wish: Vector2 = Vector2.ZERO
## This tick's view in radians: yaw 0 faces -Z, positive turns left; pitch 0 is level, positive up.
var yaw: float = 0.0
var pitch: float = 0.0
## The commands taken this tick, in arrival order. No rule reads them yet (hands are story 1.4).
var commands: Array[NightCommand] = []
## Where the warden stands (AD-67). Only WardenRules moves it.
var warden: WardenState = WardenState.new()
## GD-19's walking speed in metres a tick, converted once (AD-33).
var walk_step: float = 0.0

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
## A def without at least one section of one plank is `sim.bad_def`, raised to 1.
func _init(night: NightDef, from_seed: int, night_faults: WatchFaults) -> void:
	def = night
	faults = night_faults
	night_seed = from_seed
	rng.seed = from_seed
	if def.section_count < 1 or def.planks_per_section < 1:
		faults.report(&"sim.bad_def", "%s: %d sections of %d planks (at least 1 of each)"
				% [def.name, def.section_count, def.planks_per_section])
		def.section_count = maxi(def.section_count, 1)
		def.planks_per_section = maxi(def.planks_per_section, 1)
	geometry = SpanGeometry.new(def, faults)
	span = SpanState.new(def.section_count, def.planks_per_section, faults)
	_apply_start(def.start)
	walk_step = WardenConstants.WALK_SPEED / NightTicks.TICKS_PER_SECOND
	_place_warden(def.start)
	_steps = [
		_step_inputs, _step_holds, _step_rigs, _step_consequences_of_actions, _step_clock,
		_step_dead, _step_loads, _step_consequences_of_loads, _step_crossings_and_windows,
		_step_lanterns, _step_wounds_and_name, _step_voices_and_ally, _step_ending,
	]


## The move wish for the next tick (AD-67). Longer than 1 is a fault, clamped; a wish that is
## not a finite number is a fault and counts as standing still.
func set_move(direction: Vector2) -> void:
	if not direction.is_finite():
		faults.report(&"sim.bad_input", "move wish %s" % direction)
		direction = Vector2.ZERO
	if direction.length() > 1.0 + MOVE_SLACK:
		faults.report(&"sim.move_too_long", "length %.3f" % direction.length())
	_next_move = direction.limit_length(1.0)


## The view for the next tick, in radians. A view that is not a finite number is a fault and
## the last view stands.
func set_view(view_yaw: float, view_pitch: float) -> void:
	if not is_finite(view_yaw) or not is_finite(view_pitch):
		faults.report(&"sim.bad_input", "view %f, %f" % [view_yaw, view_pitch])
		return
	_next_yaw = view_yaw
	_next_pitch = view_pitch


## Queued for the next advance(), in arrival order. A null command is a fault and is dropped.
func command(cmd: NightCommand) -> void:
	if cmd == null:
		faults.report(&"sim.bad_input", "a null command")
		return
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


## A hash of the tick, every part count, the warden's position, the view and the generator's state
## (AD-37): the determinism test now, the replay check in epic 6.
func checksum() -> int:
	var values: Array = [tick, rng.state, warden.position, yaw, pitch]
	values.append_array(span.counts())
	return hash(values)


## 1. Inputs (AD-34): the move wish and the view; the warden moves (AD-52); the look target is
## worked out (AD-47); then queued commands in the order they arrived. Walking is done
## (WardenRules); the look target is story 1.4; the commands are only taken (hands, story 1.4).
func _step_inputs() -> void:
	move_wish = _next_move
	yaw = _next_yaw
	pitch = _next_pitch
	WardenRules.walk(self)
	commands = _queued
	_queued = []


## 2. Holds and taps (AD-34): first whether the running action is still possible, then
## progress, then completion. No rule yet (story 1.4).
func _step_holds() -> void:
	pass


## 3. Rigs in motion (AD-34): a trapdoor's drop, a beam's sweep. No rule yet (epic 4).
func _step_rigs() -> void:
	pass


## 4. Consequences of what steps 2 and 3 changed (AD-34, AD-48). No rule yet (story 1.5).
func _step_consequences_of_actions() -> void:
	pass


## 5. The wave clock and the timetable (AD-34): warnings that are due start, or wait (AD-7).
## Tick 0 is the night's first toll (AD-33): NIGHT_STARTED.
func _step_clock() -> void:
	if tick == 0:
		var started: NightEvent = NightEvent.make(NightEvent.Kind.NIGHT_STARTED)
		started.id = def.name
		started.seed = night_seed
		emit(started)


## 6. The dead, including one reaching the warden (AD-34). No rule yet (epic 3).
func _step_dead() -> void:
	pass


## 7. Loads, creaks, groans and collapses (AD-34). No rule yet (story 1.5).
func _step_loads() -> void:
	pass


## 8. Consequences of what step 7 changed (AD-34, AD-48). No rule yet (story 1.5).
func _step_consequences_of_loads() -> void:
	pass


## 9. Crossings and windows (AD-34). No rule yet (epic 3).
func _step_crossings_and_windows() -> void:
	pass


## 10. Lanterns, oil and what is lit (AD-34). No rule yet (epic 4).
func _step_lanterns() -> void:
	pass


## 11. Wounds, the name (the hum's range, reading it), and the night-wide countdowns (the dead
## standing still, hurrying) (AD-34). No rule yet (epics 4 and 5).
func _step_wounds_and_name() -> void:
	pass


## 12. Voices, the ally, and the scoring marks for the log (AD-34). No rule yet (epic 2).
func _step_voices_and_ally() -> void:
	pass


## 13. The ending (AD-34): always the last event of its tick; dawn wins a tie. No rule yet:
## nothing ends a night in this story.
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


## Story 1.3 decision D3: the warden starts at `start.warden_along` on the centre line, or on the
## landing's centre for -1.0. A start that cannot be stood on is `warden.bad_start`, and the
## warden starts on the landing. Runs after the planks are set, which decide what can be stood on.
func _place_warden(start: StartState) -> void:
	warden.position = geometry.warden_start()
	if start.warden_along == -1.0:
		return
	var placed: Vector3 = Vector3(0.0, 0.0, geometry.world_z(start.warden_along))
	if not WardenRules.can_stand(placed, self):
		faults.report(&"warden.bad_start", "along %f cannot be stood on; the warden starts on the landing"
				% start.warden_along)
		return
	warden.position = placed
