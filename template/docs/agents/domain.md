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
