## Pure logic of the ear test: the 12 direction x level combinations, trial order,
## the source position of each combination, scoring, and CSV rows.
## No nodes and no file I/O, so res://tests/run_tests.gd covers it headless.
##
## Every tunable value of the test lives here as a constant: source positions, bus FX,
## emitter settings, timings, trial counts and the pass mark. Tune by ear, here only.
extends RefCounted

# ------------------------------------------------------------------ directions & levels

## Answer-grid column order. Left/right are as seen facing the far bank.
const DIRECTIONS: Array[String] = ["town", "left_rail", "right_rail", "far_bank"]
## Answer-grid row order.
const LEVELS: Array[String] = ["above", "inside", "below"]

const DIRECTION_LABELS: Dictionary = {
	"town": "Town",
	"left_rail": "Left rail",
	"right_rail": "Right rail",
	"far_bank": "Far bank",
}
const LEVEL_LABELS: Dictionary = {
	"above": "Above",
	"inside": "Inside",
	"below": "Below",
}

## World axes. Godot's forward is -Z, so a listener with zero rotation faces the far bank.
const DIRECTION_VECTORS: Dictionary = {
	"town": Vector3(0.0, 0.0, 1.0),
	"far_bank": Vector3(0.0, 0.0, -1.0),
	"left_rail": Vector3(-1.0, 0.0, 0.0),
	"right_rail": Vector3(1.0, 0.0, 0.0),
}

# ------------------------------------------------------------------ source positions (m)
# The deck top is y = 0; the listener stands at the origin, mid-span.

const EAR_HEIGHT: float = 1.6
## Horizontal distance from the listener along the direction, unless noted below.
const SOURCE_DISTANCE: float = 6.0
const ABOVE_Y: float = 5.0
## In the abyss under the span.
const BELOW_Y: float = -6.0
## Inside, left/right rail: in the parapet, at ear height.
const INSIDE_RAIL_DISTANCE: float = 2.0
const INSIDE_RAIL_Y: float = EAR_HEIGHT
## Inside, town/far bank: in the deck slab.
const INSIDE_DECK_Y: float = -0.5

# ------------------------------------------------------------------ audio buses & emitter

const LEVEL_BUSES: Dictionary = {
	"above": &"Above",
	"inside": &"Inside",
	"below": &"Below",
}
## Applied over res://default_bus_layout.tres at startup (ear_test.gd), so these win.
## filter: "high_pass" or "low_pass".
const BUS_FX: Dictionary = {
	"above": {"filter": "high_pass", "cutoff_hz": 400.0, "room_size": 0.4, "damping": 0.1, "wet": 0.2},
	"inside": {"filter": "low_pass", "cutoff_hz": 900.0, "room_size": 0.15, "damping": 0.8, "wet": 0.35},
	"below": {"filter": "low_pass", "cutoff_hz": 2500.0, "room_size": 0.9, "damping": 0.3, "wet": 0.45},
}
## 0 dB: distance filtering must not blur the level filters.
const EMITTER_ATTENUATION_FILTER_DB: float = 0.0
const EMITTER_UNIT_SIZE: float = 10.0
const EMITTER_MAX_DB: float = 3.0
# Stereo panning strength is the project setting audio/general/3d_panning_strength (1.0).

# ------------------------------------------------------------------ timings (s)

const SILENCE_BEFORE_CRY_S: float = 1.0
## The cry loops if the clip is shorter, and is cut if longer.
const CRY_WINDOW_S: float = 4.0
const PRACTICE_FEEDBACK_S: float = 2.0

# ------------------------------------------------------------------ session & scoring

const ROUND_PRACTICE: String = "practice"
const ROUND_SCORED: String = "scored"
const PRACTICE_REPEATS: int = 1
const SCORED_REPEATS: int = 2
## Shuffles tried before build_scored_order falls back to blocks (about 1 in 3 qualifies).
const MAX_ORDER_ATTEMPTS: int = 200
## Pass = both direction and level right on at least this % of scored trials.
const PASS_PERCENT: int = 80

const CSV_COLUMNS: Array[String] = [
	"tester_id", "output_mode", "round", "trial_index",
	"true_direction", "true_level", "answer_direction", "answer_level",
	"direction_correct", "level_correct", "both_correct", "response_ms", "clip",
]


# ------------------------------------------------------------------ combinations & order

static func make_combo(direction: String, level: String) -> Dictionary:
	return {"direction": direction, "level": level}


## All 12 combinations, level-major, in answer-grid order.
static func all_combinations() -> Array:
	var combos: Array = []
	for level: String in LEVELS:
		for direction: String in DIRECTIONS:
			combos.append(make_combo(direction, level))
	return combos


static func combo_label(combo: Dictionary) -> String:
	return "%s · %s" % [LEVEL_LABELS[combo["level"]], DIRECTION_LABELS[combo["direction"]]]


