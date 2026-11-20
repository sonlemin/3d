## The launch switches (AD-61): one table, parsed once into this value, which Main passes down.
## No other script reads the command line. Switches go after `--`:
##     godot --path game -- --seed=3
## A bad switch is a setup problem (AD-28): it is listed in `problems` for Main to report and
## the title to show, and parsing carries on. parse() itself logs nothing, so tests can feed it
## bad input freely.
class_name LaunchOptions
extends RefCounted

## How a row's value is read.
enum Kind {
	INT,    ## A whole number, e.g. --seed=7.
	START,  ## One of START_VALUES.
	FLAG,   ## No value: given means on, e.g. --trace. `--trace=x` is a problem.
	NAME,   ## A non-empty lower-snake name ([a-z0-9_]+), e.g. --show=span_counts.
}

## The values `--start` accepts. Still to come: planning (story 1.7), lesson and round
## (epic 2). tools/ci.sh starts the game once with each of them.
const START_VALUES: Array[StringName] = [&"night"]
## The characters a NAME value may hold.
const NAME_CHARS: String = "abcdefghijklmnopqrstuvwxyz0123456789_"
## Any whole number of up to 18 digits fits a 64-bit int.
const MAX_INT_DIGITS: int = 18

## The one table: a switch, how its value is read, the field it fills, and the flag set when
## it was given (empty when the field alone says so). A new switch is one more row here.
const SWITCHES: Dictionary[String, Dictionary] = {
	"--seed": {"kind": Kind.INT, "field": &"seed", "given": &"seed_given"},
	"--start": {"kind": Kind.START, "field": &"start", "given": &""},
	"--trace": {"kind": Kind.FLAG, "field": &"trace", "given": &""},
	"--show": {"kind": Kind.NAME, "field": &"show", "given": &""},
}

## True when --seed was given; otherwise the caller picks a seed.
var seed_given: bool = false
var seed: int = 0
## The screen to start on; empty means the title.
var start: StringName = &""
## Print every NightEvent as one line (AD-29). A debug switch: source runs and playtest builds.
var trace: bool = false
## A show-me setup to open (AD-56); empty for none. `list` lists them. Whether the name exists
## is checked by the debug tools, not here.
var show: StringName = &""
## One line per bad switch, "launch.<what>: <detail>", in the order given.
var problems: PackedStringArray = []


## The switches of this run (the arguments after `--`). A switch typed before `--` goes to
## the engine, which ignores it without a word; it is listed as a problem here.
static func from_command_line() -> LaunchOptions:
	var options: LaunchOptions = parse(OS.get_cmdline_user_args())
	options.problems.append_array(misplaced(OS.get_cmdline_args()))
	return options


## One problem line per launch switch found among the engine's own arguments. Pure.
static func misplaced(engine_args: PackedStringArray) -> PackedStringArray:
	var found: PackedStringArray = []
	for arg: String in engine_args:
		if SWITCHES.has(arg.get_slice("=", 0)):
			found.append("launch.misplaced: '%s' was ignored; launch switches go after `--`" % arg)
	return found


## Pure: reads only `args`.
static func parse(args: PackedStringArray) -> LaunchOptions:
	var options: LaunchOptions = LaunchOptions.new()
	var seen: Dictionary[String, bool] = {}
	for arg: String in args:
		var switch_name: String = arg.get_slice("=", 0)
		if not SWITCHES.has(switch_name):
			options.problems.append("launch.unknown: '%s' is not a launch switch (known: %s)"
					% [arg, ", ".join(PackedStringArray(SWITCHES.keys()))])
			continue
		if seen.has(switch_name):
			options.problems.append("launch.repeated: %s given more than once; the first good value stands" % switch_name)
			continue
		var row: Dictionary = SWITCHES[switch_name]
		var what: String = switch_name.trim_prefix("--")
		var value: String = arg.substr(switch_name.length() + 1) if arg.contains("=") else ""
		var parsed: Variant = _read(row["kind"], value, arg.contains("="))
		if parsed == null:
			options.problems.append("launch.%s: '%s' is not %s" % [what, arg, _wanted(row["kind"], switch_name)])
			continue
		# Only a value that was taken counts as given: a bad one does not block a later good one.
		seen[switch_name] = true
		options.set(row["field"], parsed)
		var given: StringName = row["given"]
		if not given.is_empty():
			options.set(given, true)
	return options


## The switch's value, or null when `value` is not one of its kind. `has_value` is whether
## an `=` was typed at all.
static func _read(kind: Kind, value: String, has_value: bool) -> Variant:
	match kind:
		Kind.INT:
			# More than 18 digits may not fit in 64 bits, and to_int() would log an error.
			var digits: int = value.trim_prefix("-").trim_prefix("+").length()
			return value.to_int() if value.is_valid_int() and digits <= MAX_INT_DIGITS else null
		Kind.START:
			var wanted: StringName = StringName(value)
			return wanted if START_VALUES.has(wanted) else null
		Kind.FLAG:
			return true if not has_value else null
		Kind.NAME:
			if value.is_empty():
				return null
			for c: String in value:
				if not NAME_CHARS.contains(c):
					return null
			return StringName(value)
	return null


## What a row of this kind wants, for the problem line.
static func _wanted(kind: Kind, switch_name: String) -> String:
	match kind:
		Kind.INT:
			return "%s=<whole number>" % switch_name
		Kind.START:
			if START_VALUES.is_empty():
				return "a start value (none exist yet)"
			return "a start value (%s)" % ", ".join(PackedStringArray(START_VALUES))
		Kind.FLAG:
			return "%s with no value" % switch_name
		Kind.NAME:
			return "%s=<lower_snake name>" % switch_name
	return "valid"
