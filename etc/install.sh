#!/bin/bash

set -eu

SCRIPT_DIRECTORY="${HOME}/dotfiles/etc/scripts"
DOT_DIRECTORY="${HOME}/dotfiles/etc"

sudo apt update && sudo apt upgrade -y
echo "########## apt install apps... ##########"
xargs sudo apt install -y < "${DOT_DIRECTORY}/packages.list"


echo "########## docker setting ##########"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER


echo "########## gcloud (Google Cloud CLI) ##########"
# .bashrc が gcloud 前提の分岐 (GOOGLE_IMPERSONATE_SERVICE_ACCOUNT) を持っているので apt 版を入れる。
# tarball 版 (~/google-cloud-sdk) と違い /usr/bin に入るため PATH 設定が不要
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg -o /etc/apt/keyrings/cloud.google.asc
sudo chmod a+r /etc/apt/keyrings/cloud.google.asc
echo \
  "deb [signed-by=/etc/apt/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt cloud-sdk main" | \
  sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null
sudo apt update
sudo apt install -y google-cloud-cli


echo "########## dotfiles link ##########"
cd "${SCRIPT_DIRECTORY}"
chmod +x link.sh
./link.sh


echo "########## asdf ##########"
# v0.16+ は Go 製でリリースバイナリ配布 (旧 git clone 方式は v0.15 以前)
ASDF_VERSION="v0.16.4"
ASDF_ARCH=$(dpkg --print-architecture)
mkdir -p "${HOME}/.asdf/bin"
curl -fsSL "https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/asdf-${ASDF_VERSION}-linux-${ASDF_ARCH}.tar.gz" \
    | tar -xz -C "${HOME}/.asdf/bin"
chmod +x "${HOME}/.asdf/bin/asdf"
# このスクリプト内で asdf を使うため PATH を通す (.bashrc は次回起動から反映)
export ASDF_DATA_DIR="${HOME}/.asdf"
export PATH="${HOME}/.asdf/bin:${HOME}/.asdf/shims:${PATH}"

echo "########## asdf plugins ##########"
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
asdf plugin add python https://github.com/asdf-community/asdf-python.git
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf plugin add lua https://github.com/Stratus3D/asdf-lua.git
asdf plugin add luajit https://github.com/smashedtoatoms/asdf-luajit.git
asdf plugin add perl https://github.com/ouest/asdf-perl.git
asdf plugin add deno https://github.com/asdf-community/asdf-deno.git
asdf plugin add bun https://github.com/cometkim/asdf-bun.git
asdf plugin add terraform https://github.com/asdf-community/asdf-hashicorp.git
asdf plugin add awscli https://github.com/MetricMike/asdf-awscli.git
asdf plugin add rust https://github.com/code-lever/asdf-rust.git

echo "########## asdf install (.tool-versions) ##########"
cd "${HOME}"
# link.sh で ~/dotfiles/.tool-versions が ~/.tool-versions にリンクされている前提。
# 無いまま進むと言語が何も入らず、後段の install_ai_tools.sh (npm) や build_vim.sh (asdf current) が分かりにくく落ちる
if [ ! -f "${HOME}/.tool-versions" ]; then
    echo "error: ${HOME}/.tool-versions not found (link.sh should have linked ~/dotfiles/.tool-versions)" >&2
    exit 1
fi
# asdf-luaJIT は LuaJIT と一緒に LuaRocks も入れる (バージョンは LUAROCKS_VERSION、未指定なら最新)。
# 最新の 3.13.0 は配布 tarball の rockspec が壊れていて bootstrap に失敗するので、動作確認済みの版に固定する
export LUAROCKS_VERSION="${LUAROCKS_VERSION:-3.12.2}"
# 一部プラグイン (terraform の post-install callback 等) が失敗しても本体バイナリは入る。
# 個別調査するより || true で全体を進める方針
asdf install || true


echo "########## AI tools ##########"
cd "${SCRIPT_DIRECTORY}"
chmod +x install_ai_tools.sh
./install_ai_tools.sh


echo "########## era (rainy clock / alias rain) ##########"
cd "${SCRIPT_DIRECTORY}"
chmod +x install_era.sh
./install_era.sh


echo "########## herdr (agent terminal runtime) ##########"
cd "${SCRIPT_DIRECTORY}"
chmod +x install_herdr.sh
./install_herdr.sh


echo "########## build vim ##########"
cd "${SCRIPT_DIRECTORY}"
chmod +x build_vim.sh
./build_vim.sh


echo "########## vim LSP servers ##########"
# .vimrc の executable('typescript-language-server') 分岐で使う。
# typescript は 7 系 (ネイティブ版) が tsserver.js を同梱しなくなっており、
# typescript-language-server が tsserver を見つけられず起動しない。5 系に固定する
npm install -g typescript-language-server "typescript@5"
asdf reshim nodejs


echo "########## dein.vim (vim plugin manager) ##########"
# dein は自分自身を自動インストールできないので、ここで clone しておく。
# これが無いと .vimrc の dein#begin / dein#add が E117 (未知の関数) で全滅する
DEIN_DIR="${HOME}/.cache/dein/repos/github.com/Shougo/dein.vim"
if [ ! -d "${DEIN_DIR}" ]; then
    git clone --depth 1 https://github.com/Shougo/dein.vim "${DEIN_DIR}"
fi
# プラグイン本体は .vimrc 末尾の dein#check_install() -> dein#install() が入れる。
# 入れ終わった後に hit-enter プロンプトで止まることがあるので timeout で打ち切る
timeout 1800 vim -X -c 'qa!' < /dev/null > /dev/null 2>&1 || true


sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
echo "congrats!!!!!!!!!!!"
