{
  pkgs,
  ...
}:
{
  programs.zsh = {
    shellAliases = {
      k = "kubectl";
    };
  };
}
