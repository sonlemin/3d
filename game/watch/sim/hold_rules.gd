## Holds (AD-50, UX-39): the one owner of a hold. It takes each button command, starts a hold or
## refuses it, and every tick checks, advances and completes the running one. It alone cancels a
## hold that became impossible (AD-67), by asking HandRules.check() about the hold's own target.
## Parts move only through SpanRules.move_parts() (the parts ledger).
##
## Hold mode: a release of the hold's button cancels it. Press once (UX-39): a press starts it and
## it runs its full time; a second press of the same button stops it; releases do nothing; Tab
## toggles the forearm. The mode in force when a command is taken decides what that command does.
## A change of mode cancels the running hold and lowers the forearm, so a mode always starts from
## idle hands (story 1.4 code review, Sonlm, 2026-11-21): otherwise a hold or a raised forearm
## would be left with no button behind it. In Press once, a press of the button whose hold has
## just completed is ignored for a short grace (HandConstants.PRESS_ONCE_GRACE_S).
## While the warden is not walking (story 1.5's climb back, a timed move of WardenRules), every
## press is ignored with no event, and tick() cancels a running hold and lowers the forearm.
class_name HoldRules
extends RefCounted

## Float slack for "more than 0.5 m", in metres: the feet are summed from float steps, so a walk
## of exactly HOLD_MOVE_LIMIT may land a rounding error past it. Not a rule number; far below a
## tick's step (3.5 / 60 m).
const MOVE_SLACK: float = 0.0001


## Step 1 of the tick (AD-34): one queued command, in arrival order, after the look target.
## A press while a hold runs, while the forearm is up, or (Press once) of the button whose hold
## has just completed, is ignored: no event (AD-50, UX-11).
static func take(command: NightCommand, sim: NightSim) -> void:
	match command.kind:
		NightCommand.Kind.SET_OPTION:
			_set_option(command, sim)
		NightCommand.Kind.PRESS:
			if command.input == NightTypes.HandInput.FOREARM:
				_press_forearm(sim)
			else:
				_press_hand(command.input, sim)
		NightCommand.Kind.RELEASE:
			_release(command.input, sim)


## Step 2 of the tick (AD-34), in its order: the warden not walking (a climb: the hold is
## cancelled and the forearm lowered), then still possible? then progress, then completion.
## A hold begun on tick T gets its first progress on T + 1 and completes on T + N (AD-33). A hold
## whose target fell on tick F (step 7) is cancelled here on F + 1, before its progress, so also
## when it would have completed on F + 1 (story 1.5, DW-34).
static func tick(sim: NightSim) -> void:
	var hands: HandsState = sim.hands
	if not WardenRules.walking(sim):
		if hands.holding():
			_cancel(sim)
		hands.forearm_raised = false
		return
	if not hands.holding():
		return
	var moved: Vector2 = Vector2(sim.warden.position.x - hands.began_at.x, sim.warden.position.z - hands.began_at.z)
	if moved.length() > HandConstants.HOLD_MOVE_LIMIT + MOVE_SLACK \
			or HandRules.check(hands.action, hands.target, sim.def, sim.span) != NightTypes.Reason.NONE:
		_cancel(sim)
		return
	if sim.tick == hands.began_tick:
		return
	hands.ticks_left -= 1
	if hands.ticks_left <= 0:
		_complete(sim)


## Pure: how far along the running hold is, 0 to 1 (for epic 4's hands); 0 when idle.
static func progress(hands: HandsState) -> float:
	if not hands.holding() or hands.ticks_total <= 0:
		return 0.0
	return clampf(1.0 - float(hands.ticks_left) / hands.ticks_total, 0.0, 1.0)


static func _set_option(command: NightCommand, sim: NightSim) -> void:
	if command.option == NightTypes.Option.HOLDS and NightTypes.Holds.values().has(command.value):
		if command.value == sim.holds:
			return
		if sim.hands.holding():
			_cancel(sim)
		sim.hands.forearm_raised = false
		sim.hands.done_tick = -1
		sim.holds = command.value as NightTypes.Holds
		return
	sim.faults.report(&"sim.bad_input", "set_option(%d, %d)" % [command.option, command.value])


