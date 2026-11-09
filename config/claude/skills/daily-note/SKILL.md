---
name: daily-note
description: 今日やったことを ctx（ローカルのエージェント履歴）と各リポジトリの git log から集め、Obsidian ボルト memotty の daily note（04_daily/YYYY-MM-DD.md）をプロジェクト別に書く。「/daily-note」「daily note 作って」「デイリーノート」「今日やったことまとめて」「日報書いて」で使用。
argument-hint: [対象日 YYYY-MM-DD（省略時は今日）]
---

# Daily Note

memotty（Obsidian ボルト）の daily note を、その日のエージェント履歴から書く。

- ボルト: `~/github.com/motty93/memotty`
- ノート: `04_daily/YYYY-MM-DD.md`。Obsidian の Daily Notes プラグインが `00_templates/daily.md` から生成する。無ければテンプレートをコピーして作る
- テンプレート `00_templates/daily.md` は変更しない。テンプレートの「今日やること」は平らな `- [ ] ` だけなので、書くときにプロジェクト別の見出し（下のフォーマット）に置き換える
- 材料: ctx（Claude Code / Codex のセッション履歴。ctx のデーモンが自動で取り込む）と、各プロジェクトの `git log`
- `ctx` が無い・壊れているときは「ローカル履歴が使えない」と伝え、git log だけで書く。分からないことは埋めない

## ワークフロー

1. **日付**: 引数があればその日、無ければ `date '+%Y-%m-%d'`
2. **ノート**: `04_daily/<日付>.md` を読む。手書きの項目があれば残す。無ければ `00_templates/daily.md` をコピーして作る
3. **履歴の書き出し**: ボルト直下で `bash <このスキルのディレクトリ>/scripts/dump-sessions.sh <日付>` を実行する。その日に発言のあったセッションの一覧（開始・終了時刻、発言数、リポジトリ、subagent の委譲元）を表示し、その日の user / assistant の発言だけを `.claude/tmp/daily-note-<日付>/<id>.md` に書き出す。「警告:」が出たら報告に含める
4. **読む**: 一覧の順（開始時刻順）に `<id>.md` を読む。primary が本人の意図と結果、subagent は委譲の詳細（一覧の parent が委譲元）。このスキルを実行している自分のセッションは飛ばす。合計が大きい（目安 150KB 超）ときは、プロジェクトごとにサブエージェントへ要約を任せる
5. **裏取り**: ctx に出ていないリポジトリも含め、Polaris・huntershub・voxlab・memotty のすべてで `git log --all --author=motty93 --oneline --since='<日付> 00:00' --until='<日付> 23:59'` を見る。PR / Issue の状態は `gh` で確かめ、transcript と合わせる。git log にしか無い作業（手でマージした PR など）も拾う
6. **書く**: 下のフォーマットで書く
7. **報告**: 未確認のこと（終わっていないセッション、空のままの欄）を先に書き、「## あなたがやること」で加筆とコミットを渡す。コミットは頼まれるまでしない

## プロジェクトの判定

一覧の repo 列（セッションの作業ディレクトリ）で見出しを決める。

| repo 列 | 見出し |
|---|---|
| `androots/polaris` | Polaris |
| `motty93/huntershub` | huntershub |
| `retrolab-inc/voxlab` | voxlab |
| それ以外 | リポジトリ名（例: `motty93/memotty` → memotty） |

あるリポジトリで起動したセッションが、別のリポジトリの作業をすることがある（例: memotty で起動した Codex が Polaris の PR を直す）。その場合は作業した側のリポジトリの見出しに書く。

## ノートのフォーマット

```markdown
---
title:
createdAt: 2025-05-30 10:29
updatedAt: <書いた日時 YYYY-MM-DD HH:MM>
aliases:
draft:
tags:
  - daily
---

## 今日やること

### Polaris

- [x] <やったこと（Issue / PR 番号を添える）>
- [ ] <進行中のこと。末尾に状態（検証中・作成中など）>

### huntershub

- [ ] 

### voxlab

- [ ] 

## 今日やりたいこと

### 仕事

- [ ] <当日「やる」と言ったが手を付けていないこと>

### プライベート

- [ ] 

## メモ

- <次回の確認点、見つけた事実、判断の根拠>

## 振り返り

### 仕事

<時系列の散文。1 文ごとに末尾に `<br/>`>

### プライベート
```

書き方:

- **今日やること**: テンプレートの `- [ ] ` は消し、`### Polaris` などプロジェクト見出しの下に書く。1 項目 1 行、Issue / PR 番号を添える。完了は `[x]`、セッションが終わっていない・検証待ちのものは `[ ]` のまま末尾に状態を書く
- Polaris / huntershub / voxlab の見出しは活動が無くても残し `- [ ] ` を置く。他のプロジェクトに活動があれば見出しを足す
- **今日やりたいこと > 仕事**: その日に「やる」と言ったが終わっていないもの。今日やることと重複させない
- **メモ**: 翌日以降に効くことだけ。「明日 01:30 の実行結果を確認」「〜は v0.0.10 では直らない」など
- **振り返り > 仕事**: 何を決めて何が残ったかが分かる散文。事実だけ書き、感想や評価は書かない（本人が加筆する）
- **プライベート**: ctx に手がかりが無いので空のまま残す
- 数字（件数・日付範囲）は transcript の最終報告から取る。途中経過の数字を使わない
- transcript にトークン・パスワード・個人の連絡先が出てきても書き写さない

## ctx を直接叩くとき

スクリプトが使えないときの最小手順。ctx 1.x に `ctx sql` は無いので、一覧は `ctx list events`、中身は `ctx show session` で取る。`ctx search` は話題語が要るので、その日の網羅には向かない。

```bash
ctx index wait --lexical --timeout-seconds 600
S=$(date -d '<日付>' +%s)
ctx list events --since "$(date -u -d "@$S" +%FT%TZ)" --until "$(date -u -d "@$((S + 86400))" +%FT%TZ)" \
  --event-type message --content none --limit 200000 --format jsonl |
  jq -r 'select(.record_type == "event_range_event") | .event | [.ctx_session_id, .provider, .agent_scope, .occurred_at] | @tsv' |
  awk -F'\t' '!seen[$1]++'
ctx show session <ctx_session_id> --format markdown --out <一時ファイル>
```

デーモンが索引を差し替えている最中は `the lexical generation changed while a verified reader was opening` で失敗するので、`ctx index wait` からやり直す。索引の状態は `ctx doctor` と `ctx daemon status` で見る。Claude Code がセッションを分岐すると、`~/.claude/projects` 配下にサブエージェント履歴の symlink ができる。symlink は取り込まれず、`ctx doctor` に「refresh is partial」と出るが、ほかの履歴は取り込まれる。
