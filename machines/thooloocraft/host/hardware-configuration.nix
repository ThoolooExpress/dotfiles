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

  boot.initrd.systemd.enable = true;


  # Software RAID
  boot.initrd.services.swraid = {
    enable = true;

    mdadmConf = ''
      ARRAY /dev/md0 level=raid1 num-devices=2 metadata=1.2 UUID=2f3744a0:7fc49a84:dd3955a2:497ea4fc devices=/dev/disk/by-id/wwn-0x50014ee26c7f93b4-part1,/dev/disk/by-id/wwn-0x50014ee2c1d29fc7-part1
    '';
  };

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
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

  # Writing raw file instead of using initrd because we specifically want to load
  # the data drives after the root drive is decrypted.
  environment.etc."crypttab".text = ''
    cryptdata /dev/md0 /root/cryptdata_key luks
  '';
  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
