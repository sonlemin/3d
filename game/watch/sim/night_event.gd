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
	CREAK_STARTED,  ## Step 7: the section's load came to equal its strength, above 0. Fields: t, section.
	CREAK_STOPPED,  ## Step 7: its load no longer equals its strength (or it began to groan). Fields: t, section.
	GROAN_STARTED,  ## Step 7: its load went above its strength; it falls in 2 s unless the load drops. Fields: t, section.
	GROAN_STOPPED,  ## Step 7: its load came back to or under its strength before the fall. Fields: t, section.
	SECTION_FELL,  ## Step 7: 2 s of groan; a gap for the rest of the night (ConsequenceRules settles the rest). Fields: t, section.
	WEIGHT_LIFTED,  ## Step 6: a lift of story 1.5's D1 took one test weight off the section. Fields: t, section.
	WARDEN_CAUGHT,  ## Step 8: the section under the warden fell; they hang from the edge and the climb begins. Fields: t, section.
	WARDEN_CLIMBED,  ## Step 1: the climb ended; `section` is where they stand now, 0 for the landing. Fields: t, section.
	EDGING_STARTED,  ## Step 1 (pushed into, chained, turned back) or 4 or 8 (ConsequenceRules: the last plank underfoot, GD-68; step 4 in epic 1): the warden edges round the open section along the `side` beam. Fields: t, section, side.
	EDGING_ENDED,  ## Step 1: the edging of that section is done; the next section decides what follows. Fields: t, section, side.
	CROSSING_STARTED,  ## Step 1 (pushed into, chained, turned back): the warden crosses the gap of that fallen section hand over hand. Fields: t, section.
	CROSSING_ENDED,  ## Step 1: the crossing of that gap is done; the next section decides what follows. Fields: t, section.
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
