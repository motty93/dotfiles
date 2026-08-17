#!/bin/bash
#
# git も何も入っていない新しい Ubuntu に dotfiles を導入するブートストラップ。
# wget か curl だけあれば実行できる:
#
#   wget -nv -O- https://raw.githubusercontent.com/motty93/dotfiles/master/etc/bootstrap.sh | bash
#   curl -fsSL   https://raw.githubusercontent.com/motty93/dotfiles/master/etc/bootstrap.sh | bash
#
# やること: apt で git / curl を入れる → ~/dotfiles に HTTPS で clone → etc/install.sh を実行
# (git が使える環境なら git clone → bash ~/dotfiles/etc/install.sh で同じ)

set -eu

# fork 等を試すときは DOTFILES_REPO=... で差し替えられる。clone 先は install.sh が ~/dotfiles 固定
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/motty93/dotfiles.git}"
DOTFILES_DIR="${HOME}/dotfiles"

main() {
  echo "########## bootstrap: apt (git / curl) ##########"
  # OS インストール直後は unattended-upgrades が dpkg のロックを掴んでいることが多いので、最大 10 分待つ
  sudo apt-get -o DPkg::Lock::Timeout=600 update
  sudo apt-get -o DPkg::Lock::Timeout=600 install -y git curl ca-certificates

  echo "########## bootstrap: clone ##########"
  if [ -d "${DOTFILES_DIR}/.git" ]; then
    echo "${DOTFILES_DIR} は既に git リポジトリなので clone をスキップ"
  elif [ -e "${DOTFILES_DIR}" ]; then
    echo "error: ${DOTFILES_DIR} が既にあり、git リポジトリではない。退避してから再実行する" >&2
    exit 1
  else
    git clone "${DOTFILES_REPO}" "${DOTFILES_DIR}"
  fi

  echo "########## bootstrap: install.sh ##########"
  # `... | bash` で起動すると stdin はパイプ (bash 自身がそこからこのスクリプトを読んでいる)。
  # install.sh 以下で対話が要る場合に備え、端末が使えるなら install.sh の stdin は端末に付け替える
  if [ -t 0 ] || ! { true </dev/tty; } 2>/dev/null; then
    bash "${DOTFILES_DIR}/etc/install.sh"
  else
    bash "${DOTFILES_DIR}/etc/install.sh" </dev/tty
  fi

  cat <<EOF

########## bootstrap: done ##########
origin は HTTPS (${DOTFILES_REPO}) で clone している。push するなら SSH 鍵を GitHub に登録してから切り替える:
  git -C ${DOTFILES_DIR} remote set-url origin git@github.com:motty93/dotfiles.git
EOF
}

# `... | bash` で途中まで届いた時点で実行が始まらないよう、全体を関数にして最後に呼ぶ
main "$@"
