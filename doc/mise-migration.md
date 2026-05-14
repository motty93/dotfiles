# mise への移行検討

## 背景

現在の dotfiles は **asdf v0.16+ (Go版)** でランタイム管理している。
[mise](https://mise.jdx.dev/) は Rust 製の asdf 互換ランタイムマネージャで、以下のメリットがある:

- **高速**: Rust ネイティブ実装、起動・解決が速い
- **レジストリ機能**: `mise use python@3.12` だけで多くのツールを設定不要で導入 (個別 `plugin add` が不要)
- **`.tool-versions` 互換**: 既存ファイルをそのまま流用可能
- **タスクランナー / 環境変数管理**: `.mise.toml` で統合管理可能
- **shim 不要**: PATH を動的に書き換える方式 (`asdf reshim` が不要)
- 大手プロジェクト・Anthropic 公式の dev 環境記事でも推奨が増えている

## 移行で変更するファイル

| ファイル | 変更内容 |
|---|---|
| `etc/install.sh` | asdf バイナリ取得を `curl https://mise.run \| sh` に置換。`asdf plugin add` ループ全削除 (mise はレジストリで自動解決) |
| `.bashrc` | asdf PATH 設定 (`~/.asdf/bin:~/.asdf/shims`) を `eval "$(mise activate bash)"` に置換 |
| `etc/scripts/build_vim.sh` | `asdf current ruby \| awk 'NR==2{print $2}'` を `mise current ruby` 等に書き換え (出力フォーマットが異なる) |
| `etc/scripts/install_ai_tools.sh` | 末尾の `asdf reshim nodejs` を削除 (mise は shim 不使用) |
| `.tool-versions` | そのまま流用可能 (or `.mise.toml` への移行を検討) |

## 想定手順

1. `feat/mise-migration` ブランチを切る
2. 上記ファイルを mise 対応に書き換え
3. `dotfiles-test:latest` イメージを使って Docker で検証 (`etc/docker/Dockerfile` ベース)
4. 動作確認 (asdf 修正時と同じ検証パターン: install.sh 完走 → 各ツール動作確認)
5. ホストでも `~/.asdf` をバックアップした上で切り替え検証
6. 問題なければ master にマージ

## 検証ポイント

- `mise current` の出力フォーマット → `build_vim.sh` の awk 抽出が動くか
- 全11ランタイム (nodejs/python/lua/luajit/perl/golang/deno/bun/ruby/terraform/awscli) の自動解決
- vim ビルドの LuaJIT/Lua リンク
- AI tools (claude/gemini/codex) の PATH 解決
- `LUAJIT_PREFIX` / `LUA_PREFIX` を `.bashrc:217-218` で使っている箇所 (`asdf where luajit` → `mise where luajit` に書き換え必要)

## 残課題との関係

asdf 検証時に判明した以下の問題は mise でも要再検証:

- **luarocks 3.13.0 ビルド失敗** (lua プラグイン post-install hook)
- **terraform install callback exit 1** (gpg 鍵期限切れ)

これらは asdf でも実害なしだったが、mise プラグイン経由でも同様か確認する。

## ロールバック

- `git revert <commit>` で元に戻す
- `~/.local/share/mise` を削除
- `~/.asdf` を残しておけば即復帰可能

## 参考リンク

- https://mise.jdx.dev/
- https://mise.jdx.dev/migrate-from-asdf.html
- https://mise.jdx.dev/registry.html
