---
name: setup-repo
description: Set up a repo with the ship loop wired in - standing rules, vocabulary, ADR shape, issue-tracker conventions, the two gates and the CI canary test. Works on a new repo and on one with years of history: it never overwrites, so it fills only what is missing. Triggers - "set up this repo", "new repo", "scaffold a repo", "wire up the ship loop", "add the rules and gates", "this repo has no CLAUDE.md".
---

# Set up a repo

Runs `scaffold.sh` from the installed plugin. **The person does not clone anything** — the script
is already on disk, because installing the plugin cloned the repo.

## 1. Find the script

Try these in order. Stop at the first that resolves to an existing file.

```bash
# The plugin's own root, when the harness exports it.
[ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && ls "$CLAUDE_PLUGIN_ROOT/scaffold.sh" 2>/dev/null

# Otherwise find it structurally: the scaffold.sh that sits beside a plugin manifest
# naming this plugin. Do NOT filter on the path -- the marketplace directory is named
# after the marketplace, not the plugin, and a `-path '*subir*'` test matches every path
# under a home directory called /Users/subir..., which is to say all of them.
find ~/.claude/plugins -maxdepth 6 -name scaffold.sh 2>/dev/null | while read -r f; do
  grep -q '"name": *"kata"' "$(dirname "$f")/.claude-plugin/plugin.json" 2>/dev/null \
    && echo "$f" && break
done
```

**If neither finds it**, do not guess a path and do not improvise the file copies. Say the plugin
looks half-installed, and give the person the fallback:

    git clone git@github.com:ddl-subir-m/kata.git /tmp/kata
    /tmp/kata/scaffold.sh <target>

## 2. Empty directory, or a repo with history?

Both are supported and the script is the same. What differs is what you promise.

    ls -A <target> 2>/dev/null | head -1        # empty output = nothing there yet

**Empty.** All 13 files land, plus the symlink. Say that.

**Has history.** Most of the 12 may already exist under other names, and the script writes only
what is missing. Do not promise 12. Look first, then say what is actually absent:

    for f in CLAUDE.md CONTEXT.md Makefile docs/design-system.md docs/adr docs/agents \
             .python-version .github/workflows/tests.yml .claude/settings.json; do
      [ -e "<target>/$f" ] || echo "missing: $f"
    done

**`CLAUDE.md` is the one that matters.** A live repo almost always has one, so it is skipped, and
the 13 standing rules do not arrive. The script drops them at `CLAUDE.kata.md` and warns, but the
merge is a person's judgement, not yours: their file may contradict the rules deliberately. Offer
to walk it rule by rule. Never merge it silently.

**Push the "Read these, and when" table hardest.** `CLAUDE.md` is the only file loaded into every
session, so it is the only thing that can tell an agent that `docs/agents/` and `CONTEXT.md` exist
at all. The skills hardcode those paths and so find them anyway — but a session where no skill
fires does not. Somebody says "I'll open an issue for that", nothing routes, and the filing bar is
sitting in a file nobody opened. Merging that one table is worth more than merging the other
twelve rules.

A repo with its own `Makefile` is the second one to check. The two gates must be reachable as
`make test` and `make lint`; if those targets exist and mean something else, say so and stop rather
than adding duplicates.

## 3. Confirm the target before writing

Ask for the target directory if the person did not name one. Do not assume the current directory.

Then say what will happen, in one line, and wait:

> "This writes 13 files and an `AGENTS.md` symlink into `~/code/new-thing`. It skips anything that
> already exists. Go ahead?"

For a repo with history, name the real number instead, and name what it will not do:

> "This adds 6 missing files to `~/code/api`. It leaves your `CLAUDE.md` alone, so the standing
> rules land in `CLAUDE.kata.md` for you to merge. Go ahead?"

The script never overwrites, so re-running it is safe. Say that — it removes the main worry.

## 4. Run it

```bash
<path-to-scaffold.sh> /path/to/repo
```

Report what it created and what it skipped. A long list of `skip` lines means the repo was already
scaffolded; say so rather than reporting success.

## 5. Walk the five manual steps

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

## 6. The repo declares the plugin it needs

`.claude/settings.json` is committed, and it names this marketplace and enables this plugin. Anyone
who opens the repo gets the eight skills without installing anything.

Two things to tell the person:

- **It waits for workspace trust.** A teammate's first session in the repo shows a trust prompt,
  and the skills are absent until they accept. That is deliberate: a committed settings file would
  otherwise install code on their machine unasked.
- **Their own plugins survive.** `enabledPlugins` merges per key across scopes, so a project file
  enabling this plugin does not disable anyone's user-level ones. Only a key named in both places
  changes, and the project file wins there.

If the repo is private, a teammate without access gets a fetch failure rather than a helpful
message. Say so when you hand back.

## 7. Adjust the stack if it is not Python plus Node

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

## 8. Hand back

Say plainly:

- the path you scaffolded,
- which files were created and which were skipped,
- whether `make test` and `make lint` both ran green,
- **whether you saw the plant go red**,
- which of the five manual steps are still outstanding.

The last two are the ones worth reading. The rest is bookkeeping.
