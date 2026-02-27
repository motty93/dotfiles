#!/bin/bash

# asdfで管理している言語を有効にしてVimをソースからビルドするスクリプト
# 必要なasdfプラグイン: ruby, python, lua, luajit, perl

set -eu

# asdfから各言語のバージョンを取得
RUBY_VERSION=$(asdf current ruby 2>/dev/null | awk '{print $2}')
PYTHON_VERSION=$(asdf current python 2>/dev/null | awk '{print $2}')
LUA_VERSION=$(asdf current lua 2>/dev/null | awk '{print $2}')
LUAJIT_VERSION=$(asdf current luajit 2>/dev/null | awk '{print $2}')
PERL_VERSION=$(asdf current perl 2>/dev/null | awk '{print $2}')

ASDF_DIR="${HOME}/.asdf/installs"

RUBY_DIR="${ASDF_DIR}/ruby/${RUBY_VERSION}"
PYTHON_DIR="${ASDF_DIR}/python/${PYTHON_VERSION}"
PYTHON_CONFIG_DIR=$(find "${PYTHON_DIR}/lib" -name "config-*" -type d | head -1)
LUA_DIR="${ASDF_DIR}/lua/${LUA_VERSION}"
LUAJIT_DIR="${ASDF_DIR}/luajit/${LUAJIT_VERSION}"
PERL_DIR="${ASDF_DIR}/perl/${PERL_VERSION}"

echo "=== Vim build configuration ==="
echo "Ruby:    ${RUBY_VERSION} (${RUBY_DIR})"
echo "Python:  ${PYTHON_VERSION} (${PYTHON_DIR})"
echo "Lua:     ${LUA_VERSION} (${LUA_DIR})"
echo "LuaJIT:  ${LUAJIT_VERSION} (${LUAJIT_DIR})"
echo "Perl:    ${PERL_VERSION} (${PERL_DIR})"
echo ""

# ビルドに必要なAPTパッケージをインストール
echo "=== install build dependencies ==="
sudo apt install -y \
    build-essential \
    libncurses5-dev \
    libncurses-dev \
    libacl1-dev \
    libgpm-dev \
    libxt-dev \
    libxpm-dev \
    libx11-dev \
    libsm-dev \
    libice-dev

# Vimソースコードの取得
VIM_SRC_DIR="${HOME}/vim-src"
if [ -d "${VIM_SRC_DIR}" ]; then
    echo "=== update vim source ==="
    cd "${VIM_SRC_DIR}"
    git pull
else
    echo "=== clone vim source ==="
    git clone https://github.com/vim/vim.git "${VIM_SRC_DIR}"
    cd "${VIM_SRC_DIR}"
fi

# クリーンビルド
echo "=== clean previous build ==="
make distclean 2>/dev/null || true

# configure
echo "=== configure ==="
./configure \
    --with-features=huge \
    --enable-multibyte \
    --enable-rubyinterp=yes \
    --with-ruby-command="${RUBY_DIR}/bin/ruby" \
    --enable-python3interp=yes \
    --with-python3-command="${PYTHON_DIR}/bin/python3" \
    --with-python3-config-dir="${PYTHON_CONFIG_DIR}" \
    --enable-perlinterp=yes \
    --with-perl-command="${PERL_DIR}/bin/perl" \
    --enable-luainterp=yes \
    --with-lua-prefix="${LUA_DIR}" \
    --with-luajit \
    --with-luajit-prefix="${LUAJIT_DIR}" \
    --enable-cscope \
    --enable-terminal \
    --enable-fail-if-missing \
    --prefix=/usr/local

# ビルド & インストール
echo "=== build ==="
make -j"$(nproc)"

echo "=== install ==="
sudo make install

echo ""
echo "=== done ==="
vim --version | head -5
