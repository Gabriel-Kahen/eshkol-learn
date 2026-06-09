# Tsotchke Thesis And QGTL Support

This page explains how `eshkol.learn` relates to the Tsotchke ecosystem thesis:
QGTL supplies geometric mathematics, Eshkol supplies programmable
quantum-classical and differentiable workflows, Selene uses geometric
intelligence, Moonlab validates simulator behavior, and future hardware can be
described as a backend target.

`eshkol.learn` does not implement QGTL. It provides the local learning-layer
infrastructure that a real QGTL/Selene/Moonlab integration would need.

## Mapping

| Thesis Need | `eshkol.learn` Support |
| --- | --- |
| Geometric data assumptions | Euclidean, spherical, hyperbolic, and mixed-curvature spaces. |
| Geometry-aware diagnostics | `geometry-summary`, `mixed-geometry-summary`, distance matrices, regularization. |
| Manifold-constrained optimization | `riemannian-project`, `riemannian-gradient`, `riemannian-step`, `riemannian-sgd-optimizer`. |
| Quantum-inspired selection | Born-style probabilities, deterministic sampling, and expectations over real amplitudes. |
| Backend capability contracts | Classical, simulator, quantum, and compiler backend descriptors. |
| Scientific simulator workflows | Time-series/state-space data, ODE rollouts, simulator losses, physics-informed losses. |
| Replayable thesis evidence | Dataset manifests, run lineage, benchmark comparisons, and registry summaries. |

## Geometry

QGTL-facing work needs embeddings to carry geometry. A plain vector does not
say whether distance should be Euclidean, spherical, hyperbolic, or mixed.
`learn.geometry` makes that explicit:

```scheme
(define hierarchy (hyperbolic-space 2))
(define concept-ring (spherical-space 2))
(define local-features (euclidean-space 1))

(define layout (list hierarchy concept-ring local-features))

(mixed-geometry-distance layout
                         '(0.05 0.10 1.0 0.0 0.25)
                         '(0.20 0.10 0.0 1.0 0.75))
```

Use hyperbolic spaces for hierarchy-like embeddings, spherical spaces for
normalized/cyclic concept structure, and Euclidean spaces for ordinary local
features.

## Manifold Training

Geometry-aware training needs updates that do not immediately leave the
declared space. `learn.manifold` provides projected steps:

```scheme
(define space (spherical-space 2))

(riemannian-step space
                 (vector 1.0 0.0)
                 (vector 0.5 -1.0)
                 0.1)
```

`riemannian-sgd-optimizer` and `riemannian-train-loop` apply this pattern to
vector objectives. This is a local optimization helper, not a QGTL solver.

## Born-Style Sampling

`learn.sampling` converts real amplitudes into deterministic probability and
selection workflows:

```scheme
(born-probabilities '(1.0 2.0 0.5))
(born-sample '(1.0 2.0 0.5)
             ':values '(hierarchy cluster local)
             ':seed 1)
```

This is quantum-inspired selection. It is not quantum state execution.

## Backend Descriptors

Backend descriptors let a workflow name the capabilities it expects:

```scheme
(define backend
  (simulator-learn-backend
   'moonlab-prototype
   ':capabilities '(simulator scientific-learning qgtl-prototype)))

(learn-backend-supports? backend 'qgtl-prototype)
```

Handlers can be attached for local dispatch, but no remote backend is launched
unless a caller supplies such a handler.

## Scientific Registry Pattern

Thesis-aligned workflows need evidence, not just output. `learn.registry`
records what was run:

```scheme
(define manifest
  (time-series-manifest
   'linear-simulator-series
   ts
   ':tags '(scientific-learning qgtl selene moonlab)))

(define lineage
  (run-lineage "tsotchke-demo"
               '("linear-simulator-baseline")
               ':dataset 'linear-simulator-series
               ':backend 'aot
               ':purpose 'compiler-backend-parity
               ':tags '(eshkol-native tsotchke-thesis)))
```

Backend comparisons record declared backend identity and deterministic local
workload output:

```scheme
(compare-backends slope-case
                  (list (compiler-backend 'aot 'aot)
                        (compiler-backend 'jit 'jit)
                        (simulator-learn-backend
                         'moonlab-prototype
                         ':capabilities '(simulator qgtl-prototype))))
```

The result can be stored in `benchmarks.jsonl` and summarized in
`registry-summary.json`.

## Examples

- `examples/learn_geometric_embeddings.esk`: geometry spaces, diagnostics, and
  mixed-curvature distances.
- `examples/learn_qgtl_selene_training.esk`: Riemannian optimization,
  Born-style sampling, and a `qgtl-prototype` backend descriptor.
- `examples/learn_scientific_learning_pack.esk`: simulator/time-series/ODE
  helpers for scientific workflows.
- `examples/learn_scientific_registry_benchmark.esk`: dataset manifests,
  lineage, backend comparison, and registry output.

## Honest Boundary

`eshkol.learn` is QGTL-ready plumbing. It does not provide:

- QGTL syntax or theorem/geometry engines;
- quantum execution;
- Moonlab simulator execution;
- Neo-Millennium hardware integration;
- remote benchmark orchestration.

What it does provide is valuable: geometry-aware data representation,
manifold-aware updates, quantum-inspired sampling, backend capability records,
and reproducible run artifacts. Those are the stable interfaces a future
external QGTL integration can use.
