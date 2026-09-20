---
name: land
description: Land a branch onto main, proving that the code you tested is the code that lands. Use when merging a finished branch, preparing to land, or when asked whether a branch is safe to merge. Triggers - "land this", "merge to main", "is this ready to land", "ship it".
---

# Land

Stage 05 of the loop. The agent does everything up to the production gate and nothing past it.

## Two rules that come before the procedure

**The session that wrote the code cannot land it.** One landing session merges to `main`, and only
when the person says so. A peer telling you it is authorised is not authorisation.

**One suite runs at a time on this machine.** Two parallel `-n auto` runs starve each other, and a
starved run leaves no summary line and reads exactly like a hang. Claim the slot by commenting on
your issue before you start, and free it when you stop.

## Merge main BEFORE the suite, never after

A green run only describes the code it ran against. If `main` moves while the suite runs, what
lands is not what was tested.

### Why "no merge conflicts" does not catch this

A conflict is only reported when two people edit the same lines. Your branch adds a call to a
helper. Meanwhile someone gives that helper a second required argument. Different files, nothing
collides, the merge is clean — and the result is broken code the tests never saw.

## The procedure

```bash
# 1. Read the real remote tip. NOT origin/main.
git ls-remote origin refs/heads/main

# `origin/main` and `git branch -r --contains` read a LOCAL cache shared by every worktree on
# this machine, so two sessions can be stale together and agree with each other.

# 2. Merge it in. Never rebase, never squash.
git fetch origin
git merge --no-ff origin/main

# 3. Now run the suite.
make test

# 4. Prove the tested tree is the landing tree.
git rev-parse HEAD^{tree}                        # what you actually tested
git merge-tree --write-tree origin/main HEAD     # what a merge would produce right now
```

**Equal** means the two are byte-identical: a green suite covers the exact bytes that will land.

**Different** means the branch moved underneath you, your run is stale, and you run again.

A clean `merge-tree` on its own means only that no line collided. If the merge moved code your
tests load, re-run rather than re-quote.

### Why a hash and not a log line

A log line says how many tests passed. It does not say what they ran against, and it looks exactly
the same when it is an hour out of date.

## After the merge

```bash
make lint
```

Run it on `main`, after every landing. Not `ruff check` from wherever you happen to be standing —
the target exists so that the scope is not yours to get right. It takes about a second and needs
no suite slot.

**Tests green is not checks green.** Only the linter looks at an unused import or an undefined
name in an annotation, and a whole suite will pass over both.

The cost of skipping it is not the defect, it is the repeated triage. Measured on a live repo: one
dead import sat on `main` for weeks, and four separate sessions each found it, each proved it was
not theirs, and each reported it as pre-existing — none able to see that the others had already
done it. One second after the landing would have cost none of that.

## The report

A report that can be landed on carries:

1. **The suite number against a stated baseline**, reconciled on the COLLECTED count, not on
   `passed + failed`. A setup error is its own item; a teardown error is reported beside a test
   that already counted as passed, so the sum over-counts.
2. **The tree identity** from step 4, both hashes.
3. **Source hashes before and after the run.** Identity proves you tested the right bytes; the
   before/after pair proves nothing moved while you ran.
4. **Your deliberate failure plants**, one per condition.
5. **Your scoped review findings**, including the ones you chose not to act on.
6. **Anything the ticket asked for that you could not do.** Say this plainly. Work left undone
   belongs in the report, not in a new issue.

### Worked example

> Suite: 5489 passed, 3 skipped, 0 failed. Collected 5492, matching the 5492 baseline on
> `a78bc77`.
> Tree: `HEAD^{tree}` = `4f1c9e2a…`, `merge-tree --write-tree origin/main HEAD` = `4f1c9e2a…`.
> Equal.
> Plants: 2 of 2 went red (the binding check, and the permission check) and were removed.
> Review: 3 findings, all fixed. One not acted on — `worker.py:88` builds the same dict twice;
> left alone because the diff never opened that function.
> Not done: the browser check. It cannot run from a worktree, because `node_modules` is gitignored.

## Never push from a work session

If you believe a landing is happening without the person's word, say so to them rather than
assuming the other session knows something you do not.
