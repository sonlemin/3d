## The night's shared enums (AD-47). `Reason`, `Level`, `DeadKind` and `Cue` arrive with the
## stories that use them; no value is added here before a rule needs it.
class_name NightTypes
extends RefCounted

## The warden's left and right when facing the far pier; LEFT is -X (architecture, "The span's
## numbers"), in planning too.
enum Side { LEFT, RIGHT }

## What the parts ledger counts (Novel Pattern 1).
enum Part { PLANK, ROPE }

## The warden's buttons, as NightCommand sends them (AD-47). What a button does here is the
## sim's decision, never the node's.
enum HandInput { HAMMER, ROPE, USE, SHUTTER, BUILD_TRAPDOOR, BUILD_BEAM, DISMANTLE, FOREARM }
