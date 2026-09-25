---
name: wayfinder
description: Plan work too big for one spec as a map of decision tickets on the tracker, then resolve them one per session until the way is clear.
disable-model-invocation: true
---

# Wayfinder

An idea arrived that is too big for one session and too foggy for one spec. Nobody can yet see
the way from here to the **destination**. This skill charts the way as a **map** on the issue
tracker, then works its **decision tickets** one at a time until the route is clear.

**Plan, do not build.** Each ticket resolves a decision. The map is done when nothing is left to
decide before somebody builds the thing. When you feel the pull to just do the work, you have
reached the edge of the map. That is the moment to hand off to `shape-request`.

## Use it, or not

| The work | Skill |
| --- | --- |
| One spec, one session of shaping, then tickets | `shape-request` |
| Several specs, decisions that wait on other decisions, weeks of work | `wayfinder` |

**Stop if charting finds no fog.** When the way is already clear, a map is ceremony. Say so and
offer `shape-request`.

> Needs a map: "Move billing off the monolith." Which data moves first depends on which service
> owns invoices, which depends on a finance decision nobody has made.
> Does not: "Add CSV export to the Sources table." One spec covers it.

## Refer by name

Every map and ticket is an issue, so it has a title. In everything a person reads, use the title
with the number inside it: "Who owns invoices (#212)". Never a bare list of numbers. A line of
`#212, #213, #214` tells the reader nothing.

## The map

**One issue, labelled `wayfinder:map`.** Its tickets are its **sub-issues**, so the map and the
tracker's UI show the same tree. The map is an **index**, not a store: each decision lives in its
ticket, and the map gives it one line and a link.

The map body:

```markdown
## Destination
What reaching the end looks like: a spec, a decision, or a change made in place. One or two lines.
Every session reads this before it picks a ticket.

## Notes
The domain, the skills every session should use, standing preferences for this effort.

## Decisions so far
- [Who owns invoices (#212)](link): the billing service. Finance signs off on the schema.

## Not yet specified
Questions you can see coming but cannot yet state sharply. In scope, just not ticket-shaped yet.

## Out of scope
- [Multi-currency (#219)](link): past the destination. Returns only as a new effort.
```

Open tickets are **not** listed on the map. They are open sub-issues, found by query.

## Tickets

**One question per ticket, small enough for one session.** The body is the question only:

```markdown
## Question
Which service owns an invoice once billing leaves the monolith?
```

The answer is not in the body. It goes in a comment when the ticket is resolved.

Each ticket has one type label. The type names the skill that resolves it:

| Label | Who | Resolved by |
| --- | --- | --- |
| `wayfinder:grill` | Person and agent | **`grill`**. The default. The agent never answers its own questions |
| `wayfinder:prototype` | Person and agent | **`prototype`**, when the question is "how should it look" or "how should it behave" |
| `wayfinder:research` | Agent alone | **`research`**, when a fact outside the repo blocks a decision |
| `wayfinder:task` | Either | Work that must happen before a decision can. Signing up for a service to judge its API, moving data to see its shape. Use **`wizard`** when only the person can do it |

A `task` ticket is the one type that does rather than decides. It earns its place by unblocking a
decision, not by delivering the destination.

**Triage skips these.** `triage` works only issues with `needs-triage` or no label. A `wayfinder:`
label keeps map tickets out of the inbox, and a map ticket never gets `ready-for-agent`.

## Fog and scope

**The map is incomplete on purpose.** Do not chart what you cannot see yet.

The test is whether you can **state** the question precisely now, not whether you can **answer**
it now:

- **Ticket**: the question is sharp, even when it is blocked.
- **Not yet specified**: you cannot phrase it sharply yet. Do not cut the fog into ticket-sized
  pieces. One patch can become three tickets later, or none.

**Out of scope is a different thing.** Fog lies toward the destination. Work past the destination
is out of scope, and it never becomes a ticket on this map. When a ticket turns out to be past the
destination, **close it** and add one line to **Out of scope** with the reason. It does not go in
**Decisions so far**: that section records the route walked, and a scope line is not a step on it.

## The commands

