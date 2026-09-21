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
  # An identical CLAUDE.md is OUR CLAUDE.md, from an earlier run. Step 0 tells people to run
  # this script again, so that is the documented path - and it used to answer by dropping a
  # byte-identical CLAUDE.kata.md and warning that the rules had not arrived, when they had.
  # A false alarm on the happy path teaches people to ignore the true one.
  if cmp -s "$SRC/CLAUDE.md" CLAUDE.md; then
    echo "  skip   CLAUDE.md (already ours, unchanged)"
  else
    echo "  skip   CLAUDE.md (exists)"
    if [ ! -e CLAUDE.kata.md ]; then
      cp "$SRC/CLAUDE.md" CLAUDE.kata.md
      echo "  create CLAUDE.kata.md (the standing rules, for you to merge)"
    fi
    RULES_NOT_MERGED="yes"
  fi
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
copy pyproject.toml
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

# Declared before the branch: `set -u` is on, and reading this at the checklist when the
# labels branch succeeded killed the script before it printed a single step.
LABELS_PENDING=""
if git rev-parse --git-dir >/dev/null 2>&1 && gh repo view >/dev/null 2>&1; then
  # Create what is missing. Never --force: that UPDATES a label that already exists, and
  # `wontfix` is one of GitHub's nine stock labels, so it exists on essentially every repo
  # from the day it is created. Measured on this repo: --force kept the description and
  # replaced the colour with a random one, silently, on a label nobody asked us to touch.
  EXISTING=$(gh label list --limit 200 --json name --jq '.[].name' 2>/dev/null)
  KEPT=""
  echo "Triage labels"
  for L in needs-triage needs-info ready-for-agent ready-for-human wontfix later; do
    if printf '%s\n' "$EXISTING" | grep -qx -- "$L"; then
      echo "  keep   $L (already exists)"
      KEPT="$KEPT $L"
    elif gh label create "$L" >/dev/null 2>&1; then
      echo "  create $L"
    else
      echo "  FAILED $L - create it by hand"
    fi
  done

  # A name that already exists is not the same as a meaning that already matches. This is a
  # vocabulary collision, which is the thing CONTEXT.md exists for - so report it and let a
  # person decide, rather than assuming either way.
  if [ -n "$KEPT" ]; then
    echo
    echo "  ! These already existed and were left exactly as they are:$KEPT"
    echo "    Check each one means what docs/agents/triage-labels.md says it means."
    echo "    A label that already means something else here is worse than a missing one,"
    echo "    because every filter written against it will look like it worked."
  fi
else
  # Say it here, at the point of failure - and again in the checklist below, because a line
  # printed twelve lines above a numbered list is a line people scroll past.
  echo "No GitHub remote yet - the triage labels were not created. See step 0 below."
  LABELS_PENDING="yes"
fi

echo
echo "Done. Next, by hand:"

if [ -n "$LABELS_PENDING" ]; then
  cat <<'LABELS'
  0. Create the repo on GitHub, then run this script again:
       gh repo create
       ./scaffold.sh .

     Re-running is how the labels get created, and it is safe: the script never
     overwrites a file that exists, so the second run writes nothing new and
     does only the labels. Do not hand-write a `gh label create` loop here - the
     script skips labels that already exist and reports them, and a bare loop
     with --force would silently recolour GitHub's stock `wontfix`.

     Numbered 0 because it comes before the rest: until those labels exist,
     `triage` has no vocabulary, and `ready-for-agent` - the one label the whole
     queue turns on - cannot be set at all. On a repo that already has a remote
     this step is done for you and you never see it.

LABELS
fi

cat <<'NEXT'
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

    Merge the "Read these, and when" table first, even if you merge nothing
    else. CLAUDE.md is the only file loaded into every session, so it is the
    only thing that can tell an agent the docs under docs/ exist. Without it
    those files are written, correct, and never opened.
RULES
fi
