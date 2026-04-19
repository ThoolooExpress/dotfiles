# Datadog makes me use a number of tools that will write directly into my
# .zshrc. This is a bit ugly, but unavoidable if I can't get everybody at the
# company onboard with Nix. So, Nix will output its managed config to
# `.config/nix-managed-zsh`, and that will just source my mutable ~/.zshrc at
# the end.
{
  config,
  pkgs,
  ...
}:

{
  programs.zsh = {
    initContent = ''
    [ -f ~/.zshrc ] && source ~/.zshrc
    '';
  };
}
