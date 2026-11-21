## The warden's base facts (AD-35, AD-67). Only the sim changes them. The timed moves (edging,
## crossing, the climb back, knockdown) join this in stories 1.5, 1.6 and epic 4.
class_name WardenState
extends RefCounted

## The feet, in world axes (AD-67): y 0 on the deck and the landing. Where it may be is
## WardenRules.can_stand().
var position: Vector3 = Vector3.ZERO
