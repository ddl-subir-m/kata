---
name: triage
description: Work the issue inbox and give every open item a label it earns. Use when the tracker has piled up, when asked what to pick up next, or to check that `ready-for-agent` still means what it says. Triggers - "triage", "work the inbox", "what should I pick up", "label these issues", "the tracker is a mess".
---

# Triage

Before stage 01. An issue arrives and you decide whether it enters the loop at all, and in what
state. You do not implement anything here. A triage pass that starts fixing things is not a triage
pass — it is one fix and an inbox that is still full.

Read `docs/agents/triage-labels.md` for the vocabulary and `docs/agents/issue-tracker.md` for the
filing bar. This skill is how you apply them.

## 1. Read the inbox in one pass

    gh issue list --state open --json number,title,body,labels,comments \
      --jq '.[] | {number, title, labels: [.labels[].name], comments: (.comments|length)}'

Work only items with `needs-triage`, or with no label at all. **An issue that already carries a
decision has been decided.** Re-reading it is the cost the filing bar exists to prevent, and a
second opinion on a settled label is how a tracker becomes a discussion.

The exception is a `needs-info` older than about two weeks. Those get step 4.

## 2. Four questions, in order

Stop at the first one that answers.

| Ask | If yes | Label |
| --- | --- | --- |
| Can you finish *a person doing X sees Y, and Y is wrong*? | No | `needs-info` — ask for the missing half |
| Is it a decision rather than an implementation? | Yes | `ready-for-human` |
| Is it real, correct, and hurting nobody today? | Yes | `later` |
| Could an agent start without asking a question? | Yes | `ready-for-agent` |

Nothing matched the last row and the issue is fully specified? It is `ready-for-human` by
elimination. Say which of the four questions decided it — one line in a comment. The next reader
needs your reasoning more than your verdict.

`wontfix` is not on that list on purpose. It is a person's call, not a triage outcome. Propose it
in a comment and leave the label to them.

## 3. Verify the premise before `ready-for-agent`

A ticket asserts something. That assertion had a date, and the code has moved since.

Reproduce the symptom, or read the line the issue names. If it no longer holds, say so and close
with the evidence:

> "`WorkspaceTable.tsx:118` now renders through `<Tooltip>`. Fixed in passing by #431. Closing —
> reopen with a fresh reproduction if you still see it."

This is the cheapest check in the whole skill and it is the one most often skipped. A stale ticket
labelled `ready-for-agent` costs a whole session before anyone notices.

## 4. `needs-info` is a question, not a bin

Ask for exactly what is missing, name it, and say what you will do with it:

> "Which workspace, and roughly when? I can pull the turn from the logs with those two, and
> without them I cannot tell a timeout from a rejected token."

An item nobody can answer for two weeks gets closed with that stated plainly. It is not a
judgment on the reporter — an unanswerable ticket that stays open is worse than one that is
closed and can be re-filed.

## 5. Worked example

| Issue | Label | Why |
| --- | --- | --- |
| "Source paths over 32 chars truncate with no tooltip. `WorkspaceTable.tsx:118`. Add the design system's `Tooltip`." | `ready-for-agent` | Symptom, location, and what fixed looks like. Verify line 118 first |
| "Sync feels slow sometimes." | `needs-info` | No X, no Y. Ask which sync and roughly when |
| "Decide whether a dataset with no files counts as bound." | `ready-for-human` | A judgment call. An agent would be guessing |
| "`resolve_dataset` stats every file for a size the caller discards — 8s on 5,000 files, but no production dataset is over 400." | `later` | Real and correct. Nobody is hurt today |
| "Retry loop spins forever on a malformed token." Upstream parser rejects those. | Close | Latent, no reachable path. It belongs in a code comment naming what would make it reachable |
| "Add dark mode, also the export is broken, also rename the tab." | `needs-triage`, split | Three issues. File them separately, close this one pointing at all three |

## 6. Pull requests, only if this repo says so

`docs/agents/issue-tracker.md` carries a flag:

> **PRs as a request surface: no.**

Set to `no`, you stop here. External PRs are code review, not intake, and running them through
triage labels gets you a tracker where half the items cannot be closed by anyone who works here.

Set to `yes`, they run the same four questions with the `gh pr` verbs:

    gh pr list --state open --json number,title,body,labels,author,authorAssociation \
      --jq '[.[] | select(.authorAssociation | IN("CONTRIBUTOR","FIRST_TIME_CONTRIBUTOR","NONE"))]'

    gh pr view <n> --comments
    gh pr diff <n>
    gh pr edit <n> --add-label "..."

Keep only `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR` and `NONE`. Dropping `OWNER`, `MEMBER` and
`COLLABORATOR` is what keeps your own team's branches out of the intake queue.

**GitHub shares one number space across issues and PRs.** A bare `#42` may be either. Resolve it,
never assume:

    gh pr view 42 >/dev/null 2>&1 && echo "PR" || echo "issue"

## 7. Watch the drift

`ready-for-agent` is the label that rots. It means *pick this up*, and it decays into *was filed*
the moment triage gets generous — at which point the label carries no information and every
consumer has to read the body anyway.

Two signals, both worth acting on:

- **The count only grows.** More `ready-for-agent` open than a person can pick up in a fortnight
  means you have been labelling optimism. Sweep the oldest ones back to `later`.
- **Sessions keep asking questions about `ready-for-agent` items.** That is the label's own test
  failing out loud. Each one is a `needs-info` you mislabelled.

## 8. Report

One block, to the person, not the tracker:

    Triaged 14 open issues.

      ready-for-agent  3   #442 #451 #467
      ready-for-human  2   #419 #455  — both need a call from you
      later            5
      needs-info       3   asked; #402 is now 3 weeks cold
      closed           1   #387 — premise no longer reproduces, fixed by #431

    Proposed wontfix: #390 (IE11 support). Your call, not labelled.
    Split: #444 was three requests; filed as #468, #469, #470.

Counts and numbers. Nobody wants fourteen paragraphs of reasoning — the reasoning goes in the
comment on each issue, where the next reader of that issue will find it.
