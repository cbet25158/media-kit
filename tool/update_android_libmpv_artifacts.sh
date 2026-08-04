#!/usr/bin/env bash
set -euo pipefail

REPO="cbet25158/libmpv-android-binaries"
DRY_RUN=0
VERSION="v1.0.0"
VERSION_SET=0

GRADLE_FILE="libs/android/media_kit_libs_android_video/android/build.gradle"
JARS=("default-arm64-v8a.jar" "default-armeabi-v7a.jar" "default-x86_64.jar" "default-x86.jar")

usage() {
  cat <<'EOF'
Usage:
  tool/update_android_libmpv_artifacts.sh [version] [--dry-run] [--repo=<owner/name>]

Example:
  tool/update_android_libmpv_artifacts.sh
  tool/update_android_libmpv_artifacts.sh v1.0.0

The script reads GitHub release asset digests and rewrites the Android libmpv
jar entries (url / sha256 / destination) in
libs/android/media_kit_libs_android_video/android/build.gradle.

Note: draft releases return 404 for anonymous API access - publish the release
first.
EOF
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

if [[ ! -f "$GRADLE_FILE" ]]; then
  echo "error: $GRADLE_FILE not found (run from the repository root)" >&2
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

update_jar_entry() {
  local jar="$1"
  local checksum="$2"
  local url="https://github.com/${REPO}/releases/download/${VERSION}/${jar}"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would update ${jar} in ${GRADLE_FILE}"
    return
  fi

  FILE_PATH="$GRADLE_FILE" JAR="$jar" URL="$url" CHECKSUM="$checksum" VERSION="$VERSION" ruby -e '
    path = ENV.fetch("FILE_PATH")
    jar = ENV.fetch("JAR")
    url = ENV.fetch("URL")
    checksum = ENV.fetch("CHECKSUM")
    version = ENV.fetch("VERSION")
    contents = File.read(path)

    pattern = /^(\s*)\["url": "[^"]*\/#{Regexp.escape(jar)}", "sha256": "[0-9a-fA-F]{64}", "destination": file\("\$buildDir\/[^"]+\/#{Regexp.escape(jar)}"\)\](,?)$/
    replacement = nil
    contents.sub!(pattern) do
      replacement = "#{$1}[\"url\": \"#{url}\", \"sha256\": \"#{checksum}\", \"destination\": file(\"$buildDir/#{version}/#{jar}\")]#{$2}"
    end

    abort("Entry for #{jar} was not found in #{path}") unless replacement

    File.write(path, contents)
  '
}

for jar in "${JARS[@]}"; do
  checksum="$(digest_for "$jar")"
  update_jar_entry "$jar" "$checksum"
  echo "${jar}: ${checksum}"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run completed. No files were changed."
fi
