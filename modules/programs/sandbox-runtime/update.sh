#!/usr/bin/env bash
# Usage: ./update.sh [version]
# If version is omitted, the latest version on npm is used.
set -euo pipefail

cd "$(dirname "$0")"

PACKAGE="@anthropic-ai/sandbox-runtime"
VERSION="${1:-$(npm view "$PACKAGE" version)}"
TARBALL_URL="https://registry.npmjs.org/${PACKAGE}/-/sandbox-runtime-${VERSION}.tgz"

echo "Updating to ${PACKAGE}@${VERSION}"

# 1. Fetch the tarball and compute its SRI hash.
echo "Fetching tarball..."
TARBALL_STORE_PATH="$(nix-prefetch-url --print-path "$TARBALL_URL" 2>/dev/null | tail -1)"
SRC_HASH="$(nix hash convert --hash-algo sha256 --from nix32 \
  "$(nix-prefetch-url "$TARBALL_URL" 2>/dev/null)")"

# 2. Re-generate package-lock.json from the new package.json.
# Must run from inside the extracted directory (not --prefix) so the lockfile
# uses the package name rather than an absolute file: path.
echo "Generating package-lock.json..."
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
tar -xzf "$TARBALL_STORE_PATH" -C "$WORK_DIR"
( cd "$WORK_DIR/package" && npm install --package-lock-only --ignore-scripts 2>/dev/null )
cp "$WORK_DIR/package/package-lock.json" ./package-lock.json

# 3. Compute npmDepsHash by attempting a build and reading the mismatch error.
echo "Computing npmDepsHash..."
nix-build --no-out-link -E "
  with import <nixpkgs> {};
  buildNpmPackage {
    pname = \"anthropic-sandbox-runtime\";
    version = \"${VERSION}\";
    src = fetchurl {
      url = \"${TARBALL_URL}\";
      hash = \"${SRC_HASH}\";
    };
    sourceRoot = \"package\";
    postPatch = \"cp \${./package-lock.json} package-lock.json\";
    npmDepsFetcherVersion = 2;
    npmDepsHash = \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\";
    dontNpmBuild = true;
    meta = {};
  }
" 2>/tmp/nix-build-out.txt || true
NPM_DEPS_HASH="$(grep "got:" /tmp/nix-build-out.txt | awk '{print $2}')"
if [[ -z "$NPM_DEPS_HASH" ]]; then
  echo "ERROR: could not extract npmDepsHash from build output:" >&2
  cat /tmp/nix-build-out.txt >&2
  exit 1
fi

# 4. Patch default.nix in-place.
echo "Patching default.nix..."
sed -i.bak \
  -e "s|version = \".*\";|version = \"${VERSION}\";|" \
  -e "s|hash = \"sha256-.*\";|hash = \"${SRC_HASH}\";|" \
  -e "s|npmDepsHash = \"sha256-.*\";|npmDepsHash = \"${NPM_DEPS_HASH}\";|" \
  default.nix
rm -f default.nix.bak

echo "Done. Verify with: nix-build --no-out-link -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'"
