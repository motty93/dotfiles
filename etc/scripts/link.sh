#!/bin/bash

set -eu
DOT_DIRECTORY="${HOME}/dotfiles"

cd "${DOT_DIRECTORY}" || exit 1

echo "link home directory dotfiles"
for f in .??*
do
    # ignore files and directories
    [ "$f" = ".git" ] && continue
    [ "$f" = ".github" ] && continue
    [ "$f" = ".gitignore" ] && continue
    [ "$f" = ".DS_Store" ] && continue
    [ "$f" = ".claude" ] && continue
    ln -snfv "${DOT_DIRECTORY}/${f}" "${HOME}/${f}"
done

# config/ 配下の設定ファイルを個別にシンボリックリンク
echo ""
echo "link config directory dotfiles"
CONFIG_DIR="${DOT_DIRECTORY}/config"
if [ -d "${CONFIG_DIR}" ]; then
    find "${CONFIG_DIR}" -type f | while read -r src; do
        # config/ からの相対パスを取得 (例: claude/settings.json)
        rel="${src#"${CONFIG_DIR}"/}"
        dest="${HOME}/.${rel}"
        mkdir -p "$(dirname "${dest}")"
        ln -snfv "${src}" "${dest}"
    done
fi

echo "linked dotfiles complete!"
