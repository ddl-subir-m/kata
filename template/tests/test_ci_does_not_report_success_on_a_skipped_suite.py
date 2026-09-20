"""CI cannot report success on a suite it never really ran.

Test files that need an external tool guard themselves with
`skipif(shutil.which("node") is None)`. If the CI workflow installs Python but not Node, the run
passes green while testing none of that population — which is worse than having no CI, because it
looks like coverage.

These tests make the absence loud. They assert nothing about the product. They assert that the
runner has the tools one suite needs.

Off CI they are inert: a missing tool on a laptop is the developer's own informed choice. They
bind only when `CI` is set, which GitHub Actions does.

Deliberately narrow. This is not a ban on skipping. It names the tools whose absence silently
removes real coverage, and leaves every other skip alone.

Add a tool to this file the moment a test file starts skipping on it.
"""

from __future__ import annotations

import os
import shutil

import pytest

pytestmark = pytest.mark.skipif(os.getenv("CI") is None, reason="binds on CI only")


def test_node_is_on_path_so_the_js_harnesses_actually_run():
    assert shutil.which("node") is not None, (
        "node is not on PATH, so every JavaScript harness skipped itself and the front end "
        "went untested. Install Node in the workflow."
    )


def test_ripgrep_is_on_path_so_the_grep_based_tests_actually_run():
    assert shutil.which("rg") is not None, (
        "ripgrep is not on PATH, so every grep-based test skipped itself. "
        "Install ripgrep in the workflow."
    )
