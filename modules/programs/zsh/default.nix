{
  lib,
  pkgs,
  config,
  ...
}:
{
  # Zsh shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
    };
    initContent = ''
      eval "$(starship init zsh)"
    '';
    dotDir = "${config.xdg.configHome}/zsh";
  };
}
