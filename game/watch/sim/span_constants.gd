## The span's rule numbers (AD-9, AD-21). GDD values are starting values; tuning is a commit.
## Load times arrive with their rule (story 1.5).
class_name SpanConstants
extends RefCounted

## GD-19: every section is 5 m long, along the span.
const SECTION_LENGTH: float = 5.0
## GD-19: every section is 5 m wide, across the span.
const SECTION_WIDTH: float = 5.0
## GD-19: stripping a plank is a 2 s hold of the hammer hand. Converted once into
## NightSim.ticks (AD-33).
const STRIP_PLANK_S: float = 2.0
## GD-19: stripping a rail rope is a 3 s hold of the rope hand.
const STRIP_RAIL_S: float = 3.0
## GD-19: re-laying a plank is a 3 s hold of E (UX-36).
const RELAY_PLANK_S: float = 3.0
## GD-19: the town section (section 6, the def's last) keeps at least 4 planks; a strip that
## would take it below is refused (LAST_SECTION_MINIMUM). Its rail ropes can still be stripped.
const LAST_SECTION_MIN_PLANKS: int = 4
