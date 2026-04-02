{ config, lib, ... }:

{
  options.workflows.claudeCode.settings = lib.mkOption {
    type = with lib.types; attrsOf anything;
    default = { };
    description = "Attribute set merged into ~/.claude/settings.json as JSON.";
  };

  config = {
    workflows.claudeCode.settings = {
      permissions = {
        allow = [
          "ListMcpResourcesTool"
          "ReadMcpResourceTool"
          "mcp__dd-prod"
          "mcp__dd-staging"
          "mcp__atlassian"
          "WebFetch(domain:docs.anthropic.com)"
          "WebFetch(domain:docs.claude.com)"
          "WebFetch(domain:platform.openai.com)"
          "WebSearch"
          "Bash(agent-jj:*)"

          # I turn sandbox on all the time so IDGAF
          "Read"
          "Write"
          "Edit"
          "Bash"
          "Glob"
          "Grep"
          "Task"
        ];
      };

      sandbox = {
        enabled = true;
        filesystem = {
          allowWrite = [
            "/tmp"
            "~/go"
            "~/repos"
          ];
          allowRead = [
            "/tmp"
            "~/go"
            "~/repos"
          ];
        };
        excludedCommands = [
          "docker:*"
          "bzl:*"
          "agent-jj:*"
        ];
        autoAllowBashIfSandboxed = true;
        network = {
          # The sandbox inherits the domains within `WebFetch(...)` permission grants above.
          allowedDomains = [ ];
        };
      };

      model = "sonnet[1m]";

      enabledMcpjsonServers = [
        "atlassian"
        "dd-prod"
        "dd-staging"
      ];

      hooks = {
        WorktreeCreate = [
          {
            hooks = [
              {
                type = "command";
                command = "/Users/richard.morrill/.claude/hooks/jj-worktree-create";
              }
            ];
          }
        ];
        WorktreeRemove = [
          {
            hooks = [
              {
                type = "command";
                command = "/Users/richard.morrill/.claude/hooks/jj-worktree-remove";
              }
            ];
          }
        ];
      };

      enabledPlugins = {
        "clangd-lsp@claude-plugins-official" = true;
        "gopls-lsp@claude-plugins-official" = true;
        "dd@datadog-claude-plugins" = true;
        "pr-review-toolkit@claude-plugins-official" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
      };

      alwaysThinkingEnabled = true;
      autoUpdatesChannel = "latest";

      env = {
        CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = 1;
      };
    };

    home.file = {
      ".claude/settings.json".text = builtins.toJSON config.workflows.claudeCode.settings;
      ".claude/CLAUDE.md".source = ./CLAUDE.md;
    };
  };
}
