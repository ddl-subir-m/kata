---
name: domain-modeling
description: Build and sharpen a project's shared vocabulary and decision records. Use when discussing what to call something, when a word keeps getting used two ways, when writing or editing CONTEXT.md, or when recording an architectural decision as an ADR. Triggers - "what should we call this", "add this to the glossary", "write an ADR", "record this decision".
---

# Domain modeling

Design lives in version control, in two shapes:

- **`CONTEXT.md`** — the shared vocabulary. One term per entry.
- **`docs/adr/`** — decision records. The title IS the decision.

Write both **lazily**: when a word or a decision actually settles in conversation, not upfront.
If neither file exists yet, create the one you need and say nothing about the other.

## CONTEXT.md — one term per entry

An entry says what the term is, what it is NOT, and which synonym you are deliberately avoiding.
The "not" line is the part that does the work: a glossary that only says what words mean does not
stop anybody using a different word tomorrow.

### Worked example

    ### Binding
    
    A recorded link between a conversation and one table the agent may read. A binding is created
    by a click in the catalog, never by the agent, and it survives the conversation that made it.
    
    **Not:** "connection". A connection is the credential-level link to a data source, and one
    connection carries many bindings.

Compare that with an entry that does not earn its place:

    ### User
    
    A person who uses the product.

That says nothing the word did not already say. Delete it. A glossary of forty such entries is
worse than no glossary, because it teaches the reader that reading it is a waste of time.

### When to write one

Write an entry the moment you catch either of these:

1. **Two words for one thing.** You said "binding", the ticket says "link", the code says `attach`.
2. **One word for two things.** "Sync" means the 5-minute job in one file and the initial import
   in another.

The second is the expensive one. It does not look like a problem until someone fixes the wrong
sync.

### Confirm the entry with the person before you write it

An entry is your reading of what the person meant. If your reading is wrong, the glossary makes
the mistake permanent: every later session reads it as settled.

Show the entry in plain words, then ask:

> **Binding** — a link between a conversation and one table the agent may read. A person makes it
> with a click; the agent never does. It stays after the conversation ends.
> **Not:** a connection. One connection carries many bindings.
>
> Is that what you mean by "binding"? Correct anything that is off.

Write it only after they agree. When they correct it, use their words, not a paraphrase of them.
Ask about one entry at a time, while the word is still fresh.

A word already in `CONTEXT.md` gets the same check when the person uses it in a way the entry does
not cover. Quote the entry and ask which one they mean. Do not decide it yourself.

## ADRs — the title is the decision

Not "database choice". Not "ADR about caching". The sentence you would say out loud.

| Bad title | Good title |
| --- | --- |
| `0004-authentication.md` | `0004-the-gateway-is-the-trusted-enforcement-point.md` |
| `0007-file-storage.md` | `0007-a-folder-is-the-unit-of-the-act-a-file-is-the-unit-of-the-record.md` |
| `0011-error-handling.md` | `0011-a-provider-reports-failure-and-the-caller-decides-what-it-costs.md` |

A reader scanning `ls docs/adr/` should learn the architecture from the filenames alone. That is
the whole test.

### The shape

    # <the decision, as a sentence>
    ## Status            Accepted | Superseded by ADR-XXXX
    ## Context           What was true that forced a choice. Facts, not opinions.
    ## Decision          Present tense. "We do X."
    ## Consequences      What this makes easy. What it makes hard.
    ## Rejected          The plausible wrong answer, and why it fails.

**`Rejected` is the highest-value section.** Someone will re-derive the wrong fix in about ten
minutes. Writing down why it fails saves that ten minutes, every time, forever.

### Worked example of a Rejected section

    ## Rejected
    
    **Cache the permission check for 60 seconds.** It is the obvious fix and it halves the call
    count. It fails because a revoked grant then stays live for up to a minute, and the whole
    point of routing through the gateway is that a revocation takes effect at the next call.
    
    If the call count becomes a real problem, the answer is to batch the checks within one turn,
    not to cache across turns.

Note what that paragraph does: it agrees the rejected fix is attractive, names the exact condition
that breaks it, and points at the fix that would actually work. A reader who arrives with that
idea is answered in thirty seconds.

## Watch the ADR number

Two sessions in two worktrees both write `0007-` and nothing conflicts, because the filenames
differ. The collision is silent and lands on `main`.

Read the remote tip before you pick a number:

    git fetch origin && git ls-tree --name-only origin/main docs/adr/ | tail -3

## Flag conflicts, do not silently override

If what you are writing contradicts an existing ADR, say so:

> Contradicts ADR-0007 (a folder is the unit of the act) — but worth reopening, because the
> dataset case has no folder and ADR-0007 assumed every act had one.

Then let the person decide. A superseded ADR gets its `Status` line updated; it is never deleted.
