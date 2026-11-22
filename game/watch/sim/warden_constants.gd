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
## GDD Game Mechanics 2: a warden whose section falls catches the edge and climbs back onto the
## nearest section toward the town that has planks and has not fallen (or the landing) in 5 s. A
## timed move (AD-52).
const CLIMB_BACK_S: float = 5.0
## Story 1.5 decision D3: while climbing back, the feet hang this far below the deck top of what
## is being climbed onto, so the eye (EYE_HEIGHT above them) is 0.2 m above that deck. Not a GDD
## value: a gray-box size, tuned in M2 of story 1.5.
const HANG_DROP: float = 1.4
## GDD Game Mechanics 2: "Crossing it along its side beams takes ... the warden 4 s": edging round
## an open section, whichever way and from wherever it begins (story 1.6). A timed move (AD-52). A
## warden whose last plank goes underfoot takes the share of it that the distance left is of the
## section's length (GD-68).
const EDGE_S: float = 4.0
## GDD Game Mechanics 2: "The warden crosses hand over hand in 8 s": a fallen section, a gap. A timed
## move (AD-52), one per gap.
const CROSS_GAP_S: float = 8.0
## Story 1.6 decision D1: an edging or crossing begins once the move wish has pushed straight into
## the open section or gap, at the stop, for this long in a row (within 45 degrees of straight in).
## Not a GDD value: a feel size, tuned in M1 of story 1.6.
const PUSH_TO_CROSS_S: float = 0.5
## Sonlm's play of M1 of story 1.6 (2026-11-22; replaces D2's drift over the whole edging): an
## edging sidesteps onto its side beam's line in this long (or the whole edging, if shorter), then
## goes straight along it; the along part moves steadily over the whole edging. Not a GDD value.
const EDGE_SIDESTEP_S: float = 0.5
## Sonlm's play of M1 of story 1.6 (2026-11-22): a crossing goes hand over hand in reaches of this
## many metres (10 over a 5 m gap), each in an equal share of its time. Not a GDD value: a feel size.
const CROSS_REACH: float = 0.5
## Sonlm's play of M1 of story 1.6: the share of each reach's time spent pulling (eased in and out);
## the rest is still, hanging, before the next reach. Forward only: no up-down bob (EXPERIENCE.md).
const CROSS_PULL_SHARE: float = 0.6
