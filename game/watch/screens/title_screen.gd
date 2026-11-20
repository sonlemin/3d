## The title in its first, bare form: the game's name and every setup problem found at start,
## or one line saying there are none (AD-28: setup problems are shown on the title). Epic 5
## grows this file (Lantern light, the font, the entries); it is not replaced.
## No pixel sizes here (AD-69): layout is anchors and containers only.
extends Control

## Handed over by Main before the screen enters the tree.
var session: WatchSession


func _ready() -> void:
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var lines: VBoxContainer = VBoxContainer.new()
	center.add_child(lines)
	_add_line(lines, UiText.GAME_NAME)
	if session.setup_problems.is_empty():
		_add_line(lines, UiText.NO_SETUP_PROBLEMS)
		return
	_add_line(lines, UiText.SETUP_PROBLEMS_HEADING)
	for problem: String in session.setup_problems:
		_add_line(lines, problem)


func _add_line(parent: Container, text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	parent.add_child(label)
