#!/bin/bash

# カスタム XKB (Anne Pro 2 / VXV M61) をネイティブ Linux (GNOME on Wayland) に配置するスクリプト
# - symbols: /usr/share/X11/xkb/symbols/ (パッケージ所有外のファイルなので xkeyboard-config 更新でも残る)
# - rules:   /etc/xkb/rules/evdev        (libxkbcommon の追加パス。パッケージの rules を上書きしない)
# 配置後の有効化・確認手順は doc/xkb.md を参照。install.sh からは呼ばない (GUI 機でのみ手動実行)

set -eu

if [ -n "${WSL_DISTRO_NAME:-}" ]; then
    echo "xkb: WSL2 ではキーボード配列は Windows 側で管理するため何もしない" >&2
    exit 0
fi

XKB_DIR="${HOME}/dotfiles/xkb"
SYMBOLS_DIR="/usr/share/X11/xkb/symbols"
RULES_DIR="/etc/xkb/rules"

echo "=== install symbols -> ${SYMBOLS_DIR} ==="
for f in "${XKB_DIR}"/symbols/*; do
    sudo install -m 644 "${f}" "${SYMBOLS_DIR}/$(basename "${f}")"
    echo "  $(basename "${f}")"
done

echo "=== install rules -> ${RULES_DIR}/evdev ==="
sudo install -d -m 755 "${RULES_DIR}"
sudo install -m 644 "${XKB_DIR}/rules/evdev" "${RULES_DIR}/evdev"

echo ""
echo "=== done ==="
echo "使うキーボードに合わせてどちらか一方を有効化 (即時反映、再ログイン不要):"
echo "  gsettings set org.gnome.desktop.input-sources xkb-options \"['anne_pro2:swap']\""
echo "  gsettings set org.gnome.desktop.input-sources xkb-options \"['xvx_m61:swap']\""
