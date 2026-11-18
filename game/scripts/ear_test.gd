## Ear test session: setup -> listen (hear the three levels, unscored) -> 12 practice trials
## (with feedback) -> 24 scored trials -> results.
##
## Each trial starts facing the far bank with mouse-look off for 1 s of silence; then the cry
## plays for 4 s (fading out over its last 50 ms) while the tester is free to look around;
## then the answer grid appears (in practice, with a Replay button). A scored answer is written to the CSV at once; a practice
## answer is written when its feedback ends, so a pause during the feedback counts in its row.
## Values (positions, bus FX, timings, counts, pass mark) all come from trial_plan.gd.
extends Node3D

const TrialPlan := preload("res://scripts/trial_plan.gd")
const CryLibrary := preload("res://scripts/cry_library.gd")
const ResultsLog := preload("res://scripts/results_log.gd")
const ListenerRig := preload("res://scripts/listener.gd")

enum State { SETUP, LISTEN, SILENCE, CRY, ANSWER, FEEDBACK, ROUND_BREAK, PAUSED, RESULTS }
## What resume() does; decided when the pause starts.
enum Resume { REPLAY, TO_GRID, NEXT_TRIAL }

const OUTPUT_MODES: Array[String] = ["headphones", "speakers"]
const COLOR_GOOD: Color = Color(0.55, 0.9, 0.55)
const COLOR_BAD: Color = Color(1.0, 0.55, 0.45)
const COLOR_MUTED: Color = Color(0.7, 0.72, 0.78)
const COLOR_TOWN: Color = Color(1.0, 0.78, 0.45)
const COLOR_BANNER: Color = Color(0.5, 0.07, 0.05)
const TEXT_WIDTH: float = 560.0
## The same in every case, so testers aren't told when a pause would replay the cry.
const PAUSE_TEXT: String = "Paused."
const SAVE_FAILED_TEXT: String = "Results are NOT being saved: %s"

## Where session CSVs are written. The tests point this somewhere else.
var results_dir: String = ResultsLog.DEFAULT_DIR
## Returns the time in milliseconds; response times are measured with it. Tests swap it.
var clock: Callable = Time.get_ticks_msec

var state: State = State.SETUP
var library: CryLibrary = CryLibrary.new()
var results_log: ResultsLog = null
## Problems found by apply_bus_fx() at startup. Any problem disables Start.
var bus_problems: PackedStringArray = []
## How far behind the listener the emitter is (0 ahead .. 1 behind), as last applied to the
## Shadow bus by update_rear_shadow().
var rear_shadow: float = 0.0
## Why the last session stopped early, shown on the setup screen; "" when it didn't.
var setup_error: String = ""
## "<tester ID> · <output mode>" of the last session started; "" before the first.
var last_session: String = ""
## Every logged trial of this session (practice and scored), as TrialPlan.make_result().
var results: Array = []
var round_name: String = TrialPlan.ROUND_PRACTICE
var order: Array = []
## 0-based index into `order`.
var trial_index: int = 0
var current_clip: String = ""
## The trimmed ID exactly as typed (CSV and screens); the file name uses a sanitized copy.
var tester_id: String = ""
var output_mode: String = ""
## The emitter volume for the current cry: EMITTER_VOLUME_DB plus the clip's loudness gain
## for its level (from the loudness table), so every cry plays equally loud.
var cry_base_db: float = TrialPlan.EMITTER_VOLUME_DB
## Pauses taken in the current trial so far, its practice feedback included.
var trial_pauses: int = 0
## Replay presses in the current practice trial (always 0 in the scored round).
var trial_replays: int = 0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _phase_time: float = 0.0
var _cry_started_ms: int = 0
var _resume_to: Resume = Resume.REPLAY
var _paused_at_ms: int = 0
## A practice result shown as feedback, logged when the feedback ends.
var _pending_result: Dictionary = {}
## Listen screen: every clip, in order; which one the level buttons play; whether one plays.
var _demo_clips: PackedStringArray = []
var _demo_index: int = 0
var _demo_playing: bool = false
var _demo_level: String = ""
## True when the listen screen was reopened from the practice break: its button then starts
## the scored round instead of practice.
var _listen_before_scored: bool = false

# UI, built in code by _build_ui().
var _panels: Array[Control] = []
var _save_banner: PanelContainer
var _save_banner_label: Label
var _setup_panel: PanelContainer
var _id_edit: LineEdit
var _mode_group: ButtonGroup
var _mode_buttons: Array[Button] = []
var _last_session_label: Label
var _library_label: Label
var _problem_label: Label
var _file_label: Label
var _start_button: Button
var _answer_panel: PanelContainer
var _progress_label: Label
var _feedback_label: Label
var _replay_button: Button
var _answer_buttons: Array[Button] = []
var _break_panel: PanelContainer
var _listen_panel: PanelContainer
var _demo_label: Label
var _demo_now_label: Label
var _listen_start_button: Button
var _pause_panel: PanelContainer
var _pause_label: Label
var _results_panel: PanelContainer
var _verdict_label: Label
var _results_label: Label
var _results_path_label: Label
var _folder_error_label: Label

@onready var listener: ListenerRig = $Listener
@onready var emitter: AudioStreamPlayer3D = $Emitter


func _ready() -> void:
	listener.camera.position = Vector3(0.0, TrialPlan.EAR_HEIGHT, 0.0)
	_configure_emitter()
	bus_problems = apply_bus_fx()
	for problem: String in bus_problems:
		push_error("Ear test: " + problem)
	library.discover()
	_build_ui()
	_show_setup()
	update_rear_shadow()