## Fisher-Yates shuffle driven by `rng`. Returns a new array; `items` is not modified.
## (Array.shuffle() uses the global RNG, so it can't be reproduced from a seed.)
static func shuffled(items: Array, rng: RandomNumberGenerator) -> Array:
	var out: Array = items.duplicate()
	for i: int in range(out.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var held: Variant = out[i]
		out[i] = out[j]
		out[j] = held
	return out


## Practice round: each combination once, shuffled.
static func build_practice_order(rng: RandomNumberGenerator) -> Array:
	var order: Array = []
	for _repeat: int in PRACTICE_REPEATS:
		order.append_array(all_combinations())
	return shuffled(order, rng)


## Returns the scored trial order: every entry of `combos` appears exactly `repeats` times,
## no combination appears twice in a row, and different rng seeds give different orders.
##
## Rejection sampling: shuffle the whole pool and keep the first order with no back-to-back
## repeat. That is uniform over all valid orders, so testers can't learn a pattern.
## If every attempt fails (vanishingly rare), fall back to one shuffled block per repeat:
## each block holds every combination once, so only the seam between blocks can repeat.
static func build_scored_order(combos: Array, repeats: int, rng: RandomNumberGenerator) -> Array:
	var pool: Array = []
	for _repeat: int in repeats:
		pool.append_array(combos)
	if combos.size() < 2:
		return pool  # Fewer than two combinations: there is nothing to keep apart.

	for _attempt: int in MAX_ORDER_ATTEMPTS:
		var candidate: Array = shuffled(pool, rng)
		if not has_back_to_back(candidate):
			return candidate

	var order: Array = []
	for _repeat: int in repeats:
		var block: Array = shuffled(combos, rng)
		if not order.is_empty() and block[0] == order.back():
			var held: Variant = block[0]
			block[0] = block[1]
			block[1] = held
		order.append_array(block)
	return order


## True if any combination appears twice in a row. Dictionaries compare by value.
static func has_back_to_back(order: Array) -> bool:
	for i: int in range(1, order.size()):
		if order[i] == order[i - 1]:
			return true
	return false


# ------------------------------------------------------------------ positions

## World position of the cry for one combination (see the constants above).
static func source_position(direction: String, level: String) -> Vector3:
	if not DIRECTION_VECTORS.has(direction):
		push_error("Ear test: unknown direction '%s'" % direction)
		return Vector3.ZERO
	var along: Vector3 = DIRECTION_VECTORS[direction]
	match level:
		"above":
			return along * SOURCE_DISTANCE + Vector3(0.0, ABOVE_Y, 0.0)
		"below":
			return along * SOURCE_DISTANCE + Vector3(0.0, BELOW_Y, 0.0)
		"inside":
			if direction == "left_rail" or direction == "right_rail":
				return along * INSIDE_RAIL_DISTANCE + Vector3(0.0, INSIDE_RAIL_Y, 0.0)
			return along * SOURCE_DISTANCE + Vector3(0.0, INSIDE_DECK_Y, 0.0)
	push_error("Ear test: unknown level '%s'" % level)
	return Vector3.ZERO


# ------------------------------------------------------------------ scoring

## One answered trial. Keys are the CSV columns after tester_id and output_mode.
static func make_result(round_name: String, trial_index: int, truth: Dictionary,
		answer: Dictionary, response_ms: int, clip: String) -> Dictionary:
	var direction_ok: bool = truth["direction"] == answer["direction"]
	var level_ok: bool = truth["level"] == answer["level"]
	return {
		"round": round_name,
		"trial_index": trial_index,
		"true_direction": truth["direction"],
		"true_level": truth["level"],
		"answer_direction": answer["direction"],
		"answer_level": answer["level"],
		"direction_correct": direction_ok,
		"level_correct": level_ok,
		"both_correct": direction_ok and level_ok,
		"response_ms": response_ms,
		"clip": clip,
	}


static func csv_row(tester_id: String, output_mode: String, result: Dictionary) -> PackedStringArray:
	var row: PackedStringArray = [tester_id, output_mode]
	for column: String in CSV_COLUMNS.slice(2):
		var value: Variant = result[column]
		if value is bool:
			row.append("1" if value else "0")
		else:
			row.append(str(value))
	return row


## Summary of the scored round; practice rows are ignored.
## direction_pct / level_pct count that half right whatever the other half was.
static func score(results: Array) -> Dictionary:
	var total: int = 0
	var both: int = 0
	var direction: int = 0
	var level: int = 0
	var level_trials: Dictionary = {}
	var level_both: Dictionary = {}
	for name: String in LEVELS:
		level_trials[name] = 0
		level_both[name] = 0
	for result: Dictionary in results:
		if result["round"] != ROUND_SCORED:
			continue
		total += 1
		var true_level: String = result["true_level"]
		level_trials[true_level] += 1
		if result["direction_correct"]:
			direction += 1
		if result["level_correct"]:
			level += 1
		if result["both_correct"]:
			both += 1
			level_both[true_level] += 1
	var per_level_both_pct: Dictionary = {}
	for name: String in LEVELS:
		per_level_both_pct[name] = percent(level_both[name], level_trials[name])
	return {
		"scored_trials": total,
		"both_correct": both,
		"direction_correct": direction,
		"level_correct": level,
		"both_pct": percent(both, total),
		"direction_pct": percent(direction, total),
		"level_pct": percent(level, total),
		"per_level_trials": level_trials,
		"per_level_both_pct": per_level_both_pct,
		"passed": total > 0 and both * 100 >= PASS_PERCENT * total,
	}


static func percent(part: int, whole: int) -> float:
	return 0.0 if whole == 0 else 100.0 * part / whole
