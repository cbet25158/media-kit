#!/usr/bin/env bash
set -euo pipefail

REPO="cbet25158/libmpv-android-binaries"
DRY_RUN=0
VERSION="v1.0.0"
VERSION_SET=0

CATALOG="media_kit/hook/native_bundles.json"
# "<release asset>:<bundle key in the catalog>"
TARGETS=(
  "default-arm64-v8a.jar:android_arm64"
  "default-armeabi-v7a.jar:android_arm"
  "default-x86_64.jar:android_x64"
  "default-x86.jar:android_ia32"
)

usage() {
  cat <<'USAGE'
Usage:
  tool/update_android_libmpv_artifacts.sh [version] [--dry-run] [--repo=<owner/name>]

Example:
  tool/update_android_libmpv_artifacts.sh
  tool/update_android_libmpv_artifacts.sh v1.0.0

The script reads GitHub release asset digests and rewrites the url / sha256 of
the android_* entries in media_kit/hook/native_bundles.json. Other entries and
the file's formatting are left untouched.

Note: draft releases return 404 for anonymous API access - publish the release
first.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=1
      ;;
    --repo=*)
      REPO="${arg#--repo=}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    v*)
      if [[ "$VERSION_SET" -eq 1 ]]; then
        usage
        exit 64
      fi
      VERSION="$arg"
      VERSION_SET=1
      ;;
    *)
      usage
      exit 64
      ;;
  esac
done

if [[ ! -f "$CATALOG" ]]; then
  echo "error: $CATALOG not found (run from the repository root)" >&2
  exit 1
fi

RELEASE_JSON="$(mktemp "${TMPDIR:-/tmp}/media-kit-android-release.XXXXXX.json")"
trap 'rm -f "$RELEASE_JSON"' EXIT

curl -fsSL \
  -H "Accept: application/vnd.github+json" \
  -H "User-Agent: media-kit-artifact-updater" \
  "https://api.github.com/repos/${REPO}/releases/tags/${VERSION}" \
  -o "$RELEASE_JSON"

digest_for() {
  local asset_name="$1"

  RELEASE_JSON="$RELEASE_JSON" ASSET_NAME="$asset_name" ruby -rjson -e '
    release = JSON.parse(File.read(ENV.fetch("RELEASE_JSON")))
    name = ENV.fetch("ASSET_NAME")
    asset = release.fetch("assets").find { |item| item["name"] == name }

    abort("Asset #{name} was not found in the release.") unless asset

    digest = asset["digest"]
    unless digest.is_a?(String) && digest.start_with?("sha256:")
      abort("Asset #{name} does not have a sha256 digest.")
    end

    puts digest.sub(/\Asha256:/, "")
  '
}

update_bundle() {
  local key="$1"
  local url="$2"
  local checksum="$3"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would update ${key} in ${CATALOG}"
    return
  fi

  FILE_PATH="$CATALOG" KEY="$key" URL="$url" CHECKSUM="$checksum" ruby -e '
    path = ENV.fetch("FILE_PATH")
    key = ENV.fetch("KEY")
    contents = File.read(path)

    pattern = /("#{Regexp.escape(key)}": \{\s*"url": ")[^"]*(",\s*"sha256": ")[0-9a-fA-F]{64}(")/
    replaced = contents.sub!(pattern) { "#{$1}#{ENV.fetch("URL")}#{$2}#{ENV.fetch("CHECKSUM")}#{$3}" }

    abort("Entry #{key} was not found in #{path}") unless replaced

    File.write(path, contents)
  '
}

for target in "${TARGETS[@]}"; do
  jar="${target%%:*}"
  key="${target##*:}"
  checksum="$(digest_for "$jar")"
  update_bundle "$key" "https://github.com/${REPO}/releases/download/${VERSION}/${jar}" "$checksum"
  echo "${key} (${jar}): ${checksum}"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run completed. No files were changed."
fi
