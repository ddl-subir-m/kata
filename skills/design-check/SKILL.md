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
