#!/usr/bin/env bash
# Local CI for the game and the ear test: free, no hosted service. Runs from the repo root.
#   tools/ci.sh             import, the purity and print checks, the test suite, the smoke runs
#   tools/ci.sh --export    the same, then the ear test's Windows and Linux builds into builds/,
#                           and one start of the Linux ear test build
# The pre-commit hook (.githooks/pre-commit) runs it before every commit.
# Set GODOT to use a different Godot 4.7.2 binary.
set -uo pipefail

cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot || echo "$HOME/.local/bin/godot")}"
if [[ ! -x "$GODOT" ]]; then
	echo "ci: Godot not found. Install Godot 4.7.2 or set GODOT=/path/to/godot." >&2
	exit 1
fi

log="$(mktemp)"
scratch="$(mktemp -d)"
trap 'rm -rf "$log" "$scratch"' EXIT
step() { printf 'ci: %-36s' "$1..."; }
fail() { echo "FAILED"; echo "----- output -----" >&2; tail -n 40 "$log" >&2; exit 1; }
# A smoke run or a build start fails on any of these lines (AD-28).
BAD_LINES='^(ERROR|SCRIPT ERROR|WARNING)'

# Prints "file:line:code" for each code line of the .gd files under $1 that matches the ERE $2.
# Comments are dropped first: a line whose first non-space is `#`, and text after a `#`.
# Folders named in $3 (space-separated) are skipped. A missing folder matches nothing.
code_matches() {
	local dir="$1" pattern="$2" skip="${3:-}" file
	[[ -d "$dir" ]] || return 0
	while IFS= read -r -d '' file; do
		for s in $skip; do [[ "$file" == "$s"/* ]] && continue 2; done
		sed -E 's/#.*$//' "$file" | grep -nE "$pattern" | sed "s|^|$file:|"
	done < <(find "$dir" -name '*.gd' -print0 | sort -z)
}

# Boundary 1 (watch/sim/ is node-free): whole words, so `HandInput.` passes; a global random
# call is one not preceded by a dot, so `sim.rng.randi_range(` passes.
W='[^[:alnum:]_]'
SIM_BANNED="\\bextends[[:space:]]+Node\\b|\\bNode3D\\b|\\bget_tree\\b|(^|$W)Input\\.|\\bAudioServer\\b"
SIM_BANNED+="|\\bFileAccess\\b|(^|$W)Time\\.|\\bawait\\b|(^|$W)print\\("
SIM_BANNED+="|(^|[^[:alnum:]_.])(randi|randf|randi_range|randf_range|randomize)\\(|\\.shuffle\\(|\\.pick_random\\("
# AD-29: no print in runtime code outside watch/debug/.
PRINT_BANNED="(^|$W)print\\("

# Proves the purity grep works while watch/sim/ is still empty: each banned token alone must be
# caught, and a clean file with look-alikes must pass.
purity_self_check() {
	local bad=(
		'extends Node' 'var n: Node3D = null' 'get_tree().quit()' 'if Input.is_action_pressed(&"x"):'
		'var n: int = AudioServer.bus_count' 'var f: FileAccess = null' 'var t: int = Time.get_ticks_msec()'
		'await done' 'print("x")' 'var a: int = randi()' 'var b: float = randf()' 'var c: int = randi_range(0, 3)'
		'var d: float = randf_range(0.0, 1.0)' 'randomize()' 'items.shuffle()' 'var e: int = items.pick_random()'
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
			sprint(roll)
	EOF
	local found
	found="$(code_matches "$dir" "$SIM_BANNED")"
	if [[ -n "$found" ]]; then
		echo "purity self-check: clean file flagged: $found" >>"$log"
		return 1
	fi
	return 0
}

step "import"
"$GODOT" --headless --path game --import >"$log" 2>&1 || fail
grep -qE "^(ERROR|SCRIPT ERROR)" "$log" && fail
echo "ok"

step "purity check (watch/sim/)"
: >"$log"
purity_self_check || fail
found="$(code_matches game/watch/sim "$SIM_BANNED")"
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
for value in "${start_values[@]}"; do
	smoke "smoke run: --start=$value" -- "--start=$value"
done

if [[ "${1:-}" == "--export" ]]; then
	mkdir -p builds/ear-test-windows builds/ear-test-linux
	step "export Windows"
	"$GODOT" --headless --path game --export-release "Windows" ../builds/ear-test-windows/ear_test.exe >"$log" 2>&1 || fail
	echo "ok"
	step "export Linux"
	"$GODOT" --headless --path game --export-release "Linux" ../builds/ear-test-linux/ear_test.x86_64 >"$log" 2>&1 || fail
	echo "ok"

	# The ear test build must open the ear test, not the game, and write where it always did
	# (AD-43): Godot's default folder named after config/name.eartest, not the game's folder.
	step "start the Linux ear test build"
	ear_dir="${XDG_DATA_HOME:-$HOME/.local/share}/godot/app_userdata/Ear Test"
	game_dir="${XDG_DATA_HOME:-$HOME/.local/share}/mourning_watch"
	stamp="$scratch/stamp"
	touch "$stamp"
	builds/ear-test-linux/ear_test.x86_64 --headless --verbose --quit-after 120 >"$log" 2>&1 || fail
	grep -qE "$BAD_LINES" "$log" && fail
	# The scene it opened: --verbose logs "Completed load for: '<path>'" even in a release build.
	grep -qF "Completed load for: 'res://scenes/ear_test.tscn'" "$log" \
		|| { echo "did not open res://scenes/ear_test.tscn" >>"$log"; fail; }
	grep -qF "res://watch/main.tscn" "$log" && { echo "opened the game's main scene" >>"$log"; fail; }
	# The folder it wrote its log to.
	[[ -n "$(find "$ear_dir/logs" -maxdepth 1 -name 'godot.log' -newer "$stamp" 2>/dev/null)" ]] \
		|| { echo "no fresh log in $ear_dir/logs" >>"$log"; fail; }
	[[ -z "$(find "$game_dir" -newer "$stamp" 2>/dev/null)" ]] \
		|| { echo "the ear test build wrote to $game_dir" >>"$log"; fail; }
	echo "ok"
fi
echo "ci: all checks passed"
