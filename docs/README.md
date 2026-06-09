# Documentation

Use this directory as the project manual for `eshkol.learn`.

## Start Here

- [10-minute tutorial](10-minute-tutorial.md): run the package, fit a small
  model, load CSV data, record a run, and create a scientific benchmark record.
- [API reference](api-reference.md): public `(require learn)` functions grouped
  by task.
- [Ecosystem integration](ecosystem-integration.md): how `learn` composes
  Eshkol core modules, scientific helpers, QGTL-facing primitives, and registry
  artifacts.

## Reproducibility And Extension

- [Reproducibility guide](reproducibility-guide.md): seeds, run directories,
  estimator manifests, native-autodiff notes, scientific schemas, and registry
  evidence.
- [Estimator author guide](estimator-author-guide.md): how custom estimators
  plug into `fit`, `predict`, `score`, and persistence conventions.
- [Callback author guide](callback-author-guide.md): training callback events,
  method signatures, and practical rules.

## Ecosystem Thesis

- [Tsotchke thesis and QGTL support](tsotchke-thesis-support.md): what the
  QGTL/Selene/Moonlab connection means in this library, and what remains an
  external integration.

## Verification

From the package root:

```sh
scripts/run_tests.sh
scripts/run_examples.sh
scripts/run_parity_tests.sh
```

Set `ESHKOL_ROOT=/path/to/eshkol` if the compiler checkout is not available at
`../eshkol` relative to the package root.
