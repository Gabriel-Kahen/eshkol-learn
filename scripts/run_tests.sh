#!/bin/bash

# Standalone eshkol.learn test suite.

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

for test_file in tests/*.esk; do
    name="$(basename "$test_file" .esk)"
    out="$TMP_ROOT/standalone_${name}"

    printf "Running %-34s\n" "$test_file"
    "$RUNNER" --no-stdlib -I ./lib -I "$ESH_ROOT/lib" "$test_file" -o "$out"
    "$out"
done
