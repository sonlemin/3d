## What just happened in a tick (AD-30): one typed class, a `kind` and a fixed set of fields.
## Unused fields keep their defaults. One event is one row of the playtest log. Each kind's `##`
## comment ends with "Fields: ..." naming the fields it sets; a test checks every emitted event
## against it. Kinds are past tense, upper snake, and name who did it.
class_name NightEvent
extends RefCounted

enum Kind {
	NIGHT_STARTED,  ## The night began: its first tick, step 5 (AD-33). Fields: t, id.
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
## Plain int, -1 for none, until NightTypes.Reason arrives (story 1.4).
var reason: int = -1
var amount: float = 0.0
## A line, hint, name, night or fault code.
var id: StringName = &""


static func make(event_kind: Kind) -> NightEvent:
	var event: NightEvent = NightEvent.new()
	event.kind = event_kind
	return event
