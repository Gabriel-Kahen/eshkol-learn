# eshkol.learn

`eshkol.learn` is an Eshkol-native learning library for tabular ML,
scientific fitting, geometry-aware training, and reproducible experiment
records. It is meant to compose Eshkol's existing runtime features rather than
replace them: CSV/dataframe loading, vectors, native autodiff where it works,
JSON, logging, plotting, model persistence, and optimizer helpers.

The library is intentionally practical. You can fit basic estimators, build
pipelines, run deterministic searches, train native-autodiff model descriptors,
fit simple simulator/time-series objectives, and record scientific benchmark
runs. It is not a full ML framework and it does not execute external QGTL,
Moonlab, quantum, or hardware targets by itself.

## Quick Start

From this package directory:

```sh
scripts/run_tests.sh
scripts/run_examples.sh
scripts/run_parity_tests.sh
```

The standalone scripts look for the Eshkol compiler checkout at `../eshkol` by
default. Set `ESHKOL_ROOT=/path/to/eshkol` if your compiler checkout lives
somewhere else.

Use `(require learn)` in an Eshkol source file:

```scheme
(require learn)

(define model (linear-regressor ':lr 0.01 ':epochs 200))
(fit model '((1.0) (2.0) (3.0)) '(2.0 4.0 6.0))
(display (predict model '((4.0)))) (newline)
```

Eshkol v1.2 uses flat option lists with quoted colon symbols, such as `':lr`
and `':epochs`. Do not use Python-style or Racket-style keyword calls.

## What To Read

- [10-minute tutorial](docs/10-minute-tutorial.md): first working pipeline,
  CSV workflow, experiment logging, and scientific benchmark example.
- [API reference](docs/api-reference.md): public functions grouped by task.
- [Ecosystem integration](docs/ecosystem-integration.md): how this package
  composes Eshkol core modules and what each example demonstrates.
- [Reproducibility guide](docs/reproducibility-guide.md): seeds, manifests,
  lineage, registry summaries, and AOT/JIT parity evidence.
- [Tsotchke thesis support](docs/tsotchke-thesis-support.md): the QGTL,
  Selene, Moonlab, and geometry-facing parts, with honest boundaries.
- [Estimator author guide](docs/estimator-author-guide.md): how to add a new
  estimator that works with `fit`, `predict`, and `score`.
- [Callback author guide](docs/callback-author-guide.md): how training
  callbacks are represented and called.

## Core Ideas

`eshkol.learn` uses a few simple conventions:

- Estimators are tagged vectors with method tables. The public protocol calls
  are `fit`, `predict`, `transform`, `score`, `params`, and persistence.
- Datasets are plain Eshkol data wrapped with helpers such as `tensor-dataset`
  and `csv-dataset`. Diagnostics report shape and class information before
  fitting.
- Options are flat property lists: `':seed 42`, `':epochs 200`,
  `':optimizer (sgd-optimizer ...)`.
- Runs are local directories under `runs/`. They store params, metrics,
  artifacts, dataset manifests, lineage, benchmark reports, and replay stubs.
- Backend descriptors are records with names and capabilities. They are
  integration contracts, not automatic remote execution.

## Public Surface

The package includes:

- Protocols and persistence: `fit`, `predict`, `score`, `save-estimator`,
  `load-estimator`.
- Data and preprocessing: splits, batching, CSV datasets, shape diagnostics,
  scalers, label encoders, one-hot encoders, and imputers.
- Metrics and search: classification/regression metrics, cross-validation,
  grid search, and random search.
- Estimators: linear/logistic regression, one-hidden-layer MLPs, k-means, PCA,
  nearest neighbors, curve fitting, ODE fitting, and simulator fitting.
- Native autodiff helpers: tensor-style losses, dense/activation/sequential
  descriptors, deterministic parameter initialization, SGD/Adam configs, and
  training loops for compiler-resolvable objectives.
- Scientific learning: simulator objectives, time-series and state-space
  datasets, Euler ODE rollouts, physics-informed losses, and static
  shape/parameter schemas.
- QGTL-facing helpers: Euclidean/spherical/hyperbolic geometry, mixed-curvature
  distances, Riemannian updates, Born-style sampling, and backend descriptors.
- Experiment registry: dataset manifests, run lineage, compiler/backend
  comparison, benchmark suites, registry summaries, and run-local JSONL logs.

## Example Map

| Example | What It Shows |
| --- | --- |
| `examples/learn_xor.esk` | Minimal estimator training flow. |
| `examples/learn_csv_classifier.esk` | CSV dataset loading and classification. |
| `examples/learn_ecosystem_cookbook.esk` | CLI args, logging, plotting, JSON, and run tracking. |
| `examples/learn_grid_search.esk` | Deterministic model selection. |
| `examples/learn_native_autodiff.esk` | Compiler-gradient training pattern. |
| `examples/learn_curve_fit.esk` | Finite-difference curve fitting. |
| `examples/learn_ode_fit.esk` | ODE parameter fitting. |
| `examples/learn_geometric_embeddings.esk` | Mixed-curvature geometry diagnostics. |
| `examples/learn_qgtl_selene_training.esk` | Riemannian updates, Born sampling, and backend descriptors. |
| `examples/learn_scientific_learning_pack.esk` | Time-series, state-space, ODE, and physics-informed helpers. |
| `examples/learn_scientific_registry_benchmark.esk` | Dataset manifests, lineage, backend comparison, and registry summaries. |

## QGTL Connection

The QGTL connection is infrastructure, not a hidden QGTL runtime. This package
supports the learning-layer pieces a QGTL/Selene/Moonlab workflow needs:

- explicit geometric spaces for embeddings and diagnostics;
- manifold-aware updates that keep parameters inside declared spaces;
- deterministic Born-style sampling from real amplitudes;
- backend descriptors that can name future simulator, QGTL, quantum, or
  hardware capabilities;
- registry artifacts that attach datasets, runs, backends, and benchmark
  outcomes to a reproducible Eshkol run.

See [Tsotchke thesis support](docs/tsotchke-thesis-support.md) for the exact
boundary.

## Runtime Notes

The test and example runners use `--no-stdlib` and explicit include paths so
AOT compilation loads only the modules required by each source file. This keeps
verification focused on `learn` instead of compiling the entire stdlib.

Native autodiff is supported for objectives the compiler can resolve directly.
Higher-order simulator and curve-fitting paths keep deterministic
finite-difference or closed-form fallbacks because those closures are not
always compiler-resolvable for `gradient`.

## Status

This is a working v0.1 source package and scaffold. It is suitable for small
Eshkol learning workflows, scientific examples, reproducibility experiments,
and future ecosystem integration work. It is not a mature production ML stack,
not a quantum execution layer, and not a replacement for a real external
QGTL/Moonlab backend.
