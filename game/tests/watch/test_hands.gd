## The warden's hands (story 1.4 AC 1 to 10; AD-50, AD-67, UX-11, UX-39): strip, re-lay, refuse,
## cancel, Press once, the forearm, no carry limit, and decision D3 (a section that went bare
## under the warden still holds them). Spec values written literally with their sources:
## GD-19: strip a plank 2 s = 120 ticks, strip a rail 3 s = 180, re-lay 3 s = 180; the town
## section keeps 4 planks. GDD Controls: reach 2 m, a hold cancels past 0.5 m.
## Story 1.4 code review (Sonlm, 2026-11-21): Press once ignores a hold's own button for 0.25 s =
## 15 ticks after it completes; a change of the Holds option cancels the hold and lowers the forearm.
## Ticks are compared exactly; positions within 0.001 m.
extends WatchTest

## GD-19: 2 s at 60 ticks a second.
const STRIP_PLANK_TICKS: int = 120
## GD-19: 3 s.
const STRIP_RAIL_TICKS: int = 180
## GD-19: 3 s.
const RELAY_TICKS: int = 180
## Story 1.4 code review: 0.25 s.
const GRACE_TICKS: int = 15
## GD-19: 3.5 m/s at 60 ticks a second (AD-33).
const STEP: float = 3.5 / 60.0
const TOL: float = 0.001

const HAMMER: NightTypes.HandInput = NightTypes.HandInput.HAMMER
const ROPE: NightTypes.HandInput = NightTypes.HandInput.ROPE
const USE: NightTypes.HandInput = NightTypes.HandInput.USE
const FOREARM: NightTypes.HandInput = NightTypes.HandInput.FOREARM
const PLANK: NightTypes.Part = NightTypes.Part.PLANK
const LEFT: NightTypes.Side = NightTypes.Side.LEFT
## Looking down at the deck ahead: from the eye (1.6 m) the line lands 0.622 m ahead, 1.716 m
## along it (inside the 2 m reach).
const DOWN: float = -1.2
## From x -2.2 facing -X, aimed at the left rope's centre (atan(0.6 / 0.3), test_look.gd).
const AT_RAIL: float = -1.107


## A night of `sections` with `planks` and `rails` taken off at the start (into the hand), the
## warden at `along`, walked `sideways` ticks toward -X (the left rail stops the feet at -2.2), then
## aimed (`yaw`, `pitch`) and ticked once (tick 0) so the aim is in place for the next tick.
func _ready_at(along: float, planks: Dictionary[int, int] = {}, yaw: float = 0.0, pitch: float = DOWN,
		sideways: int = 0, sections: int = 6, rails: Array[Vector2i] = []) -> NightSim:
	var start: StartState = StartState.new()
	start.warden_along = along
	start.planks = planks
	start.stripped_rails = rails
	var sim: NightSim = _sim_with(_def_with(start, sections), 1)
	for i: int in sideways:
		sim.set_move(Vector2(-1.0, 0.0))
		sim.advance()
	sim.set_move(Vector2.ZERO)
	sim.set_view(yaw, pitch)
	sim.advance()
	return sim


## At the left rail of the section at `along`, aimed at its rope.
func _at_rail(along: float, planks: Dictionary[int, int] = {}, sections: int = 6) -> NightSim:
	return _ready_at(along, planks, PI / 2.0, AT_RAIL, 60, sections)


func _tick_of(event: NightEvent) -> int:
	return roundi(event.t * 60.0)


func _press(sim: NightSim, input: NightTypes.HandInput) -> void:
	sim.command(NightCommand.press(input))


func _release(sim: NightSim, input: NightTypes.HandInput) -> void:
	sim.command(NightCommand.release(input))


func _set_holds(sim: NightSim, mode: NightTypes.Holds) -> void:
	sim.command(NightCommand.set_option(NightTypes.Option.HOLDS, mode))


func _only(events: Array[NightEvent], kind: NightEvent.Kind) -> bool:
	return events.size() == 1 and events[0].kind == kind


func _names(events: Array[NightEvent]) -> String:
	return str(events.map(func(e: NightEvent) -> String: return NightEvent.Kind.find_key(e.kind)))


## Presses `input` and runs `ticks` more ticks: the events of the press's tick and every tick after.
func _hold(sim: NightSim, input: NightTypes.HandInput, ticks: int) -> Array[NightEvent]:
	_press(sim, input)
	return _advance(sim, ticks + 1)


func _of_kind(events: Array[NightEvent], kind: NightEvent.Kind) -> Array[NightEvent]:
	return events.filter(func(e: NightEvent) -> bool: return e.kind == kind)


func _along(sim: NightSim) -> float:
	return sim.warden.position.z + sim.geometry.length()


# --- AC 1 to 3: strip, strip a rail, re-lay ---------------------------------------------------

