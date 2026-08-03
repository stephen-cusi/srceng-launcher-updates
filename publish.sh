#!/bin/bash
set -euo pipefail

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <stable|dev> <version-name> <build> <apk> <changelog.md>" >&2
    exit 1
fi

CHANNEL=$1
VERSION=$2
BUILD=$3
APK=$4
CHANGELOG=$5

if [ "$CHANNEL" != "stable" ] && [ "$CHANNEL" != "dev" ]; then
    echo "Channel must be stable or dev" >&2
    exit 1
fi
if ! [[ "$BUILD" =~ ^[0-9]+$ ]]; then
    echo "Build must be a non-negative integer" >&2
    exit 1
fi
if [ ! -f "$APK" ] || [ ! -f "$CHANGELOG" ]; then
    echo "APK and changelog files must exist" >&2
    exit 1
fi

ROOT=$(cd "$(dirname "$0")" && pwd)
APK_NAME="srceng-${VERSION}.apk"
LOG_NAME="${VERSION}.md"
cp "$APK" "$ROOT/$CHANNEL/apk/$APK_NAME"
cp "$CHANGELOG" "$ROOT/$CHANNEL/changelog/$LOG_NAME"
SHA256=$(sha256sum "$ROOT/$CHANNEL/apk/$APK_NAME" | cut -d ' ' -f 1)
BASE="https://raw.githubusercontent.com/stephen-cusi/srceng-launcher-updates/main/$CHANNEL"

cat > "$ROOT/$CHANNEL/manifest.json" <<EOF
{
  "published": true,
  "channel": "$CHANNEL",
  "versionName": "$VERSION",
  "build": $BUILD,
  "apkUrl": "$BASE/apk/$APK_NAME",
  "changelogUrl": "$BASE/changelog/$LOG_NAME",
  "sha256": "$SHA256"
}
EOF

echo "Published metadata for $CHANNEL $VERSION (build $BUILD)"
