.PHONY: setup test lint clean

# One-command reproducible setup. Lockfile-driven, so a fresh clone and CI install the same bytes.
setup:
	uv sync --extra dev
	npm ci

# THE test gate. CI runs this exact target, so CI and a laptop cannot drift apart.
#
# `--extra dev` rather than relying on `make setup` having run: pytest lives in that extra, and a
# fresh clone or git worktree has a venv built from the default dependencies alone. Without it
# `uv run pytest` does not run a smaller suite — it fails to spawn at all, and piped through
# anything that swallows the exit code, that failure reads as a pass.
#
# `-n auto` fans the suite across cores. Drop it to read interleaved output or to run one failure
# under a debugger: `uv run --extra dev pytest -q -n0 <nodeid>`.
#
# `-rs` prints every skip with its reason. Without it, a skip is folded into a total that still
# reads clean — which is how a whole population of tests goes missing from a worktree in silence.
test:
	uv run --extra dev pytest -q -n auto -rs

# THE lint gate. The `..` scope is the point of this target, not a typo.
#
# Put the scope INSIDE the command, never in a sentence about it. A gate is the command you
# actually run. `ruff check` from a subdirectory lints that subdirectory, while the sentence in
# CLAUDE.md says "the whole repo" — and the narrower command still prints "All checks passed!".
#
# Pin the ruff version exactly with `required-version` in pyproject.toml, so this and CI cannot
# disagree about what counts as clean.
lint:
	uv run --extra dev ruff check .

clean:
	find . -name __pycache__ -type d -prune -exec rm -rf {} +
	rm -rf .ruff_cache .pytest_cache
