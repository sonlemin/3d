## The warden's base facts (AD-35, AD-67). Only the sim changes them, and only WardenRules the
## timed move. Edging and crossing join the move in story 1.6, knockdown in epic 4.
class_name WardenState
extends RefCounted

## The timed moves of AD-52: WALKING is the warden's own feet; CLIMBING is story 1.5's climb back
## after a fall, during which the move wish and every press are ignored.
enum Move { WALKING, CLIMBING }

## The feet, in world axes (AD-67): y 0 on the deck and the landing (y below 0 while hanging from
## an edge). Where it may be is WardenRules.can_stand().
var position: Vector3 = Vector3.ZERO
var move: Move = Move.WALKING
## Ticks the timed move has left; 0 while walking. It ends on the tick this reaches 0.
var move_ticks_left: int = 0
## The section that fell under the warden, while climbing (where the climb ends is worked out
## from it when it ends); 0 while walking.
var fell_from: int = 0


## For NightSim.checksum(): every base fact, in a fixed order.
func values() -> Array:
	return [position, move, move_ticks_left, fell_from]
