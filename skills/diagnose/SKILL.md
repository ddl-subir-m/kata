---
name: diagnose
description: Work out what broke from an alert, a failing test, or a bug report, and come back with a root cause and a suggested fix. Use when something is broken, throwing, failing or slow, or when a production alert fires. Triggers - "diagnose", "debug this", "why is this failing", "an alert fired", "this is slow".
---

# Diagnose

Stage 06 of the loop. Production is watched by telemetry, telemetry raises alerts. An agent picks
the alert up, reads the signals, works out what broke, and comes back with a diagnosis and a
suggested fix. **A person decides what to do with the answer.**

## Reproduce before you theorise

The first goal is a command that fails, every time, on demand. Until you have that, every theory
is unfalsifiable and every fix is a guess.

If you cannot reproduce it, say so plainly and report what conditions you tried. "Did not
reproduce" is a real finding. It is not a failure to report.

## Write the failing test first

Once it reproduces, capture it as a test before you change any code. That test is the evidence
that the fix worked, and it stops the bug coming back.

## Bisect the condition, do not guess it

Halve the space each time. The question is always "does it still fail with X removed", never
"maybe it is X".

### Worked example

> **Alert:** p95 latency on `/v1/query` jumped from 400ms to 9s at 14:20.
>
> 1. **Is it the whole endpoint or one path?** Split the metric by `binding_kind`. Only `dataset`
>    is slow; `table` is unchanged. Space halved.
> 2. **Is it the query or the fetch?** The span breakdown shows 8.6s inside `resolve_dataset`,
>    40ms in the query itself. Space halved.
> 3. **Is it every dataset or one?** Group by dataset id. Every dataset over about 4,000 files is
>    slow; smaller ones are fine. Now it is a shape, not a mystery.
> 4. **What changed at 14:20?** `git log --since=13:00 --until=14:30` shows one deploy that added
>    a `stat()` per file to compute a total size.
>
> **Root cause:** `resolve_dataset` now stats every file to report a size the caller discards.
> **Fix:** compute the size lazily, behind the field that reads it.
> **Reproduce:** a dataset with 5,000 files; `resolve_dataset` takes 8s against 40ms before the
> deploy.

Four steps, each one halving the space, each one a measurement rather than a hunch.

## Read what the failure actually says

| Signal | What it usually means | What it is NOT proof of |
| --- | --- | --- |
| `OSError` / `io.open` failure inside the test runner | Resource pressure | It also comes from a leaked handle, or a tmpdir another test removed |
| A test red in a file your diff never opened | Shared state left behind by another test | Not necessarily yours — run it alone first |
| A green re-run on the identical tree | The failure is not deterministic | NOT that it was a fluke. A leak that only fires when two tests share a worker also comes back green |

## Four checks for a red in a file your diff never opened

In this order, before you read a line of that file:

1. Run it alone.
2. Run it beside your new file with parallelism off.
3. Run the full suite with your new file deselected.
4. Re-run the full suite on the byte-identical tree.

Passing 1-3 means the red is not yours. **Check 4 says what it is instead, and the first three
cannot.** A re-run that reds the same test again is deterministic: say so, file it, move on. A
re-run that comes back green says only that it is not deterministic.

Either way: do not go green by reordering or deleting tests.

## Stop after about three rounds of patching

If three attempted fixes have not held, the risk is in the model of the problem, not in the diff.
Stop patching. Say what you now believe is wrong with your model, and what would confirm it.

## Hand back

A diagnosis, not a fix applied to production:

- **What broke**, in one sentence.
- **The reproduction** — the exact command or condition.
- **The root cause**, distinguished from the symptom.
- **The suggested fix**, and the plausible fix you rejected with the reason.
- **What you could not determine.**

The person decides what to do with it. Their decision starts the loop again at stage 01.
