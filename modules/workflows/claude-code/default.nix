{ config, pkgs, ... }:

{
  home.file = {
    ".claude/settings.json" = {
      source = ./settings.json;
    };
    ".claude/CLAUDE.md" = {
      source = ./CLAUDE.md;
    };
  };
}