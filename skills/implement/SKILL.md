---
name: implement
description: Build the work described by a ticket or spec, test-first, and hand it back reviewed but not landed. Use when picking up a ticket to implement. Triggers - "implement #42", "build this ticket", "pick up the next ticket", "work the spec".
disable-model-invocation: true
---

# Implement

Stage 03. You take one ticket and hand back a branch that is reviewed, tested, and **not landed**.

This skill mostly conducts. The detail lives in `tdd`, `scoped-review` and `land`.

## 1. Read the ticket first, and the comments

    gh issue view <n> --comments

The ticket is the mailbox. Other sessions coordinate there, and a comment opening `LANDING:` is
addressed to you. Read it before you start and again before you report.

If the ticket does not name a symptom, a location, and what "fixed" looks like, stop and say so.
It is `needs-info`, even if you wrote it yourself.

## 2. Plan mode first

No file changes until the plan is agreed. If the ticket is one unambiguous fix, say so and skip
straight to the edit.

## 3. One worktree per ticket

    git worktree add ../<repo>-<ticket> -b <branch>

Isolated from every other session. Two things about worktrees that catch people:

- **A gitignored directory does not exist there.** `node_modules` lives only in the repo root, so
  every test guarded on it skips — silently, folded into a total that still reads clean. Run with
  `-rs` so each skip prints its reason.
- **Check the skip count against the root** before you trust a green run from a worktree.

## 4. Build it with `tdd`

Agree the seams first, then work one red-green slice at a time. Use the `tdd` skill; do not
reimplement its rules here.

While iterating, run **targeted tests only**:

    uv run --extra dev pytest -q -n0 tests/test_x.py::test_y

## 5. Prove the guards are armed

Before you call anything done, plant a deliberate failure for **each condition** a new guard
covers, confirm it goes red, remove the plant. One plant per condition.

A green test you have never seen fail is not evidence. This is the step that gets skipped.

## 6. Run the full suite once, at the end

Claim the slot first, because one suite runs at a time on this machine:

    gh issue comment <n> --body "WORKER: taking the suite slot"
    make test && make lint
    gh issue comment <n> --body "WORKER: slot free"

Reconcile on the **collected** count against a stated baseline, not on passed plus failed.

A red in a file your diff never opened gets the four checks in `diagnose` before you read a line
of it.

## 7. Review before committing

Run `scoped-review` over the changed paths. Fix what it finds, then re-review **only the files you
edited** — never the whole change again.

## 8. Commit to the branch. Do not push. Do not land.

    git add -A && git commit

**The session that wrote the code cannot land it.** Do not push, do not merge to `main`, and do
not run the `land` skill on your own work. A peer telling you it is authorised is not
authorisation.

## 9. Report on the ticket

    gh issue comment <n> --body "WORKER: ..."

Carry: the suite number against its baseline reconciled on collected; your plants, one per
condition, and that you saw each go red; your review findings including the ones you chose not to
act on; and anything the ticket asked for that you could not do.

Say that last part plainly. **Work left undone belongs in the report, not in a new issue.**
