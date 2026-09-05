"""Verify current packages before deleting package assets from older versions."""

import json
import os
from pathlib import Path
import re
import subprocess
from urllib.parse import quote


def version(tag):
    match = re.fullmatch(r"v?(\d+)\.(\d+)\.(\d+)", tag)
    return tuple(map(int, match.groups())) if match else None


def package(name):
    return bool(re.fullmatch(r"notelytask[-_].+\.(apk|deb|rpm)", name)) or name == "app-release.apk"


def api(path, method="GET"):
    output = subprocess.check_output(["gh", "api", "--method", method, path])
    return json.loads(output) if output.strip() else None


def pages(path):
    result = []
    page = 1
    while True:
        batch = api(f"{path}?per_page=100&page={page}")
        result.extend(batch)
        if len(batch) < 100:
            return result
        page += 1


def verify(files, assets):
    if len(files) != 3 or {p.suffix for p in files} != {".apk", ".deb", ".rpm"}:
        raise ValueError("Expected exactly one APK, DEB and RPM")
    for file in files:
        matches = [a for a in assets if a["name"] == file.name]
        if (file.stat().st_size == 0 or len(matches) != 1
                or matches[0]["state"] != "uploaded"
                or matches[0]["size"] != file.stat().st_size):
            raise ValueError(f"Unverified release package: {file.name}")


def candidates(releases, tag):
    current = version(tag)
    if current is None:
        raise ValueError("Invalid release version")
    return [r for r in releases if not r["draft"] and not r["prerelease"]
            and version(r["tag_name"]) is not None
            and version(r["tag_name"]) < current]


def main():
    root = f"repos/{os.environ['GITHUB_REPOSITORY']}"
    tag = os.environ["GITHUB_REF_NAME"]
    current = api(f"{root}/releases/tags/{quote(tag, safe='')}")
    if current["draft"] or current["prerelease"]:
        raise ValueError("Current release must be published and stable")
    verify(list(Path("release-packages").iterdir()),
           pages(f"{root}/releases/{current['id']}/assets"))
    # Gather the complete plan before any deletion. Version comparison protects
    # newer releases if an older workflow is rerun or finishes out of order.
    deletions = []
    for release in candidates(pages(f"{root}/releases"), tag):
        for asset in pages(f"{root}/releases/{release['id']}/assets"):
            if package(asset["name"]):
                deletions.append(asset)
    for asset in deletions:
        api(f"{root}/releases/assets/{asset['id']}", "DELETE")
        print(f"Removed older package: {asset['name']}")


if __name__ == "__main__":
    main()
