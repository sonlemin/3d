## A temporary aim aid (Sonlm, 2026-11-21, after playing story 1.4; DW-41): a mark at the centre
## of the night view that says what the hands would do. Debug only. It goes when epic 4's hands
## show the same things themselves (the ready pose, the hold), and before any gate 2 build:
## EXPERIENCE.md allows no ring or prompt over the night view.
##
## A consumer of the night (`on_tick(events, sim)`). It decides nothing and re-derives nothing: it
## reads `sim.look` and `sim.hands`, and asks HandRules the same two questions HoldRules asks at a
## press. What it shows:
## - nothing in reach: a dim dot;
## - a deck or a rail in reach: the word `deck` or `rail` under the dot (the buttons differ);
## - some button would start a hold now: a bright dot;
## - a hold running: a ring that closes as the hold runs, with the word of the hold's own target.
class_name AimAid
extends CanvasLayer

enum Reading { NOTHING, IN_REACH, READY, HOLDING }

## The buttons that can start a hold (Tab raises the forearm and starts none).
const HAND_INPUTS: Array[NightTypes.HandInput] = [
	NightTypes.HandInput.HAMMER, NightTypes.HandInput.ROPE, NightTypes.HandInput.USE,
]
## Sizes in the project's 1280 x 720 canvas units. Debug sizes, not rules.
const DOT_RADIUS: float = 2.5
const READY_RADIUS: float = 4.5
const RING_RADIUS: float = 14.0
const RING_WIDTH: float = 3.0
const EDGE_WIDTH: float = 1.5
const WORD_SIZE: int = 15
const WORD_DROP: float = 34.0
const DIM: Color = Color(1.0, 1.0, 1.0, 0.45)
const BRIGHT: Color = Color(1.0, 0.86, 0.35, 1.0)
## A dark edge behind every mark, so it reads on the light gray planks too.
const EDGE: Color = Color(0.0, 0.0, 0.0, 0.75)

var _mark: Control
var _reading: Reading = Reading.NOTHING
var _word: String = ""
var _progress: float = 0.0


func _init() -> void:
	name = "AimAid"
	_mark = Control.new()
	_mark.name = "Mark"
	# The mark takes no input: a click still reaches the warden's node and the night.
	_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mark.draw.connect(_draw_mark)
	add_child(_mark)


## A consumer of the night: redraws only when what it shows changed.
func on_tick(_events: Array[NightEvent], sim: NightSim) -> void:
	var now: Reading = reading(sim)
	var word: String = word_of(sim)
	var progress: float = HoldRules.progress(sim.hands)
	if now == _reading and word == _word and progress == _progress:
		return
	_reading = now
	_word = word
	_progress = progress
	_mark.queue_redraw()


## What the aid shows now, for tests.
func shown_reading() -> Reading:
	return _reading


func shown_word() -> String:
	return _word


func shown_progress() -> float:
	return _progress


## Pure: whether a press of `input`, taken on the next tick with the view unchanged, would start
## a hold. HoldRules' own gates in its own order (`_press_hand`): the warden not walking (story
## 1.5's climb back), the forearm up, a hold running, the Press once grace, then HandRules' action
## and check on what is looked at.
## Ticks it does not mirror (code reviews of 2026-11-22), each 1/60 s:
## - The last tick of a timed move (the climb, an edging, a crossing). The move ends in step 1 of
##   the next tick, before the press is taken, so that press can start a hold; but the feet move
##   onto the deck first and what is looked at changes with them, so nothing read now says what it
##   would start. The aid shows "not ready".
## - The tick before a push begins an edging or a crossing (story 1.6 D1: the wish has pushed for
##   sim.ticks.push_to_cross ticks). If the wish is still down on the next tick the move begins in
##   step 1 and the press is ignored; if it is let go, the press is taken. The aid cannot know which
##   and shows what the hands could start.
static func would_start(input: NightTypes.HandInput, sim: NightSim) -> bool:
	var hands: HandsState = sim.hands
	if not WardenRules.walking(sim) or hands.forearm_raised or hands.holding():
		return false
	if sim.holds == NightTypes.Holds.PRESS_ONCE and hands.done_tick >= 0 and input == hands.done_input \
			and sim.tick - hands.done_tick <= sim.ticks.press_once_grace:
		return false
	var action: NightTypes.HandAction = HandRules.action_for(input, sim.look)
	return HandRules.check(action, sim.look, sim.def, sim.span) == NightTypes.Reason.NONE


## Pure: the one reading for the mark.
static func reading(sim: NightSim) -> Reading:
	if sim.hands.holding():
		return Reading.HOLDING
	for input: NightTypes.HandInput in HAND_INPUTS:
		if would_start(input, sim):
			return Reading.READY
	if sim.look.kind != LookTarget.Kind.NONE:
		return Reading.IN_REACH
	return Reading.NOTHING


## Pure: `deck` or `rail` for the running hold's own target, or with no hold for what is looked
## at; empty when that is nothing.
static func word_of(sim: NightSim) -> String:
	var target: LookTarget = sim.hands.target if sim.hands.holding() else sim.look
	match target.kind:
		LookTarget.Kind.DECK:
			return "deck"
		LookTarget.Kind.RAIL:
			return "rail"
	return ""


func _draw_mark() -> void:
	var centre: Vector2 = _mark.size / 2.0
	if _reading == Reading.HOLDING:
		_mark.draw_arc(centre, RING_RADIUS, 0.0, TAU, 48, EDGE, RING_WIDTH + 2.0 * EDGE_WIDTH, true)
		if _progress > 0.0:
			# From the top, clockwise.
			_mark.draw_arc(centre, RING_RADIUS, -PI / 2.0, -PI / 2.0 + TAU * _progress, 48, BRIGHT, RING_WIDTH, true)
	var ready: bool = _reading == Reading.READY or _reading == Reading.HOLDING
	var radius: float = READY_RADIUS if ready else DOT_RADIUS
	_mark.draw_circle(centre, radius + EDGE_WIDTH, EDGE)
	_mark.draw_circle(centre, radius, BRIGHT if ready else DIM)
	if _word.is_empty():
		return
	var font: Font = ThemeDB.fallback_font
	var width: float = font.get_string_size(_word, HORIZONTAL_ALIGNMENT_LEFT, -1.0, WORD_SIZE).x
	var at: Vector2 = centre + Vector2(-width / 2.0, WORD_DROP)
	_mark.draw_string_outline(font, at, _word, HORIZONTAL_ALIGNMENT_LEFT, -1.0, WORD_SIZE, 4, EDGE)
	_mark.draw_string(font, at, _word, HORIZONTAL_ALIGNMENT_LEFT, -1.0, WORD_SIZE, BRIGHT if ready else Color.WHITE)
