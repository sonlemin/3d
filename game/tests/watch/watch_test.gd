## Base of every test file that needs a night (AD-27). It has no `_test_` function of its own,
## so the runner accepts it as a base and never runs it. Set a situation up only through a
## `StartState` on the test's own `NightDef`, then drive the sim with commands and ticks;
## never write a sim field from a test.
class_name WatchTest
extends TestCase

## The faults of the last sim made by _sim_with(), for the test to check.
var _faults: WatchFaults


## A test night: `sections` sections of 8 planks (GD-19) with `start` applied.
func _def_with(start: StartState, sections: int = 6) -> NightDef:
	var def: NightDef = NightDef.new()
	def.name = &"test_night"
	def.section_count = sections
	def.planks_per_section = 8
	def.start = start
	return def


## A sim of `def` with a fresh WatchFaults, kept in `_faults`.
func _sim_with(def: NightDef, seed: int) -> NightSim:
	_faults = WatchFaults.new()
	return NightSim.new(def, seed, _faults)


## Every event of the next `ticks` ticks, in order.
func _advance(sim: NightSim, ticks: int) -> Array[NightEvent]:
	var all: Array[NightEvent] = []
	for i: int in ticks:
		all.append_array(sim.advance())
	return all


func _has(events: Array[NightEvent], kind: NightEvent.Kind) -> bool:
	for event: NightEvent in events:
		if event.kind == kind:
			return true
	return false


func _kinds(events: Array[NightEvent]) -> Array[NightEvent.Kind]:
	var kinds: Array[NightEvent.Kind] = []
	for event: NightEvent in events:
		kinds.append(event.kind)
	return kinds
