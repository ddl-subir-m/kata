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

The slash commands do the same at user scope, from inside a session:

```
/plugin marketplace add ddl-subir-m/kata
/plugin install kata@subir
```

Nine skills, about 936 tokens always-on. A skill's full text is read only when it fires.

One of them, `what-now`, is a router you invoke by name when you cannot remember which skill fits.
It carries `disable-model-invocation: true`, so it never fires on its own and costs only ~40
tokens always-on against a ~2.2k body.

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

### `.claude-plugin/marketplace.json`

```json
{
  "name": "subir",
  "owner": {
    "name": "Subir Mansukhani",
    "url": "https://github.com/ddl-subir-m"
  },
  "description": "Subir Mansukhani's engineering skills: one loop, six stages, an agent at every step.",
  "plugins": [
    {
      "name": "kata",
      "source": "./",
      "description": "A rehearsed form for shipping: shape a request, model the domain, write the test first, review the changed paths only, land safely, diagnose an alert.",
      "category": "engineering",
      "keywords": [
        "engineering",
        "skills",
        "tdd",
        "code-review",
        "adr",
        "landing",
        "ci"
      ]
    }
  ]
}
```

### `.claude-plugin/plugin.json`

```json
{
  "name": "kata",
  "version": "2.0.0",
  "description": "A rehearsed form for shipping. One loop, six stages, an agent at every step; every stage ends by writing something down, and the next stage starts by reading it.",
  "author": {
    "name": "Subir Mansukhani",
    "url": "https://github.com/ddl-subir-m"
  },
  "repository": "https://github.com/ddl-subir-m/kata",
  "license": "MIT",
  "keywords": [
    "engineering",
    "skills",
    "tdd",
    "code-review",
    "adr",
    "landing",
    "ci"
  ],
  "skills": [
    "./skills/what-now",
    "./skills/new-repo",
    "./skills/shape-request",
    "./skills/domain-modeling",
    "./skills/design-check",
    "./skills/tdd",
    "./skills/scoped-review",
    "./skills/land",
    "./skills/diagnose"
  ]
}
```

---

## 3. The skills in full

### `skills/what-now/SKILL.md`

````markdown
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

**No repo, or a repo with no `CLAUDE.md` and no gates** → **`new-repo`**. It writes the standing
rules, the vocabulary files, the tracker conventions and the two gates. Do this before anything
else; the rest of the loop assumes those files exist.

Already set up → skip to stage 01.

## Stage 01: shape the request

**`shape-request`** — one question at a time, covering scope, users, constraints and success. It
ends with a spec published as an issue, broken into tickets that declare what blocks them.

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

**`design-check`** — checks a screen against the repo's own design system **before anyone opens
it**. UX rules get applied while the work is written, not caught in review.

It reads `docs/design-system.md` and **refuses to run if there is none**. That is deliberate: a
design check with no design system is an opinion, and it wastes a review cycle.

No UI in this repo? Delete that file and skip this stage.

## Stage 03 and 04: build and test

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

## Context hygiene

Keep stage 01 in **one unbroken window** — the shaping, the spec and the tickets should all build
on the same thinking. Then each build starts fresh from its ticket, because a ticket is
self-contained and the last one's context is disposable.

Work runs in parallel across separate worktrees, one per ticket. **Cap how wide you run at what
you can keep up with.** Builds constantly surface decisions only a person should make; run wider
than you can follow and those decisions get made by an agent guessing, or do not get made at all.

## What this repo deliberately does not have

Say so rather than improvising a substitute:

- **No post-deploy canary** and **no weekly retrospective.** Both belong in stage 06. `diagnose`
  is the shape to copy if you want them.
- **No prototype skill.** When a design question needs a runnable answer, write throwaway code and
  fold the answer back in.
- **No research skill.** Read the primary sources and cite them.
- **No handoff format.** Sessions coordinate through the ticket, which is the mailbox.

## Precondition

The tracker conventions, the triage labels and the doc layout the other skills assume are written
by **`new-repo`**. If `docs/agents/` is missing, run that first.
````

### `skills/new-repo/SKILL.md`

````markdown
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

## 2. Confirm the target before writing

Ask for the target directory if the person did not name one. Do not assume the current directory.

Then say what will happen, in one line, and wait:

> "This writes 12 files and an `AGENTS.md` symlink into `~/code/new-thing`. It skips anything that
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

## 5. The repo declares the plugin it needs

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

## 6. Adjust the stack if it is not Python plus Node

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

## 7. Hand back

Say plainly:

- the path you scaffolded,
- which files were created and which were skipped,
- whether `make test` and `make lint` both ran green,
- **whether you saw the plant go red**,
- which of the five manual steps are still outstanding.

The last two are the ones worth reading. The rest is bookkeeping.
````

### `skills/shape-request/SKILL.md`

````markdown
---
name: shape-request
description: Turn a vague request into a written spec and a set of small tickets. Use when an idea, a feature request or a half-formed ask arrives and nobody has written down what "done" means yet. Triggers - "shape this", "write a spec", "break this into tickets", "what should we build".
---

# Shape a request

Stage 01 of the loop. A request arrives as an idea, a ticket or an alert. You end this stage with
a spec published to the issue tracker and small tickets that declare what blocks them.

**Nobody writes the spec by hand. Nobody writes the ticket by hand.** The person decides whether
the work is worth doing and whether the draft is right. You do the writing.

## Skip this skill when the request is already unambiguous

One cause, one fix, nothing left to settle. Say so in a sentence and go straight to the edit.

Example of a request that skips shaping:

> "The retry loop logs `attempt=0` on the first try. It should log `attempt=1`."

Example of a request that does not:

> "Users are complaining that sync is slow."

The second one has no scope, no user, no number that says when it is fixed.

## Ask one question at a time

Never a numbered list of six questions. One question, wait, then the next. The answers change
which question comes next, and a batch of six forces the person to answer the wrong ones.

Cover these four, in this order:

| Area | The question behind it |
| --- | --- |
| Scope | What is in, and what is explicitly out? |
| Users | Who hits this, and what are they doing when they hit it? |
| Constraints | What cannot change? Existing data, a public API, a deadline, a budget. |
| Success | What number or observation says this is done? |

### Worked example

> **Request:** "Users are complaining that sync is slow."
>
> **Q1 (scope):** "Is this about the initial sync when a workspace connects, or the incremental
> sync that runs every few minutes?"
> **A:** "Incremental."
>
> **Q2 (users):** "Which workspaces? Everyone, or the large ones?"
> **A:** "Anything over about 50,000 rows."
>
> **Q3 (constraints):** "Can we change the sync interval, or is that fixed by the contract?"
> **A:** "The interval is fixed at 5 minutes. The work inside it can change."
>
> **Q4 (success):** "What is the current p95, and what would be acceptable?"
> **A:** "It is 4 minutes now. Under 90 seconds."
>
> Four answers. Now the spec writes itself, and the four answers are its four sections.

