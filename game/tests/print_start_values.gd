## A tool for tools/ci.sh (AD-61): prints every `--start` value, one per line, then their count,
## so CI can start the game once with each. Not runtime code; it may print.
##     godot --headless --path game -s res://tests/print_start_values.gd
extends SceneTree


func _initialize() -> void:
	for value: StringName in LaunchOptions.START_VALUES:
		print("start value: %s" % value)
	print("start values: %d" % LaunchOptions.START_VALUES.size())
	quit(0)
