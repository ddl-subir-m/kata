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
