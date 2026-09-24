"""CI cannot report success on a suite it never really ran.

Test files that need an external tool guard themselves with
`skipif(shutil.which("node") is None)`. If the CI workflow installs Python but not Node, the run
passes green while testing none of that population — which is worse than having no CI, because it
looks like coverage.

This test makes the absence loud. It asserts nothing about the product. It asserts that the
runner has the tools the suite needs.

Off CI it is inert: a missing tool on a laptop is the developer's own informed choice. It binds
only when `CI` is set, which GitHub Actions does.

Deliberately narrow. This is not a ban on skipping. It names the tools whose absence silently
removes real coverage, and leaves every other skip alone.

The list starts empty, because a new repo has no test that skips on a tool. The moment a test file
starts skipping on one, do both, in the same commit:

1. Add the tool to `TOOLS_THE_SUITE_SKIPS_ON` below.
2. Install it in `.github/workflows/tests.yml`. That file has the steps for Node and ripgrep,
   commented out.

Then prove it: run `CI=1 make test` with the tool off PATH and watch this go red.
"""

from __future__ import annotations

import os
import shutil

import pytest

pytestmark = pytest.mark.skipif(os.getenv("CI") is None, reason="binds on CI only")

# Each entry: the executable, and what goes untested when it is missing.
TOOLS_THE_SUITE_SKIPS_ON: dict[str, str] = {
    # "node": "every JavaScript harness skipped itself and the front end went untested",
    # "rg": "every grep-based test skipped itself",
}


def test_every_tool_the_suite_skips_on_is_on_path():
    missing = {
        tool: lost
        for tool, lost in TOOLS_THE_SUITE_SKIPS_ON.items()
        if shutil.which(tool) is None
    }
    assert not missing, "\n".join(
        f"{tool} is not on PATH, so {lost}. Install it in the workflow."
        for tool, lost in missing.items()
    )
