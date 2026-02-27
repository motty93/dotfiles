# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

WSL2 (Ubuntu) 開発環境用の個人dotfilesリポジトリ。`~/dotfiles/` 配下のdotfilesをリンクスクリプトで `$HOME` にシンボリックリンクする構成。

## 主要コマンド

### 初期セットアップ
```bash
sh ./dotfiles/etc/install.sh    # aptパッケージ、Docker、asdfのインストール + シンボリックリンク作成
```

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
- コピーモードはviキーバインド + Windowsクリップボード連携 (`clip.exe`)

### その他の設定ディレクトリ
- `config/claude/` — Claude デスクトップアプリの設定とMCPパーミッション
- `xkb/` — メカニカルキーボード用カスタムキーマップ (Anne Pro 2, VXV M61)
- `.github/` — PRテンプレート (日本語) と自動アサインワークフロー

### パッケージ管理
- `etc/packages.list` — 開発環境用APTパッケージ一覧 (ビルドツール、日本語フォント、peco、tig等)
- 言語管理は **asdf** (nodejs, golang, python) を使用、プラグインは `etc/install.sh` で追加

## 規約

- コメントやPRテンプレートは**日本語**で記述
- WSL2 on Windows を前提とした構成 (`clip.exe` によるクリップボード連携、ターミナル色設定の調整等)
- Gitユーザー: motty93 / rdwbocungelt5@gmail.com
