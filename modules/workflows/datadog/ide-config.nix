# Work-specific IDE configuration
{ pkgs, ... }:
{
  programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
    datadog.datadog-vscode
  ];
  programs.vscode.profiles.default.userSettings = {
      datadog.connection.notification.suppressSignInNotification = true;
  };
}
