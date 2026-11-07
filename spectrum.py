#!/usr/bin/python3
import os
from pathlib import Path
import subprocess

BAR_COUNT = 56
data = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
assets = data / "desfiladeiro"
runtime = Path(os.environ["XDG_RUNTIME_DIR"])
frame = runtime / "desfiladeiro-spectrum.svg"
temporary = runtime / "desfiladeiro-spectrum.tmp"


def render(levels):
    bars = []
    for index, level in enumerate(levels):
        height = 5 + min(max(level, 0), 100) * 32 / 100
        bars.append(f'<rect x="{index * 10 + 2}" y="{(40-height)/2:.1f}" '
                    f'width="5.5" height="{height:.1f}" rx="2.75"/>')
    temporary.write_text(
        '<svg xmlns="http://www.w3.org/2000/svg" width="560" height="40" '
        'viewBox="0 0 560 40"><g fill="#d5f6f8">'
        + "".join(bars) + '</g></svg>'
    )
    temporary.replace(frame)


def main():
    last = [0] * BAR_COUNT
    render(last)
    with subprocess.Popen(["cava", "-p", assets / "spectrum.ini"],
                          text=True, stdout=subprocess.PIPE) as cava:
        for line in cava.stdout:
            try:
                levels = [int(level) for level in line.strip().rstrip(";").split(";")]
            except ValueError:
                continue
            if len(levels) == BAR_COUNT and levels != last:
                render(levels)
                last = levels
        return cava.wait() or 1


if __name__ == "__main__":
    raise SystemExit(main())