## Write the spec

A spec is a committed, human-readable file that the product owner corrects before it lands. It is
not a design document and it is not a plan.

    # Incremental sync stays under 90 seconds at p95
    ## Problem
    ## Scope             (in, and explicitly out)
    ## Users affected
    ## Constraints
    ## Success criteria  (the number, and how it is measured)
    ## Open questions

Publish it as a GitHub issue. See `docs/agents/issue-tracker.md` in the repo for the commands.

## Break it into tickets

Small enough that one session can finish one. Each ticket names what blocks it, using GitHub's
native issue dependencies so the block is visible in the UI:

    BLOCKER_ID=$(gh api repos/<owner>/<repo>/issues/<blocker> --jq .id)
    gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by \
      -F issue_id=$BLOCKER_ID

`issue_id` is the numeric **database id**, not the `#number` and not the `node_id`. Getting this
wrong creates no edge and reports no error.

### Worked example

From the spec above:

| # | Ticket | Blocked by |
| --- | --- | --- |
| 1 | Measure the current p95 and record it in the spec | — |
| 2 | Add a row-count index so the incremental query stops a full scan | 1 |
| 3 | Batch the write-back into 500-row chunks | 1 |
| 4 | Re-measure p95 and close the spec issue | 2, 3 |

Ticket 1 exists because a success criterion with no baseline cannot be checked. That ticket is
almost always the first one.

## Alongside, write the words down

Every word you settle on goes into `CONTEXT.md`, and every decision into `docs/adr/`, as it
settles — not weeks later. Use the `domain-modeling` skill for that. Do it in the same session:
the reason a vocabulary rots is that somebody meant to write it down later.

## Hand back

Give the person: the spec issue number, the ticket numbers in dependency order, and any question
you could not answer. Say plainly which of the four areas is still thin.
````

### `skills/domain-modeling/SKILL.md`

````markdown
---
name: domain-modeling
description: Build and sharpen a project's shared vocabulary and decision records. Use when discussing what to call something, when a word keeps getting used two ways, when writing or editing CONTEXT.md, or when recording an architectural decision as an ADR. Triggers - "what should we call this", "add this to the glossary", "write an ADR", "record this decision".
---

# Domain modeling

Design lives in version control, in two shapes:

- **`CONTEXT.md`** — the shared vocabulary. One term per entry.
- **`docs/adr/`** — decision records. The title IS the decision.

Write both **lazily**: when a word or a decision actually settles in conversation, not upfront.
If neither file exists yet, create the one you need and say nothing about the other.

## CONTEXT.md — one term per entry

An entry says what the term is, what it is NOT, and which synonym you are deliberately avoiding.
The "not" line is the part that does the work: a glossary that only says what words mean does not
stop anybody using a different word tomorrow.

### Worked example

    ### Binding
    
    A recorded link between a conversation and one table the agent may read. A binding is created
    by a click in the catalog, never by the agent, and it survives the conversation that made it.
    
    **Not:** "connection". A connection is the credential-level link to a data source, and one
    connection carries many bindings.

Compare that with an entry that does not earn its place:

    ### User
    
    A person who uses the product.

That says nothing the word did not already say. Delete it. A glossary of forty such entries is
worse than no glossary, because it teaches the reader that reading it is a waste of time.

### When to write one

Write an entry the moment you catch either of these:

1. **Two words for one thing.** You said "binding", the ticket says "link", the code says `attach`.
2. **One word for two things.** "Sync" means the 5-minute job in one file and the initial import
   in another.

The second is the expensive one. It does not look like a problem until someone fixes the wrong
sync.

## ADRs — the title is the decision

Not "database choice". Not "ADR about caching". The sentence you would say out loud.

| Bad title | Good title |
| --- | --- |
| `0004-authentication.md` | `0004-the-gateway-is-the-trusted-enforcement-point.md` |
| `0007-file-storage.md` | `0007-a-folder-is-the-unit-of-the-act-a-file-is-the-unit-of-the-record.md` |
| `0011-error-handling.md` | `0011-a-provider-reports-failure-and-the-caller-decides-what-it-costs.md` |

A reader scanning `ls docs/adr/` should learn the architecture from the filenames alone. That is
the whole test.

### The shape

    # <the decision, as a sentence>
    ## Status            Accepted | Superseded by ADR-XXXX
    ## Context           What was true that forced a choice. Facts, not opinions.
    ## Decision          Present tense. "We do X."
    ## Consequences      What this makes easy. What it makes hard.
    ## Rejected          The plausible wrong answer, and why it fails.

**`Rejected` is the highest-value section.** Someone will re-derive the wrong fix in about ten
minutes. Writing down why it fails saves that ten minutes, every time, forever.

### Worked example of a Rejected section

    ## Rejected
    
    **Cache the permission check for 60 seconds.** It is the obvious fix and it halves the call
    count. It fails because a revoked grant then stays live for up to a minute, and the whole
    point of routing through the gateway is that a revocation takes effect at the next call.
    
    If the call count becomes a real problem, the answer is to batch the checks within one turn,
    not to cache across turns.

Note what that paragraph does: it agrees the rejected fix is attractive, names the exact condition
that breaks it, and points at the fix that would actually work. A reader who arrives with that
idea is answered in thirty seconds.

## Watch the ADR number

Two sessions in two worktrees both write `0007-` and nothing conflicts, because the filenames
differ. The collision is silent and lands on `main`.

Read the remote tip before you pick a number:

    git fetch origin && git ls-tree --name-only origin/main docs/adr/ | tail -3

## Flag conflicts, do not silently override

If what you are writing contradicts an existing ADR, say so:

> Contradicts ADR-0007 (a folder is the unit of the act) — but worth reopening, because the
> dataset case has no folder and ADR-0007 assumed every act had one.

Then let the person decide. A superseded ADR gets its `Status` line updated; it is never deleted.
````

### `skills/design-check/SKILL.md`

````markdown
---
name: design-check
description: Check a screen or component against the repo's own design system before anyone opens it. Use when building or changing UI, reviewing a screen, or when asked whether a layout is right. Triggers - "check this screen", "does this match the design system", "review this UI", "design review".
---

# Design check

Stage 02 of the loop. UX rules are applied **while the work is written**, not caught in review.
A screen is checked against the design system before anyone opens it.

## First, find the design system

Read, in this order, and stop at the first that exists:

1. `docs/design-system.md` in this repo.
2. A design-system file named in `CLAUDE.md`.
3. Any `~/.claude/rules/*design*.md`.

