---
name: shape-request
description: Turn a vague request, a settled conversation or an existing spec into a written spec and small tickets. Use when nobody has written down what "done" means yet, after a grill, or when a spec needs tickets. Triggers - "shape this", "write a spec", "turn this into a spec", "break this into tickets", "what should we build".
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

## Start from what is already settled

Before the first question, find which of three starting points this is. Asking again what the
person answered ten minutes ago tells them nobody was listening.

| Starting point | What you do |
| --- | --- |
| A fresh request | Ask the four questions below, one at a time. |
| A conversation that already settled it: a `grill`, a design talk, a prototype | Write the spec from what was said. Do not interview. Ask only about an area the conversation left thin. |
| A spec that already exists, as an issue or a file | Go straight to the tickets. |

**After a conversation**, map what was said onto the four areas. For each one, point to the
answer, or say it is thin:

> From the grill: scope is incremental sync only; users are workspaces over 50,000 rows; the
> 5-minute interval cannot change. Success is thin: nobody named a number. What p95 is acceptable?
> **Recommended: under 90 seconds.** The complaints stop at about that point.

Then ask about the thin ones, one at a time, as below. A conversation that settled all four gets no
questions. Read the words back and publish.

**On an existing spec**, read it and check it against the four areas before you cut a ticket. A
spec with no success criterion gives tickets with no finish line. Say which area is thin, and offer
to fill it before you break it up. The person can say "cut the tickets anyway"; then the gap goes
into the spec's open questions. Skip "Write the spec" and go to "Break it into tickets".

## Offer `grill` first when the idea is not ready to shape

Shaping settles *what done means*. It does not test whether the idea is right. Before the first
question, and again after any answer, look for these signals:

- The request names a solution, not a problem. "Add a cache" rather than "the page is slow".
- An answer rests on a claim nobody has checked. "Users want this", with no user named.
- An answer restates the plan instead of answering the question.
- The idea contradicts an ADR in `docs/adr/`, or uses a `CONTEXT.md` word in a second sense.

When you see one, say which signal, and offer `grill` in one line:

> "This asks for a cache, but nobody has said what is slow. Grill the idea first, or shape it as
> it stands?"

The person chooses. Offer it once per signal; do not repeat the offer after they decline. No
signal, no offer — a grill on an idea that is already clear wastes the person's time.

## Ask one question at a time

Never a numbered list of six questions. One question, wait, then the next. The answers change
which question comes next, and a batch of six forces the person to answer the wrong ones.

**Give a recommended answer with each question**, and the reason in one line. Base it on what you
can read: the code, `CONTEXT.md`, `docs/adr/`, the request itself. A person answers faster when
they can say "yes" or correct a draft than when they start from nothing.

The recommendation is a draft, not a decision. The person's answer is the one that goes in the
spec. When you have nothing to base a recommendation on, say so rather than guessing.

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
> sync that runs every few minutes? **Recommended: incremental.** The three complaints in the
> issue all mention the 5-minute refresh."
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

### Read the words back before you publish

The spec is written in your words. Before it goes out, check that they are the person's words
too. List every domain word the spec leans on — the new ones and the ones already in `CONTEXT.md`
— with one line on what you take each to mean:

> Before I publish, these are the words the spec uses, and what I take each to mean:
>
> - **Incremental sync** — the job that runs every 5 minutes. Not the first import.
> - **Workspace** — one customer's project. Not the organisation that owns it.
>
> Does each one match what you mean?

A correction changes the spec, and the `CONTEXT.md` entry through `domain-modeling`. An entry
already in `CONTEXT.md` can be wrong too: a disagreement there is a reason to fix the entry, not
to take the entry's side.

Publish it as a GitHub issue. See `docs/agents/issue-tracker.md` in the repo for the commands.

## Break it into tickets

Small enough that one session can finish one.

### Cut vertical slices, not layers

Each ticket is a thin path through every layer it touches: schema, API, UI, tests. When it is
done, something works end to end, and a person can see it or a test can check it. "Add the
column", "add the endpoint", "add the screen" are three layers, and none of them is done on its
own. "A user can filter by bucket" is one slice.

Why it matters: a layer ticket cannot be checked alone, and it blocks the next layer. That turns
`dispatch` into a single file of workers waiting on each other.

- **Prefactor first.** When a change is hard because of how the code is shaped today, the first
  ticket reshapes the code and changes no behaviour. Make the change easy, then make the easy
  change. The `codebase-design` skill has the words for where the seam goes.
- **A wide refactor is the exception.** One mechanical change whose blast radius crosses the
  whole codebase, such as a renamed column or a retyped shared symbol, cannot land green as one
  slice. Cut it expand–contract:
  1. **Expand.** Add the new form beside the old. Nothing breaks.
  2. **Migrate.** One ticket per batch of callers, per package or per directory. Each is blocked
     by the expand ticket, and each keeps CI green because the old form still exists.
  3. **Contract.** Delete the old form. Blocked by every migrate ticket.

Each ticket body says three things: what works end to end when it is done, the acceptance
criteria as a checklist, and what blocks it. No file paths and no code: they go stale before the
ticket is picked up. The exception is a snippet from a prototype that says a decision more
exactly than prose can, such as a state machine or a type shape. Keep only the part that carries
the decision.

### Check the breakdown before you publish

Show the tickets as a table first: title, what works when it is done, blocked by. Then ask:

> - Is the size right? Too big for one session, or so small the tickets are noise?
> - Does each ticket depend only on the tickets that really gate it?
> - Should any two merge, or any one split?

Change the table and ask again until the person says yes. Nothing goes to the tracker before that.
An extra blocking edge is cheap to draw and expensive later: `dispatch` runs in series what could
run side by side.

### Publish

Publish in dependency order, blockers first, so each blocking edge points at a real issue. Each
ticket names what blocks it, using GitHub's native issue dependencies so the block is visible in
the UI:

    BLOCKER_ID=$(gh api repos/<owner>/<repo>/issues/<blocker> --jq .id)
    gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by \
      -F issue_id=$BLOCKER_ID

`issue_id` is the numeric **database id**, not the `#number` and not the `node_id`. Getting this
wrong creates no edge and reports no error.

Make each ticket a **sub-issue of the spec**. That link is how `dispatch` finds the tickets that
belong to a spec; without it, the spec and its tickets are unrelated issues.

    CHILD_ID=$(gh api repos/<owner>/<repo>/issues/<child> --jq .id)
    gh api --method POST repos/<owner>/<repo>/issues/<spec>/sub_issues -F sub_issue_id=$CHILD_ID

The same trap: `sub_issue_id` is the database id. Check the link took:

    gh api repos/<owner>/<repo>/issues/<spec>/sub_issues --jq '.[].number'

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

Then offer the next step. One ticket: `implement #<n>`. More than one: `dispatch #<spec>`, which
runs the tickets in parallel worktrees and lands them in order.