func _exit_tree() -> void:
	# Closing the window during practice feedback still logs that answer.
	if not _pending_result.is_empty() and results_log != null:
		_log_result(_pending_result)
		_pending_result = {}


func _process(delta: float) -> void:
	advance(delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and toggle_pause():
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		pause()


# ------------------------------------------------------------------ audio setup

## Writes `fx_table` (TrialPlan.BUS_FX) onto the level buses loaded from
## default_bus_layout.tres: sets the filter and reverb values and forces both effects on, and
## forces the bus unmuted, unbypassed, not solo, at its TrialPlan.LEVEL_BUS_VOLUME_DB, sending to
## the Shadow bus (which goes to Master and holds only the rear-shadow high shelf). Returns a
## list of problems (missing bus, bus order, unknown filter type, missing filter or reverb,
## any other effect on a bus); empty when all is in place. Tests pass other tables and names.
static func apply_bus_fx(fx_table: Dictionary = TrialPlan.BUS_FX,
		buses: Dictionary = TrialPlan.LEVEL_BUSES,
		shadow_bus: StringName = TrialPlan.SHADOW_BUS) -> PackedStringArray:
	var problems: PackedStringArray = _apply_shadow_bus(shadow_bus)
	var shadow: int = AudioServer.get_bus_index(shadow_bus)
	for level: String in TrialPlan.LEVELS:
		var bus_name: StringName = buses.get(level, &"")
		var bus: int = AudioServer.get_bus_index(bus_name)
		if bus < 0:
			problems.append("audio bus '%s' for %s is missing from default_bus_layout.tres" % [bus_name, level])
			continue
		AudioServer.set_bus_mute(bus, false)
		AudioServer.set_bus_bypass_effects(bus, false)
		AudioServer.set_bus_solo(bus, false)
		AudioServer.set_bus_volume_db(bus, TrialPlan.LEVEL_BUS_VOLUME_DB.get(level, 0.0))
		AudioServer.set_bus_send(bus, shadow_bus if shadow >= 0 else &"Master")
		if shadow >= bus:  # Godot would quietly send this bus to Master instead
			problems.append("audio bus '%s' must come after '%s' in default_bus_layout.tres"
					% [bus_name, shadow_bus])
		if not fx_table.has(level):
			problems.append("TrialPlan.BUS_FX has no entry for %s" % level)
			continue
		var fx: Dictionary = fx_table[level]
		var filter_type: String = fx.get("filter", "")
		var filter_known: bool = filter_type in TrialPlan.BUS_FILTER_TYPES
		if not filter_known:
			problems.append("audio bus '%s' has unknown filter type '%s' in TrialPlan.BUS_FX (use %s)"
					% [bus_name, filter_type, " or ".join(PackedStringArray(TrialPlan.BUS_FILTER_TYPES))])
		var filter_done: bool = false
		var reverb_done: bool = false
		for i: int in AudioServer.get_bus_effect_count(bus):
			var effect: AudioEffect = AudioServer.get_bus_effect(bus, i)
			var is_wanted_filter: bool = filter_known and (effect is AudioEffectHighPassFilter
					if filter_type == "high_pass" else effect is AudioEffectLowPassFilter)
			if is_wanted_filter and not filter_done:
				(effect as AudioEffectFilter).cutoff_hz = fx["cutoff_hz"]
				AudioServer.set_bus_effect_enabled(bus, i, true)
				filter_done = true
			elif effect is AudioEffectReverb and not reverb_done:
				var reverb: AudioEffectReverb = effect as AudioEffectReverb
				for key: String in TrialPlan.REVERB_KEYS:
					reverb.set(key, fx[key])
				AudioServer.set_bus_effect_enabled(bus, i, true)
				reverb_done = true
			elif filter_known or not (effect is AudioEffectFilter):
				problems.append("audio bus '%s' has an extra effect %s (slot %d) that TrialPlan.BUS_FX doesn't describe"
						% [bus_name, effect.get_class(), i])
		if filter_known and not filter_done:
			problems.append("audio bus '%s' has no %s filter" % [bus_name, filter_type])
		if not reverb_done:
			problems.append("audio bus '%s' has no reverb" % bus_name)
	return problems


## The Shadow bus: unmuted, unbypassed, not solo, into Master, with exactly one effect, the
## rear-shadow high shelf (cutoff from TrialPlan, gain reset to 1 until a cry is placed).
static func _apply_shadow_bus(shadow_bus: StringName) -> PackedStringArray:
	var problems: PackedStringArray = []
	var bus: int = AudioServer.get_bus_index(shadow_bus)
	if bus < 0:
		problems.append("audio bus '%s' (rear shadow) is missing from default_bus_layout.tres" % shadow_bus)
		return problems
	AudioServer.set_bus_mute(bus, false)
	AudioServer.set_bus_bypass_effects(bus, false)
	AudioServer.set_bus_solo(bus, false)
	AudioServer.set_bus_volume_db(bus, 0.0)
	AudioServer.set_bus_send(bus, &"Master")
	var shelf_done: bool = false
	for i: int in AudioServer.get_bus_effect_count(bus):
		var effect: AudioEffect = AudioServer.get_bus_effect(bus, i)
		if effect is AudioEffectHighShelfFilter and not shelf_done:
			var shelf: AudioEffectHighShelfFilter = effect as AudioEffectHighShelfFilter
			shelf.cutoff_hz = TrialPlan.REAR_SHADOW_CUTOFF_HZ
			shelf.gain = 1.0
			AudioServer.set_bus_effect_enabled(bus, i, true)
			shelf_done = true
		else:
			problems.append("audio bus '%s' has an extra effect %s (slot %d); it should hold only the rear-shadow high shelf"
					% [shadow_bus, effect.get_class(), i])
	if not shelf_done:
		problems.append("audio bus '%s' has no high-shelf filter for the rear shadow" % shadow_bus)
	return problems


## Sets the Shadow bus from where the emitter is relative to where the listener faces: the
## further behind, the more treble cut and the quieter. Runs every frame (end of advance()).
func update_rear_shadow() -> void:
	var facing: Vector3 = -listener.global_basis.z
	rear_shadow = TrialPlan.rear_amount(facing, emitter.global_position - listener.camera.global_position)
	var bus: int = AudioServer.get_bus_index(TrialPlan.SHADOW_BUS)
	if bus < 0:
		return
	AudioServer.set_bus_volume_db(bus, rear_shadow * TrialPlan.REAR_SHADOW_VOLUME_DB)
	for i: int in AudioServer.get_bus_effect_count(bus):
		var shelf: AudioEffectHighShelfFilter = AudioServer.get_bus_effect(bus, i) as AudioEffectHighShelfFilter
		if shelf != null:
			shelf.gain = TrialPlan.shelf_gain_for_db(rear_shadow * TrialPlan.REAR_SHADOW_TREBLE_DB)
			return


func _configure_emitter() -> void:
	emitter.attenuation_model = TrialPlan.EMITTER_ATTENUATION_MODEL
	emitter.attenuation_filter_db = TrialPlan.EMITTER_ATTENUATION_FILTER_DB
	emitter.volume_db = TrialPlan.EMITTER_VOLUME_DB
	emitter.max_db = TrialPlan.EMITTER_MAX_DB
	emitter.unit_size = TrialPlan.EMITTER_UNIT_SIZE
	emitter.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_DISABLED
	emitter.finished.connect(_on_emitter_finished)


func _stop_cry() -> void:
	emitter.stop()
	emitter.volume_db = TrialPlan.EMITTER_VOLUME_DB
	_demo_playing = false


# ------------------------------------------------------------------ session state machine

## The only gate for starting: a usable tester ID, a known output mode, a clip for every
## level, every clip imported and loadable, and no audio bus problem.
func can_start(raw_tester_id: String, mode: String) -> bool:
	return ResultsLog.is_tester_id_usable(raw_tester_id) \
			and mode in OUTPUT_MODES \
			and library.empty_levels().is_empty() \
			and library.problems.is_empty() \
			and bus_problems.is_empty()


## Returns true if the session is running (false if it couldn't start or stopped at once).
func start_session(raw_tester_id: String, mode: String) -> bool:
	if state != State.SETUP or not can_start(raw_tester_id, mode):
		return false
	tester_id = ResultsLog.clean_tester_id(raw_tester_id)
	output_mode = mode
	last_session = "%s · %s" % [tester_id, output_mode]
	setup_error = ""
	results.clear()
	_pending_result = {}
	_rng.randomize()
	results_log = ResultsLog.new()
	results_log.open(results_dir, tester_id, output_mode, ResultsLog.timestamp_now())
	_refresh_save_banner()
	print("Ear test: session %s / %s, seed %d, results -> %s"
			% [tester_id, output_mode, _rng.seed, results_log.global_path()])
	_demo_clips = PackedStringArray()
	for level: String in TrialPlan.LEVELS:
		_demo_clips.append_array(library.clips_for(level))
	_listen_before_scored = false
	_open_listen()
	return true


## Practice break -> the listen screen again, to refresh the three levels just before the
## scored round. Its button then starts the scored round. Nothing is logged.
func listen_again() -> bool:
	if state != State.ROUND_BREAK:
		return false
	_listen_before_scored = true
	_open_listen()
	return true


func _open_listen() -> void:
	_demo_index = 0
	listener.reset_facing()
	listener.set_look_enabled(false)
	state = State.LISTEN
	_refresh_demo_labels()
	_show_only(_listen_panel)


## Listen screen: plays the selected clip from the far bank (straight ahead, so direction
## never changes) through `level`'s bus, looped and faded exactly like a trial's cry. Only
## the level differs between the three buttons. Nothing is logged.
func play_demo(level: String) -> bool:
	if state != State.LISTEN or not level in TrialPlan.LEVELS or _demo_clips.is_empty():
		return false
	var stream: AudioStream = library.stream_for(_demo_clips[_demo_index])
	if stream == null:
		return false
	_stop_cry()
	emitter.stream = stream
	emitter.bus = TrialPlan.LEVEL_BUSES[level]
	emitter.global_position = TrialPlan.source_position(TrialPlan.LISTEN_DIRECTION, level)
	cry_base_db = TrialPlan.EMITTER_VOLUME_DB + library.gain_db(_demo_clips[_demo_index], level)
	emitter.volume_db = cry_base_db
	listener.reset_facing()
	_phase_time = 0.0
	_demo_level = level
	_demo_playing = true
	emitter.play()
	_refresh_demo_labels()
	return true


## Listen screen: the next clip (any kind of cry) for the level buttons.
func next_demo_clip() -> bool:
	if state != State.LISTEN or _demo_clips.is_empty():
		return false
	_stop_cry()
	_demo_index = (_demo_index + 1) % _demo_clips.size()
	_refresh_demo_labels()
	return true


## Listen screen (opened at the start of the session) -> the practice round.
func start_practice() -> bool:
	if state != State.LISTEN or _listen_before_scored:
		return false
	_stop_cry()
	_begin_round(TrialPlan.ROUND_PRACTICE, TrialPlan.build_practice_order(_rng))
	return state != State.SETUP


## Practice break, or the listen screen reopened from it -> the scored round.
func start_scored_round() -> bool:
	if state == State.LISTEN and _listen_before_scored:
		_stop_cry()
		_listen_before_scored = false
		state = State.ROUND_BREAK
	if state != State.ROUND_BREAK:
		return false
	var combos: Array = TrialPlan.all_combinations()
	var scored: Array = TrialPlan.build_scored_order(combos, TrialPlan.SCORED_REPEATS, _rng)
	if scored.size() != combos.size() * TrialPlan.SCORED_REPEATS:
		push_warning("Ear test: scored order has %d trials, expected %d"
				% [scored.size(), combos.size() * TrialPlan.SCORED_REPEATS])
	_begin_round(TrialPlan.ROUND_SCORED, scored)
	return true


## Steps the listen window and the practice feedback. Called every frame; tests call it directly.
func advance(delta: float) -> void:
	match state:
		State.LISTEN:
			if _demo_playing:
				_phase_time += delta
				if _phase_time >= TrialPlan.CRY_WINDOW_S:
					_stop_cry()
					_refresh_demo_labels()
				else:
					emitter.volume_db = TrialPlan.cry_volume_db(_phase_time, cry_base_db)
		State.SILENCE:
			_phase_time += delta
			if _phase_time >= TrialPlan.SILENCE_BEFORE_CRY_S:
				_start_cry()
		State.CRY:
			_phase_time += delta
			if _phase_time >= TrialPlan.CRY_WINDOW_S:
				_end_cry()
			else:
				emitter.volume_db = TrialPlan.cry_volume_db(_phase_time, cry_base_db)
		State.FEEDBACK:
			_phase_time += delta
			if _phase_time >= TrialPlan.PRACTICE_FEEDBACK_S:
				_finish_feedback()
	update_rear_shadow()


func answer(direction: String, level: String) -> bool:
	if state != State.ANSWER:
		return false
	var response_ms: int = _now_ms() - _cry_started_ms
	var result: Dictionary = TrialPlan.make_result(round_name, trial_index + 1, current_combo(),
			TrialPlan.make_combo(direction, level), response_ms, trial_pauses, current_clip.get_file())
	result["cry_kind"] = CryLibrary.kind_of(current_clip)
	if round_name == TrialPlan.ROUND_PRACTICE:
		_pending_result = result
		_show_feedback(result)
		_phase_time = 0.0
		state = State.FEEDBACK
	else:
		_log_result(result)
		_next_trial()
	return true


## Esc or focus loss mid-trial: the cry stops, the mouse is released and the pause counts.
## Where it happens decides what resume() does (see TrialPlan.REPLAY_IF_PAUSED_BEFORE_S).
func pause() -> bool:
	match state:
		State.SILENCE:
			_resume_to = Resume.REPLAY
		State.CRY:
			_resume_to = Resume.REPLAY if _phase_time < TrialPlan.REPLAY_IF_PAUSED_BEFORE_S \
					else Resume.TO_GRID
		State.ANSWER:
			_resume_to = Resume.TO_GRID
		State.FEEDBACK:
			_resume_to = Resume.NEXT_TRIAL
		State.LISTEN:
			if _demo_playing:  # nothing to pause on the listen screen; just stop the sound
				_stop_cry()
				_refresh_demo_labels()
			return false
		_:
			return false
	trial_pauses += 1
	_paused_at_ms = _now_ms()
	_stop_cry()
	listener.set_look_enabled(false)
	state = State.PAUSED
	_show_only(_pause_panel)
	return true


## Paused in the silence or early in the cry: the trial replays from its start (same
## combination, same clip). Paused later in the cry or at the grid: back to the grid with no
## replay, and the paused time doesn't count toward the response time. Paused during
## practice feedback: on to the next trial.
func resume() -> bool:
	if state != State.PAUSED:
		return false
	match _resume_to:
		Resume.REPLAY:
			_begin_trial(false)
		Resume.TO_GRID:
			_cry_started_ms += _now_ms() - _paused_at_ms
			state = State.ANSWER
			_show_answer_grid()
		Resume.NEXT_TRIAL:
			_finish_feedback()
	return true


## Practice only, at the answer grid: plays the same cry again from the silence (same
## combination, same clip, facing reset). response_ms then counts from the last cry heard.
## The scored round has no replay: each cry is heard once, as in the game.
func replay_cry() -> bool:
	if state != State.ANSWER or round_name != TrialPlan.ROUND_PRACTICE:
		return false
	trial_replays += 1
	_begin_trial(false)
	return true


func toggle_pause() -> bool:
	return resume() if state == State.PAUSED else pause()


## Back to setup for the next session: keeps the tester ID, clears the output mode.
func new_session() -> void:
	setup_error = ""
	_return_to_setup()


func current_combo() -> Dictionary:
	return order[trial_index]


func _now_ms() -> int:
	return int(clock.call())


func _begin_round(new_round_name: String, round_order: Array) -> void:
	round_name = new_round_name
	order = round_order
	trial_index = 0
	if order.is_empty():
		_end_round()  # e.g. PRACTICE_REPEATS = 0: straight to the round break
	else:
		_begin_trial(true)


func _begin_trial(pick_new_clip: bool) -> void:
	var combo: Dictionary = current_combo()
	var level: String = combo["level"]
	var direction: String = combo["direction"]
	if pick_new_clip:
		current_clip = library.pick_any(_rng) if TrialPlan.MIX_CRY_KINDS else library.pick(level, _rng)
		trial_pauses = 0
		trial_replays = 0
	var stream: AudioStream = library.stream_for(current_clip)
	if stream == null:
		_abort_session("No playable clip for %s ('%s'), so the session stopped before that trial."
				% [TrialPlan.combo_label(combo), current_clip])
		return
	_stop_cry()
	emitter.stream = stream
	emitter.bus = TrialPlan.LEVEL_BUSES[level]
	emitter.global_position = TrialPlan.source_position(direction, level)
	cry_base_db = TrialPlan.EMITTER_VOLUME_DB + library.gain_db(current_clip, level)
	listener.reset_facing()
	listener.set_look_enabled(false)  # no turning in the silence
	_show_only(null)
	_phase_time = 0.0
	state = State.SILENCE


func _start_cry() -> void:
	_phase_time = 0.0
	_cry_started_ms = _now_ms()
	listener.reset_facing()  # the cry always starts with the tester facing the far bank
	listener.set_look_enabled(true)
	emitter.volume_db = cry_base_db
	state = State.CRY
	emitter.play()


func _end_cry() -> void:
	_stop_cry()
	listener.set_look_enabled(false)
	state = State.ANSWER
	_show_answer_grid()


func _on_emitter_finished() -> void:
	if state == State.CRY or (state == State.LISTEN and _demo_playing):
		emitter.play()  # loop clips shorter than the cry window


func _log_result(result: Dictionary) -> void:
	result["pauses"] = trial_pauses
	result["replays"] = trial_replays
	results.append(result)
	results_log.append_row(TrialPlan.csv_row(tester_id, output_mode, result))
	_refresh_save_banner()


func _finish_feedback() -> void:
	if not _pending_result.is_empty():
		_log_result(_pending_result)
		_pending_result = {}
	_next_trial()


func _next_trial() -> void:
	trial_index += 1
	if trial_index < order.size():
		_begin_trial(true)
	else:
		_end_round()


func _end_round() -> void:
	if round_name == TrialPlan.ROUND_PRACTICE:
		listener.set_look_enabled(false)
		state = State.ROUND_BREAK
		_show_only(_break_panel)
	else:
		_finish_session()


func _finish_session() -> void:
	results_log.close()
	listener.set_look_enabled(false)
	state = State.RESULTS
	_show_results()


## Something that should never happen mid-session (a clip with no stream): stop rather than
## log a silent trial, and say why on the setup screen.
func _abort_session(message: String) -> void:
	push_error("Ear test: " + message)
	setup_error = message
	_return_to_setup()


func _return_to_setup() -> void:
	if results_log != null:
		results_log.close()
	_stop_cry()
	listener.set_look_enabled(false)
	_pending_result = {}
	_listen_before_scored = false
	state = State.SETUP
	_save_banner.visible = false
	for button: Button in _mode_buttons:
		button.button_pressed = false
	library.discover()
	_show_setup()


# ------------------------------------------------------------------ UI construction

func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	var ui_theme: Theme = Theme.new()
	ui_theme.default_font_size = 18
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.theme = ui_theme
	layer.add_child(center)

	_setup_panel = _build_setup_panel()
	_answer_panel = _build_answer_panel()
	_listen_panel = _build_listen_panel()
	_break_panel = _new_panel("Practice done")
	_add_text(_box(_break_panel), "Next: %d scored trials, no feedback. Same as before: listen, look around, then answer."
			% (TrialPlan.all_combinations().size() * TrialPlan.SCORED_REPEATS))
	var break_buttons: HBoxContainer = HBoxContainer.new()
	break_buttons.add_theme_constant_override("separation", 12)
	_box(_break_panel).add_child(break_buttons)
	_add_button(break_buttons, "Hear the levels again", listen_again)
	_add_button(break_buttons, "Start scored round", start_scored_round)
	_pause_panel = _new_panel("")
	_pause_label = _add_text(_box(_pause_panel), PAUSE_TEXT)
	_add_button(_box(_pause_panel), "Resume (Esc)", resume)
	_results_panel = _build_results_panel()
	_panels = [_setup_panel, _listen_panel, _answer_panel, _break_panel, _pause_panel, _results_panel]
	for panel: Control in _panels:
		center.add_child(panel)

	# Shown for the rest of the session as soon as a CSV write fails.
	_save_banner = PanelContainer.new()
	_save_banner.theme = ui_theme
	_save_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var banner_style: StyleBoxFlat = StyleBoxFlat.new()
	banner_style.bg_color = COLOR_BANNER
	banner_style.set_content_margin_all(10.0)
	_save_banner.add_theme_stylebox_override("panel", banner_style)
	_save_banner_label = Label.new()
	_save_banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_save_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_save_banner.add_child(_save_banner_label)
	layer.add_child(_save_banner)
	_save_banner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_save_banner.visible = false


func _build_setup_panel() -> PanelContainer:
	var panel: PanelContainer = _new_panel("Ear test")
	var box: VBoxContainer = _box(panel)
	_add_text(box, ("Stand still and listen. First, hear the three levels. Then each trial: 1 s of silence, then a cry for 4 s. "
			+ "Turn your head with the mouse while it plays, then click where it came from. "
			+ "%d practice trials with feedback, then %d scored trials. Esc pauses.")
			% [TrialPlan.all_combinations().size() * TrialPlan.PRACTICE_REPEATS,
				TrialPlan.all_combinations().size() * TrialPlan.SCORED_REPEATS])

	var id_row: HBoxContainer = HBoxContainer.new()
	box.add_child(id_row)
	var id_caption: Label = Label.new()
	id_caption.text = "Tester ID"
	id_caption.custom_minimum_size = Vector2(110.0, 0.0)
	id_row.add_child(id_caption)
	_id_edit = LineEdit.new()
	_id_edit.placeholder_text = "e.g. ann-01"
	_id_edit.max_length = TrialPlan.TESTER_ID_MAX_LENGTH
	_id_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_id_edit.text_changed.connect(func(_text: String) -> void: refresh_setup())
	id_row.add_child(_id_edit)

	var mode_row: HBoxContainer = HBoxContainer.new()
	box.add_child(mode_row)
	var mode_caption: Label = Label.new()
	mode_caption.text = "Output"
	mode_caption.custom_minimum_size = Vector2(110.0, 0.0)
	mode_row.add_child(mode_caption)
	_mode_group = ButtonGroup.new()
	for mode: String in OUTPUT_MODES:
		var mode_button: Button = Button.new()
		mode_button.text = mode.capitalize()
		mode_button.toggle_mode = true
		mode_button.button_group = _mode_group
		mode_button.set_meta("mode", mode)
		mode_button.toggled.connect(func(_on: bool) -> void: refresh_setup())
		mode_row.add_child(mode_button)
		_mode_buttons.append(mode_button)

	_last_session_label = _add_text(box, "")
	_last_session_label.add_theme_color_override("font_color", COLOR_MUTED)
	_library_label = _add_text(box, "")
	_problem_label = _add_text(box, "")
	_problem_label.add_theme_color_override("font_color", COLOR_BAD)
	_file_label = _add_text(box, "")
	_file_label.add_theme_color_override("font_color", COLOR_MUTED)
	_start_button = _add_button(box, "Start", _on_start_pressed)
	return panel


func _build_listen_panel() -> PanelContainer:
	var panel: PanelContainer = _new_panel("Hear the three levels")
	var box: VBoxContainer = _box(panel)
	_add_text(box, "The same cry, straight ahead of you, from above, from inside the bridge and "
			+ "from below. Play each as often as you like. Any kind of cry can come from any "
			+ "level, so listen to the space around the cry, not the voice.")
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	for level: String in TrialPlan.LEVELS:
		var column: VBoxContainer = VBoxContainer.new()
		row.add_child(column)
		var button: Button = _add_button(column, "Play " + String(TrialPlan.LEVEL_LABELS[level]).to_lower(),
				play_demo.bind(level))
		button.custom_minimum_size = Vector2(150.0, 56.0)
		button.focus_mode = Control.FOCUS_NONE
		column.add_child(_hint_label(level, HORIZONTAL_ALIGNMENT_CENTER))
	var clip_row: HBoxContainer = HBoxContainer.new()
	clip_row.add_theme_constant_override("separation", 12)
	box.add_child(clip_row)
	_demo_label = Label.new()
	_demo_label.add_theme_color_override("font_color", COLOR_MUTED)
	clip_row.add_child(_demo_label)
	_add_button(clip_row, "Another cry", next_demo_clip).focus_mode = Control.FOCUS_NONE
	_demo_now_label = Label.new()
	box.add_child(_demo_now_label)
	_listen_start_button = _add_button(box, "Start practice", _on_listen_done)
	_listen_start_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return panel


## The level's memory aid (TrialPlan.LEVEL_HINTS) in small muted text.
func _hint_label(level: String, alignment: HorizontalAlignment) -> Label:
	var hint: Label = Label.new()
	hint.text = TrialPlan.LEVEL_HINTS[level]
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", COLOR_MUTED)
	hint.horizontal_alignment = alignment
	return hint


func _build_answer_panel() -> PanelContainer:
	var panel: PanelContainer = _new_panel("")
	var box: VBoxContainer = _box(panel)
	_progress_label = Label.new()
	_progress_label.add_theme_color_override("font_color", COLOR_MUTED)
	box.add_child(_progress_label)
	var prompt: Label = Label.new()
	prompt.text = "Where did the cry come from?"
	prompt.add_theme_font_size_override("font_size", 24)
	box.add_child(prompt)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var grid: GridContainer = GridContainer.new()
	grid.columns = TrialPlan.DIRECTIONS.size() + 1
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	row.add_child(grid)
	grid.add_child(Control.new())
	for direction: String in TrialPlan.DIRECTIONS:
		var header: Label = Label.new()
		header.text = TrialPlan.DIRECTION_LABELS[direction]
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid.add_child(header)
	for level: String in TrialPlan.LEVELS:
		var row_header: VBoxContainer = VBoxContainer.new()
		row_header.alignment = BoxContainer.ALIGNMENT_CENTER
		row_header.add_theme_constant_override("separation", 0)
		var level_name: Label = Label.new()
		level_name.text = TrialPlan.LEVEL_LABELS[level]
		row_header.add_child(level_name)
		row_header.add_child(_hint_label(level, HORIZONTAL_ALIGNMENT_LEFT))
		grid.add_child(row_header)
		for direction: String in TrialPlan.DIRECTIONS:
			var button: Button = Button.new()
			button.text = "%s\n%s" % [TrialPlan.LEVEL_LABELS[level], TrialPlan.DIRECTION_LABELS[direction]]
			button.custom_minimum_size = Vector2(118.0, 64.0)
			button.focus_mode = Control.FOCUS_NONE  # no keyboard answers by accident
			button.pressed.connect(_on_answer_pressed.bind(direction, level))
			grid.add_child(button)
			_answer_buttons.append(button)

	var hint_box: VBoxContainer = VBoxContainer.new()
	row.add_child(hint_box)
	var hint: Control = Control.new()
	hint.custom_minimum_size = Vector2(170.0, 210.0)
	hint.draw.connect(_draw_hint.bind(hint))
	hint_box.add_child(hint)
	var hint_caption: Label = Label.new()
	hint_caption.text = "Seen from above.\nYou start each trial\nfacing the far bank."
	hint_caption.add_theme_font_size_override("font_size", 13)
	hint_caption.add_theme_color_override("font_color", COLOR_MUTED)
	hint_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_box.add_child(hint_caption)

	_replay_button = _add_button(box, "Replay the cry (practice only)", replay_cry)
	_replay_button.focus_mode = Control.FOCUS_NONE  # Space/Enter can't replay by accident
	_replay_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

	_feedback_label = Label.new()
	_feedback_label.add_theme_font_size_override("font_size", 24)
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_feedback_label)
	return panel


