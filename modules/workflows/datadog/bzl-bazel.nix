# Stuff that makes the `bzl` Bazel alias work properly
{
  config,
  pkgs,
  ...
}:

{
  programs.zsh = {
    initContent = ''
      compdef _bazel bzl
    '';
  };
}
