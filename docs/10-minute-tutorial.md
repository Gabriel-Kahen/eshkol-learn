# 10-Minute Tutorial

This tutorial assumes you are in the standalone package directory:

```sh
cd eshkol-learn
```

The scripts look for the Eshkol compiler checkout at `../eshkol` by default.
If your checkout is elsewhere, set `ESHKOL_ROOT`.

## 1. Run The Package Checks

```sh
scripts/run_tests.sh
scripts/run_examples.sh
scripts/run_parity_tests.sh
```

`run_tests.sh` compiles and runs every test. `run_examples.sh` compiles and
runs each example. `run_parity_tests.sh` checks that the learn parity program
produces the same output in AOT and repl/JIT-style execution.

## 2. Fit A Tiny Model

Create a scratch file:

```sh
mkdir -p scratch
```

```scheme
;; scratch/learn-tiny.esk
```

Then put this program in `scratch/learn-tiny.esk`:

```scheme
(require learn)

(define x '((0.0 0.0)
            (0.0 1.0)
            (1.0 0.0)
            (1.0 1.0)))
(define y '(0 1 1 1))

(define pipe
  (make-pipeline
   (standard-scaler)
   (logistic-regressor ':lr 0.1 ':epochs 200)))

(fit pipe x y)
(display (predict pipe x)) (newline)
(display (score pipe x y)) (newline)
```

Compile and run it from this package:

```sh
ESH_ROOT="${ESHKOL_ROOT:-../eshkol}"
"$ESH_ROOT/build/eshkol-run" --no-stdlib -I ./lib -I "$ESH_ROOT/lib" \
  scratch/learn-tiny.esk -o scratch/learn-tiny
scratch/learn-tiny
```

Options use quoted colon symbols such as `':lr`, `':epochs`, and `':seed`.

## 3. Load CSV Data

The package includes `fixtures/learn_benchmark_tabular.csv`, so you can run a
CSV example without creating new data:

```scheme
(require learn)

(define ds
  (csv-dataset "fixtures/learn_benchmark_tabular.csv"
               '("x1" "x2" "x3")
               "label"))

(define diagnostics (validate-dataset ds ':features 3))
(display (dataset-summary ds)) (newline)

(define split
  (train-valid-test-split (dataset-x ds) (dataset-y ds)
                          ':valid-ratio 0.25
                          ':test-ratio 0.25
                          ':seed 42))
```

`validate-dataset` raises on empty data, non-rectangular feature rows,
feature/target length mismatch, or an unexpected feature width. Use
`dataset-diagnostics` when you want a non-throwing report.

## 4. Record A Run

Runs are local directories. They are deliberately simple: params, metrics,
artifacts, manifests, lineage, benchmark reports, status, and replay stubs.

```scheme
(require learn)

(define run (start-run "tutorial" ':run-id "baseline" ':seed 42))
(log-param run "model" "logistic-regressor")
(log-metric run "valid_accuracy" 0.95 ':step 1)
(display (run-summary run)) (newline)
(display (replay-run run)) (newline)
(end-run run)
```

The generated files live under:

```text
runs/tutorial/baseline/
```

## 5. Use Scientific Learning Helpers

Time-series and state-space helpers give scientific workflows a consistent
shape:

```scheme
(require learn)

(define ts
  (time-series-dataset '(0.0 1.0 2.0 3.0)
                       '(1.0 3.0 5.0 7.0)
                       ':name 'linear-series))

(display (time-series-summary ts)) (newline)
(display (time-series-linear-params ts)) (newline)

(define ss
  (state-space-dataset '(0.0 1.0 2.0)
                       (list (vector 1.0)
                             (vector 3.0)
                             (vector 5.0))))

(display (state-space-summary ss)) (newline)
```

Use finite-difference or closed-form helpers for higher-order simulator
wrappers. Use native autodiff for direct objectives the compiler can resolve.

## 6. Connect Geometry And QGTL-Facing Workflows

QGTL-related support is represented as geometry, manifold updates,
quantum-inspired sampling, backend descriptors, and registry metadata:

```scheme
(require learn)

(define hierarchy (hyperbolic-space 2))
(define concepts (spherical-space 2))

(display (geometry-summary hierarchy '((0.05 0.10) (0.20 0.10)))) (newline)
(display (riemannian-step concepts
                          (vector 1.0 0.0)
                          (vector 0.5 -1.0)
                          0.1))
(newline)
(display (born-probabilities '(1.0 2.0 0.5))) (newline)
```

This is not quantum execution. It is the local learning-layer plumbing that a
real QGTL/Selene/Moonlab integration can plug into.

## 7. Register A Scientific Benchmark

The registry helpers attach dataset shape, lineage, backend identity, and
benchmark output to a run:

```scheme
(require learn)

(define ts
  (time-series-dataset '(0.0 1.0 2.0 3.0)
                       '(1.0 3.0 5.0 7.0)))
(define manifest (time-series-manifest 'linear-series ts))

(define aot (compiler-backend 'aot 'aot))
(define jit (compiler-backend 'jit 'jit))

(define slope-case
  (benchmark-case
   'linear-slope
   (lambda (backend opts)
     (vector-ref (time-series-linear-params ts) 1))
   ':expected 2.0))

(define comparison
  (compare-compiler-backends slope-case (list aot jit)))

(display (backend-comparison-summary comparison)) (newline)
```

For a complete registry workflow, run:

```sh
scripts/run_examples.sh
```

Then inspect `examples/learn_scientific_registry_benchmark.esk`.
