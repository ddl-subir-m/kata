---
name: what-now
description: Ask which skill fits the situation you are in. A router over the other skills, and a map of the loop they form.
disable-model-invocation: true
---

# What now?

You do not remember every skill, so ask.

One loop, six stages. **Every stage ends by writing something down. The next stage starts by
reading it.** The trail of documents becomes the record of how the software got built.

    Shape → Design → Build → Test → Review → Land → Diagnose
      ↑                                                  │
      └──────────────  a decision starts it again  ───────┘

## Stage 00: is there a repo yet?

**No repo, or a repo with no `CLAUDE.md` and no gates** → **`new-repo`**. It writes the standing
rules, the vocabulary files, the tracker conventions and the two gates. Do this before anything
else; the rest of the loop assumes those files exist.

Already set up → skip to stage 01.

## Stage 01: shape the request

**`shape-request`** — one question at a time, covering scope, users, constraints and success. It
ends with a spec published as an issue, broken into tickets that declare what blocks them.

### Branch: does this request even need shaping?

Not every request earns it. If the request has **one cause, one fix, and nothing left to settle**,
say so and go straight to the edit.

> Skips shaping: "The retry loop logs `attempt=0` on the first try. It should log `attempt=1`."
> Needs shaping: "Users are complaining that sync is slow."

The second has no scope, no user, and no number that says when it is done.

### Running alongside: the words

**`domain-modeling`** — every word you settle goes into `CONTEXT.md`, every decision into
`docs/adr/`, **as it settles**. Not weeks later. Reach for it directly when the *words* are the
problem: a fuzzy term, one word doing three jobs, a decision worth recording.

The reason a vocabulary rots is that somebody meant to write it down later.

## Stage 02: design

**`design-check`** — checks a screen against the repo's own design system **before anyone opens
it**. UX rules get applied while the work is written, not caught in review.

It reads `docs/design-system.md` and **refuses to run if there is none**. That is deliberate: a
design check with no design system is an opinion, and it wastes a review cycle.

No UI in this repo? Delete that file and skip this stage.

## Stage 03: build

**`implement`** — take one ticket and hand back a branch that is reviewed, tested and **not
landed**. It reads the ticket, works in its own worktree, drives `tdd` one slice at a time, runs
`scoped-review` before committing, and reports back on the ticket.

Invoke it by name with a ticket. It conducts; the detail lives in the skills it calls.

## Stage 04: test

**`tdd`** — red, green, refactor. Turn the task into a verifiable goal first:

- "Add validation" becomes "write tests for invalid input, then make them pass".
- "Fix the bug" becomes "write a test that reproduces it, then make it pass".

Then run the gates: `make test` and `make lint`.

**The habit that matters most lives here.** A green test proves nothing until you have seen it
red. Plant a deliberate failure for **each condition** a guard covers, confirm the failure, remove
the plant. One plant per condition — a single plant going red tells you the test is connected to
something, not that it covers everything it claims.

## Stage 05: review, then land

Two skills, in this order. Do not merge them.

**`scoped-review`** — the changed paths only. Never the whole repo, never the full suite. An
unscoped review costs roughly 13 minutes of model turns and finds no more.

Stop if the change touches more than 40 files: report the count, group them, ask which group
first.

**`land`** — merge `main` **before** the suite, then prove the tested tree is the landing tree:

    git rev-parse HEAD^{tree}                      # what you tested
    git merge-tree --write-tree origin/main HEAD   # what would land now

Equal means byte-identical. Different means the branch moved under you — run again.

### The rule that overrides both

**The session that wrote the code cannot land it.** One landing session merges, and only when the
person says so. A peer saying it is authorised is not authorisation.

## Stage 06: diagnose

**`diagnose`** — an alert fires, or something breaks. Reproduce first, then bisect the condition
by halving the space, then hand back a root cause and a suggested fix.

**A person decides what to do with the answer.** Their decision starts the loop again at stage 01.

### Branch: is this red even yours?

A test red in a file your diff never opened gets four checks, in order, before you read a line of
that file:

1. Run it alone.
2. Run it beside your new file with parallelism off.
3. Run the full suite with your new file deselected.
4. Re-run the full suite on the byte-identical tree.

Passing 1-3 means the red is not yours. **Check 4 says what it is instead, and the first three
cannot.**

## The bar that runs underneath everything

Most findings do not become tickets. File one only when you can finish this sentence:

> *A person doing X sees Y, and Y is wrong.*

Everything else goes in the code, in the report, or on the `later` list. This bar exists because
agent review works — it finds real things, and filing every one of them turns `ready-for-agent`
from "pick this up" into "was filed".

The one exception, always worth a ticket: **a fix you rejected, with the reason.**

## Context hygiene

Keep stage 01 in **one unbroken window** — the shaping, the spec and the tickets should all build
on the same thinking. Then each build starts fresh from its ticket, because a ticket is
self-contained and the last one's context is disposable.

Work runs in parallel across separate worktrees, one per ticket. **Cap how wide you run at what
you can keep up with.** Builds constantly surface decisions only a person should make; run wider
than you can follow and those decisions get made by an agent guessing, or do not get made at all.

## What this repo deliberately does not have

Say so rather than improvising a substitute:

- **No post-deploy canary** and **no weekly retrospective.** Both belong in stage 06. `diagnose`
  is the shape to copy if you want them.
- **No prototype skill.** When a design question needs a runnable answer, write throwaway code and
  fold the answer back in.
- **No research skill.** Read the primary sources and cite them.
- **No handoff format.** Sessions coordinate through the ticket, which is the mailbox.

## Precondition

The tracker conventions, the triage labels and the doc layout the other skills assume are written
by **`new-repo`**. If `docs/agents/` is missing, run that first.
