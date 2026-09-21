---
name: grill
description: Stress-test a plan, a decision or an idea with hard questions, one at a time, grounded in the repo's own ADRs and vocabulary rather than asked from nothing. Use when thinking needs pressure-testing before it becomes work, or when something sounds right but has not been challenged. Triggers - "grill me", "poke holes in this", "stress-test this plan", "what am I missing", "challenge this".
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

Then hand it to `shape-request` to become a spec, or `domain-modeling` if what settled was a word
or a decision rather than a plan.