**If none exists, say so and stop.** Do not invent tokens, do not guess a palette, and do not fall
back on generic taste. A design check with no design system is an opinion, and it wastes a review
cycle. Offer to create `docs/design-system.md` instead; the template in this repo has the shape.

## The checklist

Run every item. Report the ones that fail, most severe first.

### States and feedback

- [ ] Is there a design and copy for the **error** state?
- [ ] Is the **empty** state actionable? It must answer: what is this, why is it empty, what can
      I do?
- [ ] Are disabled elements explained — why disabled, and how to enable?
- [ ] Do system errors read as human sentences, while user code output stays raw and monospaced?

### Hierarchy

- [ ] Exactly **one** primary button per screen, modal or form.
- [ ] Does every button label start with a verb and name its object? "Delete project", not
      "Delete".
- [ ] Do headings run in order, with no skipped level and one H1?

### Interactive elements

- [ ] Does every icon-only button have a tooltip? This is mandatory, not a nicety.
- [ ] Is every click target at least 24x24px, or 44x44px for touch?
- [ ] Are frequent actions near where the user is already looking?

### Tables and data

- [ ] Does truncated text have a tooltip showing the full content?
- [ ] Is the primary identifier column never truncated?
- [ ] Can a person tell two rows apart without clicking into each one?
- [ ] Does a side panel overlay the table rather than crushing it?

### Forms

- [ ] Labels above fields, never a placeholder standing in for a label.
- [ ] Validation on blur, not on every keystroke.
- [ ] Are optional or advanced sections collapsed, with a summary when collapsed
      ("2 variables defined")?
- [ ] Does an empty code editor carry a placeholder example?

### Copy

- [ ] Sentence case, except for product nouns the design system names.
- [ ] Active voice. "Save changes", not "Changes can be saved".
- [ ] No exclamation points. No unnecessary apologies.

## Severity

| Severity | Definition | Example |
| --- | --- | --- |
| High | Blocks the goal, or causes real confusion | Truncated data with no tooltip and no other way to read it |
| Medium | Slows the user or reduces confidence | An icon-only button with no tooltip; a non-actionable empty state |
| Low | Polish | Spacing that could be tighter; a copy improvement |

## What NOT to flag

- User code output shown raw. That is correct — it is for debugging.
- Uniform row spacing in a data table. Also correct.
- A dense display aimed at technical users, such as a job log.

Flagging these three is the fastest way to make a design review ignored.

## What a screenshot cannot tell you

Say these are unverified rather than passing them:

tooltip presence, hover and focus states, loading states, responsive behaviour, keyboard
navigation.

### Worked example of a finding

> **High — the Source column truncates and has no tooltip.**
> `WorkspaceTable.tsx:118`. A source path longer than 32 characters renders as
> `s3://analytics-prod/2026/…`, and there is no other place in the UI that shows the full path.
> A person comparing two rows cannot tell which bucket each one points at.
> **Fix:** wrap the cell in the design system's `Tooltip` with the full value, and raise the
> column's default width to 240px.

Note the shape: severity, the file and line, the condition that triggers it, what the person
cannot do, and the specific fix. A finding without the condition is an opinion.
````

### `skills/tdd/SKILL.md`

````markdown
---
name: tdd
description: Test-driven development, and proving a guard is actually armed. Use when building a feature or fixing a bug test-first, when asked for red-green-refactor, or when a test passes and you are not sure it would ever fail. Triggers - "write a test first", "red green refactor", "does this test actually test anything", "prove the guard works".
---

# Test-driven development

Stage 04 of the loop. The agent must be able to check its own work before a person sees it.

Turn the task into a verifiable goal before writing any code:

- "Add validation" becomes "write tests for invalid input, then make them pass".
- "Fix the bug" becomes "write a test that reproduces it, then make it pass".

## The loop

1. **Red.** Write the test. Run it. **Watch it fail, and read the failure message.**
2. **Green.** Write the least code that passes.
3. **Refactor.** Clean up with the test still green.

Step 1 is not optional and it is not ceremony. A test you have never seen fail is not evidence.

## A green test proves nothing until you have seen it red

This is the single most valuable habit in the skill. Before you trust a guard, plant a deliberate
failure for **each condition it covers**, confirm the failure, then remove the plant.

### Worked example

A guard that refuses a query when the table is unbound OR the user lacks read permission. Two
conditions, so two plants:

```python
# Plant 1: break the binding check.
# In service.py, temporarily change:
#     if not binding: raise Unbound()
# to:
#     if False: raise Unbound()
# Run the test. It MUST go red.
```

```python
# Plant 2: break the permission check, with plant 1 restored.
# In service.py, temporarily change:
#     if not user.can_read(table): raise Denied()
# to:
#     if False: raise Denied()
# Run the test. It MUST go red.
```

If plant 2 stays green, the test only ever exercised the binding path. That is a test that reads
as coverage and is not.

**One plant per condition.** A single plant that reds the test tells you the test is connected to
*something*, not that it covers everything it claims.

### The trap this catches

A shared noun in the brief covering two faults that fail in opposite directions. You plant the
one the brief named, it goes red, and you conclude the guard is armed — while the other condition
has never been exercised. Measured more than once: a green plant may not have planted the
condition you meant.

## Seams: where tests go

A seam is a public boundary. Tests live at seams, never against internals. Code can change
entirely; the tests should not.

**Agree the seams before writing the first test.** Say which boundaries you intend to test, and
confirm them. You cannot test everything, and agreeing up front puts the effort on the critical
paths instead of on every edge case.

> "The seams I plan to test are the `POST /v1/query` handler and the `resolve_binding()` return
> value. I am not testing the SQL builder directly — it has no callers outside `resolve_binding`.
> Does that match how you see it?"

## What a good test looks like

It reads like a specification. `test_a_user_can_check_out_a_valid_cart` tells you a capability
exists. `test_cart_service_calls_validate_once` tells you about today's implementation and goes
red the moment somebody refactors.

| Anti-pattern | Why it hurts | Instead |
| --- | --- | --- |
| Asserting on a mock's call count | Goes red on a correct refactor | Assert on the returned value or the stored row |
| One test with eight assertions | The first failure hides the other seven | One behaviour per test |
| A fixture the producer can never emit | The test passes on data that cannot happen | Build the fixture by calling the real producer |
| A predicate keyed on a word the producer always emits | The assertion is true regardless | Assert an equality over the whole list |

## Name tests after the behaviour

    def test_an_unbound_table_is_refused_before_any_query_runs():
    def test_a_revoked_grant_takes_effect_on_the_next_call():

Not `test_query_1`, not `test_error_case`.

## Read CONTEXT.md first

