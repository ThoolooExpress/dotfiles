{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Recursively merges attribute sets; lists at any depth are concatenated
  # rather than conflicting. This makes the settings option behave like a
  # JSON-merge-patch accumulator, which is what we want for a settings blob
  # that multiple modules extend.
  #
  # CAVEAT: scalar values (strings, numbers, bools) are NOT detected as
  # conflicts — the last definition silently wins. This bypasses the normal
  # module-system priority mechanism (mkDefault / mkForce) for any nested
  # scalar. If two modules set the same scalar key to different values you
  # will not get an error; whichever module is evaluated last takes effect.
  # Use this type only for settings blobs where that trade-off is acceptable.
  recursiveMerge = lib.types.mkOptionType {
    name = "recursiveMerge";
    description = "recursively merged attribute set (lists concatenated)";
    check = lib.isAttrs;
    merge = _loc: defs:
      let
        mergeTwo = a: b:
          if lib.isAttrs a && lib.isAttrs b
          then
            lib.mapAttrs (k: bv: if a ? ${k} then mergeTwo a.${k} bv else bv) b
            // lib.filterAttrs (k: _: !(b ? ${k})) a
          else if lib.isList a && lib.isList b
          then a ++ b
          else b; # scalar: last definition wins — see caveat above
      in
        lib.foldl' mergeTwo { } (map (d: d.value) defs);
  };
in

{
  options.workflows.claudeCode.settings = lib.mkOption {
    type = recursiveMerge;
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
          denyRead = [ "~" ];
          allowWrite = [
            "/tmp"
            "~/go"
            "~/repos"
          ];
          allowRead = [
            "/tmp"
            "~/go"
            "~/repos"
            "~/.config"
          ];
        };
        excludedCommands = [
          "docker:*"
          "bzl:*"
          "agent-jj:*"
          "jj:*"
          "gh:*"
        ];
        autoAllowBashIfSandboxed = true;
        network = {
          # The sandbox inherits the domains within `WebFetch(...)` permission grants above.
          allowedDomains = [
            "github.com"
            "ddbuild.io"
          ];
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

    home.file = {
      ".claude/settings.json".text = builtins.toJSON config.workflows.claudeCode.settings;
      ".claude/CLAUDE.md".source = ./CLAUDE.md;
      ".claude/hooks/jj-worktree-create" = {
        source = ./hooks/jj-worktree-create;
        executable = true;
      };
      ".claude/hooks/jj-worktree-remove" = {
        source = ./hooks/jj-worktree-remove;
        executable = true;
      };
    };

    programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
      anthropic.claude-code
    ];
  };
}
