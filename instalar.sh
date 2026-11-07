#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
data=${XDG_DATA_HOME:-$HOME/.local/share}
config=${XDG_CONFIG_HOME:-$HOME/.config}
assets="$data/desfiladeiro"
wallpaper=${1:-}
ralsei=${2:-}
sprite=${3:-}

for program in busctl cava curl fastfetch kpackagetool6 kwriteconfig6 plasma-apply-colorscheme plasma-apply-wallpaperimage python3 systemctl; do
    command -v "$program" >/dev/null || { printf 'Dependência ausente: %s\n' "$program" >&2; exit 1; }
done
: "${XDG_RUNTIME_DIR:?Execute dentro da sessão KDE Plasma.}"
for asset in "$wallpaper" "$ralsei" "$sprite"; do
    if [[ -n "$asset" && ! -f "$asset" ]]; then
        printf 'Arquivo não encontrado: %s\n' "$asset" >&2
        exit 1
    fi
done
if [[ -n "$ralsei" || -n "$sprite" ]]; then
    command -v magick >/dev/null || { printf 'Instale o ImageMagick para usar os sprites.\n' >&2; exit 1; }
fi
busctl --user status org.kde.plasmashell >/dev/null

stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT
for plugin in player espectro; do
    mkdir -p "$stage/$plugin/contents/ui"
    cp "$repo/$plugin.json" "$stage/$plugin/metadata.json"
    cp "$repo/$plugin.qml" "$stage/$plugin/contents/ui/main.qml"
done
cp "$repo/fetch-cover.py" "$stage/player/contents/ui/"
if [[ -n "$ralsei" ]]; then
    magick "$ralsei" -coalesce -trim +repage -filter point -resize '80x80>' -layers Optimize -loop 0 \
        "$stage/player/contents/ui/ralsei.gif"
    sed -i 's@^                source: ""$@                source: Qt.resolvedUrl("ralsei.gif")@' \
        "$stage/player/contents/ui/main.qml"
fi
if [[ -n "$sprite" ]]; then
    magick "$sprite" -filter point -resize '16x21!' -alpha on -depth 8 "rgba:$stage/link.rgba"
    python3 "$repo/sprite-ansi.py" "$stage/link.rgba" "$stage/link.ansi"
    install -Dm644 "$stage/link.ansi" "$assets/link.ansi"
fi

for plugin in player espectro; do
    id=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["KPlugin"]["Id"])' "$repo/$plugin.json")
    if [[ -d "$data/plasma/plasmoids/$id" ]]; then
        kpackagetool6 --type Plasma/Applet --upgrade "$stage/$plugin"
    else
        kpackagetool6 --type Plasma/Applet --install "$stage/$plugin"
    fi
done

install -Dm644 "$repo/Desfiladeiro.colors" "$data/color-schemes/Desfiladeiro.colors"
install -Dm644 "$repo/Desfiladeiro.colorscheme" "$data/konsole/Desfiladeiro.colorscheme"
install -Dm644 "$repo/Desfiladeiro.profile" "$data/konsole/Desfiladeiro.profile"
for file in fastfetch.jsonc spectrum.ini spectrum.py; do
    install -Dm644 "$repo/$file" "$assets/$file"
done
install -Dm755 "$repo/terminal" "$assets/terminal"
kwriteconfig6 --file "$data/konsole/Desfiladeiro.profile" --group General --key Command "\"$assets/terminal\""
ln -sfn "$XDG_RUNTIME_DIR/desfiladeiro-spectrum.svg" \
    "$data/plasma/plasmoids/local.desfiladeiro.spectrum/contents/ui/spectrum.svg"

mkdir -p "$config/systemd/user"
printf '[Unit]\nDescription=Espectro de áudio Desfiladeiro\nPartOf=graphical-session.target\nAfter=pipewire-pulse.service\n\n[Service]\nExecStart=/usr/bin/python3 "%s/spectrum.py"\nRestart=on-failure\nRestartSec=3\n\n[Install]\nWantedBy=graphical-session.target\n' "$assets" \
    > "$config/systemd/user/desfiladeiro-spectrum.service"
systemctl --user daemon-reload
systemctl --user enable --now desfiladeiro-spectrum.service
plasma-apply-colorscheme Desfiladeiro
if [[ -n "$wallpaper" ]]; then
    install -Dm644 "$wallpaper" "$data/wallpapers/Desfiladeiro.jpg"
    plasma-apply-wallpaperimage "$data/wallpapers/Desfiladeiro.jpg"
fi
printf 'Rice instalado. Veja o README para montar os painéis e selecionar o perfil do Konsole.\n'
