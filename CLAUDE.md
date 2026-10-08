# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

WSL2 (Ubuntu) と ネイティブ Linux (Ubuntu 24.04 / GNOME on Wayland) 兼用の個人dotfilesリポジトリ。`~/dotfiles/` 配下のdotfilesをリンクスクリプトで `$HOME` にシンボリックリンクする構成。

## 主要コマンド

### 初期セットアップ
```bash
sh ./dotfiles/etc/install.sh    # aptパッケージ、Docker、asdfのインストール + シンボリックリンク作成
```

git 未導入の新しい Ubuntu では `etc/bootstrap.sh` を wget/curl で流し込む (git/curl の apt install → HTTPS で clone → install.sh を実行。one-liner は README 参照)。

### dotfilesのリンク
```bash
sh ./dotfiles/etc/scripts/link.sh   # .??* にマッチする全ファイルを $HOME にシンボリックリンク (.git, .github, .gitignore, .DS_Store は除外)
```

## アーキテクチャ

### シンボリックリンクの仕組み
`etc/scripts/link.sh` はリポジトリルートの `.??*` にマッチする隠しファイル/ディレクトリを走査し、`ln -snfv` で `$HOME` にシンボリックリンクを作成する。リポジトリルートに新しいdotfileを追加すれば、次回実行時に自動的にリンクされる。

### シェル設定の構成
- `.bashrc` — メインのシェル初期化: ヒストリ (200k行)、PATH設定、各種連携 (asdf, gcloud, sdkman, deno, rust)
- `.bash_aliases` — コマンドショートカット (git, docker, tmux, rails, peco系ツール)
- `.bash_function` — peco/fzfを使ったインタラクティブヘルパー (ディレクトリ移動、gitブランチ選択、履歴検索)
- `.bash_secrets` — ローカル認証情報 (実際の値はコミットしない)

### エディタ設定
- `.vimrc` は **dein.vim** プラグインマネージャを使用、LSP対応 (gopls, typescript-language-server, solargraph/steep for Ruby)
- `.vim/UltiSnips/` にカスタムスニペット: elixir, ruby, rails, go, javascript, typescript, typescriptreact, prisma, markdown, toml
- Leaderキーは `,`

### Tmux
- Prefix: **Ctrl-Q** (デフォルトのC-bではない)
- Vimスタイルのペイン移動 (h/j/k/l)
- コピーモードはviキーバインド + システムクリップボード連携 (WSL2: `clip.exe` / ネイティブ: `wl-copy`、`if-shell` で分岐)

### その他の設定ディレクトリ
- `config/claude/` — Claude デスクトップアプリの設定とMCPパーミッション
- `.claude/skills/` — 自作スキル (SKILL.md)。`link.sh` は `.claude` を除外するので、`~/.claude/skills/<name>` へ手動で symlink する。Codex でも使うスキルは同じ実体を `~/.codex/skills/<name>` にも symlink する (例: `daily-note`)
- `xkb/` — メカニカルキーボード用カスタムキーマップ (Anne Pro 2, VXV M61)。ネイティブ Linux (Wayland) 向けに `etc/scripts/install_xkb.sh` でシステムへ配置する (手順は `doc/xkb.md`)
- `.github/` — PRテンプレート (日本語) と自動アサインワークフロー

### パッケージ管理
- `etc/packages.list` — 開発環境用APTパッケージ一覧 (ビルドツール、日本語フォント、peco、tig等)
- 言語管理は **asdf** (nodejs, golang, python) を使用、プラグインは `etc/install.sh` で追加

## 規約

- コメントやPRテンプレートは**日本語**で記述
- WSL2 と ネイティブ Linux を同じファイルで共用する。環境差分 (クリップボード、ブラウザ起動等) は実行時に `WSL_DISTRO_NAME` の有無で分岐し、片方だけの前提 (X11 前提など) を持ち込まない
- Gitユーザー: motty93 / rdwbocungelt5@gmail.com
