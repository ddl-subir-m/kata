---
name: wizard
description: Generate an interactive bash wizard that walks a person through steps only they can perform. Use when provisioning infrastructure, setting up credentials or CI secrets, clicking through an unfamiliar third-party dashboard, or running a one-off migration or cutover. Triggers - "set up the credentials", "walk me through provisioning", "I need to configure this by hand".
---

# Wizard

For the steps **only a person can take**: clicking through a dashboard, accepting terms, pasting a
key that only they can see, approving a billing change.

## First: could you just do it?

If you can do the step yourself, do it. A wizard for something an agent can perform is pure
ceremony.

Reach for this only where the human is genuinely in the loop — an auth wall, a physical device, a
decision with money attached, a console with no API.

## What the wizard is

One bash script that:

1. **Opens the right URL** at the right moment, so nobody hunts through a console.
2. **Explains the step in one line** before asking for anything.
3. **Captures each value** as the person produces it.
4. **Writes the values where they belong** — `.env`, `gh secret set`, a config file.
5. **Verifies** what it captured, so a typo fails here rather than in CI a day later.

The point is that the procedure stops being something you re-explain to an agent every time.

## The shape

```bash
#!/usr/bin/env bash
set -euo pipefail

step() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ask()  { local v; read -r -p "  $1: " v; printf '%s' "$v"; }

step "1/3  Create an API token"
echo "  Opening the tokens page. Create one with the 'read:packages' scope."
open "https://example.com/settings/tokens"   # xdg-open on Linux
TOKEN=$(ask "Paste the token")

step "2/3  Verify it works"
if ! curl -sf -H "Authorization: Bearer $TOKEN" https://example.com/api/me >/dev/null; then
  echo "  That token was rejected. Check the scope and run this again." >&2
  exit 1
fi
echo "  OK."

step "3/3  Store it"
gh secret set EXAMPLE_TOKEN --body "$TOKEN"
printf 'EXAMPLE_TOKEN=%s\n' "$TOKEN" >> .env
echo "  Written to GitHub secrets and .env"
```

## Rules

| Rule | Why |
| --- | --- |
| Verify every captured value before storing it | A wrong secret fails in CI tomorrow, with no clue where it came from |
| One step per screen, numbered `1/3` | The person knows how much is left |
| Never echo a secret back | It lands in scrollback and logs |
| Idempotent where possible | Re-running after a failure should be safe, and say so at the top |
| `set -euo pipefail` | A half-configured system is worse than an unconfigured one |
| Say what it will change, before it changes it | Consent, and a chance to stop |

**Do not use `[ x ] && y` under `set -e`.** The compound returns non-zero when the test is false
and kills the script. Use `if ... then ... fi`. This is measured, not theoretical — it produced a
silent partial run in this very repo.

## Hand back

The script path, what it will touch, and what the person needs in hand before starting: an
account, a role, a card, a device.

If any step cannot be verified programmatically, say which, so nobody assumes a green run means a
working setup.