When you explore the codebase, read `CONTEXT.md` if it exists, so test names use the project's own
vocabulary. A test called `test_connection_is_refused` in a repo whose glossary says "binding"
makes the next reader check whether it is testing something else.

## Fix the code, not the test

A failing test is evidence. Do not weaken it, reorder it, or delete it to go green. If the test is
genuinely wrong, say why in one sentence and change it deliberately — then plant a failure to
confirm the new version still catches what the old one caught.
````

### `skills/scoped-review/SKILL.md`

````markdown
---
name: scoped-review
description: Code review scoped to the changed paths only, with no full test-suite run. Use before landing a change, when reviewing a branch or PR, or when asked to review work in progress. Triggers - "review this", "review the branch", "review before I land", "scoped review".
---

# Scoped review

Stage 05 of the loop. Review only what changed. A whole-repo review costs roughly 13 minutes of
model turns and finds no more than a scoped one.

## 1. Collect the changed paths first

    git diff --name-only $(git merge-base HEAD origin/main)...HEAD
    git ls-files --others --exclude-standard

If you cannot name the changed paths, stop and ask. A review with no scope is the most expensive
mistake available here.

## 2. Stop if the change is too large

More than 40 files: do not start. Report the count, group the files by area, and ask which group
to review first.

> "This branch touches 63 files. They group as: the sync worker (31), the migration (18), tests
> (14). Which group first?"

## 3. Never run the full test suite

Do not run `pytest` over the whole project. Do not run `-n auto` over the whole project. Run only
the tests that cover the changed files. If you cannot tell which those are, say so and ask.

A green full suite is the commit's job, not the review's.

## 4. What to look for

In this order. Stop at the first category that produces findings worth reporting.

| Category | The question |
| --- | --- |
| Correctness | Given what inputs does this produce the wrong output or crash? |
| Composition | Each step is correct — is the composition a no-op? |
| Dead paths | Does this repair a branch nothing reaches, shipping unrun code? |
| Reuse | Does a helper for this already exist three files away? |
| Simplification | Would a senior engineer call this overcomplicated? |

### Every finding needs a failure scenario

A finding without concrete inputs is an opinion. Report the shape:

> **`sync/worker.py:214` — the retry loop never terminates on a malformed token.**
> `refresh()` returns `None` for a token that parses but has no `exp` claim. The loop treats
> `None` as "retry", so a workspace with a malformed token retries every 200ms forever and the
> log fills with identical lines.
> **Reproduce:** a token whose payload is `{"sub": "u1"}` with no `exp`.
> **Fix:** treat a `None` return as terminal and raise `TokenInvalid`.

Compare with a finding that will be ignored:

> The retry logic could be more robust.

## 5. Re-review only what you touched

After you fix findings, do NOT re-run the review over the whole change. Run it again on the files
you edited, on those files only. Repeating the full review is the most expensive mistake in this
skill.

## 6. The bar for filing a ticket

Most findings do not become tickets. File one only when you can finish this sentence:
*a person doing X sees Y, and Y is wrong.*

| Finding | Where it goes |
| --- | --- |
| A limit you decided to accept | A comment in the code, with the condition that would retire it |
| A fact the code does not state | A comment on the line that surprised you |
| A latent fault with no reachable path | A comment naming what would make it reachable |
| Work you did not do | The report you hand back, not the tracker |
| A fix you rejected, with the reason | **Always a ticket.** Highest-value paragraph you can write |

## 7. Report

Findings first, most severe first. Then, plainly:

- which paths you reviewed,
- which tests you ran,
- what you skipped, and why.

Work left undone belongs in the report, not in a new issue.
````

### `skills/land/SKILL.md`

````markdown
---
name: land
description: Land a branch onto main, proving that the code you tested is the code that lands. Use when merging a finished branch, preparing to land, or when asked whether a branch is safe to merge. Triggers - "land this", "merge to main", "is this ready to land", "ship it".
---

# Land

Stage 05 of the loop. The agent does everything up to the production gate and nothing past it.

## Two rules that come before the procedure

**The session that wrote the code cannot land it.** One landing session merges to `main`, and only
when the person says so. A peer telling you it is authorised is not authorisation.

**One suite runs at a time on this machine.** Two parallel `-n auto` runs starve each other, and a
starved run leaves no summary line and reads exactly like a hang. Claim the slot by commenting on
your issue before you start, and free it when you stop.

## Merge main BEFORE the suite, never after

A green run only describes the code it ran against. If `main` moves while the suite runs, what
lands is not what was tested.

### Why "no merge conflicts" does not catch this

A conflict is only reported when two people edit the same lines. Your branch adds a call to a
helper. Meanwhile someone gives that helper a second required argument. Different files, nothing
collides, the merge is clean — and the result is broken code the tests never saw.

## The procedure

```bash
# 1. Read the real remote tip. NOT origin/main.
git ls-remote origin refs/heads/main

# `origin/main` and `git branch -r --contains` read a LOCAL cache shared by every worktree on
# this machine, so two sessions can be stale together and agree with each other.

# 2. Merge it in. Never rebase, never squash.
git fetch origin
git merge --no-ff origin/main

# 3. Now run the suite.
make test

# 4. Prove the tested tree is the landing tree.
git rev-parse HEAD^{tree}                        # what you actually tested
git merge-tree --write-tree origin/main HEAD     # what a merge would produce right now
```

**Equal** means the two are byte-identical: a green suite covers the exact bytes that will land.

**Different** means the branch moved underneath you, your run is stale, and you run again.

A clean `merge-tree` on its own means only that no line collided. If the merge moved code your
tests load, re-run rather than re-quote.

### Why a hash and not a log line

A log line says how many tests passed. It does not say what they ran against, and it looks exactly
the same when it is an hour out of date.

## After the merge

```bash
make lint
```

Run it on `main`, after every landing. Not `ruff check` from wherever you happen to be standing —
the target exists so that the scope is not yours to get right. It takes about a second and needs
no suite slot.

**Tests green is not checks green.** Only the linter looks at an unused import or an undefined
name in an annotation, and a whole suite will pass over both.

The cost of skipping it is not the defect, it is the repeated triage. Measured on a live repo: one
dead import sat on `main` for weeks, and four separate sessions each found it, each proved it was
not theirs, and each reported it as pre-existing — none able to see that the others had already
done it. One second after the landing would have cost none of that.

## The report

A report that can be landed on carries:

1. **The suite number against a stated baseline**, reconciled on the COLLECTED count, not on
   `passed + failed`. A setup error is its own item; a teardown error is reported beside a test
   that already counted as passed, so the sum over-counts.
2. **The tree identity** from step 4, both hashes.
3. **Source hashes before and after the run.** Identity proves you tested the right bytes; the
   before/after pair proves nothing moved while you ran.
