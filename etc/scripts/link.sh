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
    [ "$f" = ".claude.json" ] && continue
    ln -snfv "${DOT_DIRECTORY}/${f}" "${HOME}/${f}"
done

# config/ 配下の設定ファイルを個別にシンボリックリンク
echo ""
echo "link config directory dotfiles"
CONFIG_DIR="${DOT_DIRECTORY}/config"
SKILLS_DIR="${CONFIG_DIR}/claude/skills"
if [ -d "${CONFIG_DIR}" ]; then
    # claude のスキルは下でディレクトリ単位でリンクするため、ファイル単位の対象から外す
    find "${CONFIG_DIR}" -type f -not -path "${SKILLS_DIR}/*" | while read -r src; do
        # config/ からの相対パスを取得 (例: claude/settings.json)
        rel="${src#"${CONFIG_DIR}"/}"
        dest="${HOME}/.${rel}"
        mkdir -p "$(dirname "${dest}")"
        ln -snfv "${src}" "${dest}"
    done
fi

# Claude Code のスキルは 1 スキル = 1 ディレクトリなので、ディレクトリごとリンクする
# (ファイル単位でリンクすると、スキル側でファイルが増減したときに追従できない)
echo ""
echo "link claude skills"
if [ -d "${SKILLS_DIR}" ]; then
    mkdir -p "${HOME}/.claude/skills"
    for src in "${SKILLS_DIR}"/*; do
        [ -d "${src}" ] || continue
        dest="${HOME}/.claude/skills/$(basename "${src}")"
        # 実ディレクトリが残っている場合はリンクに置き換える
        if [ -d "${dest}" ] && [ ! -L "${dest}" ]; then
            rm -rf "${dest}"
        fi
        ln -snfv "${src}" "${dest}"
    done
fi

echo "linked dotfiles complete!"