func _build_results_panel() -> PanelContainer:
	var panel: PanelContainer = _new_panel("Results")
	var box: VBoxContainer = _box(panel)
	_verdict_label = Label.new()
	_verdict_label.add_theme_font_size_override("font_size", 34)
	box.add_child(_verdict_label)
	_results_label = _add_text(box, "")
	_results_path_label = _add_text(box, "")
	_folder_error_label = _add_text(box, "")
	_folder_error_label.add_theme_color_override("font_color", COLOR_BAD)
	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	box.add_child(buttons)
	_add_button(buttons, "Open results folder", _on_open_folder_pressed)
	_add_button(buttons, "New session", new_session)
	return panel


## Tiny top-down map beside the answer grid: which way is town and which is the far bank.
func _draw_hint(canvas: Control) -> void:
	var font: Font = ThemeDB.fallback_font
	var area: Vector2 = canvas.size
	var deck: Rect2 = Rect2(area.x * 0.5 - 14.0, 30.0, 28.0, area.y - 62.0)
	canvas.draw_rect(deck, Color(0.42, 0.42, 0.46))
	canvas.draw_rect(Rect2(deck.position.x - 4.0, deck.position.y, 4.0, deck.size.y), Color(0.75, 0.75, 0.8))
	canvas.draw_rect(Rect2(deck.end.x, deck.position.y, 4.0, deck.size.y), Color(0.75, 0.75, 0.8))
	var you: Vector2 = deck.get_center()
	canvas.draw_line(you, you + Vector2(0.0, -24.0), Color.WHITE, 2.0)
	canvas.draw_line(you + Vector2(0.0, -24.0), you + Vector2(-5.0, -17.0), Color.WHITE, 2.0)
	canvas.draw_line(you + Vector2(0.0, -24.0), you + Vector2(5.0, -17.0), Color.WHITE, 2.0)
	canvas.draw_circle(you, 5.0, Color.WHITE)
	canvas.draw_string(font, Vector2(0.0, 18.0), "Far bank", HORIZONTAL_ALIGNMENT_CENTER, area.x, 14, COLOR_MUTED)
	canvas.draw_string(font, Vector2(0.0, area.y - 10.0), "Town", HORIZONTAL_ALIGNMENT_CENTER, area.x, 14, COLOR_TOWN)
	canvas.draw_string(font, Vector2(0.0, you.y + 5.0), "Left", HORIZONTAL_ALIGNMENT_RIGHT, deck.position.x - 10.0, 14, COLOR_MUTED)
	canvas.draw_string(font, Vector2(deck.end.x + 10.0, you.y + 5.0), "Right", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, COLOR_MUTED)