4. **Your deliberate failure plants**, one per condition.
5. **Your scoped review findings**, including the ones you chose not to act on.
6. **Anything the ticket asked for that you could not do.** Say this plainly. Work left undone
   belongs in the report, not in a new issue.

### Worked example

> Suite: 5489 passed, 3 skipped, 0 failed. Collected 5492, matching the 5492 baseline on
> `a78bc77`.
> Tree: `HEAD^{tree}` = `4f1c9e2a…`, `merge-tree --write-tree origin/main HEAD` = `4f1c9e2a…`.
> Equal.
> Plants: 2 of 2 went red (the binding check, and the permission check) and were removed.
> Review: 3 findings, all fixed. One not acted on — `worker.py:88` builds the same dict twice;
> left alone because the diff never opened that function.
> Not done: the browser check. It cannot run from a worktree, because `node_modules` is gitignored.

## Never push from a work session

If you believe a landing is happening without the person's word, say so to them rather than
assuming the other session knows something you do not.
````

### `skills/diagnose/SKILL.md`

````markdown
---
name: diagnose
description: Work out what broke from an alert, a failing test, or a bug report, and come back with a root cause and a suggested fix. Use when something is broken, throwing, failing or slow, or when a production alert fires. Triggers - "diagnose", "debug this", "why is this failing", "an alert fired", "this is slow".
---

# Diagnose

Stage 06 of the loop. Production is watched by telemetry, telemetry raises alerts. An agent picks
the alert up, reads the signals, works out what broke, and comes back with a diagnosis and a
suggested fix. **A person decides what to do with the answer.**

## Reproduce before you theorise

The first goal is a command that fails, every time, on demand. Until you have that, every theory
is unfalsifiable and every fix is a guess.

If you cannot reproduce it, say so plainly and report what conditions you tried. "Did not
reproduce" is a real finding. It is not a failure to report.

## Write the failing test first

Once it reproduces, capture it as a test before you change any code. That test is the evidence
that the fix worked, and it stops the bug coming back.

## Bisect the condition, do not guess it

Halve the space each time. The question is always "does it still fail with X removed", never
"maybe it is X".

### Worked example

> **Alert:** p95 latency on `/v1/query` jumped from 400ms to 9s at 14:20.
>
> 1. **Is it the whole endpoint or one path?** Split the metric by `binding_kind`. Only `dataset`
>    is slow; `table` is unchanged. Space halved.
> 2. **Is it the query or the fetch?** The span breakdown shows 8.6s inside `resolve_dataset`,
>    40ms in the query itself. Space halved.
> 3. **Is it every dataset or one?** Group by dataset id. Every dataset over about 4,000 files is
>    slow; smaller ones are fine. Now it is a shape, not a mystery.
> 4. **What changed at 14:20?** `git log --since=13:00 --until=14:30` shows one deploy that added
>    a `stat()` per file to compute a total size.
>
> **Root cause:** `resolve_dataset` now stats every file to report a size the caller discards.
> **Fix:** compute the size lazily, behind the field that reads it.
> **Reproduce:** a dataset with 5,000 files; `resolve_dataset` takes 8s against 40ms before the
> deploy.

Four steps, each one halving the space, each one a measurement rather than a hunch.

## Read what the failure actually says

| Signal | What it usually means | What it is NOT proof of |
| --- | --- | --- |
| `OSError` / `io.open` failure inside the test runner | Resource pressure | It also comes from a leaked handle, or a tmpdir another test removed |
| A test red in a file your diff never opened | Shared state left behind by another test | Not necessarily yours — run it alone first |
| A green re-run on the identical tree | The failure is not deterministic | NOT that it was a fluke. A leak that only fires when two tests share a worker also comes back green |

## Four checks for a red in a file your diff never opened

In this order, before you read a line of that file:

1. Run it alone.
2. Run it beside your new file with parallelism off.
3. Run the full suite with your new file deselected.
4. Re-run the full suite on the byte-identical tree.

Passing 1-3 means the red is not yours. **Check 4 says what it is instead, and the first three
cannot.** A re-run that reds the same test again is deterministic: say so, file it, move on. A
re-run that comes back green says only that it is not deterministic.

Either way: do not go green by reordering or deleting tests.

## Stop after about three rounds of patching

If three attempted fixes have not held, the risk is in the model of the problem, not in the diff.
Stop patching. Say what you now believe is wrong with your model, and what would confirm it.

## Hand back

A diagnosis, not a fix applied to production:

- **What broke**, in one sentence.
- **The reproduction** — the exact command or condition.
- **The root cause**, distinguished from the symptom.
- **The suggested fix**, and the plausible fix you rejected with the reason.
- **What you could not determine.**

The person decides what to do with it. Their decision starts the loop again at stage 01.
````

---

## 4. Scaffold a new repo

```bash
./scaffold.sh /path/to/new-repo
```

Eleven files and one symlink. It never overwrites a file that exists, so it is safe to re-run.

### `scaffold.sh`

````bash
#!/usr/bin/env bash
# Scaffold a new repo with the ship loop already wired.
#
#   ./scaffold.sh /path/to/new-repo
#
# Copies the template files, symlinks AGENTS.md to CLAUDE.md, and creates the triage labels if a
# GitHub remote is already set. Never overwrites a file that exists, so it is safe to re-run.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/template" && pwd)"
DEST="${1:?usage: scaffold.sh /path/to/repo}"

mkdir -p "$DEST"
cd "$DEST"

copy() {
  if [ -e "$1" ]; then
    echo "  skip   $1 (exists)"
  else
    mkdir -p "$(dirname "$1")"
    cp "$SRC/$1" "$1"
    echo "  create $1"
  fi
}

echo "Scaffolding $DEST"
copy CLAUDE.md
copy CONTEXT.md
copy .claude/settings.json
copy docs/design-system.md
copy docs/adr/0000-template.md
copy docs/agents/issue-tracker.md
copy docs/agents/triage-labels.md
copy docs/agents/domain.md
copy Makefile
copy .python-version
copy .github/workflows/tests.yml
copy tests/test_ci_does_not_report_success_on_a_skipped_suite.py

if [ -e AGENTS.md ]; then
  echo "  skip   AGENTS.md (exists)"
else
  ln -s CLAUDE.md AGENTS.md
  echo "  create AGENTS.md -> CLAUDE.md"
fi

if git rev-parse --git-dir >/dev/null 2>&1 && gh repo view >/dev/null 2>&1; then
  echo "Creating triage labels"
  for L in needs-triage needs-info ready-for-agent ready-for-human wontfix later; do
    gh label create "$L" --force >/dev/null 2>&1 && echo "  label  $L"
  done
