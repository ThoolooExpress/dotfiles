{ pkgs, modules, ... }:
{
  imports = [
    "${modules}/common/home"
    "${modules}/workflows/claude-code"
    "${modules}/workflows/datadog"
    "${modules}/workflows/k8s"
  ];

  home.username = "bits";
  home.homeDirectory = "/home/bits";
  home.stateVersion = "26.05";
}
