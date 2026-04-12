{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.workflows.luksCryptenroll;

  # Build the cryptenroll script lines from the device attrset
  enrollLines = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      _name: uuid:
      ''sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs="0+7+15:sha256=0000000000000000000000000000000000000000000000000000000000000000" /dev/disk/by-uuid/${uuid}''
    ) cfg.devices
  );

  luks-cryptenroll = pkgs.writeTextFile {
    name = "luks-cryptenroll";
    destination = "/bin/luks-cryptenroll";
    executable = true;
    text = enrollLines + "\n";
  };
in
{
  options.workflows.luksCryptenroll = {
    enable = lib.mkEnableOption "LUKS TPM2 cryptenroll workflow";

    devices = lib.mkOption {
      type = with lib.types; attrsOf str;
      description = "Attrset mapping device-mapper names to disk UUIDs (e.g. { cryptroot = \"abc-123\"; cryptswap = \"def-456\"; }).";
      example = { cryptroot = "baed883d-6a29-4a4f-b35a-39b3528589b9"; };
    };
  };

  config = lib.mkIf cfg.enable {
    # Use systemd stage-1 for proper LUKS TPM2 verification
    boot.initrd.systemd.enable = true;

    # Set up each device as an initrd LUKS volume
    boot.initrd.luks.devices = lib.mapAttrs (
      _name: uuid: {
        device = "/dev/disk/by-uuid/${uuid}";
        crypttabExtraOpts = [
          "tpm2-device=auto"
          "tpm2-measure-pcr=yes"
        ];
      }
    ) cfg.devices;

    environment.systemPackages = with pkgs; [
      cryptsetup
      luks-cryptenroll
    ];
  };
}
