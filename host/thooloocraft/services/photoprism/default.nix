# Set up Photoprism as a systemd service running under Podman / runsc.
{ config, secrets,... }:
{
  age.secrets.thooloocraft-photoprism-default-admin-password.file = "${secrets}/thooloocraft-photoprism-default-admin-password.age";
  virtualisation.oci-containers.containers = {
    photoprism = {
      image = "docker.io/photoprism/photoprism@sha256:3f6ea7ddab2008a7aa13c9c489fe9978dcedd0eda441be488a3e1cf023542f50";
      autoStart = true;
      extraOptions = [ "--runtime=runsc" ];
      ports = [
        "2342:2342"
      ];
      environment = {
        "PHOTOPRISM_UPLOAD_NSFW" = "true";
      };
      environmentFiles = [
        config.age.secrets.thooloocraft-photoprism-default-admin-password.path
      ];
      volumes = [
        # Originals go directly onto the RAID drives
        "/mnt/data/photoprism/originals:/photoprism/originals"
        # Config data goes onto SSD, for now just whack it into the default
        # volume storage.
        "photoprism-storage:/photoprism/storage"
      ];
    };
  };
}
