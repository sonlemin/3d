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
