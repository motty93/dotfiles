#!/bin/bash

SCRIPT_DIRECTORY="${HOME}/dotfiles/etc/scripts"

packagelist="
  vim
  tig
  curl
  git
  xsel
  ufw
  tmux
  google-chrome
  docker.io
  rbenv
  unzip
  fontforge
  wget
  gdebi
  figlet
  peco

  # google drive async
  google-drive-ocamlfuse

  # build tools
  cmdtest
  input-utils
  cmake
  buld-essential
  libgcrypt11-dev
  libyajl-dev
  libboost-all-dev
  libcurl4-openssl-dev
  libexpat1-dev
  libcppunit-dev
  binutils-dev
  debhelper
  zlib1g-dev
  dpkg-dev
  pkg-config

  # fonts
  language-pack-ja
  language-pack-gnome-ja
  fonts-takao-gothic
  fonts-takao-mincho
  fonts-takao-pgothic
  fonts-vlgothic
  fonts-ipafont-gothic
  fonts-ipafont-mincho
  libreoffice-l10n-ja
  libreoffice-help-ja
  firefox-locale-ja
  manpages-ja
  thunderbird-locale-ja
  ibus-mozc
  ibus-anthy
  kasumi
  ibus-gtk
  ibus-gtk3
  poppler-data
  cmap-adobe-japan1
  fcitx-mozc
  fcitx-anthy
  fcitx-frontend-qt5
  fcitx-config-gtk
  fcitx-config-gtk2
  fcitx-frontend-gtk2
  fcitx-frontend-gtk3
  mozc-utils-gui
  fcitx-frontend-qt4
  fcitx-frontend-qt5
  libfcitx-qt0
  libfcitx-qt5-1

  # background papers
  mint-backgrounds-*
  ubuntu-wallpapers-*
  ubuntustudio-wallpapers
  xubuntu-community-wallpapers-*

  # asdf
  automake
  autoconf
  libreadline-dev
  libncurses-dev
  libssl-dev
  libyaml-dev
  libxslt-dev
  libffi-dev
  libtool
  libbz2-dev
  libsqlite3-dev
  unixodbc-dev
  gpg
  dirmngr

  # libinput gestures
  xdotool
  wmctrl
  libinput-tools
  dconf-cli
  xserver-xorg-input-synaptics-hwe-18.04

  #wine
  winehq-stable
  winetricks

  #flash player
  adobe-flashplugin
  flashplugin-installer
  browser-plugin-freshplayer-pepperflash

  # logid
  libevdev-dev
  libconfig-dev
  libudev-dev
  libconfig++-dev
"

sudo apt update; sudo apt upgrade
echo "########## apt install apps... ##########\n"
for app in ${packagelist[@]}
do
  sudo apt install -y ${app}
done


echo "########## docker setting ##########\n"
sudo usermod -aG docker $USER
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


echo "########## font setting ##########\n"
mkdir ${HOME}/.fonts
#Cica
cd ${HOME}
git clone https://github.com/miiton/Cica.git && cd $(basename $_ .git)
docker-compose build; docker-compose run --rm cica
cp dist/*.ttf ${HOME}/.fonts
#Ricty
cd ${HOME}
wget http://levien.com/type/myfonts/Inconsolata.otf -P ${HOME}/.fonts
wget -O migu-1m.zip "https://osdn.jp/projects/mix-mplus-ipa/downloads/63545/migu-1m-20150712.zip/"
unzip migu-1m.zip -d ${HOME}/.fonts
git clone https://github.com/metalefty/Ricty.git && cd $(basename $_ .git)
./ricty_generator.sh auto
cp *.ttf ${HOME}/.fonts/


echo "########## google drive directory setting ##########\n"
mkdir ${HOME}/GoogleDrive
google-drive-ocamlfuse
google-drive-ocamlfuse ${HOME}/GoogleDrive/


echo "########## asdf ##########\n"
cd ${HOME}
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
echo "########## install node ##########\n"
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
bash $HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring
echo "########## install golang ##########\n"
asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
# asdf list-all golang
# asdf install golang <latest stable version>
# asdf global golang <latest stable version>
# asdf reshim golang
echo "########## install python ##########\n"
asdf plugin-add python
# asdf list-all python
# asdf install python <latest stable version>
# asdf global python <latest stable version>
# asdf reshim python



echo "########## gesture tools setting ##########\n"
sudo gpasswd -a $USER input
git clone http://github.com/bulletmark/libinput-gestures && cd $(basename $_ .git)
sudo ./libinput-gestures-setup install


echo "########## dotfiles link ##########\n"
cd ${SCRIPT_DIRECTORY}
sudo chmod +x link.sh
./link.sh


echo "########## wine setting ##########\n"
cd ${HOME}
winetricks allfonts
# winecfg


echo "########## discord install ##########\n"
wget -O discord.deb "https://discordapp.com/api/download?platform=linux&format=deb" -P $HOME
sudo gdebi $HOME/discord.deb


echo "########## logid install ##########\n"
cd ${HOME}
git clone git@github.com:PixlOne/logiops.git
cd logiops/
mkdir build
cd build/
cmake ..
make
sudo make install


sudo apt update; sudo apt upgrade; sudo apt autoremove
echo "congrats!!!!!!!!!!!"
