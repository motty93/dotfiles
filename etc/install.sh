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


echo "########## dotfiles link ##########"
cd "${SCRIPT_DIRECTORY}"
chmod +x link.sh
./link.sh


echo "########## asdf ##########"
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
# asdfをシェルに読み込む (.bashrcはlink.sh済み)
# shellcheck disable=SC1091
. "${HOME}/.asdf/asdf.sh"

echo "########## asdf plugins ##########"
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
asdf plugin-add python
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf plugin-add lua https://github.com/Stratus3D/asdf-lua.git
asdf plugin-add luajit https://github.com/smashedtoatoms/asdf-luajit.git
asdf plugin-add perl https://github.com/ouest/asdf-perl.git
asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git
asdf plugin-add bun https://github.com/cometkim/asdf-bun.git
asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git
asdf plugin-add awscli https://github.com/MetricMike/asdf-awscli.git

echo "########## asdf install (.tool-versions) ##########"
cd "${HOME}"
asdf install


echo "########## AI tools ##########"
cd "${SCRIPT_DIRECTORY}"
chmod +x install_ai_tools.sh
./install_ai_tools.sh


echo "########## build vim ##########"
cd "${SCRIPT_DIRECTORY}"
chmod +x build_vim.sh
./build_vim.sh


sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
echo "congrats!!!!!!!!!!!"
