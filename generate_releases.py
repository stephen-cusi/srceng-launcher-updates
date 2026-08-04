#!/usr/bin/env python3
"""Generate channel release-history indexes from versioned feed files."""

from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent
RAW_BASE = "https://raw.githubusercontent.com/stephen-cusi/srceng-launcher-updates/main"
VERSION_PATTERN = re.compile(r"^[0-9A-Za-z][0-9A-Za-z._+-]*$")


def build_number(version: str, channel: str) -> int:
    if channel == "dev":
        match = re.search(r"-dev(\d+)$", version)
        if match:
            return int(match.group(1))
    raise ValueError(f"Cannot infer build number for {channel} version {version}")


def generate(channel: str) -> None:
    channel_dir = ROOT / channel
    manifest = json.loads((channel_dir / "manifest.json").read_text(encoding="utf-8"))
    releases: dict[str, dict[str, object]] = {}

    for changelog_path in sorted((channel_dir / "changelog").glob("*.md")):
        version = changelog_path.stem
        if not VERSION_PATTERN.fullmatch(version):
            raise ValueError(f"Unsupported version name: {version}")
        apk_path = channel_dir / "apk" / f"srceng-{version}.apk"
        apk: dict[str, object] | None = None
        if apk_path.is_file():
            apk_bytes = apk_path.read_bytes()
            apk = {
                "apkUrl": f"{RAW_BASE}/{channel}/apk/{apk_path.name}",
                "apkSize": len(apk_bytes),
                "sha256": hashlib.sha256(apk_bytes).hexdigest(),
            }

        changelog = changelog_path.read_text(encoding="utf-8").strip()
        entry: dict[str, object] = {
            "versionName": version,
            "build": build_number(version, channel),
            "changelog": {
                "format": "text/markdown",
                "url": f"{RAW_BASE}/{channel}/changelog/{changelog_path.name}",
                "content": changelog,
            },
        }
        if apk is not None:
            entry.update(apk)
        releases[version] = entry

    ordered = dict(sorted(releases.items(), key=lambda item: int(item[1]["build"]), reverse=True))
    latest = manifest.get("versionName") if manifest.get("published", False) else None
    if latest is not None and latest not in ordered:
        raise ValueError(f"Manifest version is absent from release history: {latest}")

    output = {
        "schemaVersion": 1,
        "channel": channel,
        "latestVersionName": latest,
        "releasesByVersion": ordered,
    }
    target = channel_dir / "releases.json"
    temporary = target.with_suffix(".json.tmp")
    temporary.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.replace(target)


def main() -> None:
    for channel in ("stable", "dev"):
        generate(channel)


if __name__ == "__main__":
    main()
