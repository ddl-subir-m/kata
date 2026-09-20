---
name: new-repo
description: Scaffold a new repo with the ship loop already wired - standing rules, vocabulary, ADR shape, issue-tracker conventions, the two gates and the CI canary test. Use when starting a new project or repo, or when an existing repo has no CLAUDE.md and no test/lint gate. Triggers - "new repo", "scaffold a repo", "set up a new project", "wire up the ship loop", "start a new codebase".
---

# Scaffold a new repo

Runs `scaffold.sh` from the installed plugin. **The person does not clone anything** — the script
is already on disk, because installing the plugin cloned the repo.

## 1. Find the script

Try these in order. Stop at the first that resolves to an existing file.

```bash
# The plugin's own root, when the harness exports it.
[ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && ls "$CLAUDE_PLUGIN_ROOT/scaffold.sh" 2>/dev/null

# Otherwise search the plugin directories. Covers both the marketplace clone and the
# versioned plugin cache, whatever the install path turns out to be.
find ~/.claude/plugins -maxdepth 6 -name scaffold.sh -path '*how-i-ship*' 2>/dev/null | head -1
```

**If neither finds it**, do not guess a path and do not improvise the file copies. Say the plugin
looks half-installed, and give the person the fallback:

    git clone git@github.com:ddl-subir-m/how-i-ship.git /tmp/how-i-ship
    /tmp/how-i-ship/scaffold.sh <target>

## 2. Confirm the target before writing

Ask for the target directory if the person did not name one. Do not assume the current directory.

Then say what will happen, in one line, and wait:

> "This writes 11 files and an `AGENTS.md` symlink into `~/code/new-thing`. It skips anything that
> already exists. Go ahead?"

The script never overwrites, so re-running it is safe. Say that — it removes the main worry.

## 3. Run it

```bash
<path-to-scaffold.sh> /path/to/new-repo
```

Report what it created and what it skipped. A long list of `skip` lines means the repo was already
scaffolded; say so rather than reporting success.

## 4. Walk the five manual steps

The script prints these. Do not just repeat them — offer to do the ones you can.

| Step | Who does it | What you can offer |
| --- | --- | --- |
| 1. Fill `CONTEXT.md`, delete the example entry | Needs the person's domain | Ask for the first three words that matter, then write the entries with `domain-modeling` |
| 2. Write ADR-0001 | Needs a real decision | Ask what was already decided that a newcomer would get wrong |
| 3. Fill `docs/design-system.md`, or delete it | Depends on the repo | Ask: does this repo have a UI? If no, delete the file |
| 4. `make setup && make test && make lint` | You | Run it. Both gates must pass before any real code |
| 5. Plant a deliberate failure, watch it go red | You | Do it, show the red output, remove the plant |

**Step 5 is the one people skip, and it is the one that matters.** A green suite proves nothing
until you have seen it red. Run it and show the failure — do not just say the gate works.

## 5. Adjust the stack if it is not Python plus Node

The `Makefile` and the CI workflow assume `uv` and `npm`. If the repo is something else, change
the two gate commands and say what you changed.

**Keep three things whatever the stack:**

1. There are exactly **two** targets, `test` and `lint`, and CI runs those targets rather than the
   commands they wrap. That is what stops CI and a laptop drifting apart.
2. The scope lives **inside** the lint command, never in a sentence about it. A gate is the
   command you actually run.
3. The canary test stays, rewritten for the tools your suite actually needs. Its job is to fail
   loudly when the runner is missing something that would otherwise turn real tests into silent
   skips.

### Worked example: a Node-only repo

```makefile
test:
	npm test -- --reporter=dot

lint:
	npx eslint .
```

The canary test becomes a check that the tools your suite skips on are present on CI — the same
idea, different tool names.

## 6. Hand back

Say plainly:

- the path you scaffolded,
- which files were created and which were skipped,
- whether `make test` and `make lint` both ran green,
- **whether you saw the plant go red**,
- which of the five manual steps are still outstanding.

The last two are the ones worth reading. The rest is bookkeeping.
