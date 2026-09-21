---
name: writing-for-agents
description: Write documents that agents read - skills, CLAUDE.md, AGENTS.md, and the docs under docs/agents. Use when creating or editing a skill, or changing the standing instructions. Triggers - "write a skill", "edit CLAUDE.md", "add a rule", "document this for the agent".
---

# Writing for agents

A document an agent reads is not documentation. It is **instructions that compete for attention**
with everything else in the window.

## Two loads

Every line you write costs one of two things:

- **Always-on**: the frontmatter description of a skill, and all of `CLAUDE.md`. Paid every
  session, every turn. Roughly 100 tokens per skill description.
- **On-invoke**: the skill body. Paid only when it fires, and typically 1.5k.

So: **put the trigger words in the description and the detail in the body.** A body that is twice
as long costs nothing until it is needed. A description that is twice as long is a tax on every
session forever.

Check the real numbers rather than guessing:

    claude plugin details <plugin>

## Information hierarchy

Lead with the thing that changes what the reader does. Not context, not history.

> Bad: "Merging is an important part of the workflow. There are several considerations…"
> Good: "Merge `main` BEFORE the suite, never after. A green run only describes the code it ran
> against."

An agent that reads only your first sentence should still behave correctly.

## Steps need completion criteria

"Review the code" is not a step. A step says how you know it is finished.

> "Run the review. Stop if more than 40 files changed: report the count, group them, ask which
> group first."

Strong criteria let a session loop on its own. Weak criteria produce a check-in every two minutes.

## Give every rule an example

A rule with no example gets read as a slogan and ignored. One short, concrete case is worth three
paragraphs of principle.

> Rule: fix the code, not the test.
> Example: not allowed — changing `assert p95 < 90` to `assert p95 < 200` because it got slower.

## Say what NOT to do, and why

The failure mode is more memorable than the rule, and it is what the reader will recognise when
they are in it.

> "`-path '*subir*'` matches every path under `/Users/subirmansukhani`, which is all of them."

## Leading words

Front-load the operative word so a scanning reader catches it: **Never**, **Always**, **Stop if**,
**Before you**. Bury it mid-sentence and it is gone.

## When to split

Split when a document serves two different moments. One skill per moment the person is in, not one
per topic.

Do **not** split to make files shorter. Two shallow skills are worse than one deep one — the
reader now has to know which to reach for, which is interface they did not have before.

## Pruning

`CLAUDE.md` grows by one line each time a mistake happens **twice**. Not once, and not in advance.

Delete a rule when the condition that produced it is gone, and say so. A file of rules nobody can
trace to a real failure gets skimmed, and then the one rule that matters gets skimmed with it.

**The test for any line you add:** can you name the incident? If not, it is a guess, and it is
costing every session from now on.
