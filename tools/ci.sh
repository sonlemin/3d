#!/usr/bin/env bash
# Local CI for the ear test: free, no hosted service. Runs from the repo root.
#   tools/ci.sh             import + test suite + smoke run of the game
#   tools/ci.sh --export    the same, then Windows and Linux builds into builds/
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
trap 'rm -f "$log"' EXIT
step() { printf 'ci: %-28s' "$1..."; }
fail() { echo "FAILED"; echo "----- output -----" >&2; tail -n 40 "$log" >&2; exit 1; }

step "import"
"$GODOT" --headless --path game --import >"$log" 2>&1 || fail
grep -qE "^(ERROR|SCRIPT ERROR)" "$log" && fail
echo "ok"

step "tests"
"$GODOT" --headless --path game -s res://tests/run_tests.gd >"$log" 2>&1 || fail
echo "ok ($(grep -oE '[0-9]+ passed, [0-9]+ failed' "$log"))"

step "smoke run (120 frames)"
"$GODOT" --headless --path game --quit-after 120 >"$log" 2>&1 || fail
grep -qE "^(ERROR|SCRIPT ERROR|WARNING)" "$log" && fail
echo "ok"

if [[ "${1:-}" == "--export" ]]; then
	mkdir -p builds/ear-test-windows builds/ear-test-linux
	step "export Windows"
	"$GODOT" --headless --path game --export-release "Windows" ../builds/ear-test-windows/ear_test.exe >"$log" 2>&1 || fail
	echo "ok"
	step "export Linux"
	"$GODOT" --headless --path game --export-release "Linux" ../builds/ear-test-linux/ear_test.x86_64 >"$log" 2>&1 || fail
	echo "ok"
fi
echo "ci: all checks passed"
