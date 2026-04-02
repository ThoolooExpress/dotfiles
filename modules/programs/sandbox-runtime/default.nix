{
  pkgs,
  lib,
  config,
  ...
}:
let
  sandbox-runtime = pkgs.buildNpmPackage rec {
    pname = "anthropic-sandbox-runtime";
    version = "0.0.46";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@anthropic-ai/sandbox-runtime/-/sandbox-runtime-${version}.tgz";
      hash = "sha256-qhpkYClh0ttW5PvJMDwzdjSrPNLvak42gygbfOawtB8=";
    };

    # The npm tarball unpacks to "package/".
    sourceRoot = "package";

    # The published tarball has no lockfile; we vendor one generated from the
    # same package.json so that buildNpmPackage can compute a stable hash.
    postPatch = ''
      cp ${./package-lock.json} package-lock.json
    '';

    npmDepsFetcherVersion = 2;
    npmDepsHash = "sha256-ZZILHTR42WIAnpjg1AEAOqgedHVroVLAryTpFc2vWoI=";

    # The tarball already contains a pre-built dist/; no build step needed.
    dontNpmBuild = true;

    meta = with lib; {
      description = "Anthropic Sandbox Runtime - wraps security boundaries around arbitrary processes";
      homepage = "https://www.npmjs.com/package/@anthropic-ai/sandbox-runtime";
      license = licenses.asl20;
      mainProgram = "srt";
    };
  };
in
{
  options.programs.sandbox-runtime.enable = lib.mkEnableOption "Anthropic sandbox runtime";

  config = lib.mkIf config.programs.sandbox-runtime.enable {
    home.packages = [ sandbox-runtime ];
  };
}
