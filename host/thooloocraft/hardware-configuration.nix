{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Use Systemd stage-1. This is needed for both the SW Raid
  # as well as properly verifying the LUKS encrypted volume.
  boot.initrd.systemd.enable = true;

  # Software RAID
  boot.initrd.services.swraid = {
    enable = true;

    mdadmConf = ''
      ARRAY /dev/md0 level=raid1 num-devices=2 metadata=1.2 UUID=2f3744a0:7fc49a84:dd3955a2:497ea4fc devices=/dev/disk/by-id/wwn-0x50014ee26c7f93b4-part1,/dev/disk/by-id/wwn-0x50014ee2c1d29fc7-part1
    '';
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/75bba4a1-b517-4793-9be5-1b8c0f0f2ecb";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9D34-8923";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/mnt/data" = {
    device = "/dev/mapper/cryptdata";
    fsType = "btrfs";
  };

  boot.initrd.luks.devices."cryptdata" = {
    device = "/dev/md0";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
