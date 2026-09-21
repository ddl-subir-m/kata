# How I ship

One loop, six stages, an agent at every step.

Every stage ends by writing something down. The next stage starts by reading it. The trail of
documents becomes the record of how the software got built.

    Shape request → Write spec → Break into tickets → Build → Review PR → Land it → Diagnose alert
                                                                                          ↓
                                                                                    back to Shape

Nobody writes the spec by hand. Nobody writes the ticket by hand. The person decides whether the
work is worth doing and whether the draft is right. The agent does the writing.

## Install

Everything is in this repo. You do not clone it.

```bash
claude plugin marketplace add ddl-subir-m/kata
claude plugin install kata@subir
```

That is the whole install. Eighteen skills, in every project on this machine.

Already inside a Claude Code session? `/plugin marketplace add ddl-subir-m/kata` then
`/plugin install kata@subir`.

## Then what

**Have a repo already?** Nothing more to do. Ask for `what-now` and it tells you which skill fits.

**Starting a new one?** Ask for `new-repo` in any directory. It writes 12 files and an `AGENTS.md`
symlink — the rules, the docs, the two gates, CI. It never overwrites, so re-running is safe.

The skills live in `~/.claude`, shared by every repo. The 12 files live in the repo and get
committed. One of them, `.claude/settings.json`, records that the repo uses these skills, so a
teammate who clones it is offered the same install.

That is the full picture. Everything below is detail you can read when you need it.

## The eighteen skills

| Stage | Skill | What it does |
| --- | --- | --- |
| — | `what-now` | Ask which skill fits. A router over the others, and a map of the flow |
| 00 | `new-repo` | Scaffolds a new repo from the installed plugin. No clone needed |
| 00/01 | `triage` | Works the issue inbox. Every open item gets a label it earns |
| 01 | `grill` | Stress-tests a plan with hard questions, one at a time |
| 01 | `shape-request` | One question at a time until the spec writes itself, then tickets |
| 01 | `research` | Investigates against primary sources, leaves a cited Markdown file |
| 01/02 | `domain-modeling` | `CONTEXT.md` entries and ADRs whose titles are the decision |
| 02 | `codebase-design` | Deep modules, seams, and where to hide complexity |
| 02 | `design-check` | Checks a screen against this repo's own design system |
| 02 | `prototype` | Throwaway build to answer one design question |
| 03 | `implement` | Takes one ticket, drives tdd, reviews, commits. Never pushes |
| 04 | `tdd` | Red-green-refactor, and one failure plant per guard condition |
| 05 | `scoped-review` | Review the changed paths only. Never the whole repo |
| 05 | `merge-conflicts` | Resolves an in-progress merge by intent, never `--abort` |
| 05 | `land` | Merge main before the suite, then prove the tested tree is the landing tree |
| 06 | `diagnose` | Reproduce, bisect the condition, hand back a root cause |
| — | `wizard` | A bash wizard for the steps only a person can take |
| — | `writing-for-agents` | Writing skills, `CLAUDE.md`, and the docs agents read |

Eighteen skills, about 1,843 tokens always-on. A skill's full text is read only when it fires. The
always-on figure is the real cost of breadth: it was 959 with ten skills. Each description is
roughly 100 tokens, paid every session; `triage` added ~110. If a skill here is one you never
reach for, disabling the plugin per repo is cheaper than carrying it — or fork the marketplace and
trim the `skills` array in `plugin.json`. `what-now` costs just ~40 of that, because it never fires
on its own.

## Not sure which skill you want?

Ask for `what-now`. It is a router: it walks the six stages, names the branch points (does this
request even need shaping? is this red even yours?), and says plainly what this repo does **not**
cover. It never fires on its own — you have to ask for it.

## Scaffold a new repo

Ask for one in any directory, and the `new-repo` skill runs the scaffold out of the installed
plugin. Nothing to clone.

To run it by hand instead:

    ~/.claude/plugins/marketplaces/subir/scaffold.sh /path/to/new-repo

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

## Installing it for a team

The two commands at the top install for **you**, everywhere. To put it on a repo instead, so
everyone who clones gets it:

```bash
claude plugin marketplace add ddl-subir-m/kata --scope project
claude plugin install kata@subir --scope project
git add .claude/settings.json && git commit -m "Adopt kata skills"
```

<details>
<summary>The details that bite</summary>

| Scope | Who gets it | Written to |
| --- | --- | --- |
| User | You, in every project | `~/.claude/settings.json` |
| Project | Everyone on the repo | `.claude/settings.json`, commit it |
| Local | You, in this repo only | `.claude/settings.local.json`, not shared |

**Use the CLI for project scope, not the panel.** Picking *Project scope* in `/plugin` writes
`enabledPlugins` but may leave the marketplace registered to you alone. The teammate then sees the
plugin reported as not installed. `--scope project` writes both keys.

**Project scope waits for workspace trust.** The first session in the repo shows a trust prompt,
and the skills are absent until it is accepted. That is deliberate: a committed settings file
would otherwise install code on someone's machine unasked.

**A project-scope plugin cannot be uninstalled per person.** The shared settings file owns it.
Anyone who does not want it turns it off for themselves only:

```bash
claude plugin disable kata@subir --scope local
```

**Your own plugins are safe.** `enabledPlugins` merges per key across scopes, so adopting this at
project scope leaves every user-level plugin enabled. Only a key named in both places changes, and
the project file wins there.

**The scopes compose.** A project file says what the repo needs; your user install says what you
want everywhere. `claude plugin list` shows the scope of each, and flags any key set in both.

**`--scope` is a CLI flag only.** The slash command asks instead of taking a flag, so
`/plugin install kata@subir --scope project` is not a thing.

**Not on GitHub?** `owner/repo` is GitHub-only. Use a URL, HTTPS or SSH, or a local path:

```bash
claude plugin marketplace add https://gitlab.com/company/kata.git
claude plugin marketplace add git@bitbucket.org:you/kata.git
claude plugin marketplace add ./path/to/kata
```

Point at the **repo**, never at the raw `marketplace.json`. A direct link to that file downloads
only the file, and the plugin's `"source": "./"` then has nothing to resolve against.

</details>

## The full runbook

`RUNBOOK.md` carries every file in this repo reproduced in full, plus the machine-level setup
(CLI tools, global instructions, hooks) and the order to do it in.

## Licence

MIT.
