{ pkgs, modules, ... }:
{
  imports = [
    "${modules}/programs/vscode"
    "${modules}/common/home"
  ];

  home.username = "thoolooexpress";
  home.homeDirectory = "/home/thoolooexpress";
}
