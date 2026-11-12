## Ear test session: setup -> 12 practice trials (with feedback) -> 24 scored trials -> results.
##
## Each trial: the tester faces the far bank, hears 1 s of silence, then 4 s of cry while free
## to look around; then the answer grid appears. Every answer is written to the CSV at once.
## Values (positions, bus FX, timings, counts, pass mark) all come from trial_plan.gd.
extends Node3D

const TrialPlan := preload("res://scripts/trial_plan.gd")
const CryLibrary := preload("res://scripts/cry_library.gd")
const ResultsLog := preload("res://scripts/results_log.gd")
const ListenerRig := preload("res://scripts/listener.gd")

enum State { SETUP, SILENCE, CRY, ANSWER, FEEDBACK, ROUND_BREAK, PAUSED, RESULTS }

const OUTPUT_MODES: Array[String] = ["headphones", "speakers"]
const COLOR_GOOD: Color = Color(0.55, 0.9, 0.55)
const COLOR_BAD: Color = Color(1.0, 0.55, 0.45)
const COLOR_MUTED: Color = Color(0.7, 0.72, 0.78)
const COLOR_TOWN: Color = Color(1.0, 0.78, 0.45)
const TEXT_WIDTH: float = 560.0

## Where session CSVs are written. The tests point this somewhere else.
var results_dir: String = ResultsLog.DEFAULT_DIR

var state: State = State.SETUP
var library: CryLibrary = CryLibrary.new()
var results_log: ResultsLog = null
## Every answered trial of this session (practice and scored), as TrialPlan.make_result().
var results: Array = []
var round_name: String = TrialPlan.ROUND_PRACTICE
var order: Array = []
## 0-based index into `order`.
var trial_index: int = 0
var current_clip: String = ""
var tester_id: String = ""
var output_mode: String = ""

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _phase_time: float = 0.0
var _cry_started_ms: int = 0
var _streams: Dictionary = {}  # clip path -> AudioStream

# UI, built in code by _build_ui().
var _panels: Array[Control] = []
var _setup_panel: PanelContainer
var _id_edit: LineEdit
var _mode_group: ButtonGroup
var _library_label: Label
var _file_label: Label
var _start_button: Button
var _answer_panel: PanelContainer
var _progress_label: Label
var _feedback_label: Label
var _answer_buttons: Array[Button] = []
var _break_panel: PanelContainer
var _pause_panel: PanelContainer
var _results_panel: PanelContainer
var _verdict_label: Label
var _results_label: Label
var _results_path_label: Label

@onready var listener: ListenerRig = $Listener
@onready var emitter: AudioStreamPlayer3D = $Emitter


func _ready() -> void:
	listener.camera.position = Vector3(0.0, TrialPlan.EAR_HEIGHT, 0.0)
	_configure_emitter()
	for problem: String in apply_bus_fx():
		push_error("Ear test: " + problem)
	library.discover()
	_build_ui()
	_show_setup()


