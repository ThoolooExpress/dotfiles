{
  lib,
  ...
}:
{
  # Zsh shell configuration
  programs.atuin = {
    enable = true;
    settings = {
      search_mode = "fuzzy";
    };
  };
}
