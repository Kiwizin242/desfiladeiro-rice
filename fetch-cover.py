#!/usr/bin/python3
import hashlib
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from urllib.parse import urlsplit


def main(url):
    parsed = urlsplit(url)
    if parsed.scheme not in {"https", "http"} or not parsed.hostname:
        return 1

    cache = Path(os.environ["XDG_RUNTIME_DIR"]) / "desfiladeiro-artwork"
    cache.mkdir(mode=0o700, exist_ok=True)
    name = hashlib.sha256(url.encode()).hexdigest()
    cover = cache / name
    if not cover.is_file():
        with tempfile.NamedTemporaryFile(dir=cache) as download:
            result = subprocess.run([
                "/usr/bin/curl", "--fail", "--silent", "--show-error", "--location",
                "--proto", "=http,https", "--proto-redir", "=http,https",
                "--connect-timeout", "5", "--max-time", "12", "--max-filesize", "8388608",
                "--output", download.name, "--", url,
            ], check=False)
            if result.returncode or not Path(download.name).stat().st_size:
                return 1
            with tempfile.NamedTemporaryFile(dir=cache, delete=False) as ready:
                ready.write(Path(download.name).read_bytes())
            Path(ready.name).replace(cover)

    cover.touch()
    old = sorted((entry for entry in cache.iterdir() if len(entry.name) == 64),
                 key=lambda entry: entry.stat().st_mtime, reverse=True)
    for entry in old[16:]:
        entry.unlink(missing_ok=True)
    print(cover.as_uri())
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1]))
