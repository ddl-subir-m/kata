# The title is the decision itself

Not "database choice". Not "ADR about caching". The sentence you would say out loud.

| Bad title | Good title |
| --- | --- |
| `0004-authentication.md` | `0004-the-gateway-is-the-trusted-enforcement-point.md` |
| `0007-file-storage.md` | `0007-a-folder-is-the-unit-of-the-act-a-file-is-the-unit-of-the-record.md` |
| `0011-error-handling.md` | `0011-a-provider-reports-failure-and-the-caller-decides-what-it-costs.md` |

A reader scanning `ls docs/adr/` should learn the architecture from the filenames alone. That is
the whole test.

**Before you pick a number**, read the remote tip — two worktrees both writing `0007-` conflict
in nothing, because the filenames differ:

    git fetch origin && git ls-tree --name-only origin/main docs/adr/ | tail -3

---

## Status

Accepted | Superseded by ADR-XXXX

## Context

What was true that forced a choice. Facts, not opinions.

> Every query went through the client SDK, which meant the permission check ran in the caller's
> process. Three callers existed and two of them cached the result.

## Decision

The decision, in the present tense. "We do X."

> The gateway is the trusted enforcement point. Every read passes through it, and no caller
> checks permissions itself.

## Consequences

What this makes easy. What this makes hard. What a reader must now accept.

> **Easy:** a revocation takes effect at the next call, with no cache to drain.
> **Hard:** the gateway is now on the hot path for every read, so its latency is the floor for
> every caller.
> **Accept:** a caller cannot answer "may I read this" without a network hop.

## Rejected

The plausible wrong answer, and why it fails. **This is the highest-value section.** Someone will
re-derive the wrong fix in about ten minutes; writing down why it fails saves that ten minutes
every time.

> **Cache the permission check for 60 seconds.** It is the obvious fix and it halves the call
> count. It fails because a revoked grant then stays live for up to a minute, and the whole point
> of routing through the gateway is that a revocation takes effect at the next call.
>
> If the call count becomes a real problem, the answer is to batch the checks within one turn, not
> to cache across turns.

Note what that paragraph does: it agrees the rejected fix is attractive, names the exact condition
that breaks it, and points at the fix that would actually work. A reader arriving with that idea
is answered in thirty seconds.
