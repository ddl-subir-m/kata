---
name: reinstall-kata
description: Put the latest pushed kata into the installed plugin without changing the version number. Use after pushing a fix to kata when the installed copy is stale. Triggers - "reinstall kata", "refresh the plugin", "update my plugin", "the installed skill is old".
---

# Reinstall kata

`claude plugin update` compares version numbers. Kata stays at the same version until other people
install it, so `update` says "already at the latest version" and changes nothing. Reinstall instead.

**Only while nobody else has it installed.** After that, raise the version in
`.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`, and let `claude plugin update`
do the work for everyone.

## 1. Check that the fix is pushed

The install fetches from GitHub, not from this directory. An unpushed fix does not arrive.

```bash
git status -sb | head -1        # must show main...origin/main with no ahead count
git status --porcelain          # must be empty
```

Anything uncommitted or ahead: say so and stop. Do not commit or push on your own initiative.

## 2. Reinstall

```bash
claude plugin marketplace update subir
claude plugin uninstall kata@subir
claude plugin install kata@subir
```

## 3. Prove the installed copy matches

Read the installed path. Do not glob the cache: old versions stay there after an upgrade, so
`kata/*/` matches several folders and `diff` fails with a usage error.

Compare everything a user of the plugin runs: the skills, and the template and script that
`setup-repo` copies from. A fix to `template/` or `scaffold.sh` alone does not show in `skills/`.

```bash
INSTALLED=$(jq -r '.plugins["kata@subir"][0].installPath' ~/.claude/plugins/installed_plugins.json)
diff -rq skills "$INSTALLED/skills" \
  && diff -rq template "$INSTALLED/template" \
  && diff -q scaffold.sh "$INSTALLED/scaffold.sh" \
  && echo "installed copy matches"
```

Any difference means the install did not take the pushed commit. Report the diff; do not report
success.

## 4. Tell the person to restart

The running session keeps the skill text it loaded at start. The new skills load after a restart
of Claude Code.
