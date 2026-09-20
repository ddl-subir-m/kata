# Issue tracker: GitHub

Issues live as GitHub issues. Use the `gh` CLI for all operations. `gh` infers the repo from
`git remote -v` when run inside a clone.

## Operations

- **Create**: `gh issue create --title "..." --body "..."` (heredoc for multi-line bodies).
- **Read**: `gh issue view <number> --comments`
- **List**: `gh issue list --state open --json number,title,labels --jq '.[] | {number,title,labels:[.labels[].name]}'`
- **Comment**: `gh issue comment <number> --body "..."`
- **Label**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

## Blocking

GitHub native issue dependencies, which are visible in the UI:

    BLOCKER_ID=$(gh api repos/<owner>/<repo>/issues/<blocker> --jq .id)
    gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by \
      -F issue_id=$BLOCKER_ID

Note: `issue_id` is the numeric **database id**, not the `#number` and not the `node_id`.
`issue_dependencies_summary.blocked_by` counts open blockers only — that is the live gate.

## When to file

**A ticket needs a symptom: something a person could hit, and notice.**

File it when you can finish this sentence: *a person doing X sees Y, and Y is wrong.*

### Worked examples

| Finding | File it? | Why |
| --- | --- | --- |
| A source path over 32 chars truncates in the table with no tooltip, so a person comparing two rows cannot tell which bucket each points at | **Yes** | X and Y are both concrete |
| `resolve_binding` builds the same dict twice | No | Nobody sees anything. It is a comment on the line |
| The retry loop would spin forever on a malformed token, but the parser rejects those upstream | No | Latent, no reachable path. Say so in the code |
| The browser check could not run from a worktree | No | Work you did not do. It goes in the report |
| "Cache the permission check for 60s" was rejected because a revoked grant stays live for a minute | **Yes** | A rejected fix with its reason is always worth a ticket |

This bar exists because agent review works. It finds real things. Filing every one of them turns
`ready-for-agent` from "pick this up" into "was filed". The cost of a ticket is not writing it —
it is that every future reader must re-read it and decide again.

Do NOT file when the finding is one of these. Each has a better home:

- **A limit you decided to accept.** Write it in the code, with the condition that would retire it.
  The next reader asks "may I delete this?" and a ticket cannot answer that.
- **A fact you learned that the code does not state.** A comment on the line that surprised you.
  A ticket is the wrong shape for knowledge — it gets closed, and the knowledge goes with it.
- **A latent fault with no reachable path.** Say so in the code and name what would make it
  reachable. If the path arrives, THAT is the ticket.
- **Work you simply did not do.** Say it in the report, not the tracker.

When a finding is real but nobody is hurt today, `later` is the honest label. It is not a softer
`wontfix` — it says the work is right and the moment is not now.

**Always worth a ticket, regardless:** a fix you rejected, with the reason. A plausible wrong fix
will be re-derived by the next person in about ten minutes. Writing down why it fails is the
single highest-value paragraph in most issues here.

## A ticket body that an agent can pick up

    ## Symptom
    A person filtering the Sources table by bucket sees rows whose Source column reads
    `s3://analytics-prod/2026/...`. There is nowhere else in the UI that shows the full path.

    ## Reproduce
    Open /workspaces/42/sources with any source path longer than 32 characters.

    ## Expected
    The full path is reachable — a tooltip on hover, at minimum.

    ## Where
    `WorkspaceTable.tsx:118`

    ## Rejected
    Widening the column to fit the longest path. The longest path is 180 characters and the
    table has five other columns.

Five short sections. "Rejected" is there for the same reason it is in an ADR.
