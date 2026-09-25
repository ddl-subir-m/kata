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

**No repo, or a repo missing any of the rules, docs or gates** → **`setup-repo`**. It writes the
standing rules, the vocabulary files, the tracker conventions and the two gates. Do this before
anything else; the rest of the loop assumes those files exist.

It is not only for empty directories. It never overwrites, so on a repo with years of history it
fills the gaps and leaves everything else alone. The one it cannot fill is `CLAUDE.md`: a live repo
has its own, so the standing rules land beside it in `CLAUDE.kata.md` and the merge is a person's
call.

Everything already in place → skip to stage 01.

## Before stage 01: is it in the tracker?

**`triage`** when the request arrived as an issue, when the inbox has piled up, or when you are
asked what to pick up next. It gives every open item a label it earns, and it verifies a ticket's
premise still holds before marking it `ready-for-agent` — the code has moved since somebody wrote
that assertion down.

It does not implement anything. A triage pass that starts fixing is one fix and a full inbox.

An issue that comes out `ready-for-agent` goes straight to stage 03. One that is still a vague
idea goes to stage 01 below.

## Stage 01: shape the request

**`shape-request`** — one question at a time, covering scope, users, constraints and success,
then the approach: where it runs, the seams, the riskiest unknown. Tickets come last.

**`grill`** when the idea is not ready to be shaped yet. It stress-tests the thinking: works the
frontier, names the weakest point, and never chooses for you. Reach for it when something sounds
right but nobody has pushed on it.

**`research`** when the blocker is a fact rather than a decision. It reads the primary sources and
leaves a cited Markdown file in the repo. A search snippet is not a source. It
ends with a spec published as an issue, broken into tickets that declare what blocks them.

**`wayfinder`** when the work is too big for one spec: weeks of it, with decisions that wait on
other decisions. It charts a map issue with one decision ticket per sub-issue, then resolves one
ticket per session until the way is clear. The map ends in `shape-request`, once per part that can
land alone. Ask for it by name. One spec's worth of work does not need a map.

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

**`codebase-design`** for the shape of a module: depth, seams, what to hide, where a test can
observe behaviour without mocks. Reach for it when the argument is about interfaces.

**`improve-codebase-architecture`** when nobody has a design question yet, but the code is hard
to change. It finds shallow modules in the files that change most, shows the best candidates as a
visual report, and grills the one you pick. The candidate that settles goes to `shape-request`.
Ask for it by name.

**`prototype`** when a design question needs a **runnable** answer rather than an argument. Name
the question in one sentence first; a prototype that answers no question is unreviewed code.

**`design-check`** — checks a screen against the repo's own design system **before anyone opens
it**. UX rules get applied while the work is written, not caught in review.

It looks for a design system in three places and stops at the first it finds:
`docs/design-system.md`, a file named in `CLAUDE.md`, then any `~/.claude/rules/*design*.md`.
**If it finds none, it refuses to run.** That is deliberate: a design check with no design system
is an opinion, and it wastes a review cycle.

The last place is on one person's machine. Put the file in `docs/` when teammates need the same
check.

No UI in this repo? Delete `docs/design-system.md` and skip this stage.

## Stage 03: build

**`implement`** — take one ticket and hand back a branch that is reviewed, tested and **not
landed**. It reads the ticket, works in its own worktree, drives `tdd` one slice at a time, runs
`scoped-review` before committing, and reports back on the ticket.

Invoke it by name with a ticket. It conducts; the detail lives in the skills it calls.

**`dispatch`** — when more than one ticket is ready. Give it a spec or a list of tickets. It puts
them in waves by what blocks what, cuts one worktree per ticket, starts a worker in each (prompts
you paste, or background agents), then **becomes the landing session** and lands each branch as
its report comes in. It writes no product code, which is why it is allowed to land.

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

**`merge-conflicts`** if the merge stops. Resolve by intent, hunk by hunk, never by taking a side
wholesale. Never `--abort` on your own initiative.

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

Applying that bar to a tracker that already piled up is **`triage`**.

## Context hygiene

Keep stage 01 in **one unbroken window** — the shaping, the spec and the tickets should all build
on the same thinking. Then each build starts fresh from its ticket, because a ticket is
self-contained and the last one's context is disposable.

Work runs in parallel across separate worktrees, one per ticket; `dispatch` sets them up. **Cap how wide you run at what
you can keep up with.** Builds constantly surface decisions only a person should make; run wider
than you can follow and those decisions get made by an agent guessing, or do not get made at all.

## Off the loop entirely

Three skills sit outside the stages. Reach for them by name.

**`wizard`** — for steps only a person can take: a dashboard with no API, a key only they can see,
a billing decision. It generates an interactive bash script that opens the URL, captures each
value and verifies it. If an agent could just do the step, it should.

**`writing-for-agents`** — for writing skills, `CLAUDE.md`, and the docs under `docs/agents/`.
Its core rule: the description is paid every session, the body only when it fires, so put the
trigger words in one and the detail in the other.

**`grill-only`** — `grill` without the writing. Same interview, same reading of `docs/adr/` and
`CONTEXT.md`, but no ADR and no glossary entry: it says what it would have written and leaves the
repo alone. For a repo you are a guest in, or an idea too raw to be worth a number.

Not for when writing the file feels like a commitment. That hesitation usually means the decision
is real, and `grill` is the one you want.

## What this repo deliberately does not have

Say so rather than improvising a substitute:

- **No post-deploy canary** and **no weekly retrospective.** Both belong in stage 06, and
  `diagnose` is the shape to copy.
- **No handoff format.** Sessions coordinate through the ticket, which is the mailbox.

## Precondition

The tracker conventions, the triage labels and the doc layout the other skills assume are written
by **`setup-repo`**. If `docs/agents/` is missing, run that first.