func _test_strip_a_plank() -> void:
	var sim: NightSim = _ready_at(17.5)
	var begun: int = sim.tick
	_press(sim, HAMMER)
	var first: Array[NightEvent] = sim.advance()
	_check("ac1: HOLD_STARTED on the press's tick", _only(first, NightEvent.Kind.HOLD_STARTED)
			and _tick_of(first[0]) == begun, _names(first))
	if not first.is_empty():
		_check("ac1: HOLD_STARTED names section 4 and strip_plank",
				first[0].section == 4 and first[0].id == &"strip_plank", "%d %s" % [first[0].section, first[0].id])
	var unchanged: bool = sim.span.planks(4) == 8 and sim.span.in_hand(PLANK) == 0
	for i: int in STRIP_PLANK_TICKS - 1:
		var events: Array[NightEvent] = sim.advance()
		unchanged = unchanged and events.is_empty() and sim.span.planks(4) == 8 and sim.span.in_hand(PLANK) == 0
	_check("ac1: nothing moves on T to T+119", unchanged)
	_check("ac1: progress is 119/120 on T+119", is_equal_approx(HoldRules.progress(sim.hands), 119.0 / 120.0),
			str(HoldRules.progress(sim.hands)))
	var done: Array[NightEvent] = sim.advance()
	_check("ac1: PLANK_STRIPPED on T+120, section 4", _only(done, NightEvent.Kind.PLANK_STRIPPED)
			and _tick_of(done[0]) == begun + STRIP_PLANK_TICKS and done[0].section == 4, _names(done))
	_check("ac1: the deck has 7, the hand 1", sim.span.planks(4) == 7 and sim.span.in_hand(PLANK) == 1,
			"%d %d" % [sim.span.planks(4), sim.span.in_hand(PLANK)])
	# GD-54: the plank that leaves first is place 3 (SpanGeometry's order); the sim keeps only the count.
	_check("ac1: the place that left is the order's first, 3", not sim.geometry.places_kept(7).has(3))
	_check("ac1: the hands are idle again", not sim.hands.holding() and HoldRules.progress(sim.hands) == 0.0)
	_check("ac1: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_strip_a_rail() -> void:
	var sim: NightSim = _at_rail(17.5)
	var begun: int = sim.tick
	var events: Array[NightEvent] = _hold(sim, ROPE, STRIP_RAIL_TICKS)
	var started: Array[NightEvent] = _of_kind(events, NightEvent.Kind.HOLD_STARTED)
	_check("ac2: HOLD_STARTED for strip_rail, section 4, left", started.size() == 1 and started[0].id == &"strip_rail"
			and started[0].section == 4 and started[0].side == LEFT, _names(events))
	var done: Array[NightEvent] = _of_kind(events, NightEvent.Kind.RAIL_STRIPPED)
	_check("ac2: RAIL_STRIPPED on T+180, section 4, left", done.size() == 1
			and _tick_of(done[0]) == begun + STRIP_RAIL_TICKS and done[0].section == 4 and done[0].side == LEFT,
			_names(events))
	_check("ac2: not a tick earlier", events.size() == 2, _names(events))
	_check("ac2: the rail is gone and 1 rope is in hand",
			not sim.span.rail_standing(4, LEFT) and sim.span.in_hand(NightTypes.Part.ROPE) == 1)
	_check("ac2: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_right_rail_carries_its_side() -> void:
	# The right rail, from x 2.2 facing +X (yaw -pi/2): every event of a rail action names RIGHT
	# (LEFT is the field's default, so only the right rail proves the side is set).
	var start: StartState = StartState.new()
	start.warden_along = 17.5
	var sim: NightSim = _sim_with(_def_with(start), 1)
	for i: int in 60:
		sim.set_move(Vector2(1.0, 0.0))
		sim.advance()
	sim.set_move(Vector2.ZERO)
	sim.set_view(-PI / 2.0, AT_RAIL)
	sim.advance()
	_press(sim, ROPE)
	var events: Array[NightEvent] = _advance(sim, 10)
	_release(sim, ROPE)
	events.append_array(sim.advance())
	var right: NightTypes.Side = NightTypes.Side.RIGHT
	var started: Array[NightEvent] = _of_kind(events, NightEvent.Kind.HOLD_STARTED)
	var cancelled: Array[NightEvent] = _of_kind(events, NightEvent.Kind.HOLD_CANCELLED)
	_check("side: HOLD_STARTED and HOLD_CANCELLED of the right rail say RIGHT", started.size() == 1
			and started[0].side == right and cancelled.size() == 1 and cancelled[0].side == right, _names(events))
	events = _hold(sim, ROPE, STRIP_RAIL_TICKS)
	var done: Array[NightEvent] = _of_kind(events, NightEvent.Kind.RAIL_STRIPPED)
	_check("side: RAIL_STRIPPED of the right rail says RIGHT", done.size() == 1 and done[0].side == right
			and not sim.span.rail_standing(4, right) and sim.span.rail_standing(4, LEFT), _names(events))


func _test_relay_a_plank() -> void:
	var sim: NightSim = _ready_at(17.5, {4: 5})
	var begun: int = sim.tick
	var events: Array[NightEvent] = _hold(sim, USE, RELAY_TICKS)
	var done: Array[NightEvent] = _of_kind(events, NightEvent.Kind.PLANK_RELAID)
	_check("ac3: PLANK_RELAID on T+180, section 4", done.size() == 1
			and _tick_of(done[0]) == begun + RELAY_TICKS and done[0].section == 4, _names(events))
	_check("ac3: the deck 6, the hand 2", sim.span.planks(4) == 6 and sim.span.in_hand(PLANK) == 2,
			"%d %d" % [sim.span.planks(4), sim.span.in_hand(PLANK)])
	# GD-69: a deck with no planks takes one. From section 5 (along 20.4) looking back at bare section 4.
	sim = _ready_at(20.4, {4: 0})
	events = _hold(sim, USE, RELAY_TICKS)
	_check("ac3: a bare deck takes a plank (GD-69)", _of_kind(events, NightEvent.Kind.PLANK_RELAID).size() == 1
			and sim.span.planks(4) == 1 and sim.span.in_hand(PLANK) == 7, _names(events))
	_check("ac3: no fault", _faults.total() == 0, str(_faults.codes()))


# --- AC 4: refusals ---------------------------------------------------------------------------

## Presses `input` on `sim` and on `twin` (the same night) nothing; true when `sim` emitted exactly
## one REFUSED with `reason` and both end with the same checksum (nothing changed).
func _refused(sim: NightSim, twin: NightSim, input: NightTypes.HandInput, reason: NightTypes.Reason,
		section: int, id: StringName) -> bool:
	_press(sim, input)
	var events: Array[NightEvent] = _advance(sim, 3)
	twin.advance()
	twin.advance()
	twin.advance()
	if events.size() != 1 or events[0].kind != NightEvent.Kind.REFUSED:
		_check("refused: one REFUSED event", false, _names(events))
		return false
	var e: NightEvent = events[0]
	var fields_ok: bool = e.reason == reason and e.section == section and e.id == id
	if not fields_ok:
		_check("refused: fields", false, "%s s%d %s" % [NightTypes.Reason.find_key(e.reason), e.section, e.id])
	return fields_ok and sim.checksum() == twin.checksum()


func _test_refusals() -> void:
	# A re-lay with no plank in hand: the hand is read first (Sonlm, 2026-11-21), so even at a
	# full deck (with nothing lost, an empty hand means every deck is full).
	_check("ac4: E with no plank in hand is NO_PLANK_IN_HAND",
			_refused(_ready_at(17.5), _ready_at(17.5), USE, NightTypes.Reason.NO_PLANK_IN_HAND, 4, &"relay_plank"))
	# A plank in hand (section 2 at 7) and a full deck 4.
	_check("ac4: E at a full deck with a plank in hand is DECK_FULL",
			_refused(_ready_at(17.5, {2: 7}), _ready_at(17.5, {2: 7}), USE, NightTypes.Reason.DECK_FULL, 4, &"relay_plank"))
	# GD-19: the town section (6) at 4 keeps its planks.
	_check("ac4: a strip of section 6 at 4 is LAST_SECTION_MINIMUM",
			_refused(_ready_at(27.5, {6: 4}), _ready_at(27.5, {6: 4}), HAMMER, NightTypes.Reason.LAST_SECTION_MINIMUM,
					6, &"strip_plank"))
	_check("ac4: on a 4-section night the town section is 4",
			_refused(_ready_at(17.5, {4: 4}, 0.0, DOWN, 0, 4), _ready_at(17.5, {4: 4}, 0.0, DOWN, 0, 4), HAMMER,
					NightTypes.Reason.LAST_SECTION_MINIMUM, 4, &"strip_plank"))
	_check("ac4: a strip of a bare deck is NO_PLANKS_LEFT",
			_refused(_ready_at(20.4, {4: 0}), _ready_at(20.4, {4: 0}), HAMMER, NightTypes.Reason.NO_PLANKS_LEFT, 4,
					&"strip_plank"))
	# UX-6 applies to keys as well as clicks: a press that finds no action is refused.
	var sky: float = 0.5
	_check("ac4: the hammer at the sky is NO_ACTION_HERE, section 0, no id",
			_refused(_ready_at(17.5, {}, 0.0, sky), _ready_at(17.5, {}, 0.0, sky), HAMMER,
					NightTypes.Reason.NO_ACTION_HERE, 0, &""))
	_check("ac4: the rope hand at a deck is NO_ACTION_HERE",
			_refused(_ready_at(17.5), _ready_at(17.5), ROPE, NightTypes.Reason.NO_ACTION_HERE, 0, &""))
	_check("ac4: E at a rail is NO_ACTION_HERE",
			_refused(_at_rail(17.5, {2: 7}), _at_rail(17.5, {2: 7}), USE, NightTypes.Reason.NO_ACTION_HERE, 0, &""))
	for input: NightTypes.HandInput in [NightTypes.HandInput.SHUTTER, NightTypes.HandInput.BUILD_TRAPDOOR,
			NightTypes.HandInput.BUILD_BEAM, NightTypes.HandInput.DISMANTLE]:
		_check("ac4: %s at a deck is NO_ACTION_HERE (its action is epic 4)" % NightTypes.HandInput.find_key(input),
				_refused(_ready_at(17.5), _ready_at(17.5), input, NightTypes.Reason.NO_ACTION_HERE, 0, &""))
	_check("ac4: refusals report no fault", _faults.total() == 0, str(_faults.codes()))


func _test_town_section_floor() -> void:
	# GD-19: section 6 at 5 gives one plank, then refuses before a last plank can go.
	var sim: NightSim = _ready_at(27.5, {6: 5})
	var events: Array[NightEvent] = _hold(sim, HAMMER, STRIP_PLANK_TICKS)
	_check("town: at 5, a strip completes to 4", _of_kind(events, NightEvent.Kind.PLANK_STRIPPED).size() == 1
			and sim.span.planks(6) == 4, _names(events))
	_press(sim, HAMMER)
	events = sim.advance()
	_check("town: at 4, the next is refused", _only(events, NightEvent.Kind.REFUSED)
			and events[0].reason == NightTypes.Reason.LAST_SECTION_MINIMUM and sim.span.planks(6) == 4, _names(events))


func _test_town_rails_can_be_stripped() -> void:
	for sections: int in [6, 4]:
		var along: float = sections * 5.0 - 2.5
		var sim: NightSim = _at_rail(along, {sections: 4}, sections)
		var events: Array[NightEvent] = _hold(sim, ROPE, STRIP_RAIL_TICKS)
		_check("ac4: %d sections, the town section at 4 still gives its rail" % sections,
				_of_kind(events, NightEvent.Kind.RAIL_STRIPPED).size() == 1
				and not sim.span.rail_standing(sections, LEFT), _names(events))
		_check("ac4: %d sections, no fault" % sections, _faults.total() == 0, str(_faults.codes()))


# --- AC 5: cancel -----------------------------------------------------------------------------

func _test_release_cancels() -> void:
	var sim: NightSim = _ready_at(17.5)
	var begun: int = sim.tick
	var events: Array[NightEvent] = _hold(sim, HAMMER, 59)
	_release(sim, HAMMER)
	var cancel: Array[NightEvent] = sim.advance()
	_check("ac5: a release on T+60 cancels on T+60", _only(cancel, NightEvent.Kind.HOLD_CANCELLED)
			and _tick_of(cancel[0]) == begun + 60, _names(cancel))
	if not cancel.is_empty():
		_check("ac5: HOLD_CANCELLED names section 4 and strip_plank",
				cancel[0].section == 4 and cancel[0].id == &"strip_plank")
	events = _advance(sim, 120)
	_check("ac5: nothing moves after it", events.is_empty() and sim.span.planks(4) == 8
			and sim.span.in_hand(PLANK) == 0 and not sim.hands.holding(), _names(events))
	# AD-50: a release on the same tick as the last one cancels (step 1 runs before step 2).
	sim = _ready_at(17.5)
	begun = sim.tick
	_hold(sim, HAMMER, STRIP_PLANK_TICKS - 1)
	_release(sim, HAMMER)
	cancel = sim.advance()
	_check("ac5: a release on T+120 itself cancels", _only(cancel, NightEvent.Kind.HOLD_CANCELLED)
			and _tick_of(cancel[0]) == begun + STRIP_PLANK_TICKS and sim.span.planks(4) == 8, _names(cancel))
	# A release of another button does nothing.
	sim = _ready_at(17.5)
	_press(sim, HAMMER)
	sim.advance()
	_release(sim, ROPE)
	_release(sim, FOREARM)
	events = _advance(sim, STRIP_PLANK_TICKS)
	_check("ac5: releasing another button does not cancel", _of_kind(events, NightEvent.Kind.PLANK_STRIPPED).size() == 1,
			_names(events))


## Presses HAMMER at along 17.5, then walks toward the far pier with `wishes` (one per tick),
## then stands until T+120. The events of every tick.
func _walk_during_hold(wishes: Array[Vector2]) -> Array[NightEvent]:
	var sim: NightSim = _ready_at(17.5)
	_press(sim, HAMMER)
	var events: Array[NightEvent] = sim.advance()
	for wish: Vector2 in wishes:
		sim.set_move(wish)
		events.append_array(sim.advance())
	sim.set_move(Vector2.ZERO)
	events.append_array(_advance(sim, STRIP_PLANK_TICKS))
	return events


func _test_moving_cancels() -> void:
	# GDD Controls: moving more than 0.5 m cancels. 9 ticks at 0.5 / (9 * 3.5 / 60) of full speed
	# walk exactly 0.5 m: kept. One more full step (0.058 m) is past it: cancelled on that tick.
	var exact: float = 0.5 / (9.0 * STEP)
	var wishes: Array[Vector2] = []
	for i: int in 9:
		wishes.append(Vector2(0.0, -exact))
	var events: Array[NightEvent] = _walk_during_hold(wishes)
	_check("ac5: walking exactly 0.5 m keeps the hold", _of_kind(events, NightEvent.Kind.PLANK_STRIPPED).size() == 1
			and _of_kind(events, NightEvent.Kind.HOLD_CANCELLED).is_empty(), _names(events))
	wishes.append(Vector2(0.0, -1.0))
	events = _walk_during_hold(wishes)
	var cancel: Array[NightEvent] = _of_kind(events, NightEvent.Kind.HOLD_CANCELLED)
	_check("ac5: 0.5 m and one step more cancels, on that tick (T+10)", cancel.size() == 1
			and _tick_of(cancel[0]) == _tick_of(events[0]) + 10
			and _of_kind(events, NightEvent.Kind.PLANK_STRIPPED).is_empty(), _names(events))
	# A walk of exactly 0.5 m whose float steps add up a hair past it (10 sideways ticks from along
	# 15.0 land 0.50000006 m away) is still 0.5 m: kept (HoldRules.MOVE_SLACK).
	var start: StartState = StartState.new()
	start.warden_along = 15.0
	var sim: NightSim = _sim_with(_def_with(start), 1)
	sim.set_view(0.0, DOWN)
	sim.advance()
	var from: Vector3 = sim.warden.position
	_press(sim, HAMMER)
	events = sim.advance()
	for i: int in 10:
		sim.set_move(Vector2(0.5 / (10.0 * STEP), 0.0))
		events.append_array(sim.advance())
	sim.set_move(Vector2.ZERO)
	var walked: float = Vector2(sim.warden.position.x - from.x, sim.warden.position.z - from.z).length()
	events.append_array(_advance(sim, STRIP_PLANK_TICKS))
	_check("ac5: a 0.5 m walk summed a rounding error past 0.5 keeps the hold", walked > 0.5 and walked < 0.5001
			and _of_kind(events, NightEvent.Kind.PLANK_STRIPPED).size() == 1, "%.9f %s" % [walked, _names(events)])
	# Sideways counts the same (x and z).
	wishes = []
	for i: int in 10:
		wishes.append(Vector2(1.0, 0.0))
	events = _walk_during_hold(wishes)
	_check("ac5: walking 0.58 m sideways cancels too", _of_kind(events, NightEvent.Kind.HOLD_CANCELLED).size() == 1,
			_names(events))


func _test_looking_around_does_not_cancel() -> void:
	var sim: NightSim = _ready_at(17.5)
	_press(sim, HAMMER)
	var events: Array[NightEvent] = sim.advance()
	for i: int in STRIP_PLANK_TICKS:
		sim.set_view(TAU * (i + 1) / STRIP_PLANK_TICKS, 0.8 * sin(i * 0.1))
		events.append_array(sim.advance())
	_check("ac5: turning a full circle during the hold does not cancel it",
			_of_kind(events, NightEvent.Kind.PLANK_STRIPPED).size() == 1
			and _of_kind(events, NightEvent.Kind.HOLD_CANCELLED).is_empty(), _names(events))


func _test_check_on_a_changed_target() -> void:
	# "Can no longer be started": HandRules.check() on the hold's own target once the state no
	# longer allows it, on sims whose StartState has that state. Pure: nothing is emitted.
	var deck4: LookTarget = LookTarget.deck(4, 1.0)
	var bare: NightSim = _ready_at(20.4, {4: 0})
	_check("check: strip on a deck gone bare is NO_PLANKS_LEFT",
			HandRules.check(NightTypes.HandAction.STRIP_PLANK, deck4, bare.def, bare.span) == NightTypes.Reason.NO_PLANKS_LEFT)
	var stripped: NightSim = _ready_at(17.5, {}, 0.0, DOWN, 0, 6, [Vector2i(4, LEFT)])
	_check("check: strip of a rail that went is NO_ACTION_HERE",
			HandRules.check(NightTypes.HandAction.STRIP_RAIL, LookTarget.rail(4, LEFT, 0.5), stripped.def,
					stripped.span) == NightTypes.Reason.NO_ACTION_HERE)
	_check("check: and of a rail still up is NONE",
			HandRules.check(NightTypes.HandAction.STRIP_RAIL, LookTarget.rail(4, NightTypes.Side.RIGHT, 0.5),
					stripped.def, stripped.span) == NightTypes.Reason.NONE)
	var town: NightSim = _ready_at(17.5, {6: 4})
	_check("check: strip of the town section at 4 is LAST_SECTION_MINIMUM",
			HandRules.check(NightTypes.HandAction.STRIP_PLANK, LookTarget.deck(6, 1.0), town.def, town.span)
			== NightTypes.Reason.LAST_SECTION_MINIMUM)
	_check("check: and of section 5 there is NONE",
			HandRules.check(NightTypes.HandAction.STRIP_PLANK, LookTarget.deck(5, 1.0), town.def, town.span)
			== NightTypes.Reason.NONE)
	var full: NightSim = _ready_at(17.5, {2: 7})
	_check("check: re-lay on a full deck with a plank in hand is DECK_FULL",
			HandRules.check(NightTypes.HandAction.RELAY_PLANK, deck4, full.def, full.span) == NightTypes.Reason.DECK_FULL)
	_check("check: re-lay on section 2 (7) with that plank is NONE",
			HandRules.check(NightTypes.HandAction.RELAY_PLANK, LookTarget.deck(2, 1.0), full.def, full.span)
			== NightTypes.Reason.NONE)
	_check("check: no action is NO_ACTION_HERE",
			HandRules.check(NightTypes.HandAction.NONE, deck4, full.def, full.span) == NightTypes.Reason.NO_ACTION_HERE)
	_check("check: action_for maps hammer+deck, rope+rail, E+deck, and nothing else",
			HandRules.action_for(HAMMER, deck4) == NightTypes.HandAction.STRIP_PLANK
			and HandRules.action_for(USE, deck4) == NightTypes.HandAction.RELAY_PLANK
			and HandRules.action_for(ROPE, LookTarget.rail(4, LEFT, 0.5)) == NightTypes.HandAction.STRIP_RAIL
			and HandRules.action_for(ROPE, deck4) == NightTypes.HandAction.NONE
			and HandRules.action_for(HAMMER, LookTarget.rail(4, LEFT, 0.5)) == NightTypes.HandAction.NONE
			and HandRules.action_for(HAMMER, LookTarget.none()) == NightTypes.HandAction.NONE)
	_check("check: no fault", _faults.total() == 0, str(_faults.codes()))


# --- AC 6: one action at a time ---------------------------------------------------------------

func _test_one_action_at_a_time() -> void:
	var sim: NightSim = _ready_at(17.5, {2: 7})
	var begun: int = sim.tick
	_press(sim, HAMMER)
	var events: Array[NightEvent] = _advance(sim, 31)
	_check("ac6: the hold began, and nothing else in its first 30 ticks", _only(events, NightEvent.Kind.HOLD_STARTED),
			_names(events))
	_press(sim, ROPE)
	_press(sim, USE)
	_press(sim, HAMMER)
	_press(sim, NightTypes.HandInput.SHUTTER)
	var mid: Array[NightEvent] = sim.advance()
	_check("ac6: other presses mid-hold emit nothing", mid.is_empty(), _names(mid))
	events = _advance(sim, STRIP_PLANK_TICKS)
	var done: Array[NightEvent] = _of_kind(events, NightEvent.Kind.PLANK_STRIPPED)
	_check("ac6: the first completes on time", done.size() == 1 and _tick_of(done[0]) == begun + STRIP_PLANK_TICKS
			and events.size() == 1, _names(events))


# --- AC 7: Press once -------------------------------------------------------------------------

func _test_press_once() -> void:
	var sim: NightSim = _ready_at(17.5)
	_set_holds(sim, NightTypes.Holds.PRESS_ONCE)
	var begun: int = sim.tick
	_press(sim, HAMMER)
	sim.advance()
	_check("ac7: the option is taken", sim.holds == NightTypes.Holds.PRESS_ONCE)
	_release(sim, HAMMER)
	var events: Array[NightEvent] = _advance(sim, STRIP_PLANK_TICKS)
	var done: Array[NightEvent] = _of_kind(events, NightEvent.Kind.PLANK_STRIPPED)
	_check("ac7: Press once: the hold runs its full time, the release ignored", done.size() == 1
			and _tick_of(done[0]) == begun + STRIP_PLANK_TICKS and events.size() == 1, _names(events))
	# A second press of the same input stops it (begun after the grace that follows a completion).
	_advance(sim, GRACE_TICKS)
	_press(sim, HAMMER)
	sim.advance()
	_advance(sim, 30)
	_press(sim, ROPE)
	var other: Array[NightEvent] = sim.advance()
	_check("ac7: a press of another input is ignored", other.is_empty(), _names(other))
	_press(sim, HAMMER)
	var stop: Array[NightEvent] = sim.advance()
	_check("ac7: a second press of the same input cancels", _only(stop, NightEvent.Kind.HOLD_CANCELLED)
			and sim.span.planks(4) == 7, _names(stop))
	# Moving still cancels.
	_press(sim, HAMMER)
	sim.advance()
	events = []
	for i: int in 10:
		sim.set_move(Vector2(0.0, -1.0))
		events.append_array(sim.advance())
	_check("ac7: walking 0.5 m and a step cancels in Press once too",
			_of_kind(events, NightEvent.Kind.HOLD_CANCELLED).size() == 1, _names(events))
	_check("ac7: no fault", _faults.total() == 0, str(_faults.codes()))


## Story 1.4 code review: the press meant to stop a hold may land just after it completed. For
## 15 ticks after the completion that button is ignored; another button is not; Hold mode has no
## such grace.
func _test_press_once_grace() -> void:
	# One tick after the completion, and on the last tick of the grace: ignored.
	for late: int in [1, GRACE_TICKS]:
		var sim: NightSim = _ready_at(17.5)
		_set_holds(sim, NightTypes.Holds.PRESS_ONCE)
		var begun: int = sim.tick
		_press(sim, HAMMER)
		var events: Array[NightEvent] = _advance(sim, STRIP_PLANK_TICKS + 1)
		_check("grace: the strip completed on T + 120", sim.tick == begun + STRIP_PLANK_TICKS + 1
				and _of_kind(events, NightEvent.Kind.PLANK_STRIPPED).size() == 1, _names(events))
		_advance(sim, late - 1)
		_press(sim, HAMMER)
		events = _advance(sim, STRIP_PLANK_TICKS + 5)
		_check("grace: the same button %d ticks after the completion is ignored, no event" % late,
				events.is_empty() and not sim.hands.holding() and sim.span.planks(4) == 7, _names(events))
		_check("grace: no fault", _faults.total() == 0, str(_faults.codes()))
	# The tick after the grace: a new hold.
	var after: NightSim = _ready_at(17.5)
	_set_holds(after, NightTypes.Holds.PRESS_ONCE)
	_press(after, HAMMER)
	_advance(after, STRIP_PLANK_TICKS + 1 + GRACE_TICKS)
	_press(after, HAMMER)
	var started: Array[NightEvent] = after.advance()
	_check("grace: 16 ticks after the completion the same button starts a hold",
			_only(started, NightEvent.Kind.HOLD_STARTED), _names(started))
	# Another button inside the grace acts at once: E re-lays the plank just stripped.
	var other: NightSim = _ready_at(17.5)
	_set_holds(other, NightTypes.Holds.PRESS_ONCE)
	_press(other, HAMMER)
	_advance(other, STRIP_PLANK_TICKS + 1)
	_press(other, USE)
	started = other.advance()
	_check("grace: another button is not held back", _only(started, NightEvent.Kind.HOLD_STARTED)
			and started[0].id == &"relay_plank", _names(started))
	# Hold mode: no grace. The button has to come up and go down again, and that press counts.
	var hold: NightSim = _ready_at(17.5)
	_press(hold, HAMMER)
	_advance(hold, STRIP_PLANK_TICKS + 1)
	_release(hold, HAMMER)
	_press(hold, HAMMER)
	started = hold.advance()
	_check("grace: Hold mode has none: a press one tick after the completion starts a hold",
			_only(started, NightEvent.Kind.HOLD_STARTED), _names(started))


## Story 1.4 code review: a change of the Holds option cancels the running hold and lowers the
## forearm, so no hold and no raised forearm is left with no button behind it.
func _test_mode_change_starts_from_idle_hands() -> void:
	# Hold to Press once with a hold running.
	var sim: NightSim = _ready_at(17.5)
	_press(sim, HAMMER)
	_advance(sim, 30)
	_set_holds(sim, NightTypes.Holds.PRESS_ONCE)
	var events: Array[NightEvent] = sim.advance()
	_check("mode: Hold to Press once cancels the running hold", _only(events, NightEvent.Kind.HOLD_CANCELLED)
			and not sim.hands.holding() and sim.holds == NightTypes.Holds.PRESS_ONCE, _names(events))
	events = _advance(sim, STRIP_PLANK_TICKS + 5)
	_check("mode: and no part moves afterwards", events.is_empty() and sim.span.planks(4) == 8, _names(events))
	# Press once to Hold with a hold running (no button is down).
	_press(sim, HAMMER)
	_advance(sim, 30)
	_check("mode: a Press once hold is running", sim.hands.holding())
	_set_holds(sim, NightTypes.Holds.HOLD)
	events = sim.advance()
	_check("mode: Press once to Hold cancels it too", _only(events, NightEvent.Kind.HOLD_CANCELLED)
			and not sim.hands.holding(), _names(events))
	events = _advance(sim, STRIP_PLANK_TICKS + 5)
	_check("mode: and it does not complete with nothing held", events.is_empty() and sim.span.planks(4) == 8,
			_names(events))
	# Press once to Hold with the forearm toggled up.
	_set_holds(sim, NightTypes.Holds.PRESS_ONCE)
	_press(sim, FOREARM)
	sim.advance()
	_check("mode: the forearm is toggled up", sim.hands.forearm_raised)
	_set_holds(sim, NightTypes.Holds.HOLD)
	sim.advance()
	_check("mode: a change of mode lowers the forearm", not sim.hands.forearm_raised)
	_press(sim, HAMMER)
	events = sim.advance()
	_check("mode: and the hands work at once", _only(events, NightEvent.Kind.HOLD_STARTED), _names(events))
	# The same mode again changes nothing: the hold runs on, and so does a raised forearm.
	_set_holds(sim, NightTypes.Holds.HOLD)
	events = sim.advance()
	_check("mode: setting the mode it already has leaves the hold alone", events.is_empty() and sim.hands.holding(),
			_names(events))
	_release(sim, HAMMER)
	_press(sim, FOREARM)
	sim.advance()
	_set_holds(sim, NightTypes.Holds.HOLD)
	sim.advance()
	_check("mode: and leaves a raised forearm up", sim.hands.forearm_raised)
	# A change of mode also ends the grace: the button acts at once in the new mode and back.
	var grace: NightSim = _ready_at(17.5)
	_set_holds(grace, NightTypes.Holds.PRESS_ONCE)
	_press(grace, HAMMER)
	_advance(grace, STRIP_PLANK_TICKS + 1)
	_set_holds(grace, NightTypes.Holds.HOLD)
	_set_holds(grace, NightTypes.Holds.PRESS_ONCE)
	_press(grace, HAMMER)
	events = grace.advance()
	_check("mode: a change of mode ends the grace", _only(events, NightEvent.Kind.HOLD_STARTED), _names(events))
	_check("mode: no fault", _faults.total() == 0, str(_faults.codes()))


## A press and a release of one button taken in the same tick (Hold mode): the hold begins and is
## cancelled on that tick, in that order, and nothing moves.
func _test_press_and_release_in_one_tick() -> void:
	var sim: NightSim = _ready_at(17.5)
	_press(sim, HAMMER)
	_release(sim, HAMMER)
	var events: Array[NightEvent] = sim.advance()
	_check("one tick: press then release is a hold begun and cancelled on that tick", events.size() == 2
			and events[0].kind == NightEvent.Kind.HOLD_STARTED and events[1].kind == NightEvent.Kind.HOLD_CANCELLED
			and not sim.hands.holding(), _names(events))
	events = _advance(sim, STRIP_PLANK_TICKS + 5)
	_check("one tick: and no part moves", events.is_empty() and sim.span.planks(4) == 8, _names(events))
	# Release then press (the button was down from before): the release finds no hold, the press begins one.
	_release(sim, HAMMER)
	_press(sim, HAMMER)
	events = sim.advance()
	_check("one tick: release then press begins a hold", _only(events, NightEvent.Kind.HOLD_STARTED)
			and sim.hands.holding(), _names(events))


func _test_press_once_forearm() -> void:
	var sim: NightSim = _ready_at(17.5)
	_set_holds(sim, NightTypes.Holds.PRESS_ONCE)
	_press(sim, FOREARM)
	var raise: Array[NightEvent] = sim.advance()
	_check("ac7: Tab press raises, and emits nothing", sim.hands.forearm_raised and raise.is_empty(), _names(raise))
	_release(sim, FOREARM)
	sim.advance()
	_check("ac7: Tab release does nothing", sim.hands.forearm_raised)
	_press(sim, HAMMER)
	_press(sim, USE)
	var blocked: Array[NightEvent] = _advance(sim, 5)
	_check("ac7: toggled up, a hand press does nothing, not even a refusal", blocked.is_empty()
			and not sim.hands.holding(), _names(blocked))
	_press(sim, FOREARM)
	sim.advance()
	_check("ac7: Tab press again lowers", not sim.hands.forearm_raised)
	# Back to Hold: Tab is held again.
	_set_holds(sim, NightTypes.Holds.HOLD)
	_press(sim, FOREARM)
	sim.advance()
	_press(sim, FOREARM)
	sim.advance()
	_check("hold: a second Tab press keeps it raised", sim.hands.forearm_raised)
	_release(sim, FOREARM)
	sim.advance()
	_check("hold: Tab release lowers", not sim.hands.forearm_raised)


# --- AC 8: the forearm ------------------------------------------------------------------------

func _test_forearm() -> void:
	var sim: NightSim = _ready_at(17.5)
	_press(sim, FOREARM)
	var raise: Array[NightEvent] = sim.advance()
	_check("ac8: Tab press raises the forearm", sim.hands.forearm_raised)
	_check("ac8: raising emits nothing", raise.is_empty(), _names(raise))
	var events: Array[NightEvent] = []
	for i: int in 60:
		sim.set_move(Vector2(0.0, -1.0))
		events.append_array(sim.advance())
	sim.set_move(Vector2.ZERO)
	_check("ac8: with it up, the warden still walks (60 ticks: 3.5 m, GD-19)", absf(_along(sim) - 14.0) < TOL,
			str(_along(sim)))
	_press(sim, HAMMER)
	_press(sim, USE)
	events.append_array(_advance(sim, 5))
	_check("ac8: a hand press does nothing, not even a refusal", events.is_empty(), _names(events))
	_release(sim, FOREARM)
	var lower: Array[NightEvent] = sim.advance()
	_check("ac8: Tab release lowers it", not sim.hands.forearm_raised)
	_check("ac8: lowering emits nothing", lower.is_empty(), _names(lower))
	_press(sim, HAMMER)
	events = sim.advance()
	_check("ac8: lowered, the hammer works again", _only(events, NightEvent.Kind.HOLD_STARTED), _names(events))
	_press(sim, FOREARM)
	sim.advance()
	_check("ac8: Tab during a hold is ignored", not sim.hands.forearm_raised and sim.hands.holding())
	_check("ac8: no fault", _faults.total() == 0, str(_faults.codes()))


# --- AC 9: no carry limit ---------------------------------------------------------------------

func _test_no_carry_limit() -> void:
	# 7 planks from section 2, 7 from section 3 and 6 from section 4, standing mid each section.
	var sim: NightSim = _ready_at(7.5)
	var stripped: int = 0
	for section: int in [2, 3, 4]:
		var count: int = 6 if section == 4 else 7
		for i: int in count:
			stripped += _of_kind(_hold(sim, HAMMER, STRIP_PLANK_TICKS), NightEvent.Kind.PLANK_STRIPPED).size()
		for i: int in 86:
			sim.set_move(Vector2(0.0, 1.0))
			sim.advance()
		sim.set_move(Vector2.ZERO)
	_check("ac9: 20 strips in a row, 20 in hand", stripped == 20 and sim.span.in_hand(PLANK) == 20,
			"%d %d" % [stripped, sim.span.in_hand(PLANK)])
	_check("ac9: no limit and no fault", _faults.total() == 0, str(_faults.codes()))


# --- AC 10 and D3: the last plank underfoot ---------------------------------------------------

func _test_last_plank_underfoot() -> void:
	# Section 3 at 1 plank; the warden at along 14.0 strips it from where they stand.
	var sim: NightSim = _ready_at(14.0, {3: 1})
	var at: Vector3 = sim.warden.position
	var events: Array[NightEvent] = _hold(sim, HAMMER, STRIP_PLANK_TICKS)
	_check("ac10: the strip completes", _of_kind(events, NightEvent.Kind.PLANK_STRIPPED).size() == 1
			and sim.span.planks(3) == 0, _names(events))
	_check("ac10: the warden stays in place", sim.warden.position.is_equal_approx(at), str(sim.warden.position))
	_check("ac10: where they stand can no longer be stood on", not WardenRules.can_stand(sim.warden.position, sim))
	# D3: walking toward the town moves them on every tick, through 15.0 to 15.3, into section 4.
	var moved_every_tick: bool = true
	var in_band: bool = false
	var last: float = _along(sim)
	for i: int in 40:
		sim.set_move(Vector2(0.0, 1.0))
		sim.advance()
		moved_every_tick = moved_every_tick and _along(sim) > last + STEP - TOL
		in_band = in_band or (_along(sim) > 15.0 and _along(sim) < 15.3)
		last = _along(sim)
	_check("d3: walking off the bare section moves on every tick", moved_every_tick, str(_along(sim)))
	_check("d3: through the 15.0 to 15.3 band", in_band)
	_check("d3: and on into section 4 (along 14.0 + 40 steps = 16.333)", absf(_along(sim) - (14.0 + 40 * STEP)) < TOL,
			str(_along(sim)))
	# Story 1.3 D1: once standing again, the bare section blocks at section_end(3) + 0.3 = 15.3.
	for i: int in 40:
		sim.set_move(Vector2(0.0, -1.0))
		sim.advance()
	_check("d3: walking back stops at 15.3", absf(_along(sim) - 15.3) < TOL, str(_along(sim)))
	_check("d3: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_last_plank_from_the_next_section() -> void:
	# On section 4 at along 15.1 (0.1 m in), stripping section 3's last plank (looking back, down).
	var sim: NightSim = _ready_at(15.1, {3: 1})
	var events: Array[NightEvent] = _hold(sim, HAMMER, STRIP_PLANK_TICKS)
	_check("d3: the strip from section 4 takes section 3's last plank",
			_of_kind(events, NightEvent.Kind.PLANK_STRIPPED).size() == 1 and events[events.size() - 1].section == 3
			and sim.span.planks(3) == 0, _names(events))
	_check("d3: at 15.1 the warden cannot stand by the rule", not WardenRules.can_stand(sim.warden.position, sim))
	for i: int in 10:
		sim.set_move(Vector2(0.0, -1.0))
		sim.advance()
	_check("d3: section 3 holds them: they can walk onto it (15.1 - 10 steps = 14.517)",
			absf(_along(sim) - (15.1 - 10 * STEP)) < TOL, str(_along(sim)))
	for i: int in 30:
		sim.set_move(Vector2(0.0, 1.0))
		sim.advance()
	_check("d3: and off it toward the town (15.1 + 20 steps = 16.267)", absf(_along(sim) - (15.1 + 20 * STEP)) < TOL,
			str(_along(sim)))
	for i: int in 30:
		sim.set_move(Vector2(0.0, -1.0))
		sim.advance()
	_check("d3: once past 15.3, the bare section blocks again at 15.3", absf(_along(sim) - 15.3) < TOL, str(_along(sim)))
	_check("d3: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_bare_from_the_start_blocks() -> void:
	# D3's negative: section 3 bare in the StartState, the warden at 15.5: never into 15.0 to 15.3.
	var sim: NightSim = _ready_at(15.5, {3: 0})
	var lowest: float = _along(sim)
	for i: int in 30:
		sim.set_move(Vector2(0.0, -1.0))
		sim.advance()
		lowest = minf(lowest, _along(sim))
	_check("d3: a section bare from the start stops the warden at 15.3", absf(_along(sim) - 15.3) < TOL
			and lowest > 15.3 - TOL, "%f %f" % [_along(sim), lowest])


func _test_last_plank_town_section() -> void:
	# AC 10 is sections 1 to 5: on the town section the floor of 4 refuses first (GD-19).
	var sim: NightSim = _ready_at(27.5, {6: 4})
	_press(sim, HAMMER)
	var events: Array[NightEvent] = sim.advance()
	_check("ac10: the town section never reaches its last plank", _only(events, NightEvent.Kind.REFUSED)
			and sim.span.planks(6) == 4, _names(events))


# --- Story 1.5 AC 10 / DW-34: a hold on a section that falls; the hands during the climb -------
# GD-19 / GDD Game Mechanics 2: 3 planks under 4 weights groans from tick 0 and falls on tick 120
# (2 s). The fall is step 7 of tick F; HoldRules is step 2, so it cancels on F + 1. The climb back
# is 5 s = 300 ticks, during which every press is ignored (story 1.5, "The climb").

## GDD Game Mechanics 2: the fall tick of a section overloaded from tick 0.
const FALL_TICK: int = 120


## As _ready_at(), with test weights placed too.
func _loaded_at(along: float, planks: Dictionary[int, int], weights: Dictionary[int, int], yaw: float = 0.0,
		pitch: float = DOWN, sideways: int = 0) -> NightSim:
	var start: StartState = StartState.new()
	start.warden_along = along
	start.planks = planks
	start.weights = weights
	var sim: NightSim = _sim_with(_def_with(start), 1)
	for i: int in sideways:
		sim.set_move(Vector2(-1.0, 0.0))
		sim.advance()
	sim.set_move(Vector2.ZERO)
	sim.set_view(yaw, pitch)
	sim.advance()
	return sim


## Runs to the tick after the fall (F + 1) and returns that tick's events.
func _after_the_fall(sim: NightSim) -> Array[NightEvent]:
	_advance(sim, FALL_TICK + 1 - sim.tick)
	return sim.advance()


func _test_dw34_a_strip_hold_on_a_falling_section() -> void:
	# On section 5 at along 20.4, a strip of section 4's deck begun on tick 1: it would complete on
	# tick 121 = F + 1, and is cancelled on that tick instead (the check runs before progress).
	var sim: NightSim = _loaded_at(20.4, {4: 3}, {4: 4})
	_press(sim, HAMMER)
	var began: Array[NightEvent] = sim.advance()
	_check("dw34: the strip began on tick 1", _only(began, NightEvent.Kind.HOLD_STARTED) and _tick_of(began[0]) == 1,
			_names(began))
	_check("dw34: it is set to complete on tick 121", sim.hands.ticks_left == STRIP_PLANK_TICKS)
	var cancelled: Array[NightEvent] = _after_the_fall(sim)
	_check("dw34: HOLD_CANCELLED on F + 1 = 121, section 4 strip_plank", _only(cancelled, NightEvent.Kind.HOLD_CANCELLED)
			and _tick_of(cancelled[0]) == FALL_TICK + 1 and cancelled[0].section == 4 and cancelled[0].id == &"strip_plank",
			_names(cancelled))
	_check("dw34: no plank moved to the hand (5 from the start)", sim.span.in_hand(PLANK) == 5 and not sim.hands.holding())
	# One begun later (tick 30) is cancelled on 121 too.
	sim = _loaded_at(20.4, {4: 3}, {4: 4})
	_advance(sim, 30 - sim.tick)
	_press(sim, HAMMER)
	var started: Array[NightEvent] = sim.advance()
	_check("dw34: a strip begun on tick 30", _only(started, NightEvent.Kind.HOLD_STARTED) and _tick_of(started[0]) == 30,
			_names(started))
	cancelled = _after_the_fall(sim)
	_check("dw34: is cancelled on 121", _only(cancelled, NightEvent.Kind.HOLD_CANCELLED)
			and _tick_of(cancelled[0]) == FALL_TICK + 1, _names(cancelled))
	_check("dw34: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_dw34_a_rail_strip_hold_on_a_falling_section() -> void:
	# At the left rail (x -2.2) on section 5 at along 20.1, aimed back at section 4's left rope (at
	# along 19.6, 1.0 high): a 3 s strip begun on tick 61 would end on 241. The fall on 120 loses the
	# rope; the warden steps back 0.2 m (D2, under 0.5 m); the hold is cancelled on 121.
	var start: StartState = StartState.new()
	start.warden_along = 20.1
	start.planks = {4: 3}
	start.weights = {4: 4}
	var sim: NightSim = _sim_with(_def_with(start), 1)
	for i: int in 60:
		sim.set_move(Vector2(-1.0, 0.0))
		sim.advance()
	sim.set_move(Vector2.ZERO)
	var to: Vector3 = Vector3(-2.5, 1.0, 19.6 - 30.0) - (sim.warden.position + Vector3(0.0, 1.6, 0.0))
	sim.set_view(atan2(-to.x, -to.z), atan2(to.y, Vector2(to.x, to.z).length()))
	sim.advance()
	_check("dw34: aimed at section 4's left rail", sim.look.kind == LookTarget.Kind.RAIL and sim.look.section == 4
			and sim.look.side == LEFT, "%s s%d" % [LookTarget.Kind.find_key(sim.look.kind), sim.look.section])
	_press(sim, ROPE)
	sim.advance()
	_check("dw34: the rail strip is running", sim.hands.holding() and sim.hands.action == NightTypes.HandAction.STRIP_RAIL)
	var cancelled: Array[NightEvent] = _after_the_fall(sim)
	_check("dw34: HOLD_CANCELLED on F + 1, section 4 strip_rail L", _only(cancelled, NightEvent.Kind.HOLD_CANCELLED)
			and _tick_of(cancelled[0]) == FALL_TICK + 1 and cancelled[0].section == 4 and cancelled[0].id == &"strip_rail"
			and cancelled[0].side == LEFT, _names(cancelled))
	_check("dw34: no rope in hand", sim.span.in_hand(NightTypes.Part.ROPE) == 0)
	_check("dw34: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_dw34_a_relay_hold_on_a_falling_section() -> void:
	# Section 4 at 2 planks under 4 weights; on section 5 at along 20.4 with 6 planks in hand, a 3 s
	# re-lay onto it begun on tick 1 would end on 181: cancelled on 121 (hand first, then the fall).
	var sim: NightSim = _loaded_at(20.4, {4: 2}, {4: 4})
	_press(sim, USE)
	sim.advance()
	_check("dw34: the re-lay is running", sim.hands.holding() and sim.hands.action == NightTypes.HandAction.RELAY_PLANK)
	var cancelled: Array[NightEvent] = _after_the_fall(sim)
	_check("dw34: HOLD_CANCELLED on F + 1, section 4 relay_plank", _only(cancelled, NightEvent.Kind.HOLD_CANCELLED)
			and _tick_of(cancelled[0]) == FALL_TICK + 1 and cancelled[0].id == &"relay_plank", _names(cancelled))
	_check("dw34: the 6 planks stay in hand", sim.span.in_hand(PLANK) == 6, str(sim.span.in_hand(PLANK)))


func _test_a_hold_running_when_the_warden_falls() -> void:
	# On section 4 at along 15.5 (it falls under them on 120), stripping section 3's deck (pitch -1.2
	# lands at along 14.878): the hold is not on the fallen section, and is cancelled on 121.
	var sim: NightSim = _loaded_at(15.5, {4: 3}, {4: 4})
	_check("climb: aimed at section 3's deck", sim.look.kind == LookTarget.Kind.DECK and sim.look.section == 3)
	_press(sim, HAMMER)
	sim.advance()
	var at_fall: Array[NightEvent] = _advance(sim, FALL_TICK + 1 - sim.tick)
	_check("climb: caught on 120 with the hold still running", _has(at_fall, NightEvent.Kind.WARDEN_CAUGHT)
			and sim.hands.holding())
	var next: Array[NightEvent] = sim.advance()
	_check("climb: HOLD_CANCELLED on 121, section 3", _only(next, NightEvent.Kind.HOLD_CANCELLED) and next[0].section == 3,
			_names(next))
	_check("climb: section 3 kept its 8 planks", sim.span.planks(3) == 8)
	# Where the fall alone cancels it: on section 4 at along 19.6, 0.4 m from section 5, stripping
	# section 5's deck (yaw pi, pitch -1.2 lands at along 20.222). The catch moves the feet 0.4 m
	# along (to section 5's edge, under the 0.5 m limit) and section 5's deck is still there, so
	# only "the warden is not walking" cancels it. Begun on tick 30, it would complete on 150.
	sim = _loaded_at(19.6, {4: 3}, {4: 4}, PI, DOWN)
	_check("climb: aimed at section 5's deck", sim.look.kind == LookTarget.Kind.DECK and sim.look.section == 5)
	_advance(sim, 30 - sim.tick)
	_press(sim, HAMMER)
	at_fall = _advance(sim, FALL_TICK + 1 - sim.tick)
	_check("climb: caught 0.4 m from where the hold began, the hold still running",
			_has(at_fall, NightEvent.Kind.WARDEN_CAUGHT) and sim.hands.holding()
			and absf(sim.warden.position.z - sim.hands.began_at.z - 0.4) < TOL, str(sim.warden.position))
	next = sim.advance()
	_check("climb: HOLD_CANCELLED on 121, section 5", _only(next, NightEvent.Kind.HOLD_CANCELLED) and next[0].section == 5,
			_names(next))
	var rest: Array[NightEvent] = _advance(sim, 60)
	_check("climb: and no plank of section 5 moves on 150", not _has(rest, NightEvent.Kind.PLANK_STRIPPED)
			and sim.span.planks(5) == 8, _names(rest))


func _test_the_forearm_is_lowered_by_the_fall() -> void:
	# On section 4 at along 17.5, Tab held (Hold mode) when it falls: lowered on 121, with no event.
	var sim: NightSim = _loaded_at(17.5, {4: 3}, {4: 4})
	_press(sim, FOREARM)
	_advance(sim, FALL_TICK + 1 - sim.tick)
	_check("climb: the forearm is still up on the fall's tick", sim.hands.forearm_raised and not WardenRules.walking(sim))
	var next: Array[NightEvent] = sim.advance()
	_check("climb: lowered on 121, with no event", not sim.hands.forearm_raised and next.is_empty(), _names(next))
	# Press once: a Tab press during the climb does not raise it again.
	sim = _loaded_at(17.5, {4: 3}, {4: 4})
	_set_holds(sim, NightTypes.Holds.PRESS_ONCE)
	_press(sim, FOREARM)
	_advance(sim, FALL_TICK + 2 - sim.tick)
	_check("climb: Press once: lowered too", not sim.hands.forearm_raised)
	_press(sim, FOREARM)
	sim.advance()
	_check("climb: Press once: Tab during the climb does not raise it", not sim.hands.forearm_raised)


func _test_buttons_held_through_the_climb() -> void:
	# Code review of 2026-11-22: a button still down when the climb ends has nothing behind it, as
	# after a change of Holds mode (idle hands): nothing starts until a fresh press.
	# Tab (Hold mode), held from before the fall on tick 120 and never let go: lowered on 121; the
	# climb ends on 420 and the forearm stays down.
	var sim: NightSim = _loaded_at(17.5, {4: 3}, {4: 4})
	_press(sim, FOREARM)
	var events: Array[NightEvent] = _advance(sim, FALL_TICK + 300 + 6 - sim.tick)
	_check("held Tab: the climb ended on 420 and nothing else happened since the catch", _names(events)
			== str(["SECTION_FELL", "WARDEN_CAUGHT", "WARDEN_CLIMBED"]) and events[2].section == 5
			and _tick_of(events[2]) == 420 and WardenRules.walking(sim), _names(events))
	_check("held Tab: with Tab still down the forearm stays down after the climb (tick 425)", not sim.hands.forearm_raised)
	_release(sim, FOREARM)
	_press(sim, FOREARM)
	events = sim.advance()
	_check("held Tab: let go and pressed again, it rises, with no event", sim.hands.forearm_raised and events.is_empty(),
			_names(events))
	# The hammer (Hold mode), held on a strip of section 5's deck from section 4 (along 19.6, yaw pi)
	# when section 4 falls: cancelled on 121. Up on section 5 at along 20.3 the same aim is still
	# section 5's deck (lands at along 20.922), and the button is still down: no hold starts.
	sim = _loaded_at(19.6, {4: 3}, {4: 4}, PI, DOWN)
	_press(sim, HAMMER)
	events = _advance(sim, FALL_TICK + 300 + 6 - sim.tick)
	_check("held hammer: cancelled on 121, the climb ended on 420, and no hold began after it",
			_names(events) == str(["HOLD_STARTED", "SECTION_FELL", "WARDEN_CAUGHT", "HOLD_CANCELLED", "WARDEN_CLIMBED"])
			and _tick_of(events[3]) == 121 and _tick_of(events[4]) == 420 and not sim.hands.holding()
			and sim.look.kind == LookTarget.Kind.DECK and sim.look.section == 5, _names(events))
	_release(sim, HAMMER)
	events = sim.advance()
	_check("held hammer: letting go then does nothing", events.is_empty(), _names(events))
	_press(sim, HAMMER)
	events = sim.advance()
	_check("held hammer: a fresh press starts a strip of section 5", _only(events, NightEvent.Kind.HOLD_STARTED)
			and events[0].section == 5, _names(events))
	_check("held: no fault", _faults.total() == 0, str(_faults.codes()))


func _test_presses_during_the_climb_are_ignored() -> void:
	# On section 4 at along 17.5, it falls under them on 120. During the climb (121 to 419) every
	# button, Tab too, is pressed and released while looking toward the town and down (yaw pi, pitch
	# -1.2): from the eye 0.2 m above section 5's deck that is its deck, so a press would start a
	# strip if it were taken. No event, no hold. On 420 the climb ends (along 20.3; the same aim lands
	# at along 20.922, section 5) and a press is taken that tick.
	var sim: NightSim = _loaded_at(17.5, {4: 3}, {4: 4})
	_advance(sim, FALL_TICK + 1 - sim.tick)
	_check("climb: hanging", not WardenRules.walking(sim))
	sim.set_view(PI, DOWN)
	sim.advance()
	_check("climb: from the hang, that aim is section 5's deck", sim.look.kind == LookTarget.Kind.DECK
			and sim.look.section == 5, "%s s%d" % [LookTarget.Kind.find_key(sim.look.kind), sim.look.section])
	var quiet: bool = true
	for input: int in NightTypes.HandInput.size():
		_press(sim, input as NightTypes.HandInput)
		quiet = quiet and sim.advance().is_empty() and not sim.hands.holding() and not sim.hands.forearm_raised
		_release(sim, input as NightTypes.HandInput)
		quiet = quiet and sim.advance().is_empty()
	_check("climb: every press and release during the climb: no event, no hold, no forearm", quiet)
	_advance(sim, FALL_TICK + 300 - sim.tick)
	_press(sim, HAMMER)
	var up: Array[NightEvent] = sim.advance()
	_check("climb: on 420 the climb ends and a press is taken that tick: a strip of section 5",
			_kinds(up) == [NightEvent.Kind.WARDEN_CLIMBED, NightEvent.Kind.HOLD_STARTED] and up[1].section == 5,
			_names(up))
	_check("climb: no fault", _faults.total() == 0, str(_faults.codes()))
