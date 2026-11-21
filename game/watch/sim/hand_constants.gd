## The warden's hands' rule numbers (AD-9, AD-50). GDD values are starting values; tuning is a
## commit. Hold lengths are the span's (SpanConstants), as GD-19 gives them with the span.
class_name HandConstants
extends RefCounted

## GDD Controls: the warden acts on what is looked at "within 2 m", measured along the view
## line from the eye (LookRules).
const REACH: float = 2.0
## GDD Controls: a hold is cancelled by "moving more than 0.5 m" from where it began (the feet,
## across the ground: x and z only).
const HOLD_MOVE_LIMIT: float = 0.5
## Story 1.4, code review (Sonlm, 2026-11-21): in Press once (UX-39), a press of the button whose
## hold has just completed is ignored for this long, in seconds. The press meant to stop a hold
## can land just after it finished; without this it would start a new hold that runs its full
## time with no one behind it.
const PRESS_ONCE_GRACE_S: float = 0.25
