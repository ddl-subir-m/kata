---
name: grill
description: Stress-test a plan, a decision or an idea with hard questions, one at a time - grounded in the repo's own ADRs and vocabulary, and writing what settles back out as ADRs and glossary entries. Use when thinking needs pressure-testing before it becomes work, or when something sounds right but has not been challenged. Triggers - "grill me", "poke holes in this", "stress-test this plan", "what am I missing", "challenge this".
---

# Grill

Relentless interview. The goal is to find what breaks the idea, before code does.

**The facts are your job. The decisions are theirs.** You do the digging; you never choose.

## One question at a time

Never a numbered list. Ask, wait, then let the answer pick the next question. A batch of six
forces a person to answer the wrong five.

## Work the frontier

The frontier is the edge of what has actually been settled. Each round, aim at the weakest thing
that is being treated as settled.

    Round 1  →  the claim everything else rests on
    Round 2  →  whatever that answer just exposed
    Round 3  →  the thing they keep restating instead of answering

If an answer restates the plan rather than defending it, that is the frontier. Stay there.

## Read the record before the first question

A question from nothing is generic, and a generic question gets a generic answer. Read first, in
this order, and only what is there:

| Read | Looking for |
| --- | --- |
| `docs/adr/` | A decision this plan contradicts, or silently re-opens |
| `CONTEXT.md` | A domain word being used in a second sense |
| `docs/agents/issue-tracker.md` | Whether this is even worth a ticket |
| `docs/research/`, if present | A question somebody already answered |

**The sharpest question in the room is usually a citation.** "ADR-0007 chose the opposite and gave
a reason - what changed?" cannot be waved away, and it takes one `ls docs/adr/` to find, because an
ADR's title IS its decision.

Say what you read, in one line, before you start. If none of those files exist, say that too and
grill from first principles - but say it, so nobody mistakes an ungrounded interview for a
grounded one.

## The questions that earn their place

| Ask | Because |
| --- | --- |
| "What would have to be true for this to be wrong?" | Turns a belief into something checkable |
| "Who hits this, and what are they doing when they do?" | Vague users hide vague requirements |
| "What are you NOT doing, and why is that safe?" | Scope is defined by its edges |
| "What is the number that says this worked?" | No number means no finish line |
| "What did you try that did not work?" | Finds the constraint nobody wrote down |
| "If this ships and something breaks, what breaks first?" | Cheapest failure analysis there is |

## Stop pretending to be neutral

If you can see the flaw, name it. A grilling that only asks questions while knowing the answer
wastes the person's time.

> "You are assuming a revocation takes effect immediately. It cannot, if the check is cached for
> 60 seconds. Which one are you giving up?"

## Know when to stop

Stop when the next question would be invented rather than found. Then summarise:

- **What is settled**, in their words not yours.
- **What is still open**, as questions.
- **What you think is the weakest point**, said plainly, once.

## Write the record as you go

A grilling that settles something and leaves no trace has to be repeated, and the second time
nobody remembers the reasoning that made the first one land. Capture as you go, not at the end -
by the end the wording that convinced somebody has already been paraphrased away.

Use the `domain-modeling` skill to write these. Do not hand-roll the files; it knows the shapes.

| What just happened | What to write |
| --- | --- |
| A decision got made that outlives this branch | An ADR in `docs/adr/`, titled with the decision itself |
| A word turned out to mean two things | A `CONTEXT.md` entry naming which one wins here |
| An answer rested on a fact nobody has | Nothing yet - hand it to `research` first |
| An answer rested on whether something works, and only running code can say ("does a phone camera give a usable signal?") | Nothing yet - name the one question and hand it to `prototype` first |
| Something was ruled OUT, and why | The same ADR. The rejected option is half its value. |

**Not every answer earns an ADR.** The bar is whether somebody six months out would otherwise
re-open it. A decision that only shapes this branch belongs in the branch, not in `docs/adr/`.

**Write the rejected options down.** An ADR that lists only what was chosen reads as arbitrary, and
the next person re-argues the alternatives from scratch. The grilling is where those alternatives
were named out loud - that is the one moment they are cheap to record.

In a repo you do not own, use `grill-only` instead: same interview, same reading, but it says
what it would have written rather than writing it.

Say which files you wrote, or say plainly that nothing met the bar. Both are real outcomes; a
grilling that produces no ADR is not a grilling that failed.

Then hand it to `shape-request` to become a spec.
