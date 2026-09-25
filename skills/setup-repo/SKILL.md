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

**Empty.** All 14 files land, plus the symlink. Say that.

**Has history.** Most of the 13 may already exist under other names, and the script writes only
what is missing. Do not promise 12. Look first, then say what is actually absent:

    for f in CLAUDE.md CONTEXT.md Makefile docs/design-system.md docs/adr docs/agents \
             .python-version .gitignore .github/workflows/tests.yml .claude/settings.json; do
      [ -e "<target>/$f" ] || echo "missing: $f"
    done

**`CLAUDE.md` is the one that matters.** A live repo almost always has one, so it is skipped, and
the 13 standing rules do not arrive. The script drops them at `CLAUDE.kata.md` and warns, but the
merge is a person's judgement, not yours: their file may contradict the rules deliberately. Offer
to walk it rule by rule. Never merge it silently.

**A design system file at the root.** Look for one before the script runs:

    ls <target>/DESIGN*.md <target>/design*.md 2>/dev/null

A file such as `DESIGN.md` or `DESIGN-apple.md` (the getdesign.md format) is a design system the
person brought. `design-check` reads only `docs/design-system.md`, so offer to move it there
**before** the script runs. The script never overwrites, so it then keeps the person's file
instead of writing the placeholder. Moved after, the placeholder must be replaced by hand, and
every colour in the placeholder is `#000000`.

**Is there a product idea yet?** In an empty folder there is often only a name. Ask once, in one
line: "Is there an idea written down yet, or only the name?" The answer changes step 6 and step 8.

**A repo with its own `.gitignore` keeps it.** Check that it ignores `.venv/`, `__pycache__/`,
`.pytest_cache/` and `.ruff_cache/`. If a cache is not ignored, a test run changes tracked files,
and `git worktree remove` refuses a worktree whose branch has already landed. Offer the missing
lines; do not add them silently.

**Push the "Read these, and when" table hardest.** `CLAUDE.md` is the only file loaded into every
session, so it is the only thing that can tell an agent that `docs/agents/` and `CONTEXT.md` exist
at all. The skills hardcode those paths and so find them anyway — but a session where no skill
fires does not. Somebody says "I'll open an issue for that", nothing routes, and the filing bar is
sitting in a file nobody opened. Merging that one table is worth more than merging the other
twelve rules.

A repo with its own `Makefile` is the second one to check. The two gates must be reachable as
`make test` and `make lint`; if those targets exist and mean something else, say so and stop rather
than adding duplicates.

### Is it on GitHub yet?

The loop runs on git and GitHub. `implement` and `dispatch` cut worktrees, which need a commit on
`main`. The triage labels need a GitHub repo. Look before you promise anything:

    git -C <target> rev-parse --show-toplevel 2>/dev/null   # nothing = not a repo; another path = nested
    git -C <target> rev-parse -q --verify HEAD              # nothing = no commit yet
    git -C <target> remote get-url origin 2>/dev/null       # nothing = no remote
    gh auth status >/dev/null 2>&1 && echo "gh ready"       # nothing = gh missing or logged out

| What you find | What the script does | What is left |
| --- | --- | --- |
| Not a repo | `git init -b main` | Commit, then GitHub |
| Inside another repo | Nothing. It never nests a repo | The person's call: see step 5 |
| No commit | Nothing | The first commit |
| No remote, or `gh` not ready | Nothing | `gh`, login, `gh repo create` |
| On GitHub | Creates the labels | Nothing |

**Inside another repo is the one to catch before writing.** The files become part of the parent
repo. Ask whether that is meant before step 3, not after.

## 3. Confirm the target before writing

Ask for the target directory if the person did not name one. Do not assume the current directory.

Then say what will happen, in one line, and wait:

> "This writes 14 files and an `AGENTS.md` symlink into `~/code/new-thing`, and runs `git init`
> there. It skips anything that already exists. Go ahead?"

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

## 5. Walk step 0: what the repo is still missing

When the repo is not on GitHub yet, the script prints a step 0 that lists only what is missing,
in order. **Do not paste that list back.** Take the person through it one item at a time: say
what is missing and why it matters, do it or hand it over, check it took, then go to the next.

| Missing | Who does it | What you do |
| --- | --- | --- |
| Inside another repo | The person decides | Ask: should these files be part of `<parent>`? If yes, they commit there, and there are no labels to make. If no, move them to their own folder and run the script again. **Never `git init` inside another repo.** |
| First commit | You, after a yes | Show `git status --short`. Point out anything that looks secret or large before staging it. Ask, then commit: `git add -A && git commit -m "Scaffold the ship loop"` |
| `gh` not installed | You, after a yes | Offer `brew install gh`. Off macOS, give the link: https://cli.github.com |
| `gh` not logged in | **Only the person** | It opens a browser with their account. Ask them to type `! gh auth login` so it runs in this session. Never ask for a token |
| No remote | You, after two answers | Ask for the name, and private or public. **Recommend private and the folder name.** Say it creates a real repo on their account, then run `gh repo create <name> --private --source=. --push` |
| Remote on another host | The person | The labels are GitHub labels. Give them the six in `docs/agents/triage-labels.md` to create in their tracker by hand |

