"""Replace only /notelytask in the ci-builds HTTPS API namespace."""

import os
from pathlib import Path
import sys

import requests


def request(session, method, endpoint, path, **kwargs):
    response = session.request(
        method, f"https://download.dbilgin.com/api/v2/user/{endpoint}",
        params={"path": path}, timeout=(20, 300), allow_redirects=False, **kwargs,
    )
    if not 200 <= response.status_code < 300:
        raise RuntimeError(f"{method} {endpoint} failed: HTTP {response.status_code}")
    return response


def main():
    files = [Path(name) for name in sys.argv[1:]]
    if len(files) != 3 or {p.suffix for p in files} != {".apk", ".deb", ".rpm"}:
        raise ValueError("Expected exactly one APK, DEB, and RPM")
    for path in files:
        if not path.is_file() or path.stat().st_size == 0:
            raise ValueError(f"Missing or empty release package: {path}")

    with requests.Session() as session:
        session.headers["X-SFTPGO-API-KEY"] = os.environ["SFTPGO_API_KEY"]
        destination = "/notelytask"
        # Authenticate before deletion; Go FileMode distinguishes directories
        # from symlinks. Recursive removal is performed by SFTPGo itself.
        entries = request(session, "GET", "dirs", "/").json()
        existing = next((e for e in entries if e["name"] == "notelytask"), None)
        if existing is not None:
            mode = existing["mode"]
            if not mode & 2147483648 or mode & 134217728:
                raise ValueError("/notelytask must be a directory, not a symlink")
            request(session, "DELETE", "dirs", destination)
        request(session, "POST", "dirs", destination)
        for path in files:
            with path.open("rb") as data:
                request(session, "POST", "files/upload",
                        f"{destination}/{path.name}", data=data,
                        headers={"Content-Type": "application/octet-stream"})
            print(f"Uploaded {path.name}")
        uploaded = request(session, "GET", "dirs", destination).json()
        if {e["name"]: e["size"] for e in uploaded} != {
            p.name: p.stat().st_size for p in files
        }:
            raise RuntimeError("Uploaded package names or sizes do not match")


if __name__ == "__main__":
    main()
