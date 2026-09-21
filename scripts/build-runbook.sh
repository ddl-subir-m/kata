#!/usr/bin/env bash
# Rebuild RUNBOOK.md from the real files, so it cannot drift from what the repo ships.
#
#   ./scripts/build-runbook.sh
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
OUT=RUNBOOK.md

# Embed a file inside a fenced block. The outer fence is one backtick longer than the longest
# run of backticks inside the file, so a markdown file carrying its own code fences survives.
embed() {
  local path="$1" lang="$2"
  local longest fence
  longest=$( { grep -oE '^`+' "$path" || true; } | awk '{ if (length($0) > m) m = length($0) } END { print m+0 }')
  if [ "$longest" -lt 3 ]; then longest=3; fi
  fence=$(printf '`%.0s' $(seq $((longest + 1))))
  printf '### `%s`\n\n%s%s\n' "$path" "$fence" "$lang"
  cat "$path"
  printf '%s\n\n' "$fence"
}

{
cat <<'HEAD'
# Runbook

Every file this repo ships, reproduced in full, plus the machine-level setup and the order to do
it in.

**This file is generated.** Run `./scripts/build-runbook.sh` after changing any file below.

---

## 1. The machine layer

Install once per laptop. Every repo then reuses it.

| What | Where | Why you need it |
| --- | --- | --- |
| `gh` | Homebrew | the issue tracker is GitHub issues |
| `uv` | astral.sh | Python, lockfiles, one interpreter everywhere |
| Node 22+ | Homebrew | JavaScript test harnesses; 22 is the floor for `stripTypeScriptTypes` |
| `ripgrep` | Homebrew | grep-based tests, and fast search |
| `~/.claude/CLAUDE.md` | your file | your voice and standing preferences |
| `~/.claude/settings.json` | your file | hooks, permissions, model, theme |

```bash
brew install gh ripgrep node
curl -LsSf https://astral.sh/uv/install.sh | sh
```

No other plugins are required, and nothing is cloned by hand. The eight skills in section 2
cover every stage of the loop, scaffolding included.

---

## 2. Install the skills

Pick a scope. Both are one line.

**User scope** — live in every project on the machine:

```bash
claude plugin marketplace add ddl-subir-m/kata \
  && claude plugin install kata@subir
```

**Project scope** — run inside the repo, then commit the file it writes:

```bash
claude plugin marketplace add ddl-subir-m/kata --scope project \
  && claude plugin install kata@subir --scope project

git add .claude/settings.json && git commit -m "Adopt the kata skills"
```

From inside a session, `/plugin install` opens the plugin's details pane and asks which scope,
so it covers all three:

```
/plugin marketplace add ddl-subir-m/kata
/plugin install kata@subir
# then choose: User scope / Project scope / Local scope
```

`--scope` is a CLI flag only -- the slash command asks rather than taking a flag. On v2.1.275 or
later, `/plugin install kata --marketplace ddl-subir-m/kata` adds and installs in one go.

| Scope | Who gets it | Written to |
| --- | --- | --- |
| User | You, in every project | `~/.claude/settings.json` |
| Project | Everyone on the repo | `.claude/settings.json`, commit it |
| Local | You, in this repo only | `.claude/settings.local.json`, not shared |

For project scope prefer the CLI two-liner: it writes `extraKnownMarketplaces` as well as
`enabledPlugins`, and a teammate needs both or the plugin reports as not installed.

Eighteen skills, about 1,843 tokens always-on. A skill's full text is read only when it fires.

That always-on figure is the real cost of breadth: it was 959 with ten skills. Each description
is roughly 100 tokens, paid every session. If a skill here is one you never reach for, disabling
the plugin per repo is cheaper than carrying it — or fork the marketplace and trim the `skills`
array in `plugin.json`.

One of them, `what-now`, is a router you invoke by name when you cannot remember which skill
fits. It carries `disable-model-invocation: true`, so it never fires on its own and costs only
~40 tokens always-on against a ~2.2k body.

The scaffold writes that same `.claude/settings.json` into every new repo, byte for byte, so a
scaffolded repo needs nobody to run the install at all.

Three things a teammate hits:

- **Project scope waits for workspace trust.** The first session shows a prompt; the skills are
  absent until it is accepted.
- **A project-scope plugin cannot be uninstalled per person.** To turn it off for yourself only:
  `claude plugin disable kata@subir --scope local`
- **Existing plugins are safe.** `enabledPlugins` merges per key across scopes.

A host other than GitHub takes the full git URL instead of the `owner/repo` shorthand. Point at
the repo, never at the raw `marketplace.json`.

HEAD

printf '### `.claude-plugin/marketplace.json`\n\n```json\n'; cat .claude-plugin/marketplace.json; printf '```\n\n'
printf '### `.claude-plugin/plugin.json`\n\n```json\n'; cat .claude-plugin/plugin.json; printf '```\n\n'

cat <<'MID'
---

## 3. The skills in full

MID

for s in what-now new-repo triage grill shape-request research domain-modeling codebase-design \
         design-check prototype implement tdd scoped-review merge-conflicts land diagnose \
         wizard writing-for-agents; do
  embed "skills/$s/SKILL.md" markdown
done

cat <<'MID3'
---

## 4. Scaffold a new repo

```bash
./scaffold.sh /path/to/new-repo
```

MID3

# Derived, not typed: the count drifted once when a twelfth template file was added.
echo "$(grep -c '^copy ' scaffold.sh) files and one symlink. It never overwrites a file that exists, so it is safe to re-run."
echo

embed scaffold.sh bash

cat <<'MID4'
---

## 5. The template files in full

These are what `scaffold.sh` copies.

MID4

embed template/.claude/settings.json json
embed template/CLAUDE.md markdown
embed template/CONTEXT.md markdown
embed template/docs/adr/0000-template.md markdown
embed template/docs/agents/issue-tracker.md markdown
embed template/docs/agents/triage-labels.md markdown
embed template/docs/agents/domain.md markdown
embed template/docs/design-system.md markdown

cat <<'MID5'
---

## 6. The two gates in full

`make test` and `make lint`. The same two run on a laptop and in CI, so they cannot drift apart.
Build these on day one — an agent cannot check its own work without them.

MID5

embed template/Makefile makefile
embed template/.github/workflows/tests.yml yaml
embed template/tests/test_ci_does_not_report_success_on_a_skipped_suite.py python
embed template/.python-version text

cat <<'TAIL'
### Three traps this closes

1. **A green suite that tested nothing.** CI installs Python but not Node, every JavaScript test
   skips itself, and the total still reads clean. The canary test makes it red.
2. **A lint gate with the wrong scope.** `ruff check` from a subdirectory lints that subdirectory
   and still prints "All checks passed!". Put the scope inside the command, never in a sentence
   about it.
3. **A silent skip in a worktree.** `node_modules` is gitignored, so it exists only in the repo
   root. `-rs` prints every skip with its reason, which is the only thing that tells a skip from a
   pass at a glance.

---

## 7. The order to do it

**Day 1, about 30 minutes.** Run the scaffold. Get `make test` and `make lint` green. Plant a
deliberate failure and watch it go red. You now have a feedback loop the agent cannot weaken.

**Day 2.** Fill `CONTEXT.md` with the first three words that matter. Write ADR-0001. Create the
labels. You now have a vocabulary and a bar for filing.

**When the first mistake repeats.** Add one line to `CLAUDE.md`. Not before.

---

## 8. What to leave behind

Do not carry another repo's `CLAUDE.md` in wholesale. Most of a mature one is scar tissue:
answers to problems your new repo does not have yet. Carrying them in makes the file unreadable on
day one, which is the one thing a standing-rules file cannot afford.

Carry three things instead:

1. The thirteen rules in `template/CLAUDE.md`.
2. The two gate commands.
3. The CI canary test.

Let the rest grow from real mistakes. A rule earns its place the second time something goes wrong,
not the first time you imagine it might.
TAIL
} > "$OUT"

echo "wrote $OUT ($(wc -l < "$OUT" | tr -d ' ') lines)"
