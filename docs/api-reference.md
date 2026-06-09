# API Reference

This page groups the public `(require learn)` API by job. Most functions accept
plain Eshkol lists/vectors. Options are flat property lists with quoted colon
symbols, for example `':seed 42` or `':epochs 200`.

## Protocols

Use these functions with any learn estimator, transformer, predictor, or
pipeline.

| Function | Purpose |
| --- | --- |
| `fit estimator x [y]` | Fit an estimator or transformer in place. |
| `predict estimator x` | Return predictions for rows in `x`. |
| `predict-proba estimator x` | Return prediction probabilities when supported. |
| `transform estimator x` | Transform rows using a fitted transformer. |
| `fit-transform estimator x [y]` | Fit and transform in one call. |
| `score estimator x y` | Return the estimator's score for features and targets. |
| `params estimator` | Return estimator parameters as a learn alist. |
| `set-params estimator updates` | Merge parameter updates into an estimator. |
| `save-estimator estimator filename` | Write a JSON estimator manifest. |
| `load-estimator filename` | Load a supported built-in estimator or metadata-only manifest. |
| `estimator-kind estimator` | Return the estimator kind symbol. |
| `estimator-state estimator` | Return estimator state. |
| `estimator-fitted? estimator` | Return whether the estimator has been fitted. |
| `estimator-method estimator name` | Return a method procedure from the method table. |
| `estimator-has-method? estimator name` | Check whether a method is present. |

Alists use `(learn-pair key value)`. Read them with
`(learn-alist-get alist key default)`.

## Data

| Function | Purpose |
| --- | --- |
| `tensor-dataset x y` | Wrap existing feature and target sequences. |
| `csv-dataset filename feature-cols target-col` | Load a CSV file into a dataset. |
| `dataset? value` | Check for a learn dataset. |
| `dataset-x ds`, `dataset-y ds` | Access features and targets. |
| `dataset-size ds` | Count feature rows. |
| `dataset-batches ds batch-size` | Split a dataset into dataset batches. |
| `dataset-shape ds` | Return shape-only metadata. |
| `dataset-summary ds` | Return shape and class summary metadata. |
| `dataset-diagnostics ds ...` | Return non-throwing validation diagnostics. |
| `validate-dataset ds ...` | Raise on invalid shape or feature width. |
| `validate-feature-width x expected` | Raise when feature rows have the wrong width. |
| `dataframe->xy df feature-cols target-col` | Convert an existing dataframe to `(x y)`. |
| `train-valid-test-split x y ...` | Deterministic train/valid/test split. |
| `shuffle-split x y ...` | Deterministic train/test split. |
| `k-fold-split x y ...` | Deterministic k-fold split. |
| `batch-dataset x y batch-size` | Batch raw feature/target sequences. |

Common options:

```scheme
':seed 42
':valid-ratio 0.2
':test-ratio 0.2
':features 3
':k 5
```

## Preprocessing

| Function | Purpose |
| --- | --- |
| `standard-scaler` | Center and scale each feature column. |
| `minmax-scaler` | Scale feature columns into a min/max range. |
| `label-encoder` | Map labels to deterministic integer IDs. |
| `one-hot-encoder` | Convert labels to one-hot rows. |
| `imputer` | Replace missing values using a configured strategy. |

Use scalers and encoders directly with `fit`, `transform`, and
`fit-transform`, or inside `make-pipeline`.

## Metrics

Classification:

- `accuracy`
- `precision`
- `recall`
- `f1`
- `confusion-matrix`
- `log-loss`
- `top-k-accuracy`

Regression:

- `mse`
- `rmse`
- `mae`
- `r2-score`

Training diagnostics:

- `loss-history`
- `gradient-norm-history`
- `learning-curve`

## Training, Search, And Callbacks

| Function | Purpose |
| --- | --- |
| `train-loop objective initial-params ...` | Run full-batch vector optimization. |
| `make-trainer ...` | Build a trainer descriptor. |
| `training-step ...` | Run one training step. |
| `validation-step ...` | Run one validation step. |
| `epoch-result ...` | Build epoch metadata. |
| `history result` | Read training history. |
| `compile-model model ...` | Prepare a model/training descriptor. |
| `cross-validate estimator x y ...` | Evaluate folds. |
| `grid-search estimator param-grid x y ...` | Try deterministic parameter combinations. |
| `random-search estimator param-space x y ...` | Try deterministic sampled configurations. |
| `best-estimator result` | Return the best estimator from search. |
| `best-params result` | Return the best parameter set. |
| `validation-report result` | Return structured validation metadata. |

Callbacks:

- `early-stopping`
- `checkpoint`
- `progress-log`
- `metric-logger`
- `terminate-on-nan`
- `lr-scheduler-callback`

## Optimizers

General vector-objective optimizers:

