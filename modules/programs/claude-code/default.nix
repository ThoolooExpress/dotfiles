{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.claude-code = {
    enable = true;

    # Anthropic ships updates faster than nixpkgs tracks; install via the
    # vendor channel rather than Nix.
    package = null;

    context = import ../../lib/agents;
    hooksDir = ./hooks;

    settings = {
      permissions = {
        defaultMode = "bypassPermissions";
      };
      skipDangerousPermissionsPrompt = true;

      model = "opus";

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
                command = "${config.home.homeDirectory}/.claude/hooks/jj-worktree-create";
              }
            ];
          }
        ];
        WorktreeRemove = [
          {
            hooks = [
              {
                type = "command";
                command = "${config.home.homeDirectory}/.claude/hooks/jj-worktree-remove";
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
  };

  programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
    anthropic.claude-code
  ];
}
