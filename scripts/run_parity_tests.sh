#!/bin/bash

# Standalone eshkol.learn AOT/JIT parity check.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ESH_ROOT="${ESHKOL_ROOT:-$ROOT_DIR/../eshkol}"
cd "$ROOT_DIR"

if [ -n "${BUILD_DIR:-}" ]; then
    RUNNER="$BUILD_DIR/eshkol-run"
elif [ -x "$ESH_ROOT/build/eshkol-run" ]; then
    RUNNER="$ESH_ROOT/build/eshkol-run"
elif [ -x "$ESH_ROOT/build-poet/eshkol-run" ]; then
    RUNNER="$ESH_ROOT/build-poet/eshkol-run"
else
    echo "Error: eshkol-run not found. Set BUILD_DIR or ESHKOL_ROOT, or place the compiler checkout at ../eshkol." >&2
    exit 1
fi

TMP_ROOT="${TMPDIR:-$ROOT_DIR/.tmp}"
mkdir -p "$TMP_ROOT"

TEST_FILE="tests/learn_parity_program.esk"
OUT="$TMP_ROOT/standalone_learn_parity_aot"
AOT_LOG="$TMP_ROOT/standalone_learn_parity_aot.log"
JIT_LOG="$TMP_ROOT/standalone_learn_parity_jit.log"
COMPILE_LOG="$TMP_ROOT/standalone_learn_parity.compile.log"
DIFF_LOG="$TMP_ROOT/standalone_learn_parity.diff"

printf "Running standalone learn AOT/JIT parity "
"$RUNNER" --no-stdlib -I ./lib -I "$ESH_ROOT/lib" "$TEST_FILE" -o "$OUT" >"$COMPILE_LOG" 2>&1
"$OUT" >"$AOT_LOG" 2>&1
"$RUNNER" --no-stdlib -I ./lib -I "$ESH_ROOT/lib" -r "$TEST_FILE" >"$JIT_LOG" 2>&1

if ! diff -u "$AOT_LOG" "$JIT_LOG" >"$DIFF_LOG"; then
    echo "FAIL"
    sed -n '1,120p' "$DIFF_LOG"
    exit 1
fi

echo "PASS"