func _new_panel(title_text: String) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var margin: MarginContainer = MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)
	if not title_text.is_empty():
		var title: Label = Label.new()
		title.text = title_text
		title.add_theme_font_size_override("font_size", 28)
		box.add_child(title)
	return panel


func _box(panel: PanelContainer) -> VBoxContainer:
	return panel.get_child(0).get_child(0) as VBoxContainer


func _add_text(parent: Control, text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(TEXT_WIDTH, 0.0)
	parent.add_child(label)
	return label


func _add_button(parent: Control, text: String, action: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.pressed.connect(func() -> void: action.call())
	parent.add_child(button)
	return button


# ------------------------------------------------------------------ UI updates

func _show_only(panel: Control) -> void:
	for each: Control in _panels:
		each.visible = each == panel


func _refresh_demo_labels() -> void:
	_listen_start_button.text = "Start scored round" if _listen_before_scored else "Start practice"
	_demo_label.text = "Cry %d of %d" % [_demo_index + 1, _demo_clips.size()]
	_demo_now_label.text = ("Playing: " + String(TrialPlan.LEVEL_LABELS[_demo_level])) if _demo_playing else " "


func _show_setup() -> void:
	refresh_setup()
	_show_only(_setup_panel)


func _selected_mode() -> String:
	var pressed: BaseButton = _mode_group.get_pressed_button()
	return "" if pressed == null else String(pressed.get_meta("mode"))


## Redraws the setup screen from the current state; Start is enabled only if can_start().
func refresh_setup() -> void:
	var lines: PackedStringArray = []
	var empty: PackedStringArray = library.empty_levels()
	if empty.is_empty():
		var counts: PackedStringArray = []
		for level: String in TrialPlan.LEVELS:
			counts.append("%s %d" % [level, library.clips_for(level).size()])
		lines.append("Clips found: " + " · ".join(counts))
		_library_label.remove_theme_color_override("font_color")
	else:
		for level: String in empty:
			lines.append("No usable .wav clips in %s" % library.folder_for(level))
		lines.append("Add clips there, run  %s  and restart." % CryLibrary.IMPORT_COMMAND)
		_library_label.add_theme_color_override("font_color", COLOR_BAD)
	lines.append_array(library.warnings)
	_library_label.text = "\n".join(lines)

	var problems: PackedStringArray = library.problems.duplicate()
	for problem: String in bus_problems:
		problems.append("Audio bus problem: %s. Fix BUS_FX in trial_plan.gd or default_bus_layout.tres." % problem)
	if not setup_error.is_empty():
		problems.append(setup_error)
	_problem_label.text = "\n".join(problems)
	_problem_label.visible = not problems.is_empty()

	_last_session_label.text = "Last session: " + last_session
	_last_session_label.visible = not last_session.is_empty()

	var mode: String = _selected_mode()
	if not ResultsLog.is_tester_id_usable(_id_edit.text):
		_file_label.text = "Enter a tester ID."
	elif mode.is_empty():
		_file_label.text = "Pick the output mode in use."
	else:
		_file_label.text = "Saves to %s" % results_dir.path_join(
				ResultsLog.file_name_for(_id_edit.text, mode, "<date-time>"))
	_start_button.disabled = not can_start(_id_edit.text, mode)


func _refresh_save_banner() -> void:
	var failing: bool = results_log != null and results_log.has_error()
	if failing:
		_save_banner_label.text = SAVE_FAILED_TEXT % results_log.error_message
	_save_banner.visible = failing


func _show_answer_grid() -> void:
	var round_label: String = "Practice" if round_name == TrialPlan.ROUND_PRACTICE else "Scored"
	_progress_label.text = "%s trial %d / %d" % [round_label, trial_index + 1, order.size()]
	_feedback_label.text = ""
	for button: Button in _answer_buttons:
		button.disabled = false
	_replay_button.visible = round_name == TrialPlan.ROUND_PRACTICE
	_replay_button.disabled = false
	_show_only(_answer_panel)


func _show_feedback(result: Dictionary) -> void:
	for button: Button in _answer_buttons:
		button.disabled = true
	_replay_button.disabled = true
	if result["both_correct"]:
		_feedback_label.text = "Correct"
		_feedback_label.add_theme_color_override("font_color", COLOR_GOOD)
	else:
		_feedback_label.text = "It was: %s" % TrialPlan.combo_label(current_combo())
		_feedback_label.add_theme_color_override("font_color", COLOR_BAD)


func _show_results() -> void:
	var summary: Dictionary = TrialPlan.score(results)
	var total: int = summary["scored_trials"]
	var passed: bool = summary["passed"]
	_verdict_label.text = "PASS" if passed else "FAIL"
	_verdict_label.add_theme_color_override("font_color", COLOR_GOOD if passed else COLOR_BAD)
	var per_level: PackedStringArray = []
	for level: String in TrialPlan.LEVELS:
		per_level.append("%s %.1f%%" % [TrialPlan.LEVEL_LABELS[level], summary["per_level_both_pct"][level]])
	var lines: PackedStringArray = [
		"Tester %s, %s. Pass mark: both right on at least %d%% of scored trials."
				% [tester_id, output_mode, TrialPlan.PASS_PERCENT],
		"Both correct: %.1f%%  (%d / %d)" % [summary["both_pct"], summary["both_correct"], total],
		"Direction correct, any level: %.1f%%  (%d / %d)" % [summary["direction_pct"], summary["direction_correct"], total],
		"Level correct, any direction: %.1f%%  (%d / %d)" % [summary["level_pct"], summary["level_correct"], total],
		"Both correct by level: " + "  ·  ".join(per_level),
		"Level mix-ups (true → answered): " + TrialPlan.confusion_text(summary["level_confusions"]),
	]
	_results_label.text = "\n".join(lines)
	if results_log.has_error():
		_results_path_label.text = "Could not save the results: %s\nAttempted path: %s" \
				% [results_log.error_message, results_log.global_path()]
		_results_path_label.add_theme_color_override("font_color", COLOR_BAD)
	else:
		_results_path_label.text = "CSV: %s" % results_log.global_path()
		_results_path_label.remove_theme_color_override("font_color")
	show_open_folder_result(OK, "")
	_show_only(_results_panel)


## Replaces (never appends to) the line under the results about opening the folder.
func show_open_folder_result(err: Error, folder: String) -> void:
	_folder_error_label.text = "" if err == OK else "Could not open %s (%s)" % [folder, error_string(err)]
	_folder_error_label.visible = err != OK


# ------------------------------------------------------------------ UI callbacks

func _on_start_pressed() -> void:
	start_session(_id_edit.text, _selected_mode())


func _on_listen_done() -> void:
	if _listen_before_scored:
		start_scored_round()
	else:
		start_practice()


func _on_answer_pressed(direction: String, level: String) -> void:
	answer(direction, level)


func _on_open_folder_pressed() -> void:
	var folder: String = ProjectSettings.globalize_path(results_dir)
	show_open_folder_result(OS.shell_open(folder), folder)
