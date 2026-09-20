---
name: scoped-review
description: Code review scoped to the changed paths only, with no full test-suite run. Use before landing a change, when reviewing a branch or PR, or when asked to review work in progress. Triggers - "review this", "review the branch", "review before I land", "scoped review".
---

# Scoped review

Stage 05 of the loop. Review only what changed. A whole-repo review costs roughly 13 minutes of
model turns and finds no more than a scoped one.

## 1. Collect the changed paths first

    git diff --name-only $(git merge-base HEAD origin/main)...HEAD
    git ls-files --others --exclude-standard

If you cannot name the changed paths, stop and ask. A review with no scope is the most expensive
mistake available here.

## 2. Stop if the change is too large

More than 40 files: do not start. Report the count, group the files by area, and ask which group
to review first.

> "This branch touches 63 files. They group as: the sync worker (31), the migration (18), tests
> (14). Which group first?"

## 3. Never run the full test suite

Do not run `pytest` over the whole project. Do not run `-n auto` over the whole project. Run only
the tests that cover the changed files. If you cannot tell which those are, say so and ask.

A green full suite is the commit's job, not the review's.

## 4. What to look for

In this order. Stop at the first category that produces findings worth reporting.

| Category | The question |
| --- | --- |
| Correctness | Given what inputs does this produce the wrong output or crash? |
| Composition | Each step is correct — is the composition a no-op? |
| Dead paths | Does this repair a branch nothing reaches, shipping unrun code? |
| Reuse | Does a helper for this already exist three files away? |
| Simplification | Would a senior engineer call this overcomplicated? |

### Every finding needs a failure scenario

A finding without concrete inputs is an opinion. Report the shape:

> **`sync/worker.py:214` — the retry loop never terminates on a malformed token.**
> `refresh()` returns `None` for a token that parses but has no `exp` claim. The loop treats
> `None` as "retry", so a workspace with a malformed token retries every 200ms forever and the
> log fills with identical lines.
> **Reproduce:** a token whose payload is `{"sub": "u1"}` with no `exp`.
> **Fix:** treat a `None` return as terminal and raise `TokenInvalid`.

Compare with a finding that will be ignored:

> The retry logic could be more robust.

## 5. Re-review only what you touched

After you fix findings, do NOT re-run the review over the whole change. Run it again on the files
you edited, on those files only. Repeating the full review is the most expensive mistake in this
skill.

## 6. The bar for filing a ticket

Most findings do not become tickets. File one only when you can finish this sentence:
*a person doing X sees Y, and Y is wrong.*

| Finding | Where it goes |
| --- | --- |
| A limit you decided to accept | A comment in the code, with the condition that would retire it |
| A fact the code does not state | A comment on the line that surprised you |
| A latent fault with no reachable path | A comment naming what would make it reachable |
| Work you did not do | The report you hand back, not the tracker |
| A fix you rejected, with the reason | **Always a ticket.** Highest-value paragraph you can write |

## 7. Report

Findings first, most severe first. Then, plainly:

- which paths you reviewed,
- which tests you ran,
- what you skipped, and why.

Work left undone belongs in the report, not in a new issue.
