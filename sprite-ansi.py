"""Converte um sprite RGBA de 16 × 21 em texto para o Fastfetch."""
from pathlib import Path
import sys

source, target = map(Path, sys.argv[1:])
pixels = source.read_bytes()
width, height = 16, 21
if len(pixels) != width * height * 4:
    raise SystemExit("Tamanho RGBA inválido")

rows = []
for y in range(height):
    row = []
    for x in range(width):
        start = 4 * (y * width + x)
        red, green, blue, alpha = pixels[start:start + 4]
        row.append(f"\x1b[38;2;{red};{green};{blue}m██\x1b[39m" if alpha else "  ")
    rows.append("".join(row))
target.write_text("\n".join(rows) + "\n")