## UX-11: Tab raises the forearm (Hold) or toggles it (Press once); ignored during a hold, and
## while the warden is not walking (story 1.5).
static func _press_forearm(sim: NightSim) -> void:
	if not WardenRules.walking(sim) or sim.hands.holding():
		return
	if sim.holds == NightTypes.Holds.PRESS_ONCE:
		sim.hands.forearm_raised = not sim.hands.forearm_raised
	else:
		sim.hands.forearm_raised = true


## Ignored while the warden is not walking (story 1.5) and with the forearm up; a press during a
## hold only stops it (Press once, its own button); the Press once grace; then HandRules decides.
static func _press_hand(input: NightTypes.HandInput, sim: NightSim) -> void:
	var hands: HandsState = sim.hands
	if not WardenRules.walking(sim) or hands.forearm_raised:
		return
	if hands.holding():
		if sim.holds == NightTypes.Holds.PRESS_ONCE and input == hands.input:
			_cancel(sim)
		return
	if sim.holds == NightTypes.Holds.PRESS_ONCE and hands.done_tick >= 0 and input == hands.done_input \
			and sim.tick - hands.done_tick <= sim.ticks.press_once_grace:
		return
	var action: NightTypes.HandAction = HandRules.action_for(input, sim.look)
	var reason: NightTypes.Reason = HandRules.check(action, sim.look, sim.def, sim.span)
	if reason != NightTypes.Reason.NONE:
		sim.refuse(reason, sim.look, action)
		return
	hands.action = action
	hands.input = input
	hands.target = sim.look.copy()
	hands.began_at = sim.warden.position
	hands.began_tick = sim.tick
	hands.ticks_total = HandRules.ticks_of(action, sim.ticks)
	hands.ticks_left = hands.ticks_total
	sim.emit(_hand_event(NightEvent.Kind.HOLD_STARTED, hands))


## Hold mode only: Tab's release lowers the forearm; the hold's own button's release cancels it.
static func _release(input: NightTypes.HandInput, sim: NightSim) -> void:
	if sim.holds != NightTypes.Holds.HOLD:
		return
	if input == NightTypes.HandInput.FOREARM:
		sim.hands.forearm_raised = false
	elif sim.hands.holding() and input == sim.hands.input:
		_cancel(sim)


static func _cancel(sim: NightSim) -> void:
	sim.emit(_hand_event(NightEvent.Kind.HOLD_CANCELLED, sim.hands))
	_clear(sim.hands)


static func _complete(sim: NightSim) -> void:
	var hands: HandsState = sim.hands
	var n: int = hands.target.section
	var done: NightEvent
	match hands.action:
		NightTypes.HandAction.STRIP_PLANK:
			SpanRules.move_parts(NightTypes.Part.PLANK, 1, PartPlace.deck(n), PartPlace.hand(), sim)
			done = NightEvent.make(NightEvent.Kind.PLANK_STRIPPED)
		NightTypes.HandAction.STRIP_RAIL:
			SpanRules.move_parts(NightTypes.Part.ROPE, 1, PartPlace.rail(n, hands.target.side), PartPlace.hand(), sim)
			done = NightEvent.make(NightEvent.Kind.RAIL_STRIPPED)
			done.side = hands.target.side
		NightTypes.HandAction.RELAY_PLANK:
			SpanRules.move_parts(NightTypes.Part.PLANK, 1, PartPlace.hand(), PartPlace.deck(n), sim)
			done = NightEvent.make(NightEvent.Kind.PLANK_RELAID)
	done.section = n
	hands.done_input = hands.input
	hands.done_tick = sim.tick
	_clear(hands)
	sim.emit(done)


## HOLD_STARTED or HOLD_CANCELLED for the running hold: its section, its action as `id`, and the
## side for a rail.
static func _hand_event(kind: NightEvent.Kind, hands: HandsState) -> NightEvent:
	var event: NightEvent = NightEvent.make(kind)
	event.section = hands.target.section
	event.id = HandRules.id_of(hands.action)
	if hands.action == NightTypes.HandAction.STRIP_RAIL:
		event.side = hands.target.side
	return event


static func _clear(hands: HandsState) -> void:
	hands.action = NightTypes.HandAction.NONE
	hands.input = NightTypes.HandInput.HAMMER
	hands.target = LookTarget.none()
	hands.began_at = Vector3.ZERO
	hands.began_tick = 0
	hands.ticks_left = 0
	hands.ticks_total = 0
