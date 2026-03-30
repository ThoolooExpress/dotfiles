{pkgs, ...}: {
    home.username = "richard.morrill";
    home.homeDirectory = "/Users/richard.morrill";    
    home.stateVersion = "25.11"; # Comment out for error with "latest" version
    programs.home-manager.enable = true;
}