else
  echo "No GitHub remote yet - create the labels later:"
  echo "  for L in needs-triage needs-info ready-for-agent ready-for-human wontfix later; do gh label create \$L --force; done"
fi

cat <<'NEXT'

Done. Next, by hand:
  1. Fill CONTEXT.md with the first three words that matter. Delete the example entry.
  2. Write ADR-0001. Title it with the decision itself.
  3. Fill docs/design-system.md, or delete it if this repo has no UI.
  4. make setup && make test && make lint   (both gates must run before you write real code)
  5. Plant a deliberate failure in one test. Confirm it goes red. Remove it.

Step 5 is the one people skip. A green suite proves nothing until you have seen it red.
NEXT
````

---

## 5. The template files in full

These are what `scaffold.sh` copies.

### `template/.claude/settings.json`

````json
{
  "extraKnownMarketplaces": {
    "subir": {
      "source": {
        "source": "github",
        "repo": "ddl-subir-m/kata"
      }
    }
  },
  "enabledPlugins": {
    "kata@subir": true
  }
}
````

### `template/CLAUDE.md`

````markdown
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
| 01 Shape a request into a spec and tickets | `shape-request` |
| 01/02 Vocabulary and decisions | `domain-modeling` |
| 02 Check a screen before anyone opens it | `design-check` |
| 04 Write the test first; prove the guard is armed | `tdd` |
| 05 Review only the changed paths | `scoped-review` |
| 05 Merge main, prove the tested tree is the landing tree | `land` |
| 06 Work out what broke and hand back a diagnosis | `diagnose` |
````

### `template/CONTEXT.md`

````markdown
# Context

The shared vocabulary for this repo. One term per entry. Agents use these words and do not drift
to synonyms.

Write an entry when a word gets settled in conversation — not weeks later. If a word you need is
not here, either you are inventing language the project does not use, or there is a real gap.

## How to write an entry

An entry says what the term is, what it is **not**, and which synonym you are deliberately
avoiding. The "not" line does the work. A glossary that only says what words mean does not stop
anybody using a different word tomorrow.

Write one the moment you catch either of these:

1. **Two words for one thing.** You said "binding", the ticket says "link", the code says `attach`.
2. **One word for two things.** "Sync" means the 5-minute job in one file and the initial import
   in another. This is the expensive one — it does not look like a problem until somebody fixes
   the wrong sync.

## Glossary

### Binding

_(Example entry. Delete it once you have three real ones.)_

A recorded link between a conversation and one table the agent may read. A binding is created by a
click in the catalog, never by the agent, and it survives the conversation that made it.

**Not:** "connection". A connection is the credential-level link to a data source, and one
connection carries many bindings.

### <Term>

<One paragraph. What it is, and what it is NOT.>

**Not:** <the word people reach for that means something else here>

---

An entry that does not earn its place looks like this, and should be deleted:

> **User** — a person who uses the product.

It says nothing the word did not already say. A glossary of forty such entries is worse than no
glossary, because it teaches the reader that reading it is a waste of time.

---

## Decisions

Decisions live in `docs/adr/`, one file each, titled with the decision itself.
````

### `template/docs/adr/0000-template.md`

````markdown
# The title is the decision itself

Not "database choice". Not "ADR about caching". The sentence you would say out loud.

| Bad title | Good title |
| --- | --- |
| `0004-authentication.md` | `0004-the-gateway-is-the-trusted-enforcement-point.md` |
| `0007-file-storage.md` | `0007-a-folder-is-the-unit-of-the-act-a-file-is-the-unit-of-the-record.md` |
| `0011-error-handling.md` | `0011-a-provider-reports-failure-and-the-caller-decides-what-it-costs.md` |

A reader scanning `ls docs/adr/` should learn the architecture from the filenames alone. That is
the whole test.

**Before you pick a number**, read the remote tip — two worktrees both writing `0007-` conflict
in nothing, because the filenames differ:

    git fetch origin && git ls-tree --name-only origin/main docs/adr/ | tail -3

---

## Status

Accepted | Superseded by ADR-XXXX

## Context

What was true that forced a choice. Facts, not opinions.

> Every query went through the client SDK, which meant the permission check ran in the caller's
> process. Three callers existed and two of them cached the result.

## Decision

The decision, in the present tense. "We do X."

> The gateway is the trusted enforcement point. Every read passes through it, and no caller
> checks permissions itself.

## Consequences

What this makes easy. What this makes hard. What a reader must now accept.

> **Easy:** a revocation takes effect at the next call, with no cache to drain.
> **Hard:** the gateway is now on the hot path for every read, so its latency is the floor for
> every caller.
> **Accept:** a caller cannot answer "may I read this" without a network hop.

## Rejected

The plausible wrong answer, and why it fails. **This is the highest-value section.** Someone will
re-derive the wrong fix in about ten minutes; writing down why it fails saves that ten minutes
every time.

> **Cache the permission check for 60 seconds.** It is the obvious fix and it halves the call
> count. It fails because a revoked grant then stays live for up to a minute, and the whole point
> of routing through the gateway is that a revocation takes effect at the next call.
>
> If the call count becomes a real problem, the answer is to batch the checks within one turn, not
> to cache across turns.

Note what that paragraph does: it agrees the rejected fix is attractive, names the exact condition
that breaks it, and points at the fix that would actually work. A reader arriving with that idea
is answered in thirty seconds.
````

### `template/docs/agents/issue-tracker.md`

````markdown
# Issue tracker: GitHub

Issues live as GitHub issues. Use the `gh` CLI for all operations. `gh` infers the repo from
`git remote -v` when run inside a clone.

## Operations

- **Create**: `gh issue create --title "..." --body "..."` (heredoc for multi-line bodies).
- **Read**: `gh issue view <number> --comments`
- **List**: `gh issue list --state open --json number,title,labels --jq '.[] | {number,title,labels:[.labels[].name]}'`
- **Comment**: `gh issue comment <number> --body "..."`
- **Label**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

## Blocking

GitHub native issue dependencies, which are visible in the UI:

    BLOCKER_ID=$(gh api repos/<owner>/<repo>/issues/<blocker> --jq .id)
    gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by \
      -F issue_id=$BLOCKER_ID

Note: `issue_id` is the numeric **database id**, not the `#number` and not the `node_id`.
`issue_dependencies_summary.blocked_by` counts open blockers only — that is the live gate.

## When to file

**A ticket needs a symptom: something a person could hit, and notice.**

File it when you can finish this sentence: *a person doing X sees Y, and Y is wrong.*

### Worked examples