- `sgd-optimizer`
- `adam-optimizer`
- `lbfgs-optimizer`
- `conjugate-gradient-optimizer`
- `optimizer?`
- `optimizer-kind`
- `optimizer-params`
- `optimizer-minimize`

Geometry-aware and native-autodiff optimizers:

- `riemannian-sgd-optimizer`
- `autodiff-sgd-optimizer`
- `autodiff-adam-optimizer`

Use native-autodiff optimizers for direct objectives the compiler can resolve.
Use finite-difference optimizer configs for higher-order simulator and curve
fitting paths.

## Built-In Estimators

| Function | Purpose |
| --- | --- |
| `linear-regressor` | Scalar regression with deterministic optimization. |
| `logistic-regressor` | Binary/classification-oriented logistic model. |
| `mlp-regressor` | One-hidden-layer regression MLP. |
| `mlp-classifier` | One-hidden-layer classification MLP. |
| `kmeans` | K-means clustering. |
| `pca` | Power-iteration principal component projection. |
| `nearest-neighbors` | K-nearest-neighbor classifier. |
| `curve-fit` | Fit scalar/vector curve parameters. |
| `ode-parameter-fit` | Fit ODE parameters to observed states. |
| `differentiable-simulator-fit` | Fit simulator parameters with learn optimizer paths. |

## Pipelines

| Function | Purpose |
| --- | --- |
| `make-pipeline step ...` | Chain transformers and a final estimator. |
| `pipeline-step name estimator` | Name a pipeline step. |

Pipeline objects support `fit`, `predict`, `transform`, and `score` depending
on their final step.

## Geometry

| Function | Purpose |
| --- | --- |
| `euclidean-space dimension` | Describe Euclidean embedding space. |
| `spherical-space dimension` | Describe spherical embedding space. |
| `hyperbolic-space dimension` | Describe Poincare-ball-style hyperbolic space. |
| `geometry-space kind dimension ...` | Build a custom geometry descriptor. |
| `geometry-distance space a b` | Compute distance in the declared space. |
| `mixed-geometry-distance spaces a b` | Split a vector across multiple spaces and sum distances. |
| `geometry-summary space rows` | Report geometry diagnostics for rows. |
| `mixed-geometry-summary spaces rows` | Report mixed-geometry metadata. |
| `geometry-distance-matrix space rows` | Compute pairwise distances. |
| `geometric-regularization space rows` | Penalize points outside declared geometry assumptions. |

## Manifold Training

| Function | Purpose |
| --- | --- |
| `riemannian-project space point` | Project a point onto/inside the declared space. |
| `riemannian-gradient space point grad` | Convert an Euclidean gradient to a tangent update. |
| `riemannian-step space point grad lr` | Take one projected manifold step. |
| `riemannian-train-loop space objective initial ...` | Train while projecting each update. |

## Born Sampling

| Function | Purpose |
| --- | --- |
| `born-probabilities amplitudes` | Convert real amplitudes to normalized probabilities. |
| `born-sample-index amplitudes ...` | Deterministically sample an index with a seed. |
| `born-sample amplitudes ...` | Sample an index or mapped value. |
| `born-expectation amplitudes values` | Compute expected value. |
| `born-sampling-summary amplitudes` | Return probability diagnostics. |

These are quantum-inspired helpers, not quantum execution.

## Backend Extension

| Function | Purpose |
| --- | --- |
| `learn-backend kind name capabilities ...` | Build a backend descriptor. |
| `classical-learn-backend ...` | Build a classical backend descriptor. |
| `simulator-learn-backend name ...` | Build a simulator backend descriptor. |
| `quantum-learn-backend name ...` | Build a quantum backend descriptor. |
| `learn-backend? value` | Check for a backend descriptor. |
| `learn-backend-kind backend` | Return backend kind. |
| `learn-backend-name backend` | Return backend name. |
| `learn-backend-capabilities backend` | Return capability symbols. |
| `learn-backend-params backend` | Return backend options. |
| `learn-backend-supports? backend capability` | Check a capability. |
| `learn-backend-summary backend` | Return summary metadata. |
| `learn-backend-handler backend operation` | Return a registered operation handler. |
| `learn-backend-call backend operation payload ...` | Call a registered handler. |

Backends are descriptors and dispatch contracts. They do not automatically
launch remote simulators or hardware.

## Native Autodiff

| Function | Purpose |
| --- | --- |
| `tensor-mse-loss`, `tensor-mae-loss` | Scalar losses over row/vector data. |
| `tensor-binary-cross-entropy` | Binary classification loss. |
| `tensor-l2-regularization` | L2 penalty for parameter vectors. |
| `dense-layer`, `activation-layer` | Build model layer descriptors. |
| `sequential-model layers` | Build a flat-parameter sequential model. |
| `learn-layer?`, `learn-layer-kind`, `learn-layer-params` | Inspect layers. |
| `learn-model?`, `learn-model-layers` | Inspect models. |
| `layer-param-count`, `model-param-count` | Count flat parameters. |
| `model-zero-params`, `model-init-params` | Create deterministic parameter vectors. |
| `model-forward`, `model-predict` | Evaluate a model. |
| `model-mse-loss`, `model-binary-cross-entropy-loss` | Model-level objectives. |
| `autodiff-train-loop` | Train a compiler-resolvable objective. |

