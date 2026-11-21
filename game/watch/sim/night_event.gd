## What just happened in a tick (AD-30): one typed class, a `kind` and a fixed set of fields.
## Unused fields keep their defaults. One event is one row of the playtest log. Each kind's `##`
## comment ends with "Fields: ..." naming the fields it sets; a test checks every emitted event
## against it. Kinds are past tense, upper snake, and name who did it.
class_name NightEvent
extends RefCounted

enum Kind {
	NIGHT_STARTED,  ## The night began: its first tick, step 5 (AD-33); `id` is the def's name. Fields: t, id, seed.
	HOLD_STARTED,  ## The warden began a hold (step 1); `id` the action, `side` set for a rail. Fields: t, section, side, id.
	HOLD_CANCELLED,  ## Let go, pressed again (Press once), moved over 0.5 m, or impossible on its target. Fields: t, section, side, id.
	PLANK_STRIPPED,  ## A strip completed (step 2): one plank from that deck to the hand. Fields: t, section.
	RAIL_STRIPPED,  ## A rail strip completed: that rail's rope to the hand. Fields: t, section, side.
	PLANK_RELAID,  ## A re-lay completed: one plank from the hand to that deck. Fields: t, section.
	REFUSED,  ## A designed "no" (AD-28), from sim.refuse(); NO_ACTION_HERE leaves section 0 and id empty. Fields: t, reason, section, side, id.
}

var kind: Kind = Kind.NIGHT_STARTED
## Seconds since the night began: the tick / 60. Set by NightSim.emit().
var t: float = 0.0
## 1 to n; 0 for none.
var section: int = 0
var side: NightTypes.Side = NightTypes.Side.LEFT
## Metres from the far pier.
var along: float = 0.0
## A cry's level. Plain int, -1 for none, until NightTypes.Level arrives (epic 2).
var level: int = -1
## 0 for none.
var dead_id: int = 0
## Plain int, -1 for none, until NightTypes.DeadKind arrives (epic 3).
var dead_kind: int = -1
## A cry slot, 1 to 4; 0 for none.
var slot: int = 0
## A sound id of content/sound_cues.gd (AD-45).
var sound: StringName = &""
## Why a press was refused, on REFUSED; NONE on every other kind.
var reason: NightTypes.Reason = NightTypes.Reason.NONE
var amount: float = 0.0
## A line, hint, name, night or fault code.
var id: StringName = &""
## The night's seed (AD-3: the seed is logged), on NIGHT_STARTED; 0 on every other kind.
var seed: int = 0


static func make(event_kind: Kind) -> NightEvent:
	var event: NightEvent = NightEvent.new()
	event.kind = event_kind
	return event
