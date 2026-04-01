# Set up Crafty Controller as a systemd service under podman.
# Requires modules/programs/podman
{ ... }:
{
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    container-name = {
      # 4.10.2
      image = "docker.io/arcadiatechnology/crafty-4@sha256:914ccf8232ba591db3d9c3f97bac368ae1e6dd8218f4618e2b4699e05018acfd";
      autoStart = true;
      extraOptions = [ "--runtime=runsc" ];
      ports = [
        "8443:8443"
        "8123:8123"
        "25500-25600:25500-25600"
      ];
      volumes = [
        "crafty-backups:/crafty/backups"
        "crafty-logs:/crafty/logs"
        "crafty-servers:/crafty/servers"
        "crafty-config:/crafty/app/config"
        "crafty-import:/crafty/import"
      ];
    };
  };
}
