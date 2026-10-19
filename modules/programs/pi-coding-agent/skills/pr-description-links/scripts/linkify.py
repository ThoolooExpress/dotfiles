#!/usr/bin/env python3
"""Link Markdown `path:line` pointers to a GitHub PR's Files changed view."""

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse

POINTER = re.compile(
    r"(?<![\[`])`(?P<path>[A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.-]+)*\.[A-Za-z0-9_-]+):(?P<line>[1-9][0-9]*)`"
)
HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@")


def parse_pr(url):
    parsed = urlparse(url)
    match = re.fullmatch(r"/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)/pull/([1-9][0-9]*)(?:/files)?/?", parsed.path)
    if parsed.scheme != "https" or parsed.netloc != "github.com" or not match:
        raise ValueError("expected a https://github.com/OWNER/REPO/pull/NUMBER URL")
    return match.groups()


def changed_lines(patch):
    lines = set()
    current = None
    for row in patch.splitlines():
        match = HUNK.match(row)
        if match:
            current = int(match.group(1))
        elif current is not None:
            if row.startswith(("+", " ")):
                lines.add(current)
                current += 1
            elif row.startswith("\\ No newline at end of file"):
                continue
            elif not row.startswith("-"):
                current = None
    return lines


def load_files(owner, repo, number, fixture):
    if fixture is not None:
        pages = json.loads(fixture.read_text())
    else:
        endpoint = f"repos/{owner}/{repo}/pulls/{number}/files?per_page=100"
        result = subprocess.run(
            ["gh", "api", "--hostname", "github.com", "--paginate", "--slurp", endpoint],
            capture_output=True, text=True, timeout=60,
        )
        if result.returncode != 0:
            raise ValueError(f"gh api failed: {result.stderr.strip()}")
        pages = json.loads(result.stdout)
    if pages and isinstance(pages[0], list):
        return [entry for page in pages for entry in page]
    return pages


def linkify(text, url, files):
    visible = {entry["filename"]: changed_lines(entry.get("patch") or "") for entry in files}
    in_fence = False
    output = []

    def replace(match):
        path, line = match.group("path", "line")
        if path not in visible:
            raise ValueError(f"{path}:{line} is not a changed file in this PR")
        fragment = "diff-" + hashlib.sha256(path.encode("utf-8")).hexdigest()
        if int(line) in visible[path]:
            fragment += "R" + line
        return f"[`{path}:{line}`]({url}/files#{fragment})"

    for row in text.splitlines(keepends=True):
        if row.lstrip().startswith(("```", "~~~")):
            in_fence = not in_fence
        output.append(row if in_fence else POINTER.sub(replace, row))
    return "".join(output)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pr", help="https://github.com/OWNER/REPO/pull/NUMBER")
    parser.add_argument("draft", type=Path, help="Markdown draft, or - for stdin")
    parser.add_argument("--files-json", type=Path, help="PR files API fixture for offline testing")
    args = parser.parse_args()
    try:
        owner, repo, number = parse_pr(args.pr)
        url = f"https://github.com/{owner}/{repo}/pull/{number}"
        text = sys.stdin.read() if str(args.draft) == "-" else args.draft.read_text()
        files = load_files(owner, repo, number, args.files_json)
        sys.stdout.write(linkify(text, url, files))
    except (ValueError, OSError, json.JSONDecodeError, subprocess.TimeoutExpired) as exc:
        print(f"linkify: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
