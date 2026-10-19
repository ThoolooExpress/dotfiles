---
name: personal-change-description-style
description:
  Write PR / commit descriptions in the style preferred by the user. Use when
  writing or updating a PR or commit description.
---

# Personal change description style

This is the way the user prefers that all PR / commit descriptions be written.
This guidance overrides all non-mandatory guidance at the repo level. It is OK
to diverge from repo conventions in favor of this style, as long as no hard
requirements that will block review / merge are violated.

1:1 corresponding PR and jj / git descriptions should be identical. Ignore
project PR templates unless they are mandatory for a change to be reviewed and
merged.

## Structure / content

### Title / 1st line

The PR title / 1st line of the commit description should be:

```markdown
[MYJIRA-1234] Consolidate Spork compatibility check functions
```

- If Jira is not used in the project at all, drop the `[JIRA-1234]`. If Jira is
  used but it's unclear which ticket to reference, ask user. It is normal that
  multiple PRs will reference the same ticket.
- Capitalize only first letter of title and proper nouns, initialisms and
  acronyms.
- Don't use prefixes like `fix(something):`, `build/makefile:`, `chore:`, etc,
  even if they are widely used in the repo. ONLY use them if they are
  specifically documented as being MANDATORY for a change to be reviewed and
  merged.

### 1st body paragraph: justification / context

Give a brief summary of WHY this change needed to happen and how it fits into
other ongoing work (which may be merged before or after this change). This
paragraph may be dropped if the change is very mechanical (for e.g. upgrading a
dependency version). Try to get this info from what the user has said to you;
don't make it up after the fact. If unsure, ask the user for more details.

Example:

```markdown
Previously, we had 3 different functions that all answered the same basic
question: "Is this pod compatible with Spork?". This meant that every time the
prerequisites for enabling Spork changed, every one of these functions had to be
updated, and when any were missed, errors occurred. With Spork becoming GA next
quarter, we need a single source of truth for whether we can enable Spork for a
given pod that we can rely on.
```

### 2nd body paragraph: substance as prose

Give a brief summary of WHAT changed, and WHAT still needs to be done in clear,
concise prose:

```markdown
Make the function `SporkCompatible` the canonical way to check if a pod is
compatible with Spork. Delete all other equivalent functions and migrate all
existing callers.
```

This section does not need to include trivial unit test work. It is standard
practice to keep tests up-to-date with production code, so there is no need to
detail this. Only talk about tests in this section if changes to tests is the
main point of the change, if test coverage is nonstandard (for e.g. no unit
tests for a lower-level lib because it is covered by tests for a higher-level
lib), or if significant changes had to be made to more sophisticated types of
tests, like integration tests.

### Details section

Using headings and bullet points, detail exactly what is going on in the change,
with code pointers. If multiple independent parts of the codebase had to be
updated, use sub-headings (can drop sub-heading if only one logical component
was updated.)

```markdown
## Details

### SporkLib

- Update comment on `SporkCompatible` to indicate that it is the only supported
  way to check if a pod is compatible with spork:
  libs/go/spork_lib/spork_compatible.go:88
- Delete `SporkSupported`: libs/go/spork_lib/helpers/spork_pod_helpers.go
- Migrate all callsites to `SporkCompatible`

### SporkManagementService

- Delete `SporkWorksYayHelper`: apps/spork_management_service/helpers.go:99
- Migrate all callsites to `SporkCompatible`
```

No need for specific pointers for very repetitive changes.

Do not detail trivial accessory changes like:

- Unit test updates that simply mirror behavior changes in production code.
- Proto gencode changes in response to `.proto` file edits.
- BUILD.bazel file updates

Exception: Go into details about any of these areas if they are the entire point
of the change, or if something nonstandard has been done.

### Validation section

Explain exactly how you validated that a change won't have any adverse effects.
This does not mean detailing every test that you wrote; it should be assumed
that all new code will come with appropriate tests. Instead, detail the exact
steps you took to check your work.

```markdown
## Validation

- All unit tests in repo pass.
- Manually started `SporkManagementService`, locally exercised full Spork
  onboarding flow against the staging k8s cluster.
- These changes have been baking in staging since 2026-10-10, no alerts.
```

You do not need to say that "CI passed"; Anybody reading the PR description can
see the CI status section on GitHub.

### Additional full example

```markdown
[MYJIRA-1234] Create a dedicated method for widget recoloring

Previously, clients called `/WidgetService.UpdateWidget` with
`UpdateWidgetRequest.color` set in order to change the color of their widgets.
The problem is, by setting different fields in the request message, it is
possible to change any property of the widget, making this a highly-privileged
method. We want to allow certain users ONLY permission to change the color of
their widget, but our ACLs only support allowing / denying at the method level.

Create a new method, `/WidgetService.RecolorWidget` that supports only
recoloring. Update thick client to use this method when a simple recoloring is
requested. Direct RPC callers still need to be migrated. ACLs for the new method
still mirror those of `UpdateWidget`. Will determine correct permissions for new
method and update ACL in a follow-up.

## Details:

### Widget Service

- Add new RPC method to proto: libs/proto/widget_service/widget_service.proto:44
- Add new RPC handler that only recolors, register:
  apps/widget_service/handlers/recolor_widget/recolor_widget.go,
  apps/widget_service/main/main.go
- Added a call to new method in integration test:
  apps/widget_service/integration_test/main/main.go
- Copy permissions of existing `UpdateWidget` handler to apply to new handler
  temporarily: apps/widget_service/config/policy.yaml

### Widget Thick Client

- Update `WidgetThickClient.Recolor(...)` to call the new `RecolorWidget` RPC
  under the hood instead of `UpdateWidget`:
  libs/go/widget_thick_client/widget_thick_client.go
- Update thick client docs to tell users to contact us if they have a need to
  grant only recolor permissions: libs/go/widget_thick_client/README.md

## Validation

- All unit / integration tests pass
- Manually tested full widget creation / update / recolor flow with grpcurl
- This change has baked in staging since 2026-10-01, no alerts
```

## Formatting

Descriptions should be clean, well-formatted Markdown. Draft descriptions in a
markdown file, and then run `prettier` if available.

## Links

Use markdown links with readable titles. Avoid bare URLs except where the link
is already shortened and intended to be human-readable. For e.g, feel free to
just write `http://go/my-link` as a bare URL and let GitHub auto-link it. For
references to other PRs, prefer the bare shortlink format, `#[0-9]+` as that
will work better if PR is being viewed in an alternative frontend like Graphite.

For code pointers within the change itself, don't manually create links.
Instead, invoke the `pr-description-links` skill if available.

## Responding to comments

After responding to comments, make sure the description still reflects how the
code works. There is no need to log comment responses in the description just
update it to reflect the current state of the code, as if it were originally
written that way.
