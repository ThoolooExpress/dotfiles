{ pkgs, modules, ... }:
{
  imports = [
    "${modules}/programs/vscode"
  ];

  home.username = "thoolooexpress";
  home.homeDirectory = "/home/thoolooexpress";
}
