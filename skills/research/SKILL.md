---
name: research
description: Investigate a question against primary sources and leave the findings as a cited Markdown file in the repo. Use when a topic needs reading legwork, when API or library facts must be gathered, or when a claim needs checking against the thing that owns it. Triggers - "research this", "look into", "what does the API actually support", "check the docs on".
---

# Research

Delegate the reading to a background agent, so you keep working while it reads.

## The job you hand it

1. **Investigate against primary sources.** Official docs, the source code, the spec, the
   first-party API. Not a blog post about them. Follow every claim back to the thing that owns it.
2. **Write the findings to one Markdown file**, citing each claim's source with a link.
3. **Save it where the repo already keeps such notes.** Match the existing convention. If there is
   none, pick somewhere sensible and say where.

## A search result is not a source

This is the rule that does the work. A search snippet, an answer summary, or a model's memory of
an API is **not** a citation. Open the page. Read the section. Link to it.

> Bad: "The dependencies API takes the issue number."
> Good: "The dependencies API takes the numeric database id, not the `#number` or the `node_id`
> — [docs.github.com/.../dependencies](https://docs.github.com/), read 2026-09-20."

The second one survives being wrong, because the next reader can check it. The first one becomes
folklore.

## What the file must carry

- **The question**, as asked.
- **The answer**, first, in a sentence or two. Not a chronology of what you read.
- **Each claim with its link**, and the date you read it.
- **What you could not determine.** An open question written down is worth more than a confident
  guess, because it tells the next person where to start.

## Say what you could not verify

If the docs do not answer it, say so plainly rather than reasoning to a plausible answer. "The
page does not say, and I could not find it elsewhere" is a real finding.

If a claim held only under a version, say which. A fact with no version is a fact with an
expiry date and no label on it.

## Where it goes next

Research feeds thinking rather than replacing it. The file is material you take **into**
`shape-request` or `domain-modeling`, not a decision on its own.
