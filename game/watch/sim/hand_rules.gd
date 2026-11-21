## What a button does at what is looked at, and whether it can start (AD-15, AD-47). Pure:
## HoldRules reports. check() is the one test of "can this action start on this target now";
## HoldRules asks it at the press and again every tick of a hold (AD-67).
class_name HandRules
extends RefCounted


## Pure: the action `input` means at `target`; NONE when it means nothing there.
static func action_for(input: NightTypes.HandInput, target: LookTarget) -> NightTypes.HandAction:
	if target.kind == LookTarget.Kind.DECK:
		if input == NightTypes.HandInput.HAMMER:
			return NightTypes.HandAction.STRIP_PLANK
		if input == NightTypes.HandInput.USE:
			return NightTypes.HandAction.RELAY_PLANK
	elif target.kind == LookTarget.Kind.RAIL and input == NightTypes.HandInput.ROPE:
		return NightTypes.HandAction.STRIP_RAIL
	return NightTypes.HandAction.NONE


## Pure: NONE when `action` can be started on `target` now, otherwise why not. A re-lay reads the
## hand before the deck (Sonlm, 2026-11-21, story 1.4): an empty hand is NO_PLANK_IN_HAND even at
## a full deck. With nothing lost, an empty hand means every deck is full, so deck first would make
## NO_PLANK_IN_HAND impossible. A fallen section takes no re-lay (story 1.5): NO_ACTION_HERE, as
## at nothing (a strip there is NO_PLANKS_LEFT already, a rail strip NO_ACTION_HERE).
static func check(action: NightTypes.HandAction, target: LookTarget, def: NightDef,
		span: SpanState) -> NightTypes.Reason:
	match action:
		NightTypes.HandAction.STRIP_PLANK:
			var planks: int = span.planks(target.section)
			if planks <= 0:
				return NightTypes.Reason.NO_PLANKS_LEFT
			if target.section == def.section_count and planks <= SpanConstants.LAST_SECTION_MIN_PLANKS:
				return NightTypes.Reason.LAST_SECTION_MINIMUM
			return NightTypes.Reason.NONE
		NightTypes.HandAction.STRIP_RAIL:
			# A target is only ever a standing rail; this is for a hold whose rail went.
			if not span.rail_standing(target.section, target.side):
				return NightTypes.Reason.NO_ACTION_HERE
			return NightTypes.Reason.NONE
		NightTypes.HandAction.RELAY_PLANK:
			if span.in_hand(NightTypes.Part.PLANK) <= 0:
				return NightTypes.Reason.NO_PLANK_IN_HAND
			# Story 1.5: a target is never a fallen deck; this is for a hold whose section fell.
			if span.fallen(target.section):
				return NightTypes.Reason.NO_ACTION_HERE
			if span.planks(target.section) >= def.planks_per_section:
				return NightTypes.Reason.DECK_FULL
			return NightTypes.Reason.NONE
	return NightTypes.Reason.NO_ACTION_HERE


## Pure: the hold length of `action` in ticks (sim.ticks); 0 for NONE.
static func ticks_of(action: NightTypes.HandAction, ticks: NightTicks) -> int:
	match action:
		NightTypes.HandAction.STRIP_PLANK:
			return ticks.strip_plank
		NightTypes.HandAction.STRIP_RAIL:
			return ticks.strip_rail
		NightTypes.HandAction.RELAY_PLANK:
			return ticks.relay_plank
	return 0


## The action's name for an event's `id` and the trace: `strip_plank`, `strip_rail`,
## `relay_plank`; empty for NONE.
static func id_of(action: NightTypes.HandAction) -> StringName:
	match action:
		NightTypes.HandAction.STRIP_PLANK:
			return &"strip_plank"
		NightTypes.HandAction.STRIP_RAIL:
			return &"strip_rail"
		NightTypes.HandAction.RELAY_PLANK:
			return &"relay_plank"
	return &""
