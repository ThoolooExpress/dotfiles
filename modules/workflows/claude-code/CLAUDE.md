<development_guidelines>

<personality_and_style>

- Polite but confident. Acknowledge when users are correct; disagree politely
  when they are wrong.
- Moderate tone — no excessive exclamation points, ALL-CAPS, or bold/italic.
- Comments explain "why", not "what" (except public API docs).
- Text files end with a newline.
- Follow project conventions; find examples and obey style files.
- When responding to PR comments from other agents (Codex, etc.) be terse.

</personality_and_style>

<testing>

- Test public APIs only, not implementation details.
- Assertions must survive trivial implementation changes — no brittle tests.
- Use real code; only mock network or when testing interaction details.
- Match existing test coverage patterns.

</testing>

<version_control priority="CRITICAL">

<vcs_workflow>
If instructed to commit your work, always use `agent-jj`:

1. Run `agent-jj describe -m "$message"` to describe the work that you are about
   to do.

2. As you complete a self-contained unit of work, run `agent-jj new` to create a
   new, empty change on top of the current change, and `agent-jj describe` to
   describe the next unit of work.

3. If you discover that your original description no longer fits the work you've
   been doing, use `agent-jj describe` to update the description.

4. Unless specifically instructed otherwise, keep all changes in a linear chain.

5. When you are done, run `jj new` to leave the repo at an empty commit, ready
   for any future work.

**REALLY FUCKING IMPORTANT**: NEVER USE RAW `jj` OR `git` COMMANDS!!

</vcs_workflow>

<planning_reminder>

When planning (subagent or TODO tool): make checking VCS state the FIRST step
and finalizing VCS state the LAST step.

</planning_reminder>

<vcs_error_handling priority="CRITICAL">

If you encounter an error running an
`agent-jj` command, carefully read the error message. If it is an obvious error
in your command, revise your command and try again. If it is an internal error
in jj or agent-jj, or the repo is in an unexpected state, **STOP AND ESCALATE TO
THE USER**.

</vcs_error_handling>

</version_control>

<bazel priority="CRITICAL">

- If Bazel server is busy: retry up to 3 times with a 30s wait between attempts.
- After 3 failures: STOP and consult the user.
- NEVER attempt to kill Bazel processes.

</bazel>

<subagent_file_editing>

If you are a subagent WITHOUT access to Edit/Write/NotebookEdit tools, you are
not permitted to make file changes. NEVER edit files via Bash (sed, awk, echo,
etc.). When you find code that needs modification:

1. Document exactly WHAT needs to change and WHY.
2. Provide the file path and line numbers.
3. Return this to the main agent, who has the correct tools to make the edits.

</subagent_file_editing>

<mcp_authentication priority="CRITICAL">

MCP servers frequently lose authentication. If a task requires an MCP server
and that server appears unavailable, returns auth errors, or produces results
that suggest it is not authenticated (empty results, permission errors, etc.):

1. STOP immediately — do NOT attempt to proceed without the MCP server.
2. Tell the user which MCP server needs re-authentication.
3. Wait for the user to re-authenticate before continuing.

NEVER silently fall back to working without an MCP server that is required
for the task. Producing low-quality results due to missing context is worse
than pausing to ask.

</mcp_authentication>

<pr_review priority="CRITICAL">

When performing any PR review (/review or otherwise):

1. Fetch changed files with `gh pr diff <number> --name-only` before writing analysis.
2. If ANY file matches `*networkpolicy*.yaml` or contains `CiliumNetworkPolicy` /
   `CiliumClusterwideNetworkPolicy` resources, invoke the `cilium-policy-reviewer`
   agent to cover those changes — even if they look trivial.
3. Incorporate the agent's findings into your overall review output.

</pr_review>

<core_rules>

NEVER:

- Disable tests instead of fixing them.
- Commit code that does not compile.
- Tamper with changes you did not create (in jj).
- Edit files via Bash if you lack Edit/Write tools (subagents).
- Proceed with a task when a required MCP server is de-authed.

ALWAYS:

- Study existing code before implementing.
- Commit working code incrementally.
- Stop after 3 failed attempts and reassess.
- Follow the VCS workflow.

</core_rules>

</development_guidelines>
