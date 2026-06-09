# Estimator Author Guide

Estimators are tagged vectors with method tables. You create them with
`learn-make-estimator` from `learn.core`, then the public protocol functions
call the methods by name.

Use this guide when you want a custom value to work with:

```scheme
(fit estimator x y)
(predict estimator x)
(score estimator x y)
(params estimator)
```

## Estimator Shape

An estimator has:

- a kind symbol;
- a method alist;
- a parameter alist;
- a state value;
- a fitted flag.

Alists should use `(learn-pair key value)`, not dotted pairs.

```scheme
(require learn.core)
(require learn.protocols)
(require learn.metrics)

(define my-estimator
  (learn-make-estimator
   'my-estimator
   methods
   (list (learn-pair ':answer 42))
   '()))
```

## Method Signatures

Each method receives the estimator first.

| Method | Signature |
| --- | --- |
| `fit` | `(method estimator x y opts)` |
| `predict` | `(method estimator x opts)` |
| `predict-proba` | `(method estimator x opts)` |
| `transform` | `(method estimator x opts)` |
| `score` | `(method estimator x y opts)` |

`opts` is the flat option list passed to the public protocol call.

## Minimal Predictor

```scheme
(require learn.core)
(require learn.protocols)

(define (constant-fit estimator x y opts)
  (let ((label (if (null? y) 0 (car y))))
    (learn-set-estimator-state!
     estimator
     (list (learn-pair 'label label)))
    (learn-set-estimator-fitted! estimator #t)
    estimator))

(define (constant-predict estimator x opts)
  (let ((label (learn-alist-get (learn-estimator-state estimator)
                                'label
                                0)))
    (map (lambda (row) label) x)))

(define (constant-score estimator x y opts)
  (accuracy y (constant-predict estimator x opts)))

(define constant-classifier
  (learn-make-estimator
   'constant-classifier
   (list (learn-pair 'fit constant-fit)
         (learn-pair 'predict constant-predict)
         (learn-pair 'score constant-score))
   (list (learn-pair ':strategy 'first-label))
   '()))
```

If your guide or test uses metrics such as `accuracy`, require `learn` or
`learn.metrics` as appropriate.

## Parameters

Use quoted colon symbols for user-configurable parameters:

```scheme
(list (learn-pair ':lr 0.01)
      (learn-pair ':epochs 200)
      (learn-pair ':seed 42))
```

Read with:

```scheme
(learn-alist-get (learn-estimator-params estimator) ':lr 0.01)
```

Merge updates with the public protocol:

```scheme
(set-params estimator (list (learn-pair ':lr 0.05)))
```

## State

State should contain fitted values: coefficients, centering statistics, label
maps, learned centroids, or other runtime values. Keep it inspectable with
plain lists, vectors, numbers, strings, booleans, and symbols whenever possible.

Procedure-valued state cannot be serialized by `save-estimator`.

## Persistence

Built-in estimators register loader functions so `load-estimator` can reattach
methods. Custom estimators can still be saved as manifests, but procedure
methods are not serialized.

For a custom estimator, keep:

- source file defining methods;
- saved estimator manifest;
- run params and metrics;
- dataset manifest or source path.

## Design Guidelines

- Validate shapes before fitting when possible.
- Keep parameter names stable.
- Return the estimator from mutating methods.
- Store learned values in state, not in params.
- Prefer deterministic seeds for any randomized behavior.
- Add a small test proving `fit`, `predict`, and `score` work through the
  public protocol.
