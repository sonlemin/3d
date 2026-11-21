## The event trace (AD-29): with `--trace`, every NightEvent prints as one line: time, kind,
## who, where. A consumer of the night screen; debug only, so it may print.
##     godot --path game -- --start=night --trace --seed=7
class_name NightTrace
extends RefCounted

## The kinds the warden's hands emit (story 1.4): their "who" is `warden`.
const WARDEN_KINDS: Array[NightEvent.Kind] = [
	NightEvent.Kind.HOLD_STARTED, NightEvent.Kind.HOLD_CANCELLED, NightEvent.Kind.PLANK_STRIPPED,
	NightEvent.Kind.RAIL_STRIPPED, NightEvent.Kind.PLANK_RELAID, NightEvent.Kind.REFUSED,
]


func on_tick(events: Array[NightEvent], _sim: NightSim) -> void:
	for event: NightEvent in events:
		print(line(event))


## One event as `"%7.3f %-17s "` (time, kind) then who, where and, on REFUSED, the reason, each
## separated by a space; trailing spaces trimmed. Pure.
## Who: `warden` for the hands' kinds, followed by the event's id (the action) where it has one;
## the event's id otherwise (the dead join with their stories). Where: `s3`, plus ` L` or ` R`
## when the event carries a side (a rail action: RAIL_STRIPPED, or a hand event whose id is
## `strip_rail`). NIGHT_STARTED's line is kept exactly: `one_night seed=7` (AD-3), so any traced
## night can be run again with `--seed`; tools/ci.sh greps it.
static func line(event: NightEvent) -> String:
	var kind_name: String = NightEvent.Kind.find_key(event.kind)
	var parts: PackedStringArray = []
	if WARDEN_KINDS.has(event.kind):
		parts.append("warden")
		if event.id != &"":
			parts.append(String(event.id))
	elif event.kind == NightEvent.Kind.NIGHT_STARTED:
		parts.append("%s seed=%d" % [event.id, event.seed])
	elif event.id != &"":
		parts.append(String(event.id))
	if event.section > 0:
		var where: String = "s%d" % event.section
		if event.kind == NightEvent.Kind.RAIL_STRIPPED or event.id == &"strip_rail":
			where += " L" if event.side == NightTypes.Side.LEFT else " R"
		parts.append(where)
	if event.kind == NightEvent.Kind.REFUSED:
		parts.append(NightTypes.Reason.find_key(event.reason))
	return ("%7.3f %-17s %s" % [event.t, kind_name, " ".join(parts)]).strip_edges(false, true)
