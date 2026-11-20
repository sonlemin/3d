## Time in the night is whole ticks (AD-33): constants are seconds (`_S`), turned into ticks
## once, here. Rules count ticks; nothing adds up float seconds. Each duration joins this file
## with its rule.
class_name NightTicks
extends RefCounted

## AD-33: the sim's clock is the physics tick, 60 per second.
const TICKS_PER_SECOND: int = 60


## Whole ticks for a time in seconds, rounded to the nearest tick.
static func of(seconds: float) -> int:
	return roundi(seconds * 60.0)
