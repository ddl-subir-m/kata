---
name: shape-request
description: Turn a vague request into a written spec and a set of small tickets. Use when an idea, a feature request or a half-formed ask arrives and nobody has written down what "done" means yet. Triggers - "shape this", "write a spec", "break this into tickets", "what should we build".
---

# Shape a request

Stage 01 of the loop. A request arrives as an idea, a ticket or an alert. You end this stage with
a spec published to the issue tracker and small tickets that declare what blocks them.

**Nobody writes the spec by hand. Nobody writes the ticket by hand.** The person decides whether
the work is worth doing and whether the draft is right. You do the writing.

## Skip this skill when the request is already unambiguous

One cause, one fix, nothing left to settle. Say so in a sentence and go straight to the edit.

Example of a request that skips shaping:

> "The retry loop logs `attempt=0` on the first try. It should log `attempt=1`."

Example of a request that does not:

> "Users are complaining that sync is slow."

The second one has no scope, no user, no number that says when it is fixed.

## Ask one question at a time

Never a numbered list of six questions. One question, wait, then the next. The answers change
which question comes next, and a batch of six forces the person to answer the wrong ones.

Cover these four, in this order:

| Area | The question behind it |
| --- | --- |
| Scope | What is in, and what is explicitly out? |
| Users | Who hits this, and what are they doing when they hit it? |
| Constraints | What cannot change? Existing data, a public API, a deadline, a budget. |
| Success | What number or observation says this is done? |

### Worked example

> **Request:** "Users are complaining that sync is slow."
>
> **Q1 (scope):** "Is this about the initial sync when a workspace connects, or the incremental
> sync that runs every few minutes?"
> **A:** "Incremental."
>
> **Q2 (users):** "Which workspaces? Everyone, or the large ones?"
> **A:** "Anything over about 50,000 rows."
>
> **Q3 (constraints):** "Can we change the sync interval, or is that fixed by the contract?"
> **A:** "The interval is fixed at 5 minutes. The work inside it can change."
>
> **Q4 (success):** "What is the current p95, and what would be acceptable?"
> **A:** "It is 4 minutes now. Under 90 seconds."
>
> Four answers. Now the spec writes itself, and the four answers are its four sections.

## Write the spec

A spec is a committed, human-readable file that the product owner corrects before it lands. It is
not a design document and it is not a plan.

    # Incremental sync stays under 90 seconds at p95
    ## Problem
    ## Scope             (in, and explicitly out)
    ## Users affected
    ## Constraints
    ## Success criteria  (the number, and how it is measured)
    ## Open questions

Publish it as a GitHub issue. See `docs/agents/issue-tracker.md` in the repo for the commands.

## Break it into tickets

Small enough that one session can finish one. Each ticket names what blocks it, using GitHub's
native issue dependencies so the block is visible in the UI:

    BLOCKER_ID=$(gh api repos/<owner>/<repo>/issues/<blocker> --jq .id)
    gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by \
      -F issue_id=$BLOCKER_ID

`issue_id` is the numeric **database id**, not the `#number` and not the `node_id`. Getting this
wrong creates no edge and reports no error.

### Worked example

From the spec above:

| # | Ticket | Blocked by |
| --- | --- | --- |
| 1 | Measure the current p95 and record it in the spec | — |
| 2 | Add a row-count index so the incremental query stops a full scan | 1 |
| 3 | Batch the write-back into 500-row chunks | 1 |
| 4 | Re-measure p95 and close the spec issue | 2, 3 |

Ticket 1 exists because a success criterion with no baseline cannot be checked. That ticket is
almost always the first one.

## Alongside, write the words down

Every word you settle on goes into `CONTEXT.md`, and every decision into `docs/adr/`, as it
settles — not weeks later. Use the `domain-modeling` skill for that. Do it in the same session:
the reason a vocabulary rots is that somebody meant to write it down later.

## Hand back

Give the person: the spec issue number, the ticket numbers in dependency order, and any question
you could not answer. Say plainly which of the four areas is still thin.