**Check each one took** before the next: `git log --oneline -1` after the commit, `gh auth status`
after the login, `gh repo view --json url` after the remote. A step that failed quietly makes every
later step fail loudly and far from the cause.

Then run the script again, from the repo. It writes no files the second time and creates only the
labels. Go on to 6b if it kept any.

> Worked example, an empty folder:
>
> "Two things are missing before the labels can exist. First, the first commit: `implement` needs
> it to cut a worktree. Here is what would be staged: 14 files, nothing secret. Commit it?"
> — yes — *commits, shows the hash.*
> "Now the GitHub repo. I recommend `new-thing`, private. This creates a real repo on your
> account. Go ahead, or a different name?"
> — yes — *runs `gh repo create`, shows the URL, re-runs the script, reports 5 labels created and
> `wontfix` kept.*

The person can stop at any item. Then say what is still missing, and that `triage` and stage 03
will not work until it is done.

## 6. Walk the five manual steps

The script prints these. Do not just repeat them — offer to do the ones you can.

| Step | Who does it | What you can offer |
| --- | --- | --- |
| 1. Fill `CONTEXT.md`, delete the example entry | Needs the person's domain | Ask for the first three words that matter, then write the entries with `domain-modeling`. **No idea yet: skip it** |
| 2. Write ADR-0001 | Needs a real decision | Ask what was already decided that a newcomer would get wrong. **No idea yet: skip it** |
| 3. Fill `docs/design-system.md`, or delete it | Depends on the repo | Ask: does this repo have a UI? If no, delete the file |
| 4. `make setup && make test && make lint` | You | Run it. Both gates must pass before any real code |
| 5. Plant a deliberate failure, watch it go red | You | Do it, show the red output, remove the plant |

**No idea yet means steps 1 and 2 wait.** Do not ask for words or a decision about a product
nobody has described. An entry written from one vague sentence is worse than none: every later
session reads it as settled.

> Written too early: "Pulse — a heart rate monitor built from off-the-shelf parts." The product
> turned out to be a browser app using the webcam. Until somebody corrected the entry, `what-now`
> read it and suggested research on Bluetooth heart rate sensors.

Say instead that `grill` and `shape-request` fill `CONTEXT.md` and `docs/adr/` as the idea
settles. Delete the example entry, so it is not mistaken for a real one.

**Step 5 is the one people skip, and it is the one that matters.** A green suite proves nothing
until you have seen it red. Run it and show the failure — do not just say the gate works.

## 6b. Walk any label the script kept

The script creates the six triage labels, but it never touches one that already exists - no
`--force`, ever. It prints each kept label under a `!` line. Do not skim past that line.

**`wontfix` is kept on almost every repo**, because it is one of GitHub's nine stock labels and
ships with the repo from the day it was created. So this is the normal case, not the rare one.

A name that already exists is not a meaning that already matches. Read
`docs/agents/triage-labels.md` with the person, one kept label at a time, and ask what it means
*here*:

- **Same meaning** - nothing to do. GitHub's `wontfix` and ours usually agree.
- **Different meaning** - a vocabulary collision, and `CONTEXT.md` is where that gets settled.
  Either rename ours in `docs/agents/triage-labels.md`, or agree to retire the old use. Do not
  quietly adopt the old one.

**Never offer to overwrite the existing label.** Recolouring or re-describing somebody's label is
not yours to do, and the damage is invisible: every filter written against it still returns rows,
so nothing looks broken until somebody trusts the queue.

If the repo is not on GitHub yet, no labels exist and there is nothing to walk until step 5 is
done. Say so rather than inventing a check.

## 7. The repo declares the plugin it needs

`.claude/settings.json` is committed, and it names this marketplace and enables this plugin. Anyone
who opens the repo gets the kata skills without installing anything.

Two things to tell the person:

- **It waits for workspace trust.** A teammate's first session in the repo shows a trust prompt,
  and the skills are absent until they accept. That is deliberate: a committed settings file would
  otherwise install code on their machine unasked.
- **Their own plugins survive.** `enabledPlugins` merges per key across scopes, so a project file
  enabling this plugin does not disable anyone's user-level ones. Only a key named in both places
  changes, and the project file wins there.

If the repo is private, a teammate without access gets a fetch failure rather than a helpful
message. Say so when you hand back.

## 8. Adjust the stack if it is not Python plus Node

The `Makefile` and the CI workflow assume `uv` and `npm`. If the repo is something else, change
the two gate commands and say what you changed.

**No code and no idea yet: do not ask for the stack.** A stack chosen before the product is
described is a guess, and the approach step of `shape-request` makes the real choice later. Keep
the template gates, so both still run green, and say plainly: "The gates are Python and Node for
now. When `shape-request` picks the language, its first ticket rewrites them."

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

## 9. Hand back

Say plainly:

- the path you scaffolded,
- which files were created and which were skipped,
- **what waits for the idea**: the glossary words, ADR-0001 and the stack, when there was no idea
  yet,
- **what is still missing from step 0**: the commit, the GitHub repo, the labels. Say "nothing"
  when nothing is,
- whether `make test` and `make lint` both ran green,
- **whether you saw the plant go red**,
- which of the five manual steps are still outstanding.

The last two are the ones worth reading. The rest is bookkeeping.
