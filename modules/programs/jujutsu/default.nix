{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.jujutsu = {
    enable = true;
    settings = {

      ui = {
        default-command = "log";
      };

      aliases = {
        forgotten = [
          "log"
          "-r"
          "forgotten"
          "-T"
          "comfortable_with_files"
        ];
      };

      templates = {
        draft_commit_description = ''
          concat(
            coalesce(description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
        git_push_bookmark = "my_git_push_bookmark";
      };

      template-aliases = {
        "format_timestamp(timestamp)" = "timestamp.ago()";

        "format_short_cryptographic_signature(sig)" = ''
          if(sig, "🔑", "⚠️")
        '';

        "first_line_suffix(description)" = ''
          description
            .first_line()
            .replace(regex:"^[?[[:upper:]]+-[[:digit:]]+]?[[:blank:]]+", "")
            .lower()
            .replace(regex:"[[:^word:]]", "-")
            .replace(regex:"-+", "-")
            .replace(regex:"^-|-$", "")
            .substr(0, 24)
            .replace(regex:"-$", "")
        '';

        "jira_issue_prefix(description)" = ''
          description
            .match(regex:"^[?[[:upper:]]+-[[:digit:]]+]?[[:blank:]]+")
            .match(regex:"[[:upper:]]+-[[:digit:]]+")
        '';

        comfortable_with_files = ''
          builtin_log_compact(self) ++ "\n" ++
          diff.summary() ++ "\n"
        '';

        my_git_push_bookmark = ''
          separate(
            "/",
            "richard.morrill",
            jira_issue_prefix(description),
            first_line_suffix(description),
          )
        '';

      };

      fsmonitor = {
        backend = "watchman";
        watchman.register-snapshot-trigger = true;
      };

      revsets = {
        log = "present(@) | tracked_remote_bookmarks() | tracked_remote_bookmarks()..mine() | trunk()..mine() | (visible_heads() & mine()) | present(@-) | present(green) | present(trunk())";
      };

      revset-aliases = {
        forgotten = "(visible_heads() & mine()) ~ tracked_remote_bookmarks()::";
      };

      git = {
        "private-commits" = "description(glob:'private:*')";
      };

      snapshot = {
        "max-new-file-size" = 1000000000;
      };
    };
  };

  programs.zsh.shellAliases = {
    st = "(jj st --color=always --no-pager && echo '' && jj log -r '@-' --no-graph -T 'comfortable_with_files' --no-pager --color=always) | less -RX";
  };

  # Install and configure watchman
  # TODO: Move this to a dedicated module if I have a use for Watchman outside
  # of jj and / or want to configure watchman settings per machine.
  home.packages = [
    pkgs.watchman
  ];
  xdg.configFile = {
    # This creates a home-dir level Watchman config that tells Watchman not to
    # look at stuff it really shouldn't be looking at. Some options are
    # redundant because for some reason Meta can't just pick a name and stick
    # with it across different versions.
    "watchman/watchman.json".text = builtins.toJSON {
      enforce_root_files = true;
      root_files = [
        ".git"
        ".hg"
        ".svn"
        ".jj"
      ];
      root_restrict_files = [
        ".git"
        ".hg"
        ".svn"
        ".jj"
      ];
      ignore_vcs = [
        ".git"
        ".hg"
        ".svn"
        ".jj"
      ];
    };
  };
  home.sessionVariables = {
    WATCHMAN_CONFIG_FILE = "${config.xdg.configHome}/watchman/watchman.json";
  };
}
