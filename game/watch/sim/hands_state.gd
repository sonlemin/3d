## The warden's hands' base facts (Novel Pattern 3, AD-35). Only HoldRules changes them. A hold
## is running while `action` is not NONE (worked out, never stored twice). A pose per hand joins
## this in epic 4 story 1.
class_name HandsState
extends RefCounted

## The hold in progress; NONE when the hands are idle.
var action: NightTypes.HandAction = NightTypes.HandAction.NONE
## The button that began it: Hold mode cancels on its release, Press once on its second press.
var input: NightTypes.HandInput = NightTypes.HandInput.HAMMER
## A copy of what was looked at when it began: HoldRules re-checks this target every tick,
## never what is looked at now (looking around never cancels a hold).
var target: LookTarget = LookTarget.none()
## The feet when it began: moving more than HandConstants.HOLD_MOVE_LIMIT from here cancels it.
var began_at: Vector3 = Vector3.ZERO
## The tick it began on: it gets no progress on that tick (AD-33: begun on T, done on T + N).
var began_tick: int = 0
## Ticks still to run, counted down from ticks_total; it completes on the tick this reaches 0.
var ticks_left: int = 0
var ticks_total: int = 0
## UX-11: Tab raised to read the tallies. While up, neither hand can start an action.
var forearm_raised: bool = false


func holding() -> bool:
	return action != NightTypes.HandAction.NONE


## For NightSim.checksum(): every base fact, in a fixed order.
func values() -> Array:
	return [action, input, target.values(), began_at, began_tick, ticks_left, ticks_total, forearm_raised]
