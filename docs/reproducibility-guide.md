# Reproducibility Guide

The goal of reproducibility in `eshkol.learn` is simple: a future reader should
know what data shape was used, which seed and optimizer settings were used,
which backend descriptors were compared, and where to find the run artifacts.

## Minimal Checklist

For every serious run, record:

- dataset source and feature/target columns;
- dataset diagnostics or static shape/schema metadata;
- random seed;
- estimator kind and parameters;
- optimizer kind, learning rate, iteration limit, and tolerance;
- native-autodiff versus finite-difference/closed-form fitting path;
- train/validation/test split ratios;
- metrics with steps;
- backend descriptors when comparing AOT, JIT, simulator, or future hardware;
- parent run IDs for lineage.

## Deterministic Data Splits

Always pass explicit seeds:

```scheme
(train-valid-test-split x y
                        ':valid-ratio 0.25
                        ':test-ratio 0.25
                        ':seed 42)

(cross-validate model x y ':k 5 ':seed 42)
```

Use `dataset-diagnostics` or `validate-dataset` before fitting:

```scheme
(define diagnostics (dataset-diagnostics ds ':features 3))
(display diagnostics) (newline)
(validate-dataset ds ':features 3)
```

## Run Directories

Wrap experiments with `start-run` and `end-run`:

```scheme
(define run (start-run "baseline" ':run-id "seed-42" ':seed 42))
(log-param run "model" "linear-regressor")
(log-param run "lr" 0.01)
(log-metric run "valid_r2" 0.91 ':step 1)
(end-run run)
```

Run layout:

```text
runs/
  experiment-name/
    run-id/
      params.jsonl
      metrics.jsonl
      artifacts.txt
      dataset-manifests.jsonl
      lineage.jsonl
      benchmarks.jsonl
      registry-summary.json
      status.txt
      replay.esk
```

Not every file is present for every run. Simple runs may only have params,
metrics, status, and replay stubs. Scientific registry workflows add manifests,
lineage, benchmark logs, and registry summaries.

## Estimator Persistence

Use `save-estimator` and `load-estimator` for supported built-ins:

```scheme
(save-estimator model "runs/baseline/seed-42/model.json")
(define restored (load-estimator "runs/baseline/seed-42/model.json"))
```

Estimator manifests are JSON. Supported built-ins reload with methods and
state. Unknown or custom procedure-valued estimators load as metadata-only
serialized estimators, so keep custom source code next to the manifest.

## Native Autodiff Replays

Native-autodiff model primitives have deterministic initialization:

```scheme
(define model (sequential-model (list (dense-layer 1 1))))
(define initial (model-init-params model ':seed 17 ':scale 0.1))
```

Record:

- model layer descriptors;
- initializer seed and scale;
- optimizer kind and settings;
- objective source pattern;
- final parameters and final loss.

Native autodiff is appropriate for direct objectives the compiler can resolve.
For higher-order simulator wrappers, record that the run used a
finite-difference or closed-form path.

## Scientific Learning Replays

Scientific runs should record static schemas:

```scheme
(define state-shape (shape-schema 'state '(4 2)))
(define param-shape
  (parameter-schema '(offset slope) (vector 0.0 0.0)))
```

For simulator and ODE workflows, record:

- time grid;
- state dimension;
- target value shape;
- parameter schema and bounds;
- physics/data/conservation weights;
- simulator or RHS function source;
- fitting mode: native autodiff, finite difference, closed form, or direct
  curve/ODE helper.

## Registry Evidence

Use registry helpers when scientific runs need lineage or backend comparison:

```scheme
(define manifest (time-series-manifest 'series ts))
(log-dataset-manifest run manifest)

(define lineage
  (run-lineage "seed-42" '("baseline")
               ':dataset 'series
               ':backend 'aot
               ':purpose 'compiler-backend-parity))
(log-run-lineage run lineage)

(define comparison
  (compare-compiler-backends bench
                             (list (compiler-backend 'aot 'aot)
                                   (compiler-backend 'jit 'jit))))
(log-benchmark-result run comparison)
```

`backend-comparison-summary` records backend name, backend kind, backend mode,
status, output, and metrics. Treat it as local benchmark evidence, not proof
that an external simulator or hardware backend executed.

## AOT/JIT Parity Evidence

For process-level parity, run:

```sh
scripts/run_parity_tests.sh
```

Keep the output with the registry artifact when you need to show that a learn
program produced identical AOT and repl/JIT-style output.

## Cleanup

Examples and tests may create `runs/`. Remove generated artifacts when you are
only checking the package:

```sh
rm -rf runs
```

Do not remove run directories that contain evidence you intend to keep.
