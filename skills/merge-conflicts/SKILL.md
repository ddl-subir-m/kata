---
name: merge-conflicts
description: Resolve an in-progress git merge or rebase, hunk by hunk, by intent rather than by picking lines. Use when a merge or rebase has stopped with conflicts. Triggers - "resolve the conflicts", "fix this merge", "the rebase is stuck", "CONFLICT".
---

# Resolving merge conflicts

You are here because an operation is **in progress and stopped**. Your job is to finish it.

## 1. See where you actually are

    git status
    git diff --name-only --diff-filter=U

Merge and rebase invert the meaning of the sides, and getting this backwards silently keeps the
wrong code:

| | `--ours` | `--theirs` |
| --- | --- | --- |
| **merge** | the branch you are on | the branch being merged in |
| **rebase** | the branch being replayed **onto** | your commits being replayed |

In a rebase, "ours" is the upstream. Read the table, do not trust the habit.

## 2. Never `--abort` on your own initiative

Aborting throws away the operation and any resolution already done, and it is a decision for the
person, not for you. If you believe aborting is right, **say so and stop**.

## 3. Resolve by intent, not by picking a side

For each conflicting hunk, find out what each side was **trying to do** before deciding what the
merged code should say.

    git log --oneline -3 <side>            # what was that branch doing
    git log -p -1 <sha> -- <path>          # the change, with its message

Then write the code that satisfies both intents. Often that is neither side verbatim.

> Their side renamed `attach_table` to `create_binding`. Your side added a second caller of
> `attach_table`. Taking either side gives you broken code: one loses the rename, the other loses
> the caller. The resolution is your new caller, calling the new name.

**Taking a side wholesale is the failure mode here.** It compiles, it looks resolved, and it
silently drops one side's work.

## 4. Watch for the conflicts git does not report

A conflict is only raised when two sides touch the same lines. The dangerous case is a clean merge
that is still broken:

> They gave a helper a second required argument. You added a call to it, in another file. Nothing
> collides, the merge is clean, and the result does not run.

After resolving, **build and run the tests**, not just the conflicted files. A clean `git status`
is not evidence.

## 5. Finish the operation

    git add <resolved paths>
    git merge --continue     # or: git rebase --continue

Leaving the repo mid-merge is worse than either outcome, because the next session cannot tell a
paused operation from a broken one.

## 6. Report

- Which files conflicted, and how many hunks.
- For each non-obvious resolution, **what the two intents were** and what you wrote instead.
- Whether the tests ran, and what they said.
- Anything you resolved with low confidence. Name it rather than hoping.
