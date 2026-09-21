---
name: grill-only
description: Grill a plan without writing anything to the repo - no ADRs, no glossary entries. Use in a repo you do not own.
disable-model-invocation: true
---

Use the `grill` skill, with one change: skip **"Write the record as you go"** entirely. Write no
files. Do not create an ADR, do not edit `CONTEXT.md`, do not hand anything to `domain-modeling`.

**Still read the record.** The reading step stays. Grilling a plan without checking what the repo
already decided is how you ask a generic question, and a generic question gets a generic answer.
Reading writes nothing.

## Instead of writing, say what you would have written

At the end, in the chat and nowhere else:

> **Would have written** `docs/adr/0008-refresh-tokens-are-single-use.md` &mdash; chosen: single-use,
> rotated on every refresh. Rejected: long-lived with a revocation list, because the cache window
> makes revocation take up to 60 seconds.

Enough that somebody could paste it into a file, with the rejected option and its reason. An ADR
that lists only what was chosen reads as arbitrary, and that is just as true when it lives in a
chat window.

Then say plainly that nothing was written, and that `grill` is the one that writes.

## When this is the wrong skill

You own the repo and the decision outlives the branch. Then a paragraph in a transcript is a worse
outcome than a file, and `grill` is what you want. This skill exists for a repo you are a guest in,
or an idea too raw to be worth a number in `docs/adr/`.

Reaching for it because writing the file feels like a commitment is the case it is NOT for. That
hesitation is usually the signal the decision is real.
