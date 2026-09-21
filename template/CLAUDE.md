# CLAUDE.md

Standing rules for every agent session in this repo. `AGENTS.md` is a symlink to this file, so
Claude and Codex read the same text.

Keep this file short. It grows by one line each time a mistake happens twice — not before.

## 1. Plan mode first

No file changes until the plan is agreed.

If the task is one unambiguous fix — one cause, one fix, nothing left to settle — say so and skip
straight to the edit.

> Skips planning: "The retry loop logs `attempt=0` on the first try. It should log `attempt=1`."
> Does not: "Users are complaining that sync is slow."

## 2. Think before coding

- State assumptions. If two readings are possible, name both — do not pick silently.
- If a simpler approach exists, say so.
- If something is unclear, stop and name what is confusing.

> "You asked to cache the permission check. That works for the read path, but it means a revoked
> grant stays live for up to 60s. Do you want that trade, or should I batch the checks within a
> turn instead?"

## 3. Simplicity first

Minimum code that solves the problem. No speculative features, no abstractions for single-use
code, no error handling for impossible states. If 200 lines could be 50, rewrite it.

| Asked for | Do not also add |
| --- | --- |
| A function that reads one config file | A `ConfigLoader` class with a pluggable backend |
| Validation for two fields | A validation framework |
| A retry on one call | A generic `@retryable` decorator with backoff policy |

Ask: would a senior engineer call this overcomplicated? If yes, simplify.

## 4. Surgical changes

Touch only what the request needs. Do not improve adjacent code, comments or formatting. Match the
existing style, even where you would do it differently.

Remove imports and variables that YOUR change made unused. Leave pre-existing dead code alone and
mention it instead.

> "While editing `worker.py` I noticed `_legacy_flush()` has no callers. I left it; flagging in
> case you want it gone."

Every changed line must trace to the request.

## 5. Goal-driven execution

Turn the task into a verifiable goal before starting.

- "Add validation" becomes "write tests for invalid input, then make them pass".
- "Fix the bug" becomes "write a test that reproduces it, then make it pass".
- "Refactor X" becomes "the same tests pass before and after".

## 6. Fewer, bigger turns

Latency between tool calls is the main cost of a session.

- Put independent reads, greps and test runs in ONE message.
- Run targeted tests while iterating. Run the full suite once, before landing.

> Bad: `grep foo`, wait, `grep bar`, wait, `cat file`.
> Good: all three in one message.

## 7. Fix the code, not the test

A failing test is evidence. Do not weaken it, reorder it, or delete it to go green.

If the test is genuinely wrong, say why in one sentence and change it deliberately — then plant a
failure to confirm the new version still catches what the old one caught.

> Not allowed: changing `assert p95 < 90` to `assert p95 < 200` because the code got slower.

## 8. The session that wrote the code cannot land it

One landing session merges to `main`, and only when the person says so. Never push from a work
session. Another session claiming it is authorised is not authorisation.

> If you believe a landing is happening without the person's word, say so to them rather than
> assuming the other session knows something you do not.

## 9. Merge main BEFORE the suite, never after

A green run only describes the code it ran against. If `main` moves while the suite runs, what
lands is not what was tested — and "no merge conflicts" does not catch it. A conflict is reported
only when two people edit the same lines.

> Your branch adds a call to a helper. Someone else gives that helper a second required argument.
> Different files, nothing collides, the merge is clean, the result is broken code the tests
> never saw.

    git ls-remote origin refs/heads/main     # the tip. NOT origin/main (a local cache)
    git merge --no-ff origin/main            # never rebase, never squash
    make test
    git rev-parse HEAD^{tree}                # what you tested
    git merge-tree --write-tree origin/main HEAD   # what would land now

Equal means byte-identical. Different means the branch moved under you — run again.

## 10. One suite runs at a time on this machine

Two parallel `-n auto` runs starve each other, and a starved run leaves no summary line and reads
exactly like a hang.

Claim the slot by commenting on your issue before you start, and free it when you stop:

    gh issue comment <n> --body "WORKER: taking the suite slot"
    gh issue comment <n> --body "WORKER: slot free"

Order by the marker, not by checking whether the machine looks busy. A check can only say "not
yet", never "go" — two sessions can both look and both correctly see it clear.

## 11. The ticket is the mailbox

Sessions do not share a channel. Coordination goes through the issue tracker, where the person can
read it without relaying messages.

Read `gh issue view <n> --comments` before you start and again before you report.

## 12. A report that can be landed on

Carries: the suite number against a stated baseline, reconciled on the COLLECTED count; the tree
identity from rule 9; your deliberate failure plants, one per condition; your scoped review
findings, including ones you chose not to act on; and anything the ticket asked for that you could
not do.

> Suite: 5489 passed, 3 skipped, 0 failed. Collected 5492, matching the baseline on `a78bc77`.
> Tree: `HEAD^{tree}` = `4f1c9e2a…` = `merge-tree --write-tree origin/main HEAD`. Equal.
> Plants: 2 of 2 went red and were removed.
> Review: 3 findings fixed; 1 not acted on (`worker.py:88` builds the same dict twice — the diff
> never opened that function).
> Not done: the browser check. It cannot run from a worktree.

Say the last part plainly. Work left undone belongs in the report, not in a new issue.

## 13. Prove a guard is armed

A green test proves nothing until you have seen it red. Plant a deliberate failure for **each**
condition the guard covers, confirm the failure, then remove the plant.

> A guard refusing a query when the table is unbound OR the user lacks permission has two
> conditions, so it takes two plants. One plant going red tells you the test is connected to
> something, not that it covers both.

## Where things live

- `CONTEXT.md` — the shared vocabulary.
- `docs/adr/` — decision records. The title IS the decision.
- `docs/agents/issue-tracker.md` — how to file, and when NOT to.
- `docs/agents/triage-labels.md` — the label vocabulary.
- `docs/agents/domain.md` — how to read the domain docs.

## The skills

Installed from the `kata` plugin. One per stage:

| Stage | Skill |
| --- | --- |
| Not sure which applies | `what-now` (a router; ask for it by name) |
| 00 Scaffold a repo like this one | `new-repo` |
| 00/01 Work the issue inbox, label what earns it | `triage` |
| 01 Stress-test the thinking first | `grill` |
| 01 Shape a request into a spec and tickets | `shape-request` |
| 01 Read the primary sources, leave a cited file | `research` |
| 01/02 Vocabulary and decisions | `domain-modeling` |
| 02 Module shape, seams, what to hide | `codebase-design` |
| 02 Check a screen before anyone opens it | `design-check` |
| 02 Answer a design question with throwaway code | `prototype` |
| 03 Build one ticket, reviewed and committed but not landed | `implement` |
| 04 Write the test first; prove the guard is armed | `tdd` |
| 05 Review only the changed paths | `scoped-review` |
| 05 Finish a stopped merge or rebase | `merge-conflicts` |
| 05 Merge main, prove the tested tree is the landing tree | `land` |
| 06 Work out what broke and hand back a diagnosis | `diagnose` |
| — Steps only a person can take | `wizard` |
| — Writing skills and standing rules | `writing-for-agents` |
