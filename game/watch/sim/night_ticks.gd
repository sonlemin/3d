## Time in the night is whole ticks (AD-33): constants are seconds (`_S`), turned into ticks
## once, here. Rules count ticks; nothing adds up float seconds. Each duration joins this file
## with its rule, as one field of the object NightSim builds once (`sim.ticks`, Data Patterns).
class_name NightTicks
extends RefCounted

## AD-33: the sim's clock is the physics tick, 60 per second.
const TICKS_PER_SECOND: int = 60

## GD-19: a plank strip's hold (SpanConstants.STRIP_PLANK_S), in ticks.
var strip_plank: int = 0
## GD-19: a rail strip's hold, in ticks.
var strip_rail: int = 0
## GD-19: a re-lay's hold, in ticks.
var relay_plank: int = 0
## Press once: how long after a hold completes its own button is ignored
## (HandConstants.PRESS_ONCE_GRACE_S), in ticks.
var press_once_grace: int = 0
## GD-19: a groan's length before the section falls (SpanConstants.GROAN_S), in ticks.
var groan: int = 0
## GDD Game Mechanics 2: the climb back after a fall (WardenConstants.CLIMB_BACK_S), in ticks.
var climb_back: int = 0
## GDD Game Mechanics 2: edging round an open section (WardenConstants.EDGE_S), in ticks.
var edge: int = 0
## GDD Game Mechanics 2: crossing a gap hand over hand (WardenConstants.CROSS_GAP_S), in ticks.
var cross_gap: int = 0
## Story 1.6 D1: the push that begins an edging or crossing (WardenConstants.PUSH_TO_CROSS_S): the
## move begins on the tick after this many ticks of pushing in a row.
var push_to_cross: int = 0
## Sonlm's play of M1 of story 1.6: an edging's sidestep onto its beam line
## (WardenConstants.EDGE_SIDESTEP_S), in ticks.
var edge_sidestep: int = 0


func _init() -> void:
	strip_plank = of(SpanConstants.STRIP_PLANK_S)
	strip_rail = of(SpanConstants.STRIP_RAIL_S)
	relay_plank = of(SpanConstants.RELAY_PLANK_S)
	press_once_grace = of(HandConstants.PRESS_ONCE_GRACE_S)
	groan = of(SpanConstants.GROAN_S)
	climb_back = of(WardenConstants.CLIMB_BACK_S)
	edge = of(WardenConstants.EDGE_S)
	cross_gap = of(WardenConstants.CROSS_GAP_S)
	push_to_cross = of(WardenConstants.PUSH_TO_CROSS_S)
	edge_sidestep = of(WardenConstants.EDGE_SIDESTEP_S)


## Whole ticks for a time in seconds, rounded to the nearest tick.
static func of(seconds: float) -> int:
	return roundi(seconds * TICKS_PER_SECOND)
