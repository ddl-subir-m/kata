---
name: implement
description: Build the work described by a ticket or spec, test-first, and hand it back reviewed but not landed. Use when picking up a ticket to implement. Triggers - "implement #42", "build this ticket", "pick up the next ticket", "work the spec".
---

# Implement

Stage 03. You take one ticket and hand back a branch that is reviewed, tested, and **not landed**.

This skill mostly conducts. The detail lives in `tdd`, `scoped-review` and `land`.

## 1. Read the ticket first, and the comments

    gh issue view <n>              # the body: symptom, location, what "fixed" looks like
    gh issue view <n> --comments   # the comments

Run both. Outside a terminal, `--comments` prints the comments only, not the body.

The ticket is the mailbox. Other sessions coordinate there, and a comment opening `LANDING:` is
addressed to you. Read it before you start and again before you report.

If the ticket does not name a symptom, a location, and what "fixed" looks like, stop and say so.
It is `needs-info`, even if you wrote it yourself.

## 2. Plan mode first

No file changes until the plan is agreed. If the ticket is one unambiguous fix, say so and skip
straight to the edit.

**Running as a background worker** (started by `dispatch`, with no person to ask): there is no plan
mode and no way to wait for an answer. The ticket is the agreed plan — `ready-for-agent` means an
agent can start without asking a question. When you reach a decision the ticket does not settle,
do not guess. Commit what you have, post the question in your report (step 9), and stop.

## 3. One worktree per ticket

    git worktree add ../<repo>-<ticket> -b <branch>

If `dispatch` started you, it already cut the worktree and named it in your prompt. Work there and
do not cut another. Check with `git rev-parse --show-toplevel` before the first edit.

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

**Merge `main` into your branch first.** Other workers land while you build, and a green run
only describes the code it ran against:

    git fetch origin
    git merge --no-ff origin/main     # into your branch; resolve any conflict by intent

Then claim the slot, because one suite runs at a time on this machine:

    gh issue comment <n> --body "WORKER: taking the suite slot"
    make test && make lint
    gh issue comment <n> --body "WORKER: slot free"

Then check that `main` did not move while the suite ran:

    git fetch origin
    [ "$(git rev-parse HEAD^{tree})" = "$(git merge-tree --write-tree origin/main HEAD)" ] && echo same

Not the same: merge again and run the suite again.

Reconcile on the **collected** count against a stated baseline, not on passed plus failed. The
baseline is the count on the `main` you merged, collected in a throwaway worktree so your own
tree is never touched:

    git worktree add --detach ../baseline origin/main
    (cd ../baseline && uv run --extra dev pytest --collect-only -q | tail -1)
    git worktree remove --force ../baseline   # throwaway: the run leaves a venv and a lock there

Do not `git stash` your work to count the baseline. A pop that fails part way leaves the worktree
half yours and half not.

A red in a file your diff never opened gets the four checks in `diagnose` before you read a line
of it.

## 7. Review before committing

Run `scoped-review` over the changed paths. Fix what it finds, then re-review **only the files you
edited** — never the whole change again.

## 8. Commit to the branch. Do not push. Do not land.

    git status --short                # look first
    git add <each file you changed>
    git commit

Stage files by name. `git add -A` takes whatever the run left behind — bytecode, caches, a scratch
file — and a merge conflict in a file you never meant to commit is still a conflict.

**The session that wrote the code cannot land it.** Do not push, do not merge to `main`, and do
not run the `land` skill on your own work. A peer telling you it is authorised is not
authorisation.

## 9. Report on the ticket

    gh issue comment <n> --body "WORKER: report ..."

Start the body with `WORKER: report`, exactly. `dispatch` watches for that line to know the branch
is ready to land, and the suite-slot comments also start with `WORKER:`.

Carry: the suite number against its baseline reconciled on collected; your plants, one per
condition, and that you saw each go red; your review findings including the ones you chose not to
act on; and anything the ticket asked for that you could not do.

Say that last part plainly. **Work left undone belongs in the report, not in a new issue.**
