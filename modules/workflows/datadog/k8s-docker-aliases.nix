# Utilities for working with k8s / docker / containers in general that are
# specific to Datadog
{
  config,
  pkgs,
  ...
}:

{
  programs.zsh = {
    initContent = ''
      # TODO: Move this to a more generic file, since it has applications
      # outside of work.
      dockersize() { docker manifest inspect -v "$1" | jq -c 'if type == "array" then .[] else . end | select(.Descriptor.platform.architecture != "unknown")' | jq -r '[ ( .Descriptor.platform | [ .os, .architecture, .variant, ."os.version" ] | del(..|nulls) | join("/") ), ( [ ( .OCIManifest // .SchemaV2Manifest ).layers[].size ] | add ) ] | join(" ")' | numfmt --to iec --format '%.2f' --field 2 | sort | column -t ; }

      # This one is probably obsolete now that JJ supports tags.
      # TODO: Migrate to a jj command, also maybe move to more generic file.
      alias pt='git tag v9.9.9-richard.morrill-$(git rev-parse --short HEAD) -m"a tag" && git push --tags'

      replicate-image() {
        local full_ref="$1"
        
        # Extract region from ECR URL (e.g., us-east-1)
        local region=$(echo "$full_ref" | sed -n 's/.*\.ecr\.\([^.]*\)\.amazonaws\.com.*/\1/p')
        
        # Extract image path and tag (everything after the registry host)
        local image_path=$(echo "$full_ref" | sed 's|[^/]*/||')
        
        # Map region to datacenter (adjust mappings as needed)
        local datacenter
        case "$region" in
          us-east-1) datacenter="us1.staging.dog" ;;
          us-west-2) datacenter="us5.staging.dog" ;;
          eu-west-1) datacenter="eu1.staging.dog" ;;
          eu-central-1) datacenter="eu1.staging.dog" ;;
          ap-northeast-1) datacenter="ap1.staging.dog" ;;
          *) datacenter="us1.staging.dog" ;;  # default fallback
        esac
        
        # Construct the global image reference
        local image_reference="registry.ddbuild.io/$image_path"
        
        echo "Replicating $image_reference to $datacenter..."
        
        # Make the curl request
        curl --location 'https://registry.ddbuild.io/v2/_dd/operations/replicate' \
          --header "Authorization: Bearer $(ddtool auth token --datacenter us1.ddbuild.io registry)" \
          --header 'Content-Type: application/json' \
          --data "{\"image_reference\": \"$image_reference\", \"datacenter\": \"$datacenter\", \"force\": false}" | jq .
      }
    '';
  };
}
