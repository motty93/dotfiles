#!/bin/bash

set -u
DOT_DIRECTORY="${HOME}/dotfiles"
BIN_DIRECTORY="${HOME}/dotfiles/bin"
XKB_DIRECTORY="${HOME}/dotfiles/xkb"

echo "xkb files"
setxkbmap -print >> ${HOME}/keymap/mypc_default
ln -snfv ${XKB_DIRECTORY} ${HOME}/.xkb

echo "link home directory dotfiles"
cd ${DOT_DIRECTORY}
for f in .??*
do
    #ignore files and directories
    [ "$f" = ".git" ] && continue
    [ "$f" = ".gitgnore" ] && continue
    [ "$f" = ".DS_Store" ] && continue
    ln -snfv ${DOT_DIRECTORY}/${f} ${HOME}/${f}
done

echo "lick bin files"
cd ${BIN_DIRECTORY}
for f in .??*
do
    #ignore files
    [ "$f" = ".keep" ] && continue
    [ "$f" = ".DS_Store" ] && continue
    ln -snfv ${BIN_DIRECTORY}/${f} /usr/local/bin/${f}
done

echo "linked dotfiles complete!"
