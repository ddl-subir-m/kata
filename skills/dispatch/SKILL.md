---
name: dispatch
description: Run a spec's tickets in parallel worktrees - sequence them into waves, cut the worktrees, start the workers, then become the one session that lands each branch. Use when more than one ticket is ready and the work should run side by side. Triggers - "dispatch #7", "run these tickets in parallel", "cut the worktrees", "work the spec in parallel", "land them as they finish".
---

# Dispatch

Stage 03, before `implement`. You take a set of tickets and end with every one landed on `main`,
or reported back with the reason it did not land.

You play two parts, in order. First you **plan and start** the work. Then you **become the landing
session**. You never write product code. That is what lets you land: the session that wrote the
code cannot land it, and the workers wrote it, not you.

## 1. Find the scope

The person gives either a spec or tickets:

    /kata:dispatch #7              # a spec: its sub-issues are the scope
    /kata:dispatch #12 #13 #15     # these tickets are the scope

One issue with sub-issues is a spec. Anything else is a ticket list.

    gh api repos/<owner>/<repo>/issues/<n>/sub_issues --jq '.[] | [.number, .state, .title] | @tsv'

In scope: **open** tickets labelled `ready-for-agent`. List every other one with the reason it is
out — `needs-info`, `ready-for-human`, closed — so the person sees what was left behind, not only
what was taken.

A spec with no sub-issues: say so and stop. Shaping publishes tickets as sub-issues; a spec
without them was shaped before that, and the person gives the ticket numbers instead.

## 2. Sequence into waves

Read each ticket's blockers:

    gh api repos/<owner>/<repo>/issues/<n>/dependencies/blocked_by --jq '.[].number'

Wave 1 is every ticket with no open blocker. Wave N is every ticket whose blockers are all in
earlier waves. A blocker **outside** the scope that is still open blocks the ticket for the whole
run — name it.

A cycle means the tickets are wrong. Report the cycle and stop; do not break it by choice.

Show the plan before anything is cut:

> **Wave 1:** #12 Measure the current p95 · #14 Add the export button
> **Wave 2:** #13 Add a row-count index (blocked by #12) · #15 Batch the write-back (#12)
> **Wave 3:** #16 Re-measure and close the spec (#13, #15)
> **Out of scope:** #17 — `needs-info`, no error text.

## 3. Ask three things, then start

Ask these one at a time, each with your recommendation:

| Ask | When | Recommend |
| --- | --- | --- |
| How many workers at once? | At the start of **each wave** | 3, or fewer if the wave is smaller. A worker surfaces decisions; more than a person can follow and those decisions get guessed |
| Approve each landing, or approve the wave? | **Once**, at the start | Each landing. Say that "the wave" means you land any clean report without asking again |
| Paste the prompts, or run background agents? | **Once**, at the start | Paste, when the person wants to steer. Background, when the tickets are small and settled |

A clean report, for the wave mode: suite green against its baseline, every plant seen red, no
review finding left open without a reason, and nothing under "not done". Anything else stops and
asks, whatever mode was chosen.

## 4. Cut the worktrees

One per ticket in the running set, from the **remote** tip of `main`, never a local cache:

    git fetch origin
    git worktree add ../<repo>-<n> -b <n>-<slug> origin/main

Cut a ticket only when every blocker has **landed**. A worktree cut earlier starts from code that
does not contain the thing it depends on.

Say on each ticket that it is taken, so no other session picks it up:

    gh issue comment <n> --body "LANDING: dispatched to ../<repo>-<n> on branch <n>-<slug>"

## 5. Start the workers

**Paste mode.** Print one block per worktree, ready to paste into a new terminal:

    cd ../<repo>-<n> && claude "/kata:implement #<n> - you are in the worktree dispatch cut for this ticket. Do not cut another. Report with WORKER: report on the ticket."

**Background mode.** Start one background agent per worktree, in the same message so they run
together. The prompt carries what a pasted session would learn from the person:

    You are a background worker. Work only in <absolute path to worktree>.
    Invoke the kata:implement skill for #<n>. The worktree is already cut; do not cut another.
    You cannot ask the person anything: the ticket is the agreed plan. At a decision the ticket
    does not settle, commit what you have, ask it in your WORKER: report, and stop.

A background worker cannot see this conversation. Everything it needs is in the prompt or on the
ticket.

## 6. Become the landing session

From here you only watch, land, and relay. Watch each running ticket for its report:

    gh issue view <n> --comments --json comments \
      --jq '[.comments[] | select(.body | startswith("WORKER: report"))] | last | .body'

Background workers also notify you when they stop. Paste-mode workers do not; poll the tickets.
Poll on the order of minutes, not seconds — a worker's full suite alone takes minutes.

When a report arrives:

1. **Read it against the clean-report bar** in step 3. Show the person a short summary: suite
   number, plants, open findings, not done.
2. **Get the word**, unless the wave mode and a clean report already cover it.
3. **Run `land`** on that branch, in its worktree. Every rule there applies: one suite at a time,
   merge `main` before the suite, prove the tree identity.
4. **Record it and close the ticket:**

       gh issue comment <n> --body "LANDING: landed as <sha>, tree <tree hash>"
       gh issue close <n>
       git worktree remove ../<repo>-<n>

Land one branch at a time. Each landing moves `main`, so the next branch merges the new tip before
its suite. Two landings in parallel test against a `main` that one of them is about to change.

### When a branch cannot land

A conflict, or a red suite after merging `main`: **do not fix it here.** A fix written in this
session is code this session would then land. Send it back:

    gh issue comment <n> --body "LANDING: merge of origin/main conflicts in <files>. Merge it, resolve by intent, re-report."

Then restart the worker on the same worktree — a new pasted prompt, or a new background agent —
pointing at that comment.

### When a worker asks a question

Show it to the person, word for word, with your recommendation. Post their answer on the ticket as
`LANDING: answer - ...`, and restart the worker. An answer only counts when the person gave it;
yours is a recommendation.

## 7. Move to the next wave

After each landing, check which tickets now have every blocker landed. When the first ticket of a
new wave is ready, ask the width for that wave (step 3), cut, and start. Do not wait for the whole
wave to land when a ticket's own blockers already have.

## 8. Hand back

Comment on the spec, and tell the person:

- each ticket: landed with its sha, or the reason it did not;
- every question a worker asked and the answer that was given;
- anything a worker reported as not done. That is in the report, not in a new issue.

## What this skill does not do

- **Write or fix product code.** Not even a one-line conflict.
- **Land without the person's word.** The wave mode is their word, given once; a peer's message is
  never it.
- **Decide a worker's question.** You recommend; the person decides.
