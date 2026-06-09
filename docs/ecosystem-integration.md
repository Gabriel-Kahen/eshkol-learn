# Ecosystem Integration

`eshkol.learn` is a workflow layer. It does not replace Eshkol's core modules;
it gives learning and scientific programs a consistent way to compose them.

## What It Composes

| Eshkol Surface | How `learn` Uses It |
| --- | --- |
| CSV/dataframe helpers | `csv-dataset`, `dataframe->xy`, dataset diagnostics. |
| Lists/vectors/tensors | Estimator inputs, flat parameter vectors, model descriptors. |
| Optimizers | SGD/Adam/LBFGS-style vector objective wrappers. |
| Native autodiff | Direct compiler-resolvable objectives through `gradient`. |
| JSON and files | Estimator manifests, run logs, registry summaries. |
| Logging and plotting | Cookbook workflows that combine low-level utilities with `learn`. |
| AOT/JIT execution | Parity scripts and backend comparison metadata. |

The package is intentionally local. There is no server, database, remote
runner, or hardware scheduler.

## Package Metadata

The standalone package ships an `eshkol.toml` manifest:

```toml
[package]
name = "eshkol-learn"
version = "0.1.0"
entry = "examples/learn_xor.esk"
sources = ["lib/*.esk", "lib/learn/*.esk", "examples/*.esk", "tests/*.esk"]
eshkol_version = ">=1.2"
```

Current Eshkol package metadata is useful for registry and build context, but
library packages are still verified through the scripts in this directory.

## Verification Modes

Use the standalone scripts:

```sh
scripts/run_tests.sh
scripts/run_examples.sh
scripts/run_parity_tests.sh
```

The scripts compile with:

```text
--no-stdlib -I ./lib -I "$ESHKOL_ROOT/lib"
```

That keeps each test focused on its explicit imports while still allowing this
standalone package to use Eshkol core modules from the compiler checkout.

`run_parity_tests.sh` compares exact output for the learn parity program across
AOT and repl/JIT-style execution. Use that script for process-level parity
evidence; use `learn.registry` for run-local benchmark and backend metadata.

## Data Flow

A typical tabular workflow is:

```scheme
(define ds
  (csv-dataset "fixtures/learn_benchmark_tabular.csv"
               '("x1" "x2" "x3")
               "label"))

(validate-dataset ds ':features 3)

(define split
  (train-valid-test-split (dataset-x ds) (dataset-y ds)
                          ':valid-ratio 0.25
                          ':test-ratio 0.25
                          ':seed 42))

(define model (logistic-regressor ':lr 0.2 ':epochs 300))
(fit model (car split) (car (cdr split)))
```

Use `dataset-diagnostics` before `validate-dataset` when you want a report
instead of an exception.

## Model Flow

Most estimators follow the same protocol:

```scheme
(fit estimator x y)
(predict estimator x)
(score estimator x y)
(params estimator)
```

Pipelines compose transformers and estimators:

```scheme
(define pipe
  (make-pipeline
   (standard-scaler)
   (logistic-regressor ':lr 0.1 ':epochs 200)))
```

Built-in estimators are deliberately modest. They are useful for examples,
benchmarks, and small workflows; they are not meant to compete with mature ML
frameworks.

## Scientific Learning Flow

Scientific learning adds structure for simulator-heavy work:

```scheme
(define ts
  (time-series-dataset times values ':name 'experiment-series))

(define ss
  (state-space-dataset times states ':name 'observed-dynamics))

(define schema
  (parameter-schema '(offset slope) (vector 0.0 0.0)))
```

Use:

- `simulator-loss` and `simulator-objective` for simulator residuals;
- `time-series-linear-params` for deterministic scalar line fitting;
- `ode-euler-simulate` and `dynamics-residual-loss` for simple ODE workflows;
- `physics-informed-loss` to combine data, dynamics, boundary, and
  conservation terms;
- `shape-schema` and `parameter-schema` to make replay assumptions explicit.

Native autodiff works best for direct objectives written over concrete
parameter vectors. Higher-order simulator wrappers use finite-difference or
closed-form fallback paths where current compiler `gradient` resolution is not
reliable.

## Geometry And QGTL-Facing Flow

The QGTL/Selene connection is a set of learning-layer primitives:

```scheme
(define hierarchy (hyperbolic-space 2))
(define concepts (spherical-space 2))

(geometry-summary hierarchy '((0.05 0.10) (0.20 0.10)))
(riemannian-step concepts (vector 1.0 0.0) (vector 0.5 -1.0) 0.1)
(born-probabilities '(1.0 2.0 0.5))
```

These functions make geometry, manifold updates, and quantum-inspired
probability explicit in ordinary Eshkol learning code. They do not execute
QGTL or quantum programs.

Backend descriptors record what an external integration would support:

```scheme
(define backend
  (simulator-learn-backend
   'moonlab-prototype
   ':capabilities '(simulator scientific-learning qgtl-prototype)))
```

Use `learn-backend-supports?` to check capability symbols before dispatching
through handlers.

## Experiment And Registry Flow

Start with a simple run:

```scheme
(define run (start-run "cookbook" ':seed 42))
(log-param run "model" "logistic-regressor")
(log-metric run "valid_accuracy" 0.95 ':step 1)
(end-run run)
```

For scientific workflows, add manifests, lineage, and benchmark comparisons:

```scheme
(define manifest (time-series-manifest 'series ts))
(define lineage
  (run-lineage "run-001" '("baseline")
               ':dataset 'series
               ':backend 'aot))

(define comparison
  (compare-backends bench-case
                    (list (compiler-backend 'aot 'aot)
                          (compiler-backend 'jit 'jit))))
```

Run-directory helpers write:

```text
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

## Example Guide

Use these examples as canonical patterns:

- `learn_ecosystem_cookbook.esk`: combines CLI args, CSV loading, validation,
  fitting, logging, plotting, JSON report writing, and run tracking.
- `learn_native_autodiff.esk`: direct objective path for compiler-gradient
  training.
- `learn_qgtl_selene_training.esk`: geometry, Riemannian optimization,
  Born-style sampling, and backend descriptors.
- `learn_scientific_learning_pack.esk`: time-series, state-space, ODE, and
  physics-informed helpers.
- `learn_scientific_registry_benchmark.esk`: manifests, lineage, backend
  comparison, benchmark reports, and registry summaries.

## Boundaries

This package does not:

- launch QGTL, Moonlab, Neo-Millennium, or quantum hardware;
- provide a remote experiment tracking server;
- infer schemas automatically from arbitrary simulator procedures;
- guarantee native autodiff for every higher-order closure;
- replace mature ML frameworks for large-scale production training.

It does provide local, inspectable values and run artifacts so those future
systems have stable places to plug in.
