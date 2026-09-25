#!/usr/bin/env bash
# Set up a repo with the ship loop already wired. New repo or existing one.
#
#   ./scaffold.sh /path/to/repo
#
# Copies the template files, symlinks AGENTS.md to CLAUDE.md, runs git init if the folder is not a
# repo yet, and creates the triage labels if the repo is already on GitHub. Otherwise it lists
# exactly what is missing. Never overwrites a file that exists, so it is safe to re-run.
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

# The loop runs on git: implement and dispatch cut worktrees, land merges into main. A folder
# with no git got every file and no word that nothing after it would work. git init adds .git
# and touches no file, so it is as safe as the copies. A folder INSIDE another repo is not
# initialised: a nested repo is a surprise, and the labels would land on the parent's GitHub.
NESTED_IN=""
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  git init -q -b main
  echo "  create .git (git init, branch main)"
elif [ "$(git rev-parse --show-toplevel)" != "$(pwd -P)" ]; then
  NESTED_IN="$(git rev-parse --show-toplevel)"
  echo "  ! $DEST is inside another repo: $NESTED_IN"
fi

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
copy .gitignore
copy .github/workflows/tests.yml
copy tests/test_ci_does_not_report_success_on_a_skipped_suite.py

if [ -e AGENTS.md ]; then
  echo "  skip   AGENTS.md (exists)"
else
  ln -s CLAUDE.md AGENTS.md
  echo "  create AGENTS.md -> CLAUDE.md"
fi

# The labels need a GitHub repo, and a GitHub repo needs four things before it. Find every one
# that is missing, in the order they must happen, so step 0 lists exactly what is left - not
# one generic command. `gh repo create` alone, in a folder with no commit, either fails or
# clones an empty repo into a NEW subfolder, and the re-run below still finds no remote.
# Declared before the checks: `set -u` is on, and reading an unset one kills the script.
MISSING=""
if [ -n "$NESTED_IN" ]; then
  MISSING="nested"
else
  git rev-parse -q --verify HEAD >/dev/null 2>&1 || MISSING="$MISSING commit"
  if ! command -v gh >/dev/null 2>&1; then
    MISSING="$MISSING gh"
  elif ! gh auth status >/dev/null 2>&1; then
    MISSING="$MISSING auth"
  fi
  if ! git remote get-url origin >/dev/null 2>&1; then
    MISSING="$MISSING remote"
  elif [ -z "${MISSING# commit}" ] && ! gh repo view >/dev/null 2>&1; then
    MISSING="$MISSING github"
  fi
fi

# The labels need only the GitHub half. A repo already on GitHub with no commit yet still gets
# them; the commit stays on the list for the worktrees.
if [ -z "${MISSING# commit}" ]; then
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
  echo "Not on GitHub yet - the triage labels were not created. See step 0 below."
fi

echo
echo "Done. Next, by hand:"

if [ -n "$MISSING" ]; then
  if [ "$MISSING" = " commit" ]; then
    echo "  0. Make the first commit. The repo is on GitHub; only the commit is missing:"
  else
    echo "  0. Before the triage labels can exist. In this order, only what is still missing:"
  fi
  echo
  case " $MISSING " in *" nested "*) cat <<NESTED
     - This folder is inside another repo: $NESTED_IN
       The files are now part of that repo, and no labels were created. If that is
       what you meant, commit them there. If not, move them to a folder of their own
       and run this script on it.

NESTED
  esac
  case " $MISSING " in *" commit "*) cat <<'COMMIT'
     - Make the first commit. implement and dispatch cut worktrees, and a worktree
       needs a commit on main. Check nothing secret is staged before you commit:
         git add -A && git status --short
         git commit -m "Scaffold the ship loop"

COMMIT
  esac
  case " $MISSING " in *" gh "*) cat <<'GH'
     - Install the GitHub CLI:  brew install gh   (or https://cli.github.com)

GH
  esac
  case " $MISSING " in *" gh "*|*" auth "*) cat <<'AUTH'
     - Log in to GitHub. It opens a browser, so only you can do it:
         gh auth login

AUTH
  esac
  case " $MISSING " in *" remote "*) cat <<'REMOTE'
     - Create the GitHub repo from this folder and push main to it. Pick the name
       and --private or --public:
         gh repo create <name> --private --source=. --push

REMOTE
  esac
  case " $MISSING " in *" github "*) cat <<'GITHUB'
     - origin is set, but gh cannot see it as a GitHub repo. Either it is on another
       host, or your GitHub account has no access. The labels are GitHub labels: on
       another tracker, create the six in docs/agents/triage-labels.md by hand.

GITHUB
  esac
  # Nested and another-host end with no re-run: running again changes nothing. A lone missing
  # commit ends with none too: the labels were already created above.
  case "$MISSING" in *nested*|*github*|" commit") ;; *) cat <<'RERUN'
     - Then run this script again, from the repo:
         ./scaffold.sh .

     Re-running is how the labels get created, and it is safe: the script never
     overwrites a file that exists, so the second run writes nothing new and
     does only the labels. Do not hand-write a `gh label create` loop here - the
     script skips labels that already exist and reports them, and a bare loop
     with --force would silently recolour GitHub's stock `wontfix`.

     Numbered 0 because it comes before the rest: until those labels exist,
     `triage` has no vocabulary, and `ready-for-agent` - the one label the whole
     queue turns on - cannot be set at all. On a repo already on GitHub this
     step is done for you and you never see it.

RERUN
  esac
fi

cat <<'NEXT'
  1. Fill CONTEXT.md with the first three words that matter. Delete the example entry.
  2. Write ADR-0001. Title it with the decision itself.
  3. Fill docs/design-system.md, or delete it if this repo has no UI.
  4. make setup && make test && make lint   (both gates must run before you write real code)
  5. Plant a deliberate failure in one test. Confirm it goes red. Remove it.

Step 5 is the one people skip. A green suite proves nothing until you have seen it red.

No idea written down yet, only a name? Leave 1 and 2. grill and shape-request fill them
as the idea settles, and shape-request picks the language and rewrites the gates.
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
