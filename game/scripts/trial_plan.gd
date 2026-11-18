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
## Memory aids under each level name, on the answer grid and the listen screen: what each
## level sounds like (never which level a trial's cry was). Keep them true to BUS_FX.
const LEVEL_HINTS: Dictionary = {
	"above": "thin, open air",
	"inside": "muffled, boxed in",
	"below": "cave echo",
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
## Inside, left/right rail: at ear height, in the parapet pylon that rises above the 1.2 m
## parapet at x = +-1.85 (Span/PylonLeft and Span/PylonRight in ear_test.tscn).
const INSIDE_RAIL_DISTANCE: float = 1.85
const INSIDE_RAIL_Y: float = EAR_HEIGHT
## Inside, town/far bank: in the deck slab.
const INSIDE_DECK_Y: float = -0.5

# ------------------------------------------------------------------ audio buses & emitter

const LEVEL_BUSES: Dictionary = {
	"above": &"Above",
	"inside": &"Inside",
	"below": &"Below",
}
## The single source of truth for the level buses: applied over res://default_bus_layout.tres
## at startup (ear_test.gd), so values changed in the editor's Audio panel are overwritten.
## Each level bus holds exactly these two effects (any other effect is a setup problem);
## they are forced on, and the bus is forced unmuted, unbypassed, not solo, sending to Shadow.
## filter: one of BUS_FILTER_TYPES.
const BUS_FILTER_TYPES: Array[String] = ["high_pass", "low_pass"]
## Volume of each level bus. Loudness matching is done per trial instead (LOUDNESS_TABLE_PATH):
## with real recordings, how loud a cry comes out depends on the clip and the level together
## (a hissy whisper through inside's 650 Hz low-pass is ~12 dB quieter than a sob), so one trim
## per level can't even it out. These stay 0 dB; the table was measured with them at 0.
const LEVEL_BUS_VOLUME_DB: Dictionary = {
	"above": 0.0,
	"inside": 0.0,
	"below": 0.0,
}
## Per-trial loudness matching: for every clip and level, the emitter gain that brings that cry
## to the same loudness as all the others (ITU-R BS.1770, through the real buses), written by
## tools/measure_loudness.gd -- --write. A clip without an entry is a setup problem.
const LOUDNESS_TABLE_PATH: String = "res://audio/cries/loudness.json"
## The reverb settings every BUS_FX entry sets (AudioEffectReverb property names).
## Echo is the strongest level cue (it works on any clip), so the three are far apart:
## above almost dry (open air), inside a tight box (tiny room, no predelay, heavily damped),
## below a cave (largest room, long predelay, long bright tail, dry signal pulled back).
const REVERB_KEYS: Array[String] = ["room_size", "damping", "wet", "dry", "predelay_msec"]
const BUS_FX: Dictionary = {
	"above": {"filter": "high_pass", "cutoff_hz": 1000.0,
		"room_size": 0.25, "damping": 0.5, "wet": 0.06, "dry": 1.0, "predelay_msec": 10.0},
	"inside": {"filter": "low_pass", "cutoff_hz": 650.0,
		"room_size": 0.08, "damping": 0.95, "wet": 0.45, "dry": 1.0, "predelay_msec": 3.0},
	"below": {"filter": "low_pass", "cutoff_hz": 2500.0,
		"room_size": 1.0, "damping": 0.15, "wet": 0.7, "dry": 0.6, "predelay_msec": 120.0},
}
## Above keeps only what is over 1000 Hz (thin, bright) and inside only what is under 650 Hz
## (dark, muffled): no shared middle band, so the two can't sound alike.

## Every level bus sends into this bus, which holds one effect: the rear-shadow high shelf.
## It must come before the level buses in default_bus_layout.tres (Godot only sends leftward).
const SHADOW_BUS: StringName = &"Shadow"
## Rear shadow: the head and outer ears make a sound behind you duller and a little quieter
## than the same sound in front, and it brightens as you turn to face it. Plain stereo
## panning has no front/back cue; this adds one without HRTF. A high-shelf cut takes off only
## the top, so the low end that tells above from inside is untouched.
const REAR_SHADOW_CUTOFF_HZ: float = 2000.0
## Treble cut, and overall dip, with the source straight behind; half of each at the side.
const REAR_SHADOW_TREBLE_DB: float = -10.0
const REAR_SHADOW_VOLUME_DB: float = -2.0

## No distance attenuation: every source plays at the same level wherever it is, so loudness
## is not a cue (with inverse-distance falloff the below sources were ~2.7 dB quieter).
## Panning still follows the source direction.
const EMITTER_ATTENUATION_MODEL: AudioStreamPlayer3D.AttenuationModel = AudioStreamPlayer3D.ATTENUATION_DISABLED
## 0 dB: distance filtering must not blur the level filters.
const EMITTER_ATTENUATION_FILTER_DB: float = 0.0
## The emitter's volume while a cry plays, before the clip's loudness gain; the fade-out
## starts from the sum.
const EMITTER_VOLUME_DB: float = 0.0
## Ceiling on the emitter's volume (Godot caps volume_db there). Well above the largest
## loudness gain, so it never limits one; a test checks. (The editor shows +6 dB as the top of
## the range, but that is only a hint.)
const EMITTER_MAX_DB: float = 24.0
## Unused while attenuation is disabled; kept so switching the model back stays a one-line change.
const EMITTER_UNIT_SIZE: float = 10.0
# Stereo panning strength is the project setting audio/general/3d_panning_strength (1.0).

# ------------------------------------------------------------------ cries

## true: each trial plays a clip from ANY cry folder (above/inside/below hold kinds of cry:
## shriek, sob, whisper) through the trial's level bus and position, so only the filter, echo
## and position tell the level, not which kind of cry it is. false: each level plays only its
## own folder's clips, so the kind of cry gives the level away.
const MIX_CRY_KINDS: bool = true
## The listen screen plays its cries from here (straight ahead at the start of every trial),
## so its three buttons differ only in level.
const LISTEN_DIRECTION: String = "far_bank"

# ------------------------------------------------------------------ timings (s)

const SILENCE_BEFORE_CRY_S: float = 1.0
## The cry loops if the clip is shorter, and is cut if longer.
const CRY_WINDOW_S: float = 4.0
## The last part of the cry window fades to silence instead of stopping on a click.
const CRY_FADE_OUT_S: float = 0.05
## Paused in the silence or before this much of the cry was heard: resume replays the trial.
## Paused later in the cry or at the answer grid: resume goes to the grid, no replay.
const REPLAY_IF_PAUSED_BEFORE_S: float = 1.0
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
## Longest tester ID the setup screen accepts (characters).
const TESTER_ID_MAX_LENGTH: int = 64

const CSV_COLUMNS: Array[String] = [
	"tester_id", "output_mode", "round", "trial_index",
	"true_direction", "true_level", "answer_direction", "answer_level",
	"direction_correct", "level_correct", "both_correct", "response_ms", "pauses", "replays", "cry_kind", "clip",
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


## Practice round: each combination `repeats` times (PRACTICE_REPEATS), shuffled.
## Empty when repeats is 0: the session then goes straight to the round break.
static func build_practice_order(rng: RandomNumberGenerator, repeats: int = PRACTICE_REPEATS) -> Array:
	var order: Array = []
	for _repeat: int in repeats:
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


# ------------------------------------------------------------------ cry volume

## Emitter volume (dB) `elapsed_s` into the cry window: EMITTER_VOLUME_DB, then a linear
## fade to silence over the last CRY_FADE_OUT_S, so the cry never ends on a click.
static func cry_volume_db(elapsed_s: float, base_db: float = EMITTER_VOLUME_DB) -> float:
	var left: float = CRY_WINDOW_S - elapsed_s
	if CRY_FADE_OUT_S <= 0.0 or left >= CRY_FADE_OUT_S:
		return base_db
	return base_db + linear_to_db(clampf(left / CRY_FADE_OUT_S, 0.0001, 1.0))


# ------------------------------------------------------------------ rear shadow

## How far behind the listener a source is, in the horizontal plane: 0 straight ahead,
## 0.5 square to one side, 1 straight behind. From the angle's cosine, so it changes smoothly
## as the listener turns. Height is ignored.
static func rear_amount(facing: Vector3, to_source: Vector3) -> float:
	var ahead: Vector2 = Vector2(facing.x, facing.z)
	var toward: Vector2 = Vector2(to_source.x, to_source.z)
	if ahead.is_zero_approx() or toward.is_zero_approx():
		return 0.0
	return clampf((1.0 - ahead.normalized().dot(toward.normalized())) * 0.5, 0.0, 1.0)


## The AudioEffectHighShelfFilter `gain` that cuts the treble by `treble_db`. Godot's shelf
## changes the treble by 40 * log10(gain) dB (measured: gain 0.5 -> -12 dB, 0.25 -> -24 dB),
## so the gain is 10^(dB / 40), not db_to_linear(dB).
static func shelf_gain_for_db(treble_db: float) -> float:
	return pow(10.0, treble_db / 40.0)


# ------------------------------------------------------------------ scoring

## One answered trial. Keys are the CSV columns after tester_id and output_mode.
## `pauses` counts every pause taken during the trial, its practice feedback included.
## `replays` counts Replay presses (practice only); the scene fills it in when it logs the row.
## `cry_kind` is the folder the clip came from (see MIX_CRY_KINDS); the scene fills it in.
static func make_result(round_name: String, trial_index: int, truth: Dictionary,
		answer: Dictionary, response_ms: int, pauses: int, clip: String) -> Dictionary:
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
		"pauses": pauses,
		"replays": 0,
		"cry_kind": "",
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
	var confusions: Dictionary = {}  # true level -> {answered level: count}, wrong levels only
	for name: String in LEVELS:
		level_trials[name] = 0
		level_both[name] = 0
		confusions[name] = {}
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
		else:
			var answered: String = result["answer_level"]
			confusions[true_level][answered] = confusions[true_level].get(answered, 0) + 1
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
		"level_confusions": confusions,
		"passed": total > 0 and both * 100 >= PASS_PERCENT * total,
	}


## "above → inside 2, above → below 1, inside → above 1" from score()'s level_confusions, in
## LEVELS order, most first within each level; "none" when every level was right.
static func confusion_text(confusions: Dictionary) -> String:
	var parts: PackedStringArray = []
	for true_level: String in LEVELS:
		var answered: Dictionary = confusions.get(true_level, {})
		var wrong: Array = answered.keys()
		wrong.sort_custom(func(a: String, b: String) -> bool:
			return answered[a] > answered[b] or (answered[a] == answered[b] and LEVELS.find(a) < LEVELS.find(b)))
		for level: String in wrong:
			parts.append("%s → %s %d" % [true_level, level, answered[level]])
	return "none" if parts.is_empty() else ", ".join(parts)


static func percent(part: int, whole: int) -> float:
	return 0.0 if whole == 0 else 100.0 * part / whole