func _process(delta: float) -> void:
	advance(delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and toggle_pause():
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		pause()


# ------------------------------------------------------------------ audio setup

## Writes TrialPlan.BUS_FX onto the level buses loaded from default_bus_layout.tres.
## Returns a list of problems (missing bus or effect); empty when all is in place.
static func apply_bus_fx() -> PackedStringArray:
	var problems: PackedStringArray = []
	for level: String in TrialPlan.LEVELS:
		var bus_name: StringName = TrialPlan.LEVEL_BUSES[level]
		var fx: Dictionary = TrialPlan.BUS_FX[level]
		var bus: int = AudioServer.get_bus_index(bus_name)
		if bus < 0:
			problems.append("audio bus '%s' is missing from default_bus_layout.tres" % bus_name)
			continue
		var wants_high_pass: bool = fx["filter"] == "high_pass"
		var filter_done: bool = false
		var reverb_done: bool = false
		for i: int in AudioServer.get_bus_effect_count(bus):
			var effect: AudioEffect = AudioServer.get_bus_effect(bus, i)
			var is_wanted_filter: bool = effect is AudioEffectHighPassFilter if wants_high_pass \
					else effect is AudioEffectLowPassFilter
			if is_wanted_filter and not filter_done:
				(effect as AudioEffectFilter).cutoff_hz = fx["cutoff_hz"]
				filter_done = true
			elif effect is AudioEffectReverb and not reverb_done:
				var reverb: AudioEffectReverb = effect as AudioEffectReverb
				reverb.room_size = fx["room_size"]
				reverb.damping = fx["damping"]
				reverb.wet = fx["wet"]
				reverb_done = true
		if not filter_done:
			problems.append("audio bus '%s' has no %s filter" % [bus_name, fx["filter"]])
		if not reverb_done:
			problems.append("audio bus '%s' has no reverb" % bus_name)
	return problems


func _configure_emitter() -> void:
	emitter.attenuation_filter_db = TrialPlan.EMITTER_ATTENUATION_FILTER_DB
	emitter.unit_size = TrialPlan.EMITTER_UNIT_SIZE
	emitter.max_db = TrialPlan.EMITTER_MAX_DB
	emitter.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_DISABLED
	emitter.finished.connect(_on_emitter_finished)


func _stream_for(clip_path: String) -> AudioStream:
	if not _streams.has(clip_path):
		var stream: AudioStream = load(clip_path) as AudioStream
		if stream == null:
			push_error("Ear test: could not load clip %s" % clip_path)
		_streams[clip_path] = stream
	return _streams[clip_path]


# ------------------------------------------------------------------ session state machine

## The only gate for starting: a usable tester ID, a known output mode, no empty level.
func can_start(raw_tester_id: String, mode: String) -> bool:
	return ResultsLog.is_tester_id_usable(raw_tester_id) \
			and mode in OUTPUT_MODES \
			and library.empty_levels().is_empty()


func start_session(raw_tester_id: String, mode: String) -> bool:
	if state != State.SETUP or not can_start(raw_tester_id, mode):
		return false
	tester_id = ResultsLog.sanitize_tester_id(raw_tester_id)
	output_mode = mode
	results.clear()
	_rng.randomize()
	results_log = ResultsLog.new()
	results_log.open(results_dir, tester_id, output_mode, ResultsLog.timestamp_now())
	print("Ear test: session %s / %s, seed %d, results -> %s"
			% [tester_id, output_mode, _rng.seed, results_log.global_path()])
	round_name = TrialPlan.ROUND_PRACTICE
	order = TrialPlan.build_practice_order(_rng)
	trial_index = 0
	_begin_trial(true)
	return true


func start_scored_round() -> bool:
	if state != State.ROUND_BREAK:
		return false
	round_name = TrialPlan.ROUND_SCORED
	var combos: Array = TrialPlan.all_combinations()
	order = TrialPlan.build_scored_order(combos, TrialPlan.SCORED_REPEATS, _rng)
	if order.size() != combos.size() * TrialPlan.SCORED_REPEATS:
		push_warning("Ear test: scored order has %d trials, expected %d"
				% [order.size(), combos.size() * TrialPlan.SCORED_REPEATS])
	trial_index = 0
	if order.is_empty():
		_finish_session()
	else:
		_begin_trial(true)
	return true


## Steps the listen window and the practice feedback. Called every frame; tests call it directly.
func advance(delta: float) -> void:
	match state:
		State.SILENCE:
			_phase_time += delta
			if _phase_time >= TrialPlan.SILENCE_BEFORE_CRY_S:
				_start_cry()
		State.CRY:
			_phase_time += delta
			if _phase_time >= TrialPlan.CRY_WINDOW_S:
				_end_cry()
		State.FEEDBACK:
			_phase_time += delta
			if _phase_time >= TrialPlan.PRACTICE_FEEDBACK_S:
				_next_trial()


func answer(direction: String, level: String) -> bool:
	if state != State.ANSWER:
		return false
	var response_ms: int = Time.get_ticks_msec() - _cry_started_ms
	var result: Dictionary = TrialPlan.make_result(round_name, trial_index + 1, current_combo(),
			TrialPlan.make_combo(direction, level), response_ms, current_clip.get_file())
	results.append(result)
	results_log.append_row(TrialPlan.csv_row(tester_id, output_mode, result))
	if round_name == TrialPlan.ROUND_PRACTICE:
		_show_feedback(result)
		_phase_time = 0.0
		state = State.FEEDBACK
	else:
		_next_trial()
	return true


## Esc mid-trial: the cry stops and the mouse is released.
func pause() -> bool:
	if state not in [State.SILENCE, State.CRY, State.ANSWER]:
		return false
	emitter.stop()
	listener.set_look_enabled(false)
	state = State.PAUSED
	_show_only(_pause_panel)
	return true


## The paused trial replays from its start (same combination, same clip).
func resume() -> bool:
	if state != State.PAUSED:
		return false
	_begin_trial(false)
	return true


func toggle_pause() -> bool:
	return resume() if state == State.PAUSED else pause()


func new_session() -> void:
	if results_log != null:
		results_log.close()
	state = State.SETUP
	library.discover()
	_show_setup()


func current_combo() -> Dictionary:
	return order[trial_index]


func _begin_trial(pick_new_clip: bool) -> void:
	var combo: Dictionary = current_combo()
	var level: String = combo["level"]
	var direction: String = combo["direction"]
	if pick_new_clip:
		current_clip = library.pick(level, _rng)
	emitter.stop()
	emitter.stream = _stream_for(current_clip)
	emitter.bus = TrialPlan.LEVEL_BUSES[level]
	emitter.global_position = TrialPlan.source_position(direction, level)
	listener.reset_facing()
	listener.set_look_enabled(true)
	_show_only(null)
	_phase_time = 0.0
	state = State.SILENCE


func _start_cry() -> void:
	_phase_time = 0.0
	_cry_started_ms = Time.get_ticks_msec()
	state = State.CRY
	emitter.play()


func _end_cry() -> void:
	emitter.stop()
	listener.set_look_enabled(false)
	state = State.ANSWER
	_show_answer_grid()


func _on_emitter_finished() -> void:
	if state == State.CRY:
		emitter.play()  # loop clips shorter than the cry window


func _next_trial() -> void:
	trial_index += 1
	if trial_index < order.size():
		_begin_trial(true)
	elif round_name == TrialPlan.ROUND_PRACTICE:
		state = State.ROUND_BREAK
		_show_only(_break_panel)
	else:
		_finish_session()


func _finish_session() -> void:
	results_log.close()
	listener.set_look_enabled(false)
	state = State.RESULTS
	_show_results()


# ------------------------------------------------------------------ UI construction

func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ui_theme: Theme = Theme.new()
	ui_theme.default_font_size = 18
	center.theme = ui_theme
	layer.add_child(center)

	_setup_panel = _build_setup_panel()
	_answer_panel = _build_answer_panel()
	_break_panel = _new_panel("Practice done")
	_add_text(_box(_break_panel), "Next: %d scored trials, no feedback. Same as before: listen, look around, then answer."
			% (TrialPlan.all_combinations().size() * TrialPlan.SCORED_REPEATS))
	_add_button(_box(_break_panel), "Start scored round", start_scored_round)
	_pause_panel = _new_panel("Paused")
	_add_text(_box(_pause_panel), "The cry stopped. Resuming replays this trial from its start.")
	_add_button(_box(_pause_panel), "Resume (Esc)", resume)
	_results_panel = _build_results_panel()
	_panels = [_setup_panel, _answer_panel, _break_panel, _pause_panel, _results_panel]
	for panel: Control in _panels:
		center.add_child(panel)


func _build_setup_panel() -> PanelContainer:
	var panel: PanelContainer = _new_panel("Ear test")
	var box: VBoxContainer = _box(panel)
	_add_text(box, "Stand still and listen. Each trial: 1 s of silence, then a cry for 4 s. "
			+ "Turn your head with the mouse while it plays, then click where it came from. "
			+ "%d practice trials with feedback, then %d scored trials. Esc pauses; the trial then replays."
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
	_id_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_id_edit.text_changed.connect(func(_text: String) -> void: _refresh_setup())
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
		mode_button.toggled.connect(func(_on: bool) -> void: _refresh_setup())
		mode_row.add_child(mode_button)

	_library_label = _add_text(box, "")
	_file_label = _add_text(box, "")
	_file_label.add_theme_color_override("font_color", COLOR_MUTED)
	_start_button = _add_button(box, "Start", _on_start_pressed)
	return panel


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
		var row_header: Label = Label.new()
		row_header.text = TrialPlan.LEVEL_LABELS[level]
		row_header.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
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


func _show_setup() -> void:
	_refresh_setup()
	_show_only(_setup_panel)


func _selected_mode() -> String:
	var pressed: BaseButton = _mode_group.get_pressed_button()
	return "" if pressed == null else String(pressed.get_meta("mode"))


func _refresh_setup() -> void:
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
			lines.append("No .wav clips in %s" % library.folder_for(level))
		lines.append("Add clips there, run  godot --headless --path game --import  and restart.")
		_library_label.add_theme_color_override("font_color", COLOR_BAD)
	lines.append_array(library.warnings)
	_library_label.text = "\n".join(lines)

	var mode: String = _selected_mode()
	if ResultsLog.is_tester_id_usable(_id_edit.text):
		var file_name: String = ResultsLog.file_name_for(_id_edit.text,
				mode if not mode.is_empty() else "output", "<date-time>")
		_file_label.text = "Saves to %s" % results_dir.path_join(file_name)
	else:
		_file_label.text = "Enter a tester ID."
	_start_button.disabled = not can_start(_id_edit.text, mode)


func _show_answer_grid() -> void:
	var round_label: String = "Practice" if round_name == TrialPlan.ROUND_PRACTICE else "Scored"
	_progress_label.text = "%s trial %d / %d" % [round_label, trial_index + 1, order.size()]
	_feedback_label.text = ""
	for button: Button in _answer_buttons:
		button.disabled = false
	_show_only(_answer_panel)


func _show_feedback(result: Dictionary) -> void:
	for button: Button in _answer_buttons:
		button.disabled = true
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
	]
	_results_label.text = "\n".join(lines)
	if results_log.has_error():
		_results_path_label.text = "Could not save the results: %s\nAttempted path: %s" \
				% [results_log.error_message, results_log.global_path()]
		_results_path_label.add_theme_color_override("font_color", COLOR_BAD)
	else:
		_results_path_label.text = "CSV: %s" % results_log.global_path()
		_results_path_label.remove_theme_color_override("font_color")
	_show_only(_results_panel)


# ------------------------------------------------------------------ UI callbacks

func _on_start_pressed() -> void:
	start_session(_id_edit.text, _selected_mode())


func _on_answer_pressed(direction: String, level: String) -> void:
	answer(direction, level)


func _on_open_folder_pressed() -> void:
	var folder: String = ProjectSettings.globalize_path(results_dir)
	var err: Error = OS.shell_open(folder)
	if err != OK:
		_results_path_label.text += "\nCould not open %s (%s)" % [folder, error_string(err)]
