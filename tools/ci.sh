#!/usr/bin/env bash
# Local CI for the game and the ear test: free, no hosted service. Runs from the repo root.
#   tools/ci.sh             import, the purity and print checks, the test suite, the smoke runs
#                           (the game, the ear test, each --start value, each show-me setup,
#                           one traced night)
#   tools/ci.sh --export    the same, then the ear test's Windows and Linux builds into builds/,
#                           and one start of the Linux ear test build
# The pre-commit hook (.githooks/pre-commit) runs it before every commit that touches game/ or
# this file.
# Set GODOT to use a different Godot 4.7.2 binary.
set -uo pipefail

case "${1:-}" in
	'' | --export) ;;
	*) echo "ci: unknown argument '$1' (the only one is --export)" >&2; exit 2 ;;
esac
[[ $# -le 1 ]] || { echo "ci: too many arguments" >&2; exit 2; }

cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || echo "$HOME/.local/bin/godot")}"
if [[ ! -x "$GODOT" ]]; then
	echo "ci: Godot not found. Install Godot 4.7.2 or set GODOT=/path/to/godot." >&2
	exit 1
fi

log="$(mktemp)"
scratch="$(mktemp -d)"
trap 'rm -rf "$log" "$scratch"' EXIT
step() { printf 'ci: %-46s' "$1..."; }
fail() { echo "FAILED"; echo "----- output -----" >&2; tail -n 40 "$log" >&2; exit 1; }
# A smoke run or a build start fails on any of these lines (AD-28).
BAD_LINES='^(ERROR|SCRIPT ERROR|SHADER ERROR|WARNING)'