Create the labels that are missing. **Never `--force`**: it rewrites a label that already exists.

    for L in wayfinder:map wayfinder:grill wayfinder:prototype wayfinder:research wayfinder:task; do
      gh label list --limit 200 --json name --jq '.[].name' | grep -qx "$L" || gh label create "$L"
    done

Link a ticket to the map, and draw a blocking edge. Both take the **database id**, not the
`#number`. A wrong id creates no link and reports no error.

    ID=$(gh api repos/<owner>/<repo>/issues/<ticket> --jq .id)
    gh api --method POST repos/<owner>/<repo>/issues/<map>/sub_issues -F sub_issue_id=$ID

    BLOCKER=$(gh api repos/<owner>/<repo>/issues/<blocker> --jq .id)
    gh api --method POST repos/<owner>/<repo>/issues/<ticket>/dependencies/blocked_by -F issue_id=$BLOCKER

The **frontier** is every open sub-issue that nobody is assigned to, with every blocker closed:

    gh api repos/<owner>/<repo>/issues/<map>/sub_issues \
      --jq '.[] | select(.state=="open" and (.assignees|length)==0) | [.number, .title] | @tsv'

Then, for each one, it is on the frontier only if this prints `0`:

    gh api repos/<owner>/<repo>/issues/<n>/dependencies/blocked_by --jq '[.[] | select(.state=="open")] | length'

## Chart the map

The person brings a loose idea. Charting is one session, and it resolves no ticket.

1. **Name the destination.** Use `grill` to settle what this map is finding its way to. The
   destination fixes the scope, so it comes first. Settled words go to `CONTEXT.md` through
   `domain-modeling`.
2. **Find the frontier.** Grill again, **breadth-first** this time: across the whole space, not
   deep on one thread. Surface the open decisions and the first ones you can take now.
   **Stop if there is no fog.** Offer `shape-request` instead.
3. **Create the map** issue: Destination and Notes filled in, Decisions so far empty, the fog
   sketched under **Not yet specified**.
4. **Create the tickets you can state now**, link each as a sub-issue, then wire the blocking edges
   in a **second pass**. An issue needs its id before another one can point at it.
5. **Start the research tickets.** Each `wayfinder:research` ticket goes to a background agent
   running `research`, in parallel. Each one leaves its cited file and comments the path on its
   ticket.
6. **Stop.** Hand back the map, the frontier, and which tickets are waiting on the person.

## Work the map

The person brings the map. A ticket is optional; without one, you pick the next.

1. **Read the map**, not every ticket body. Destination first.
2. **Choose a ticket.** The one the person named, or the first on the frontier. **Claim it
   before any work**, so a parallel session skips it:

       gh issue edit <n> --add-assignee @me

3. **Resolve it** with the skill its label names, and any skill the map's Notes name. Read a
   closed ticket's resolution when you need its detail.
4. **Record the answer** in three places, in this order:
   - A comment on the ticket, starting `RESOLVED:`, with the answer and any fact a later ticket
     needs: a URL, a row count, where a credential lives.
   - Close the ticket.
   - One line under the map's **Decisions so far**, linked to the ticket.
5. **Update the map.** Add the tickets this answer made statable, and remove each one from **Not
   yet specified** so it lives in one place only. Close any ticket the answer made pointless. Move
   anything now past the destination to **Out of scope**.

**Never resolve more than one ticket per session.** Research tickets are the exception. The next
decision deserves a fresh window, and the map carries everything it needs.

**Expect other sessions.** The person may work unblocked tickets in parallel. Read the map again
before you edit it, and edit only the lines your ticket changed.

## At the destination

The map is done when the frontier is empty and **Not yet specified** is empty. What happens next
depends on the destination:

- **A spec**: `shape-request`, starting from the map's **Decisions so far**. It does not ask
  again what the map already settled. A big destination is several specs; make one per part that
  can land alone.
- **A decision**: it is already an ADR, written by `grill` on the way.
- **A change in place**, such as a migration: `shape-request` cuts it expand–contract.

Close the map with a comment that links what it became.

## Hand back

- The map, by title and link.
- The ticket resolved this session and its answer, or the tickets created while charting.
- The frontier now, by title, and which tickets wait on the person.
