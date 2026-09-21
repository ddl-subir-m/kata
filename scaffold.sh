#!/usr/bin/env bash
# Set up a repo with the ship loop already wired. New repo or existing one.
#
#   ./scaffold.sh /path/to/repo
#
# Copies the template files, symlinks AGENTS.md to CLAUDE.md, and creates the triage labels if a
# GitHub remote is already set. Never overwrites a file that exists, so it is safe to re-run.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/template" && pwd)"
DEST="${1:?usage: scaffold.sh /path/to/repo}"

mkdir -p "$DEST"
cd "$DEST"

copy() {
  if [ -e "$1" ]; then
    echo "  skip   $1 (exists)"
  else
    mkdir -p "$(dirname "$1")"
    cp "$SRC/$1" "$1"
    echo "  create $1"
  fi
}

echo "Scaffolding $DEST"

# CLAUDE.md is the one file a live repo usually already has, and it is the one
# carrying the standing rules. Skipping it quietly leaves a repo with every doc
# and none of the rules, so drop them alongside for merging and say so at the end.
RULES_NOT_MERGED=""
if [ -e CLAUDE.md ]; then
  echo "  skip   CLAUDE.md (exists)"
  if [ ! -e CLAUDE.kata.md ]; then
    cp "$SRC/CLAUDE.md" CLAUDE.kata.md
    echo "  create CLAUDE.kata.md (the standing rules, for you to merge)"
  fi
  RULES_NOT_MERGED="yes"
else
  copy CLAUDE.md
fi
copy CONTEXT.md
copy .claude/settings.json
copy docs/design-system.md
copy docs/adr/0000-template.md
copy docs/agents/issue-tracker.md
copy docs/agents/triage-labels.md
copy docs/agents/domain.md
copy Makefile
copy .python-version
copy .github/workflows/tests.yml
copy tests/test_ci_does_not_report_success_on_a_skipped_suite.py

if [ -e AGENTS.md ]; then
  echo "  skip   AGENTS.md (exists)"
else
  ln -s CLAUDE.md AGENTS.md
  echo "  create AGENTS.md -> CLAUDE.md"
fi

if git rev-parse --git-dir >/dev/null 2>&1 && gh repo view >/dev/null 2>&1; then
  echo "Creating triage labels"
  for L in needs-triage needs-info ready-for-agent ready-for-human wontfix later; do
    gh label create "$L" --force >/dev/null 2>&1 && echo "  label  $L"
  done
else
  echo "No GitHub remote yet - create the labels later:"
  echo "  for L in needs-triage needs-info ready-for-agent ready-for-human wontfix later; do gh label create \$L --force; done"
fi

cat <<'NEXT'

Done. Next, by hand:
  1. Fill CONTEXT.md with the first three words that matter. Delete the example entry.
  2. Write ADR-0001. Title it with the decision itself.
  3. Fill docs/design-system.md, or delete it if this repo has no UI.
  4. make setup && make test && make lint   (both gates must run before you write real code)
  5. Plant a deliberate failure in one test. Confirm it goes red. Remove it.

Step 5 is the one people skip. A green suite proves nothing until you have seen it red.
NEXT

if [ -n "$RULES_NOT_MERGED" ]; then
  cat <<'RULES'

  ! This repo already had a CLAUDE.md, so it was left alone and the standing
    rules did NOT arrive. They are in CLAUDE.kata.md beside it. Merge what you
    want into your own CLAUDE.md, then delete it. Until you do, the skills run
    without the rules they were written against.
RULES
fi
