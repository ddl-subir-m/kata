# How I ship

One loop, six stages, an agent at every step.

Every stage ends by writing something down. The next stage starts by reading it. The trail of
documents becomes the record of how the software got built.

    Shape request → Write spec → Break into tickets → Build → Review PR → Land it → Diagnose alert
                                                                                          ↓
                                                                                    back to Shape

Nobody writes the spec by hand. Nobody writes the ticket by hand. The person decides whether the
work is worth doing and whether the draft is right. The agent does the writing.

## Install the skills

    /plugin marketplace add ddl-subir-m/how-i-ship
    /plugin install how-i-ship@how-i-ship

Eight skills. No other plugins required, and nothing to clone.

| Stage | Skill | What it does |
| --- | --- | --- |
| 00 | `new-repo` | Scaffolds a new repo from the installed plugin. No clone needed |
| 01 | `shape-request` | One question at a time until the spec writes itself, then tickets with dependencies |
| 01/02 | `domain-modeling` | `CONTEXT.md` entries and ADRs whose titles are the decision |
| 02 | `design-check` | Checks a screen against this repo's design system before anyone opens it |
| 04 | `tdd` | Red-green-refactor, and one deliberate failure plant per guard condition |
| 05 | `scoped-review` | Review the changed paths only. Never the whole repo, never the full suite |
| 05 | `land` | Merge main before the suite, then prove the tested tree is the landing tree |
| 06 | `diagnose` | Reproduce, bisect the condition, hand back a root cause and a rejected fix |

## Scaffold a new repo

Ask for one in any directory, and the `new-repo` skill runs the scaffold out of the installed
plugin. Nothing to clone.

To run it by hand instead:

    ~/.claude/plugins/marketplaces/how-i-ship/scaffold.sh /path/to/new-repo

Twelve files and one symlink. It never overwrites anything, so it is safe to re-run.

    CLAUDE.md                     13 standing rules, with an example each
    .claude/settings.json         declares this marketplace, enables this plugin
    AGENTS.md -> CLAUDE.md        so Claude and Codex read the same text
    CONTEXT.md                    the shared vocabulary
    docs/design-system.md         what design-check reads
    docs/adr/0000-template.md     the decision-record shape, with a worked example
    docs/agents/*.md              issue tracker, triage labels, domain docs
    Makefile                      the two gates
    .python-version               pins the interpreter, matching CI
    .github/workflows/tests.yml   CI runs the same two targets
    tests/test_ci_does_not_report_success_on_a_skipped_suite.py

## The two gates

`make test` and `make lint`. The same two run on a laptop and in CI, so they cannot drift apart.

This is the part to build on day one. An agent cannot check its own work without it, and without
that, everything else in this repo is decoration.

Three traps the scaffold closes:

1. **A green suite that tested nothing.** CI installs Python but not Node, every JS test skips
   itself, and the total still reads clean. `test_ci_does_not_report_success_on_a_skipped_suite.py`
   makes it red.
2. **A lint gate with the wrong scope.** `ruff check` from a subdirectory lints that subdirectory
   and still prints "All checks passed!". Put the scope inside the command, never in a sentence
   about it.
3. **A silent skip in a worktree.** `node_modules` is gitignored, so it exists only in the repo
   root. `-rs` prints every skip with its reason, which is the only thing that tells a skip from a
   pass at a glance.

## The rules that matter most

**Fix the code, not the test.** A failing test is evidence.

**The session that wrote the code cannot land it.** One landing session merges to `main`, and only
when the person says so.

**Merge main before the suite, never after.** A green run only describes the code it ran against.
Compare `git rev-parse HEAD^{tree}` with `git merge-tree --write-tree origin/main HEAD`. Equal
means a green suite covers the exact bytes that will land.

**A ticket needs a symptom.** File it when you can finish this sentence: *a person doing X sees Y,
and Y is wrong.* Everything else goes in the code, in the report, or on the `later` list.

**A green test proves nothing until you have seen it red.** One deliberate failure plant per
condition.

## The full runbook

`RUNBOOK.md` carries every file in this repo reproduced in full, plus the machine-level setup
(CLI tools, global instructions, hooks) and the order to do it in.

## Licence

MIT.
