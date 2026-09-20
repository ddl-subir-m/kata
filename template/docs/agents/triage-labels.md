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