| Finding | File it? | Why |
| --- | --- | --- |
| A source path over 32 chars truncates in the table with no tooltip, so a person comparing two rows cannot tell which bucket each points at | **Yes** | X and Y are both concrete |
| `resolve_binding` builds the same dict twice | No | Nobody sees anything. It is a comment on the line |
| The retry loop would spin forever on a malformed token, but the parser rejects those upstream | No | Latent, no reachable path. Say so in the code |
| The browser check could not run from a worktree | No | Work you did not do. It goes in the report |
| "Cache the permission check for 60s" was rejected because a revoked grant stays live for a minute | **Yes** | A rejected fix with its reason is always worth a ticket |

This bar exists because agent review works. It finds real things. Filing every one of them turns
`ready-for-agent` from "pick this up" into "was filed". The cost of a ticket is not writing it —
it is that every future reader must re-read it and decide again.

Do NOT file when the finding is one of these. Each has a better home:

- **A limit you decided to accept.** Write it in the code, with the condition that would retire it.
  The next reader asks "may I delete this?" and a ticket cannot answer that.
- **A fact you learned that the code does not state.** A comment on the line that surprised you.
  A ticket is the wrong shape for knowledge — it gets closed, and the knowledge goes with it.
- **A latent fault with no reachable path.** Say so in the code and name what would make it
  reachable. If the path arrives, THAT is the ticket.
- **Work you simply did not do.** Say it in the report, not the tracker.

When a finding is real but nobody is hurt today, `later` is the honest label. It is not a softer
`wontfix` — it says the work is right and the moment is not now.

**Always worth a ticket, regardless:** a fix you rejected, with the reason. A plausible wrong fix
will be re-derived by the next person in about ten minutes. Writing down why it fails is the
single highest-value paragraph in most issues here.

## A ticket body that an agent can pick up

    ## Symptom
    A person filtering the Sources table by bucket sees rows whose Source column reads
    `s3://analytics-prod/2026/...`. There is nowhere else in the UI that shows the full path.

    ## Reproduce
    Open /workspaces/42/sources with any source path longer than 32 characters.

    ## Expected
    The full path is reachable — a tooltip on hover, at minimum.

    ## Where
    `WorkspaceTable.tsx:118`

    ## Rejected
    Widening the column to fit the longest path. The longest path is 180 characters and the
    table has five other columns.

Five short sections. "Rejected" is there for the same reason it is in an ADR.
````

### `template/docs/agents/triage-labels.md`

````markdown
# Triage labels

| Label             | Meaning                                    |
| ----------------- | ------------------------------------------ |
| `needs-triage`    | Needs evaluation                           |
| `needs-info`      | Waiting on the reporter                    |
| `ready-for-agent` | Fully specified, an agent can pick it up   |
| `ready-for-human` | Needs human implementation                 |
| `wontfix`         | Will not be actioned                       |
| `later`           | Real, correctly filed, no live symptom     |

Create them once:

    for L in needs-triage needs-info ready-for-agent ready-for-human wontfix later; do
      gh label create "$L" --force
    done

## One example per label

| Label | Example issue |
| --- | --- |
| `needs-triage` | "Sync feels slow sometimes." Nobody has looked yet. |
| `needs-info` | "The export failed." No workspace id, no timestamp, no error text. |
| `ready-for-agent` | "Source paths over 32 chars truncate with no tooltip. `WorkspaceTable.tsx:118`. Add the design system's `Tooltip` with the full value." Symptom, location and fix are all named. |
| `ready-for-human` | "Decide whether a dataset with no files counts as bound." A judgment call, not an implementation. |
| `wontfix` | "Support IE11." |
| `later` | "`resolve_dataset` stats every file to compute a size the caller discards. It is 8s on a 5,000-file dataset — but no production dataset is over 400 files yet." Real, correct, nobody hurt today. |

## Why `later` exists

A review that finds real things produces more tickets than anyone can hold. Filing every one of
them turns `ready-for-agent` from "pick this up" into "was filed", which is the failure this label
is for.

A `later` issue is **not** lesser work and it is **not** a softer `wontfix`. It says the work is
right and the moment is not now. Pick it up when its area is next opened for another reason.

Reach for it rather than not filing at all, and rather than filing as `ready-for-agent` and
hoping.

## The test for `ready-for-agent`

An agent can start without asking a question. If the issue does not name the symptom, the
location, and what "fixed" looks like, it is `needs-info` — even when you wrote it yourself.
````

### `template/docs/agents/domain.md`

````markdown
# Domain docs

How agents consume this repo's domain documentation.

**This repo is single-context**: one `CONTEXT.md` and one `docs/adr/`, both at the repo root.

## Before exploring, read these

- `CONTEXT.md` at the repo root.
- `docs/adr/` — the ADRs that touch the area you are about to work in.

If they do not exist, proceed silently. Do not flag their absence and do not suggest creating them
upfront. The `domain-modeling` skill creates them lazily, when a term or a decision actually
settles.

## Use the glossary's vocabulary

When your output names a domain concept — an issue title, a test name, a hypothesis, a variable —
use the term as `CONTEXT.md` defines it. Do not drift to a synonym the glossary avoids.

### Worked example

`CONTEXT.md` says:

> **Binding** — a recorded link between a conversation and one table the agent may read.
> **Not:** "connection".

| Do not write | Write |
| --- | --- |
| `test_connection_is_refused` | `test_an_unbound_table_is_refused` |
| "Fix the table link bug" | "An expired binding is not refused before the query runs" |
| `def attach_table(...)` | `def create_binding(...)` |

A test called `test_connection_is_refused` in this repo makes the next reader stop and check
whether it is testing the credential layer instead. That stop costs more than the rename.

## If the concept is not in the glossary yet

That is a signal, and it points two ways:

- You are inventing language the project does not use — reconsider the word.
- There is a real gap — note it, and write the entry with the `domain-modeling` skill.

Do not quietly pick a third word and move on. That is how a glossary rots.

## Flag ADR conflicts

If your output contradicts an ADR, surface it rather than silently overriding:

> Contradicts ADR-0007 (a folder is the unit of the act) — but worth reopening, because the
> dataset case has no folder and ADR-0007 assumed every act had one.

Then let the person decide. A superseded ADR gets its `Status` line updated; it is never deleted.
````

### `template/docs/design-system.md`

````markdown
# Design system

The `design-check` skill reads this file. Until it has real content, a design check has nothing to
check against and will say so rather than guess.

Fill in what your product actually uses. Delete what does not apply.

## Colour tokens

| Token | Hex | Usage |
| --- | --- | --- |
| Text / heading | `#000000` | Headings, labels, primary text |
| Text / body | `#000000` | Body copy, descriptions, secondary text |
| Primary | `#000000` | Primary button fill, links, active elements |
| On primary | `#FFFFFF` | Text and icons on primary backgrounds |
| Container border | `#000000` | Card borders, dividers, input borders |

