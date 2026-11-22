## How a night's span differs from full at the start (AD-9): the only way a test or a show-me
## setup sets a situation up. Parts it takes off the span start in the warden's hand, so the
## ledger's totals always equal the def's (and a re-lay in story 1.4 has parts to use).
class_name StartState
extends RefCounted

## Section -> planks left on its deck. A section with no key is full.
var planks: Dictionary[int, int] = {}
## Rails whose rope starts in hand, each `Vector2i(section, NightTypes.Side)`.
var stripped_rails: Array[Vector2i] = []
## Story 1.3 decision D3: where the warden starts, in metres from the far pier along the centre
## line. -1.0 means the landing's centre (SpanGeometry.warden_start()). A start that cannot be
## stood on is `warden.bad_start`, and the warden starts on the landing.
var warden_along: float = -1.0
## Story 1.5: section -> test weights standing on it, each a load of SpanConstants.TEST_WEIGHT_LOAD.
## They stand in for the dead until epic 3; only a StartState places them.
var weights: Dictionary[int, int] = {}
## Story 1.5 decision D1: one weight leaves a section on a set tick, each `Vector2i(section, tick)`
## (step 6, WEIGHT_LIFTED). It stands in for one of the dead walking off a section (epic 3), so a
## groan that holds can be reached through ticks.
var lifts: Array[Vector2i] = []
## Story 1.6 (AC 11): sections that start as gaps. Their planks and ropes go to lost through the
## ledger (what `planks` and `stripped_rails` take off first is in hand), so the def's totals still
## hold. A section outside 1 to n is `span.bad_start` and skipped; a repeat is ignored. Weights or
## lifts on a section that starts fallen are `span.bad_start` and skipped.
var fallen: Array[int] = []
