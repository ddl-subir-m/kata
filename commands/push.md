---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*)
description: Commit and push to remote without a co-author line
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes:

1. Stage all relevant changed files
2. Create a single commit with an appropriate, meaningful message
3. Push to remote origin

**Important**: Do NOT include a "Co-Authored-By" line in the commit message.

**Never push to the default branch.** If `git branch --show-current` reports the default branch,
create a branch first and push that. Landing to the default branch is the `land` skill's job, and
only when the person says so.

You have the capability to call multiple tools in a single response. Stage, commit and push using
a single message. Do not use any other tools for anything else. Do not send any other text
messages besides the tool calls.