# Prints "file:line:code" for each code line of the .gd files under $1 that matches the ERE $2.
# Text that is not code is dropped first: what is inside a one-line string ("..." or '...'), so
# a `#` in a string hides nothing after it and a banned word in a string is not flagged; then
# comments (a line whose first non-space is `#`, and text after a `#`).
# Folders named in $3 (space-separated) are skipped. A missing folder matches nothing.
code_matches() {
	local dir="$1" pattern="$2" skip="${3:-}" file s
	[[ -d "$dir" ]] || return 0
	while IFS= read -r -d '' file; do
		for s in $skip; do [[ "$file" == "$s"/* ]] && continue 2; done
		sed -E 's/"([^"\\]|\\.)*"/""/g; s/'"'"'([^'"'"'\\]|\\.)*'"'"'/'"''"'/g; s/#.*$//' "$file" \
			| grep -nE "$pattern" | awk -v f="$file" '{ print f ":" $0 }'
	done < <(find "$dir" -name '*.gd' -print0 | sort -z)
}

# Boundary 1, base types: prints each `extends` line under $1 whose base is neither RefCounted
# nor a class declared under $1 itself (`class_name X`, or an inner `class X`).
bad_bases() {
	local dir="$1" own
	[[ -d "$dir" ]] || return 0
	own="$(code_matches "$dir" '(^|[[:space:]])class(_name)?[[:space:]]+[A-Za-z_]' \
		| sed -nE 's/.*(^|[[:space:]:])class(_name)?[[:space:]]+([A-Za-z_][A-Za-z0-9_]*).*/\3/p' | sort -u | paste -sd'|')"
	code_matches "$dir" '\bextends\b' \
		| grep -vE "\bextends[[:space:]]+(RefCounted${own:+|$own})[[:space:]]*:?[[:space:]]*\$"
}

# Boundary 1 (watch/sim/ is node-free): whole words, so `HandInput.` passes; a global random
# call is one not preceded by a dot, so `sim.rng.randi_range(` passes.
W='[^[:alnum:]_]'
# AD-29: no print of any kind in runtime code outside watch/debug/.
PRINT_BANNED="(^|$W)print(s|t|err|raw|_rich|_debug|_verbose)?[[:space:]]*\\("
SIM_BANNED="\\bNode\\b|\\bNode2D\\b|\\bNode3D\\b|\\bSceneTree\\b|\\bTimer\\b|\\bget_tree\\b|\\bget_main_loop\\b"
SIM_BANNED+="|(^|$W)Input\\.|\\bAudioServer\\b|\\bFileAccess\\b|(^|$W)Time\\.|\\bawait\\b|$PRINT_BANNED"
SIM_BANNED+="|(^|[^[:alnum:]_.])(randi|randf|randfn|randi_range|randf_range|seed|rand_from_seed)[[:space:]]*\\("
SIM_BANNED+="|\\brandomize[[:space:]]*\\(|\\.shuffle[[:space:]]*\\(|\\.pick_random[[:space:]]*\\("

# Proves the purity grep works while watch/sim/ is still empty: each banned token alone must be
# caught, and a clean file with look-alikes must pass.
purity_self_check() {
	local bad=(
		'extends Node' 'var n: Node3D = null' 'get_tree().quit()' 'if Input.is_action_pressed(&"x"):'
		'var n: int = AudioServer.bus_count' 'var f: FileAccess = null' 'var t: int = Time.get_ticks_msec()'
		'await done' 'print("x")' 'var a: int = randi()' 'var b: float = randf()' 'var c: int = randi_range(0, 3)'
		'var d: float = randf_range(0.0, 1.0)' 'randomize()' 'items.shuffle()' 'var e: int = items.pick_random()'
		'var n: Node = null' 'var n: Node2D = null' 'var t: Timer = Timer.new()' 'var l: MainLoop = Engine.get_main_loop()'
		'var t: SceneTree = null' 'var g: float = randfn(0.0, 1.0)' 'seed(5)' 'var h: int = rand_from_seed(5)[0]'
		'rng.randomize()' 'var i: int = randi ()' 'print ("x")' 'prints("x")' 'printt("x")' 'printerr("x")'
		'printraw("x")' 'print_rich("x")' 'print_debug("x")' 'print_verbose("x")'
		'var s: String = "#" + str(randi())' "var s: String = '#' + str(randi())"
	)
	local i=0 line dir
	for line in "${bad[@]}"; do
		i=$((i + 1))
		dir="$scratch/purity_bad_$i"
		mkdir -p "$dir"
		printf 'extends RefCounted\n\nfunc f() -> void:\n\t%s\n' "$line" >"$dir/case.gd"
		if [[ -z "$(code_matches "$dir" "$SIM_BANNED")" ]]; then
			echo "purity self-check: not caught: $line" >>"$log"
			return 1
		fi
	done
	dir="$scratch/purity_clean"
	mkdir -p "$dir"
	cat >"$dir/clean.gd" <<-'EOF'
		## A clean sim script: look-alikes of the banned tokens that must pass.
		extends RefCounted
		# print("in a comment line")
		func f(sim: RefCounted) -> void:
			var hand: int = HandInput.HAMMER  # get_tree() in a trailing comment
			var roll: int = sim.rng.randi_range(0, 3)
			var later: float = sim.rng.randf()
			var nodes: int = NightTime.NODE_COUNT
			var input_count: int = 0
			var text: String = "print(x), randi() and Node in a string"
			var other: String = 'await get_tree() in a string'
			var seeded: int = sim.rng.seed
			sprint(roll)
		class Inner extends RefCounted:
			var a: int = 0
		class Deeper extends Inner:
			var b: int = 0
	EOF
	local found
	found="$(code_matches "$dir" "$SIM_BANNED")"
	if [[ -n "$found" ]]; then
		echo "purity self-check: clean file flagged: $found" >>"$log"
		return 1
	fi
	found="$(bad_bases "$dir")"
	if [[ -n "$found" ]]; then
		echo "purity self-check: clean base type flagged: $found" >>"$log"
		return 1
	fi
	# Base types: anything but RefCounted or a class of the folder itself must be caught.
	local base
	for base in 'extends Node2D' 'extends Control' 'extends Resource' 'class Inner extends Object:' 'extends "res://x.gd"'; do
		i=$((i + 1))
		dir="$scratch/purity_bad_$i"
		mkdir -p "$dir"
		printf '%s\n\tvar a: int = 0\n' "$base" >"$dir/case.gd"
		if [[ -z "$(bad_bases "$dir")" ]]; then
			echo "purity self-check: base type not caught: $base" >>"$log"
			return 1
		fi
	done
	return 0
}

step "import"
"$GODOT" --headless --path game --import >"$log" 2>&1 || fail
grep -qE "^(ERROR|SCRIPT ERROR)" "$log" && fail
echo "ok"

step "purity check (watch/sim/)"
: >"$log"
purity_self_check || fail
found="$(code_matches game/watch/sim "$SIM_BANNED"; bad_bases game/watch/sim)"
if [[ -n "$found" ]]; then echo "$found" >"$log"; fail; fi
if [[ -d game/watch/sim ]]; then echo "ok"; else echo "ok (no watch/sim/ yet; self-check passed)"; fi

step "print check (watch/ but debug/)"
found="$(code_matches game/watch "$PRINT_BANNED" game/watch/debug)"
if [[ -n "$found" ]]; then echo "$found" >"$log"; fail; fi
echo "ok"

step "tests"
"$GODOT" --headless --path game -s res://tests/run_tests.gd >"$log" 2>&1 || fail
total="$(grep -E '^[0-9]+ passed, [0-9]+ failed\.' "$log")"
[[ "$total" =~ ^[0-9]+\ passed,\ 0\ failed\. ]] || fail
echo "ok ($(grep -oE '^[0-9]+ passed, 0 failed' <<<"$total"), $(grep -oE '[0-9]+ expected' <<<"$total"))"

# A smoke run: 120 frames headless, failing on any error or warning line.
smoke() {
	step "$1"
	shift
	"$GODOT" --headless --path game --quit-after 120 "$@" >"$log" 2>&1 || fail
	grep -qE "$BAD_LINES" "$log" && fail
	echo "ok"
}
smoke "smoke run: the game"
smoke "smoke run: the ear test" res://scenes/ear_test.tscn

# AD-61: one smoke run per --start value that exists.
step "list --start values"
"$GODOT" --headless --path game -s res://tests/print_start_values.gd >"$log" 2>&1 || fail
grep -qE "$BAD_LINES" "$log" && fail
count_line="$(grep -E '^start values: [0-9]+$' "$log")" || fail
mapfile -t start_values < <(sed -nE 's/^start value: (.+)$/\1/p' "$log")
[[ "${count_line#start values: }" == "${#start_values[@]}" ]] || fail
echo "ok (${#start_values[@]})"
# AC 2 of story 1.2: each start value runs with --seed=1 (the third smoke run is --start=night).
for value in "${start_values[@]}"; do
	smoke "smoke run: --start=$value --seed=1" -- "--start=$value" --seed=1
done

# AD-56: one smoke run per show-me setup, so a broken setup never reaches Sonlm's review.
step "list show-me setups"
"$GODOT" --headless --path game --quit-after 120 -- --show=list >"$log" 2>&1 || fail
grep -qE "$BAD_LINES" "$log" && fail
mapfile -t shows < <(sed -nE 's/^show: ([a-z0-9_]+)( .*)?$/\1/p' "$log")
[[ ${#shows[@]} -gt 0 ]] || { echo "no show-me setup listed" >>"$log"; fail; }
# Every setup was read: the lines found match the count the list prints last.
count_line="$(grep -E '^shows: [0-9]+$' "$log")" || fail
[[ "${count_line#shows: }" == "${#shows[@]}" ]] || { echo "read ${#shows[@]} show lines" >>"$log"; fail; }
echo "ok (${#shows[@]})"
for name in "${shows[@]}"; do
	smoke "smoke run: --show=$name --seed=1" -- "--show=$name" --seed=1
done

# AD-28: the list still reports a setup problem, and the run fails on it.
step "show list with a bad switch fails"
if "$GODOT" --headless --path game --quit-after 120 -- --show=list --no-such-switch >"$log" 2>&1; then
	echo "--show=list with a bad switch exited 0" >>"$log"; fail
fi
grep -qE '^WARNING: launch\.unknown' "$log" || fail
echo "ok"

# AD-29, AD-3: one traced night, so the path Main takes with --trace runs, and its first line
# names the seed the night can be run again with.
smoke "smoke run: --start=night --trace --seed=1" -- --start=night --trace --seed=1
step "trace: NIGHT_STARTED names the seed"
grep -qE '^ +0\.000 NIGHT_STARTED +one_night seed=1$' "$log" || fail
echo "ok"

if [[ "${1:-}" == "--export" ]]; then
	mkdir -p builds/ear-test-windows builds/ear-test-linux
	# An export fails on a bad exit code, an error line, or a build file it did not write anew.
	stamp="$scratch/stamp"
	touch "$stamp"
	export_build() {
		step "export $1"
		"$GODOT" --headless --path game --export-release "$1" "../$2" >"$log" 2>&1 || fail
		grep -qE "^(ERROR|SCRIPT ERROR)" "$log" && fail
		[[ "$2" -nt "$stamp" ]] || { echo "$2 was not written by this export" >>"$log"; fail; }
		echo "ok"
	}
	export_build "Windows" builds/ear-test-windows/ear_test.exe
	export_build "Linux" builds/ear-test-linux/ear_test.x86_64

	# The ear test build must open the ear test, not the game, and write where it always did
	# (AD-43): Godot's default folder named after config/name.eartest, not the game's folder.
	# It runs with a scratch data home, so the real user folders are neither read nor written
	# and a game open in another window cannot disturb the check.
	step "start the Linux ear test build"
	data_home="$scratch/data"
	mkdir -p "$data_home"
	ear_dir="$data_home/godot/app_userdata/Ear Test"
	game_dir="$data_home/mourning_watch"
	XDG_DATA_HOME="$data_home" builds/ear-test-linux/ear_test.x86_64 --headless --verbose --quit-after 120 >"$log" 2>&1 || fail
	grep -qE "$BAD_LINES" "$log" && fail
	# The scene it opened: --verbose logs "Completed load for: '<path>'" even in a release build.
	grep -qF "Completed load for: 'res://scenes/ear_test.tscn'" "$log" \
		|| { echo "did not open res://scenes/ear_test.tscn" >>"$log"; fail; }
	grep -qF "res://watch/main.tscn" "$log" && { echo "opened the game's main scene" >>"$log"; fail; }
	# The folder it wrote its log to.
	[[ -f "$ear_dir/logs/godot.log" ]] || { echo "no log in $ear_dir/logs" >>"$log"; fail; }
	[[ ! -e "$game_dir" ]] || { echo "the ear test build wrote to $game_dir" >>"$log"; fail; }
	echo "ok"
fi
echo "ci: all checks passed"
