## The start page (story 1.1, AC 1): it shows the game's name and every setup problem found at
## start, or one line saying there are none. Texts are written literally from the story.
extends TestCase

const TitleScreen := preload("res://watch/screens/title_screen.gd")
const TitleScene := preload("res://watch/screens/title_screen.tscn")


## Every Label's text under `node`, in tree order.
func _texts(node: Node) -> PackedStringArray:
	var out: PackedStringArray = []
	for child: Node in node.get_children():
		if child is Label:
			out.append((child as Label).text)
		out.append_array(_texts(child))
	return out


func _open(problems: PackedStringArray) -> PackedStringArray:
	var title: TitleScreen = TitleScene.instantiate() as TitleScreen
	title.session = WatchSession.new(LaunchOptions.parse(PackedStringArray()), problems)
	root.add_child(title)
	var texts: PackedStringArray = _texts(title)
	root.remove_child(title)
	title.free()
	return texts


func _test_no_problems() -> void:
	var texts: PackedStringArray = _open(PackedStringArray())
	_check("title: name and 'No setup problems.'",
			texts == PackedStringArray(["The Mourning Watch", "No setup problems."]), str(texts))


func _test_lists_every_problem() -> void:
	var problems: PackedStringArray = ["launch.unknown: '--x' is not a launch switch", "input.defined_elsewhere: watch_use"]
	var texts: PackedStringArray = _open(problems)
	_check("title: name, heading, then each problem in order",
			texts == PackedStringArray(["The Mourning Watch", "Setup problems found at start:",
					problems[0], problems[1]]), str(texts))


func _test_no_pixel_sizes() -> void:
	# AD-69: only watch_theme.gd (epic 5) turns a size into canvas pixels.
	var text: String = FileAccess.get_file_as_string("res://watch/screens/title_screen.tscn")
	_check("title: the scene sets no font size override", not text.contains("theme_override_font_sizes"))
	var title: TitleScreen = TitleScene.instantiate() as TitleScreen
	_check("title: the root fills the screen by anchors alone", title.anchor_left == 0.0 and title.anchor_top == 0.0
			and title.anchor_right == 1.0 and title.anchor_bottom == 1.0 and title.offset_left == 0.0
			and title.offset_top == 0.0 and title.offset_right == 0.0 and title.offset_bottom == 0.0)
	title.free()
