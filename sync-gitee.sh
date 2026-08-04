#!/bin/bash
set -euo pipefail

# 将更新仓库的信息文件(不含 APK)同步到独立的 Gitee 信息仓库并推送。
# 用法: ./sync-gitee.sh [提交信息]

SRC=/home/arale/srceng-launcher-updates
DST=/home/arale/srceng-launcher-updates-gitee
MSG=${1:-"sync: 同步更新信息到 Gitee"}

if [ ! -d "$DST/.git" ]; then
    echo "Gitee 信息仓库不存在: $DST" >&2
    exit 1
fi

cd "$SRC"

# 只同步信息文件,排除 APK 和 .git
rm -rf "$DST/dev" "$DST/stable"
mkdir -p "$DST/dev/changelog" "$DST/dev/apk" "$DST/stable/changelog" "$DST/stable/apk"
cp .gitignore README.md generate_releases.py publish.sh "$DST/"
cp dev/manifest.json dev/releases.json "$DST/dev/"
cp dev/changelog/*.md "$DST/dev/changelog/"
cp stable/manifest.json stable/releases.json "$DST/stable/"
cp stable/changelog/*.md "$DST/stable/changelog/"
touch "$DST/dev/apk/.gitkeep" "$DST/stable/apk/.gitkeep"

cd "$DST"
git add -A
if git diff --cached --quiet; then
    echo "无改动,跳过提交"
    exit 0
fi
git -c user.name="stephen-cusi" -c user.email="stephen-cusi@users.noreply.github.com" commit -m "$MSG"
git push gitee main
echo "已同步到 Gitee"
