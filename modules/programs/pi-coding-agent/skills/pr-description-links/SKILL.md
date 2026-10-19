---
name: pr-description-links
description:
  Link code pointers in GitHub pull request descriptions to the PR's Files
  changed view. Use when writing or updating a PR description with bullets about
  individual code changes.
---

# PR description code pointers

Draft the complete PR description first. Give each bullet about a code change at
least one repo-relative code pointer when possible, formatted as
`` `path/to/file.go:123` ``. Use a changed file and a line that supports the
claim; do not invent pointers. The script links visible diff lines directly and
falls back to the file when a line is outside the diff hunk.

Run the bundled script once on the finished draft. Supply a GitHub PR URL and
write to a separate file so the draft remains available:

```sh
python3 "$SKILL_DIR/scripts/linkify.py" \
  https://github.com/OWNER/REPO/pull/NUMBER draft.md > linked.md
gh pr edit NUMBER --repo OWNER/REPO --body-file linked.md
```

Set `SKILL_DIR` to the absolute directory containing this `SKILL.md`, not the
project directory. The script requests the PR file list through `gh api` once
(paginated), checks that every pointer names a changed file, and produces
clickable Files changed links. If it fails, correct the pointers and retry; do
not publish partial output. It does not modify the PR or any jj change itself.

If matching jj and GitHub descriptions were requested, use `linked.md` for both.
Put the PR title on the first line of the jj description, followed by a blank
line and the linked body. Check the jj revision and published bookmark before
rewriting history; never push without authorization.

Pointers to files outside the PR cannot link into Files changed. Explain why a
bullet has no linked pointer when relevant. Existing Markdown links and fenced
code blocks are left alone.