## Button hierarchy

Exactly **one** primary button per screen, modal or form. Everything else is secondary, tertiary
or a link.

| Type | Background | Border | Text |
| --- | --- | --- | --- |
| Primary | Primary | — | On primary |
| Secondary | Secondary surface | Secondary border | Secondary text |
| Tertiary | transparent | — | Primary |

Labels start with a verb and name the object: "Delete project", not "Delete".

## Typography scale

| Level | Size | Use |
| --- | --- | --- |
| H1 | 32px | Page titles — one per page |
| H2 | 26px | Section headers |
| H3 | 20px | Subsection headers |
| Body | 14–16px | Primary content |
| Caption | 12px | Helper text, metadata |

Never skip a heading level. Minimum 14px for body text. Aim for 50–75 characters per line.

## Spacing

Space **within** a group is about **half** the space **between** groups. That creates visual
separation without drawing a border.

Apply it to forms, cards and detail panels. Do **not** apply it to data tables, homogeneous lists
or navigation menus — uniform spacing is correct there.

## Detail panels

| Pattern | Best for |
| --- | --- |
| Overlay side drawer | Quick previews and row details. Does not compress the main content |
| Modal dialog | Focused tasks and confirmations |
| Full page | Complex detail views. Use breadcrumbs |

Prefer an overlay drawer for table row details. It needs a backdrop, a close button, Escape to
close, and a slide animation.

## Copy

- Sentence case, except for product nouns named here.
- Active voice. "Save changes", not "Changes can be saved".
- No exclamation points. No unnecessary apologies.
- Numerals, not words: "3%", not "three percent".
- Dates as "Month Day, Year". Relative dates only within 7 days.

## Product nouns

Words that keep their capital letter. List them here so the check can tell a product noun from a
sentence-case slip.

- <Noun>
- <Noun>
````

---

## 6. The two gates in full

`make test` and `make lint`. The same two run on a laptop and in CI, so they cannot drift apart.
Build these on day one — an agent cannot check its own work without them.

### `template/Makefile`

````makefile
.PHONY: setup test lint clean

# One-command reproducible setup. Lockfile-driven, so a fresh clone and CI install the same bytes.
setup:
	uv sync --extra dev
	npm ci

# THE test gate. CI runs this exact target, so CI and a laptop cannot drift apart.
#
# `--extra dev` rather than relying on `make setup` having run: pytest lives in that extra, and a
# fresh clone or git worktree has a venv built from the default dependencies alone. Without it
# `uv run pytest` does not run a smaller suite — it fails to spawn at all, and piped through
# anything that swallows the exit code, that failure reads as a pass.
#
# `-n auto` fans the suite across cores. Drop it to read interleaved output or to run one failure
# under a debugger: `uv run --extra dev pytest -q -n0 <nodeid>`.
#
# `-rs` prints every skip with its reason. Without it, a skip is folded into a total that still
# reads clean — which is how a whole population of tests goes missing from a worktree in silence.
test:
	uv run --extra dev pytest -q -n auto -rs

# THE lint gate. The `..` scope is the point of this target, not a typo.
#
# Put the scope INSIDE the command, never in a sentence about it. A gate is the command you
# actually run. `ruff check` from a subdirectory lints that subdirectory, while the sentence in
# CLAUDE.md says "the whole repo" — and the narrower command still prints "All checks passed!".
#
# Pin the ruff version exactly with `required-version` in pyproject.toml, so this and CI cannot
# disagree about what counts as clean.
lint:
	uv run --extra dev ruff check .

clean:
	find . -name __pycache__ -type d -prune -exec rm -rf {} +
	rm -rf .ruff_cache .pytest_cache
````

### `template/.github/workflows/tests.yml`

````yaml
# The two steps are `make test` and `make lint`, never the commands they wrap. That is the whole
# point: CI and a laptop run the same two targets, so they cannot drift apart.
#
# Node is not optional here if any test file skips itself when `node` is absent. A Python-only
# runner passes green while testing none of the JavaScript, and that is worse than no CI — it
# looks like coverage. `tests/test_ci_does_not_report_success_on_a_skipped_suite.py` fails loudly
# if that ever regresses, so this file and that one have to stay in step.
name: tests

on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    env:
      # `requires-python` is a FLOOR, not a pin, and this line is the only thing that makes CI
      # agree with a laptop. Without it, uv picks a different interpreter in every worktree and
      # nothing says so. `.python-version` at the repo root puts local venvs on the same one.
      UV_PYTHON: "3.12"
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: "22"
          # Before lowering this pin, grep the JS harnesses for `node:` imports and check each
          # export against the floor — rather than trusting this comment. A comment was true when
          # it was written; a harness added a third module and nothing re-read it.

      - name: Install ripgrep
        # Present on the runner image today. Installed anyway, so the suite does not depend on
        # that staying true. The canary test turns its absence into a failure, not a silent skip.
        run: sudo apt-get update && sudo apt-get install -y ripgrep

      - uses: astral-sh/setup-uv@v5
        with:
          enable-cache: true

      - name: Tests
        run: make test

      - name: Lint
        # `always()` so a red suite does not hide a lint failure. Both answers on one run.
        if: always()
        run: make lint
````

### `template/tests/test_ci_does_not_report_success_on_a_skipped_suite.py`

````python
"""CI cannot report success on a suite it never really ran.

Test files that need an external tool guard themselves with
`skipif(shutil.which("node") is None)`. If the CI workflow installs Python but not Node, the run
passes green while testing none of that population — which is worse than having no CI, because it
looks like coverage.

These tests make the absence loud. They assert nothing about the product. They assert that the
runner has the tools one suite needs.

Off CI they are inert: a missing tool on a laptop is the developer's own informed choice. They
bind only when `CI` is set, which GitHub Actions does.

Deliberately narrow. This is not a ban on skipping. It names the tools whose absence silently
removes real coverage, and leaves every other skip alone.

Add a tool to this file the moment a test file starts skipping on it.
"""

from __future__ import annotations

import os
import shutil

import pytest

pytestmark = pytest.mark.skipif(os.getenv("CI") is None, reason="binds on CI only")


def test_node_is_on_path_so_the_js_harnesses_actually_run():
    assert shutil.which("node") is not None, (
        "node is not on PATH, so every JavaScript harness skipped itself and the front end "
        "went untested. Install Node in the workflow."
    )


def test_ripgrep_is_on_path_so_the_grep_based_tests_actually_run():
    assert shutil.which("rg") is not None, (
        "ripgrep is not on PATH, so every grep-based test skipped itself. "
        "Install ripgrep in the workflow."
    )
````

### `template/.python-version`

````text
3.12
````

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