## Scientific Learning

| Function | Purpose |
| --- | --- |
| `simulator-predictions simulator params inputs` | Run a simulator over inputs. |
| `simulator-residuals simulator params inputs targets` | Compare predictions to targets. |
| `simulator-loss simulator params inputs targets` | Mean squared simulator residual loss. |
| `simulator-objective simulator inputs targets` | Return a parameter-vector objective. |
| `time-series-dataset times values ...` | Build a time-series descriptor. |
| `time-series-summary ts` | Report samples, value dimension, and time deltas. |
| `time-series-windowed-dataset ts window-size` | Build supervised windows from a series. |
| `time-series-linear-params ts` | Closed-form scalar line fit. |
| `time-series-linear-fit ts` | Estimator wrapper for scalar line fit. |
| `time-series-parameter-fit simulator initial ts ...` | Fit simulator params to a series. |
| `ode-time-series-fit rhs initial ts ...` | Fit ODE params to a time series. |
| `state-space-dataset times states ...` | Build a state-space descriptor. |
| `state-space-summary ss` | Report samples, dimension, and transitions. |
| `state-space-transition-pairs ss` | Return adjacent transitions. |
| `ode-euler-step rhs params state t dt` | One Euler integration step. |
| `ode-euler-simulate rhs params initial times` | Euler rollout over a time grid. |
| `dynamics-residual-loss rhs params states times` | Penalize mismatch with dynamics. |
| `conservation-loss invariant states ...` | Penalize invariant drift. |
| `boundary-condition-loss predicted expected` | Penalize boundary mismatch. |
| `physics-informed-loss data residual ...` | Combine data/physics/conservation losses. |
| `shape-schema`, `shape-compatible?` | Declare and validate static shapes. |
| `parameter-schema`, `validate-parameter-vector` | Declare and validate parameter vectors. |
| `model-shape-summary`, `model-parameter-schema` | Summarize native model shapes/params. |

## Experiment Registry And Benchmarks

| Function | Purpose |
| --- | --- |
| `experiment-registry name ...` | Create a registry value. |
| `registry-summary registry` | Summarize datasets, runs, lineage, backends, and benchmarks. |
| `write-registry-summary registry filename` | Write a registry JSON summary. |
| `dataset-manifest name kind summary ...` | Build a generic dataset manifest. |
| `dataset-manifest-from-dataset name ds ...` | Build a tabular dataset manifest. |
| `time-series-manifest name ts ...` | Build a time-series manifest. |
| `state-space-manifest name ss ...` | Build a state-space manifest. |
| `log-dataset-manifest run manifest` | Append manifest JSONL to a run directory. |
| `run-lineage child parents ...` | Record parent runs, dataset, backend, purpose, and tags. |
| `run-lineage-summary lineage` | Summarize lineage metadata. |
| `log-run-lineage run lineage` | Append lineage JSONL to a run directory. |
| `compiler-backend name mode ...` | Describe an AOT/JIT compiler surface. |
| `compiler-backend-mode backend` | Return `aot`, `jit`, or another declared mode. |
| `compiler-backend-summary backend` | Summarize compiler backend metadata. |
| `benchmark-case name workload ...` | Define a deterministic local workload. |
| `benchmark-suite name cases ...` | Group benchmark cases. |
| `run-benchmark-case case backend ...` | Run one case on one backend descriptor. |
| `compare-backends case backends ...` | Run one case across backend descriptors. |
| `compare-compiler-backends case backends ...` | Compiler-focused comparison wrapper. |
| `run-benchmark-suite suite backends ...` | Compare all suite cases. |
| `benchmark-report suite comparisons` | Return suite-level report metadata. |
| `backend-comparison-summary comparison` | Summarize backend outputs and consistency. |
| `log-benchmark-result run comparison-or-result` | Append benchmark JSONL to a run directory. |

Registry benchmarks compare local deterministic workload output. They record
backend identity and consistency; they do not spawn external compilers,
Moonlab, QGTL, or hardware targets.

## Experiment Runs

| Function | Purpose |
| --- | --- |
| `start-run name ...` | Create a local run directory and context. |
| `end-run ctx` | Mark a run completed. |
| `log-param ctx key value` | Append a parameter record. |
| `log-metric ctx key value ...` | Append a metric record, optionally with `':step`. |
| `log-artifact ctx name path` | Append an artifact pointer. |
| `run-summary ctx` | Return run metadata and file paths. |
| `compare-runs runs` | Summarize multiple run contexts. |
| `replay-run ctx` | Write a replay scaffold in the run directory. |
