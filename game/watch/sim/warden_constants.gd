## The warden's rule numbers (AD-9, AD-67). GDD values are starting values; tuning is a commit.
class_name WardenConstants
extends RefCounted

## GD-19: the warden walks at 3.5 metres per second, the same in every direction; no sprint,
## no jump. Converted once into NightSim.walk_step (metres a tick, AD-33).
const WALK_SPEED: float = 3.5
## D2 of story 1.2 (moved from SpanGeometry, DW-29): the eye above the feet, for the camera and
## LookRules (story 1.4).
const EYE_HEIGHT: float = 1.6
## Story 1.3 decision D1: the feet keep this far from every edge of what can be walked on that is
## not shared with another walkable part (rails, the far pier, the landing's limits, a section
## with no planks). Not a GDD value: a gray-box size, tuned by eye in M1.
const CLEARANCE: float = 0.3
