# Work-specific IDE configuration
{ pkgs, ... }:
{
  programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
    datadog.datadog-vscode

    # These ones ones are more for just working with Bazel in general
    # TODO: Consider migrating to central Bazel workflow
    bazelbuild.vscode-bazel
    golang.go
  ];
  programs.vscode.profiles.default.userSettings = {
      datadog.connection.notification.suppressSignInNotification = true;
  };
}
