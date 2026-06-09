#!/bin/bash

# Standalone eshkol.learn examples.

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

for example in examples/learn_*.esk; do
    name="$(basename "$example" .esk)"
    out="$TMP_ROOT/standalone_${name}"
    compile_log="$TMP_ROOT/standalone_${name}.compile.log"
    run_log="$TMP_ROOT/standalone_${name}.run.log"

    printf "Running %-34s " "$example"
    "$RUNNER" --no-stdlib -I ./lib -I "$ESH_ROOT/lib" "$example" -o "$out" >"$compile_log" 2>&1
    "$out" >"$run_log" 2>&1

    if grep -Eq 'Unhandled exception|Invalid type|Failed to generate LLVM IR' "$run_log"; then
        echo "FAIL"
        sed -n '1,80p' "$run_log"
        exit 1
    fi

    echo "PASS"
done
