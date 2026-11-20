## The event trace (AD-29): with `--trace`, every NightEvent prints as one line: time, kind,
## who, where. A consumer of the night screen; debug only, so it may print.
##     godot --path game -- --start=night --trace --seed=7
class_name NightTrace
extends RefCounted


func on_tick(events: Array[NightEvent], _sim: NightSim) -> void:
	for event: NightEvent in events:
		print(line(event))


## One event as `"%7.3f %-17s %s %s"`: time, kind, who, where; trailing spaces trimmed. Pure.
## Who is the event's id while that is its only actor field; the dead and the warden join with
## their stories. Where is the section, `s3`.
static func line(event: NightEvent) -> String:
	var kind_name: String = NightEvent.Kind.find_key(event.kind)
	var who: String = String(event.id)
	var where: String = "s%d" % event.section if event.section > 0 else ""
	return ("%7.3f %-17s %s %s" % [event.t, kind_name, who, where]).strip_edges(false, true)
