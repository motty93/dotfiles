# dotfiles

## About

### Environment

WSL2 (Ubuntu) on Windows と ネイティブ Linux (Ubuntu 24.04 LTS Desktop / GNOME on Wayland) の両対応。
同じファイルを共用し、環境差分は実行時に `WSL_DISTRO_NAME` の有無で分岐する。

|  | WSL2 | ネイティブ Linux |
| --- | --- | --- |
| 判定 | `WSL_DISTRO_NAME` が設定されている | 未設定 |
| 前提 | WSLg (Windows 11 標準) | GNOME on Wayland。X11 前提の設定は置かない |
| クリップボード (tmux yank / `clip` / `pbcopy`) | `clip.exe` (UTF-16LE に変換) | `wl-copy` (wl-clipboard)。SSH 越しは tmux の OSC 52 で接続元へ |
| ブラウザで開く (previm / `chrome` 関数) | Windows 側の Chrome (`wslpath`) | `xdg-open` |
| キーボード配列 (`xkb/`) | 対象外 (Windows 側で管理) | [doc/xkb.md](doc/xkb.md) |

### Installing

git も何も入っていない新しい Ubuntu では、bootstrap を wget か curl で流し込む
(apt で git / curl を入れる → `~/dotfiles` に HTTPS で clone → `etc/install.sh` を実行):

```bash
# Ubuntu Desktop は curl が入っていないので wget
wget -nv -O- https://raw.githubusercontent.com/motty93/dotfiles/master/etc/bootstrap.sh | bash
# curl があるなら (Ubuntu Server / WSL2)
curl -fsSL https://raw.githubusercontent.com/motty93/dotfiles/master/etc/bootstrap.sh | bash
```

git が使える環境なら clone して直接実行しても同じ:

```bash
git clone https://github.com/motty93/dotfiles.git ~/dotfiles
bash ~/dotfiles/etc/install.sh
```

- 言語ランタイムは `.tool-versions` (リポジトリ管理、`~/.tool-versions` にリンクされる) を asdf でインストールする
- Vim と各ランタイムはソースビルドするため、低スペック機では数時間かかる
- GUI 不要のヘッドレス機で Vim の X11 連携が要らない場合は `VIM_WITH_X11=0 bash ~/dotfiles/etc/scripts/build_vim.sh`
- Vim のプラグイン管理は dein.vim。install.sh が dein 本体を `~/.cache/dein/repos/github.com/Shougo/dein.vim` に clone し、続く vim 起動で `.vimrc` の `dein#check_install()` が全プラグインを入れる (dein は自分自身を自動インストールできないため、この clone が無いと起動時に `E117: Unknown function: dein#begin` で全滅する)

### Customizing

- Change your `.gitconfig` user info
- bootstrap 経由だと `origin` は HTTPS なので、SSH 鍵を GitHub に登録したら `git -C ~/dotfiles remote set-url origin git@github.com:motty93/dotfiles.git` で切り替える
- Fill in `~/.bash_secrets` with actual values
- Restart the shell (`exec bash`) to load PATH changes
- Re-login or run `newgrp docker` to activate the docker group
- ネイティブ Linux でカスタムキーマップを使う場合は [doc/xkb.md](doc/xkb.md) の手順で配置する
