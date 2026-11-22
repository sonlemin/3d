## The span's rule numbers (AD-9, AD-21). GDD values are starting values; tuning is a commit.
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
## GD-19, GDD Game Mechanics 2: a section whose load is above its strength groans for 2 s, then
## falls for good. Counted from the first tick of overload; more load does not restart it (story
## 1.5). The architecture's Data Patterns example names it CREAK_GROAN_S; a creak has no length.
const GROAN_S: float = 2.0
## Story 1.5 (the epic's AC, "each a load of 1"; a Grappler's load, GD-19): one test weight's load.
## Loads are multiples of 0.5 (a hatchling, epic 3), exact in binary, so a load compares with an
## int strength by ==.
const TEST_WEIGHT_LOAD: float = 1.0
## GDD Game Mechanics 2: "The side beams carry a load of 2; more than that for 2 s and the section
## falls" (story 1.6). An open section's strength (no planks, not fallen; decision D4: as the GDD is
## written, so a section at 1 plank is weaker than one with none). An int: it is a strength.
const SIDE_BEAM_LOAD: int = 2
