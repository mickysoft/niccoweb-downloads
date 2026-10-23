#!/usr/bin/env bash
# Publishes the runtime package of a release of a Niccoweb app repository here, in the fixed
# release of its app and Business Central version (for example replication-engine-bc29), as a zip
# with a fixed name (GitHub does not take .app files as release assets), so the download links of
# the web pages never change.
#
# Usage: publish-runtime.sh <owner/source-repo> <release tag, for example 29.0.30>
# Needs: gh signed in (or GH_TOKEN) able to read the source repository's releases, and
# DOWNLOADS_TOKEN, when set, able to write releases of mickysoft/niccoweb-downloads (otherwise
# the same sign-in writes them).
set -euo pipefail
SOURCE=$1
TAG=$2
DOWNLOADS=mickysoft/niccoweb-downloads
MAJOR=${TAG%%.*}

case "$SOURCE" in
  */nwcore) PRODUCT=nw-core; FILE_PREFIX=NW-Core; APP_NAME="NW Core" ;;
  */ReplicationPackage) PRODUCT=replication-engine; FILE_PREFIX=NCW-Replication-Engine; APP_NAME="NCW Replication Engine" ;;
  *) echo "Unknown source repository $SOURCE" >&2; exit 1 ;;
esac

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
gh release download "$TAG" -R "$SOURCE" -p '*-Apps-*.zip' -D "$WORK"
unzip -q -o "$WORK"/*-Apps-*.zip -d "$WORK/apps"
RUNTIME=$(find "$WORK/apps" -name '*.runtime.app' | head -1)
if [ -z "$RUNTIME" ]; then echo "Release $TAG of $SOURCE has no runtime package" >&2; exit 1; fi
VERSION=$(basename "$RUNTIME" | sed -E 's/.*_([0-9.]+)\.runtime\.app$/\1/')

RELEASE_TAG="$PRODUCT-bc$MAJOR"
APP_FILE="$FILE_PREFIX-BC$MAJOR.runtime.app"
FILE="$FILE_PREFIX-BC$MAJOR.runtime.zip"
mkdir "$WORK/out"
cp "$RUNTIME" "$WORK/out/$APP_FILE"
if command -v zip >/dev/null; then
  (cd "$WORK/out" && zip -q "$WORK/$FILE" "$APP_FILE")
else # Git Bash on Windows
  powershell -NoProfile -Command "Compress-Archive -Path '$(cygpath -w "$WORK/out/$APP_FILE")' -DestinationPath '$(cygpath -w "$WORK/$FILE")'"
fi
TITLE="$APP_NAME for Business Central $MAJOR ($VERSION)"
NOTES="Runtime package of **$APP_NAME $VERSION** for Business Central $MAJOR on-premises, built with the latest update of Business Central $MAJOR available at build time.

Download: [$FILE](https://github.com/$DOWNLOADS/releases/download/$RELEASE_TAG/$FILE). This link always gives the latest version; the zip holds $APP_FILE.

How to install it, and what it needs: [README](https://github.com/$DOWNLOADS#readme)."

if [ -n "${DOWNLOADS_TOKEN:-}" ]; then export GH_TOKEN=$DOWNLOADS_TOKEN; fi
if gh release view "$RELEASE_TAG" -R "$DOWNLOADS" >/dev/null 2>&1; then
  gh release edit "$RELEASE_TAG" -R "$DOWNLOADS" --title "$TITLE" --notes "$NOTES" >/dev/null
else
  gh release create "$RELEASE_TAG" -R "$DOWNLOADS" --target main --title "$TITLE" --notes "$NOTES" >/dev/null
fi
gh release upload "$RELEASE_TAG" -R "$DOWNLOADS" "$WORK/$FILE" --clobber
echo "Published $FILE ($APP_NAME $VERSION) in $DOWNLOADS release $RELEASE_TAG"
