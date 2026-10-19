"""CLI tests for PR Files changed links."""

import hashlib
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/linkify.py"
PR = "https://github.com/owner/repo/pull/123"
FILE = "internal/example.go"
ANCHOR = "diff-" + hashlib.sha256(FILE.encode()).hexdigest()
FILES = [{"filename": FILE, "patch": "@@ -4,2 +4,3 @@\n context\n+added\n old\n"}]


class LinkifyTests(unittest.TestCase):
    def run_cli(self, text, files=FILES):
        with tempfile.TemporaryDirectory() as directory:
            draft = Path(directory) / "draft.md"
            fixture = Path(directory) / "files.json"
            draft.write_text(text)
            fixture.write_text(json.dumps([files]))
            return subprocess.run(
                [sys.executable, str(SCRIPT), PR, str(draft), "--files-json", str(fixture)],
                text=True, capture_output=True, timeout=15,
            )

    def test_exact_line_and_file_fallback(self):
        result = self.run_cli(f"- Change `{FILE}:5` and `{FILE}:50`.\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"[`{FILE}:5`]({PR}/files#{ANCHOR}R5)", result.stdout)
        self.assertIn(f"[`{FILE}:50`]({PR}/files#{ANCHOR})", result.stdout)

    def test_missing_patch_uses_file_anchor(self):
        result = self.run_cli(f"- Change `{FILE}:5`.\n", [{"filename": FILE, "patch": None}])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"[`{FILE}:5`]({PR}/files#{ANCHOR})", result.stdout)

    def test_unknown_file_fails_without_partial_output(self):
        result = self.run_cli(f"- Change `{FILE}:5` and `not-in-pr.go:1`.\n")
        self.assertEqual(result.returncode, 1)
        self.assertEqual(result.stdout, "")
        self.assertIn("not-in-pr.go:1 is not a changed file", result.stderr)

    def test_idempotent_and_skips_fenced_code(self):
        first = self.run_cli(f"- Change `{FILE}:5`.\n```\n`{FILE}:5`\n```\n")
        self.assertEqual(first.returncode, 0, first.stderr)
        second = self.run_cli(first.stdout)
        self.assertEqual(second.returncode, 0, second.stderr)
        self.assertEqual(second.stdout, first.stdout)
        self.assertIn(f"```\n`{FILE}:5`\n```", second.stdout)

    def test_rejects_non_github_url(self):
        with tempfile.TemporaryDirectory() as directory:
            draft = Path(directory) / "draft.md"
            draft.write_text("draft\n")
            result = subprocess.run(
                [sys.executable, str(SCRIPT), "https://example.com/owner/repo/pull/123", str(draft)],
                text=True, capture_output=True, timeout=15,
            )
        self.assertEqual(result.returncode, 1)
        self.assertIn("expected a https://github.com", result.stderr)


if __name__ == "__main__":
    unittest.main()
