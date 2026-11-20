## How a night's span differs from full at the start (AD-9): the only way a test or a show-me
## setup sets a situation up. Parts it takes off the span start in the warden's hand, so the
## ledger's totals always equal the def's (and a re-lay in story 1.4 has parts to use).
## Test weights arrive in story 1.5.
class_name StartState
extends RefCounted

## Section -> planks left on its deck. A section with no key is full.
var planks: Dictionary[int, int] = {}
## Rails whose rope starts in hand, each `Vector2i(section, NightTypes.Side)`.
var stripped_rails: Array[Vector2i] = []
