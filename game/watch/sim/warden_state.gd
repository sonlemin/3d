## The warden's base facts (AD-35, AD-67). Only the sim changes them, and only WardenRules the
## timed move. Knockdown joins the move in epic 4.
class_name WardenState
extends RefCounted

## The timed moves of AD-52: WALKING is the warden's own feet; CLIMBING is story 1.5's climb back
## after a fall; EDGING (round an open section along its side beam) and CROSSING (a gap, hand over
## hand) are story 1.6's. While any but WALKING runs, the move wish and every press are ignored.
enum Move { WALKING, CLIMBING, EDGING, CROSSING }

## The feet, in world axes (AD-67): y 0 on the deck, the landing and a side beam's line (y below 0
## while hanging from an edge or crossing a gap). Where it may be while walking is
## WardenRules.can_stand().
var position: Vector3 = Vector3.ZERO
var move: Move = Move.WALKING
## Ticks the timed move has left; 0 while walking. It ends on the tick this reaches 0.
var move_ticks_left: int = 0
## The section that fell under the warden, while climbing (where the climb ends is worked out
## from it when it ends); 0 otherwise.
var fell_from: int = 0
## Story 1.6, while edging or crossing: the section being edged or crossed; 0 otherwise.
var move_section: int = 0
## Story 1.6, while edging or crossing: +1 toward the town, -1 toward the far pier; 0 otherwise.
var move_toward: int = 0
## Story 1.6, while edging or crossing: where the feet were on the move's first tick and where they
## are on its last (decision D2); the feet in between are worked out from the ticks left.
var move_from: Vector3 = Vector3.ZERO
var move_to: Vector3 = Vector3.ZERO
## Story 1.6, while edging or crossing: the move's whole length in ticks; 0 otherwise.
var move_ticks_total: int = 0
## Story 1.6 decision D1, while walking: the ticks in a row the move wish has pushed straight into
## the open section or gap ahead, at the stop. The move begins on the tick this passes
## sim.ticks.push_to_cross.
var pushed: int = 0


## For NightSim.checksum(): every base fact, in a fixed order.
func values() -> Array:
	return [position, move, move_ticks_left, fell_from, move_section, move_toward, move_from, move_to,
			move_ticks_total, pushed]
