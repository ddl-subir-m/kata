---
name: prototype
description: Build a throwaway prototype to answer one design question. Use when a question needs a runnable answer rather than an argument - whether a state model holds up, whether a flow feels right, what a screen should look like. Triggers - "prototype this", "let's try it and see", "would this state model work", "what should this screen look like".
---

# Prototype

A detour off the main loop. You are here because a question **cannot be settled on paper** and
needs code you can run.

## First, name the question

One sentence, written down before any code. If you cannot write it, you do not need a prototype —
you need `grill`.

> "Can one conversation hold bindings to two tables without the query builder becoming ambiguous?"

A prototype that answers no question is just unreviewed code. This is the step that makes the
difference.

## It is throwaway. Mean it.

| Rule | Why |
| --- | --- |
| Its own directory, outside the repo's source tree | So nobody imports it by accident |
| No tests | You are not shipping it; the answer is the deliverable |
| No error handling | Impossible states are fine here |
| Hardcode everything | Config is a distraction from the question |
| Delete it when the question is answered | Or move it to `spikes/`, clearly marked |

If you find yourself making it robust, stop. You have started building the real thing in the wrong
place.

## Two kinds

### Logic

The question is about **state, rules or data shape**. Write the smallest program that exercises
the model and print the states it reaches.

> Question: does a binding survive a conversation being renamed?
> Prototype: a dict of bindings, a rename function, and six `print()` calls showing before/after.
> Twenty lines. Answered in ten minutes.

### UI

The question is about **what a person sees**. Build one screen with fake data. No routing, no
state management, no backend.

Check it against `docs/design-system.md` only if the question is about the design. If the question
is "does this flow make sense", ignore the styling entirely.

## Fold the answer back

The prototype is not the output. **The answer is.** Hand back:

- the question, as you wrote it at the start,
- the answer, in one or two sentences,
- what surprised you,
- what the prototype does **not** tell you.

That last one matters. A prototype with hardcoded data says nothing about behaviour at 50,000
rows, and saying so stops somebody treating it as proof.

If the answer settles a decision, write it up with `domain-modeling` as an ADR. That is where it
becomes durable; the prototype directory is not.
