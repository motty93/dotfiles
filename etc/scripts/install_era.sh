#!/bin/bash

# era (ターミナルの雨時計 / kyoheiu/era) のインストールスクリプト
# .bash_aliases の `alias rain='era'` 用。
# era は npm ではなく Deno 製。ここでは GitHub Releases のバイナリを取得する。
# 前提: curl / tar が利用可能。配置先 ~/.local/bin は .bashrc で PATH 済み。

set -eu

# 新バージョンへ上げたい時はここだけ書き換える
ERA_VERSION="v0.1.3"

echo "=== install era ${ERA_VERSION} ==="

# Linux 向け公式アセットは x86_64 のみ (WSL2 は x86_64 前提)
ARCH="$(uname -m)"
if [ "${ARCH}" != "x86_64" ]; then
    echo "era: ${ARCH} 向けの Linux バイナリは配布されていないためスキップ" >&2
    exit 0
fi

BIN_DIR="${HOME}/.local/bin"
mkdir -p "${BIN_DIR}"

# tarball は直下に era バイナリ単体 (ディレクトリなし) なので -C で直接展開
curl -fsSL "https://github.com/kyoheiu/era/releases/download/${ERA_VERSION}/era-${ERA_VERSION}-x86_64-linux.tar.gz" \
    | tar -xz -C "${BIN_DIR}"
chmod +x "${BIN_DIR}/era"

echo ""
echo "=== done ==="
# era 自体は TTY 必須の雨時計なのでここでは起動しない (実行は 'rain' で)
echo "era: ${BIN_DIR}/era (${ERA_VERSION}) — シェル再起動後 'rain' で起動 / Ctrl-C で終了"
