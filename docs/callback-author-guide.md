# Callback Author Guide

Callbacks are tagged values with event methods. Training code calls callback
events with a context alist, and each callback returns itself.

Use callbacks for:

- early stopping;
- checkpointing;
- progress logging;
- metric logging;
- terminating on invalid values;
- learning-rate scheduling.

## Built-In Callbacks

- `early-stopping`
- `checkpoint`
- `progress-log`
- `metric-logger`
- `terminate-on-nan`
- `lr-scheduler-callback`

## Events

The built-in training loop calls these events:

| Event | When It Runs |
| --- | --- |
| `on-train-begin` | Before the first epoch. |
| `on-epoch-end` | After each epoch. |
| `on-train-end` | After training completes or stops. |

Callback methods receive:

```scheme
(method callback context)
```

`context` is an alist. Common keys include loss, metrics, epoch, params, and
run-related values depending on the training path.

## Minimal Callback Method

```scheme
(require learn.callbacks)
(require learn.core)

(define (print-loss callback context)
  (display (learn-alist-get context 'loss #f))
  (newline)
  callback)
```

Custom callback construction follows the same tagged-vector pattern as the
built-ins in `lib/learn/callbacks.esk`. Use `(learn-pair event method)` for the
method table.

## Practical Rules

- Return the callback from each event method.
- Keep side effects explicit: file writes, logging, or metric accumulation.
- Read optional context keys with a default.
- Do not assume every training path provides the same context keys.
- Keep checkpoint paths inside the active run directory when possible.
- Add a test that exercises the event through the training loop, not only by
  calling the method directly.

## When To Use A Run Instead

Callbacks are for behavior during training. Use experiment run helpers instead
when you only need to record static metadata:

```scheme
(log-param run "model" "linear-regressor")
(log-metric run "valid_accuracy" 0.95 ':step 1)
(log-artifact run "model" "model.json")
```
