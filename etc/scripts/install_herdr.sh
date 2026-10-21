#!/bin/bash

# herdr (herdr.dev) のインストールスクリプト
# コーディングエージェントを常駐させておくターミナルランタイム。
# 設定 config/config/herdr/config.toml は link.sh が ~/.config/herdr/config.toml にリンク済み。
# .bash_function の herdr-ws (peco で workspace 切替) もこのバイナリ前提。
# 公式インストーラが latest.json から OS/arch 別のバイナリを取得し SHA-256 検証して配置する
# (自前でバージョン固定はしない。再実行すれば最新版に入れ替わる)。
# 前提: curl / awk が利用可能。配置先 ~/.local/bin は .bashrc で PATH 済み。

set -eu

BIN_DIR="${HOME}/.local/bin"
mkdir -p "${BIN_DIR}"

echo "=== install herdr ==="

curl -fsSL https://herdr.dev/install.sh | HERDR_INSTALL_DIR="${BIN_DIR}" sh

echo ""
echo "=== done ==="
# herdr 自体は TTY 必須なのでここでは起動しない
echo "herdr: $("${BIN_DIR}/herdr" --version 2>/dev/null || echo 'version unknown') — シェル再起動後 'herdr' で起動 / prefix は Ctrl-Q (~/.config/herdr/config.toml)"
