## The night's shared enums (AD-47). `Level`, `DeadKind` and `Cue` arrive with the stories that
## use them; no value is added here before a rule needs it.
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

## Why a press was refused (AD-28: a designed "no" is a REFUSED event, never an error). UX-6's
## "can't" will show it; the playtest log counts it (epic 6).
enum Reason {
	NONE,  ## Not refused: HandRules.check() returns it when the action can start.
	NO_ACTION_HERE,  ## That button does nothing at what is looked at (or at nothing).
	NO_PLANKS_LEFT,  ## A strip of a deck with no plank.
	LAST_SECTION_MINIMUM,  ## GD-19: the town section keeps its last 4 planks.
	DECK_FULL,  ## A re-lay onto a deck that has all its planks.
	NO_PLANK_IN_HAND,  ## A re-lay with no plank carried.
}

## What a hand does (HandRules.action_for()); `NONE` when nothing is running.
enum HandAction { NONE, STRIP_PLANK, STRIP_RAIL, RELAY_PLANK }

## The options that are rules (Data Patterns), set by NightCommand.set_option().
enum Option { HOLDS }

## UX-39: how a hold is held. HOLD: keep the button down. PRESS_ONCE: a press starts it and it
## runs its full time; a second press of the same button stops it; Tab toggles.
enum Holds { HOLD, PRESS_ONCE }
