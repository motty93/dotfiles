---
name: create-issue
description: GitHub Issue を作成。担当者を設定し、Project に追加。「/create-issue」「イシューを作成」「新しいタスクを作りたい」「Issue を立てて」で使用。
---

# Create Issue

GitHub Issue を作成する。リポジトリ固有の規約（タイトル規約・Issue テンプレート・Project 名）があればそれを優先し、無ければこのスキルの既定に従う。

## ワークフロー

1. **スコープ確認**: `gh auth status` で project スコープの有無を確認
2. **リポジトリ規約の確認**: タイトル規約ガイド・Issue テンプレート・Project 名を確認
3. **情報収集**: タイトル、本文、担当者をユーザーに確認
4. **Issue 作成**: `gh issue create` で Issue を作成（スコープに応じて `--project` を付与）
5. **Issue Type 自動設定**: イシューの内容から Type を自動判定し、GraphQL API で設定
6. **Project ステータス設定**: ユーザーにステータスを選ばせ、GraphQL API で設定（project スコープがある場合のみ）
7. **完了メッセージ**: Issue URL と設定内容を表示

## スコープ確認

gh のトークンに `project` スコープがあるか確認する。

```bash
gh auth status 2>&1 | grep -q "'project'" && echo "HAS_PROJECT_SCOPE" || echo "NO_PROJECT_SCOPE"
```

- `HAS_PROJECT_SCOPE`: `--project` オプションを使用可能
- `NO_PROJECT_SCOPE`: `--project` オプションを使用しない（使用すると認証エラーになり、イシューは作成されるがリトライ時に重複する可能性がある）

## リポジトリ規約の確認

- **タイトル規約**: リポジトリの CLAUDE.md や `docs/` 配下に Issue・PR 運用ガイドがあればそれに従う。無ければ「何を」「なぜ」が一文で分かる具体的なタイトルにする（悪い例: 「〇〇の改善」「△△の修正」）
- **Issue テンプレート**: `.github/ISSUE_TEMPLATE/*.yml` があればそのセクション構造に沿って本文を生成する。無ければ「背景（Why）/ 何をしたいか（What）/ 完了条件 / 参考情報」の 4 セクションで書く
- **Project 名**: CLAUDE.md に記載があればそれを使う。無ければ次で一覧を取り、1 件ならそれを使い、複数ならユーザーに選ばせる

```bash
OWNER=$(gh repo view --json owner --jq '.owner.login')
gh project list --owner "$OWNER" --format json --jq '.projects[] | "\(.number) \(.title)"'
```

## 確認事項

Issue 作成前に以下を確認:
- **タイトル**: 上記の規約に従って生成し、ユーザーに確認
- **本文**: テンプレートのセクション構造に沿って生成する（背景の書式は「本文の書き方」を参照）
- **担当者**: デフォルトは `@me`、変更する場合はコラボレーター一覧から選択

## 本文の書き方

背景（Why）で経緯やマージ済み PR を列挙するときは、文章とリンクを混ぜない。日付を `####` 見出しにし、1 行 1 リンクの箇条書きで書く。

- リンクテキストは「超簡単な内容」、リンク先は PR または Issue の URL
- 現在の状態などの補足は、リストの後に短い箇条書きか表で分けて書く
- 完了条件や参考情報にも同じ「1 行 1 リンク」を適用する

```
#### 2026-09-01
- [テロップ音声を m4a / wav / aac / ogg にも対応](https://github.com/retrolab-inc/voxlab/pull/329)
- [パネルを開くたびのサインインをなくす](https://github.com/retrolab-inc/voxlab/pull/338)
```

## 担当者選択フロー

1. 担当者は `@me`（自分）でよいか確認
2. 変更する場合のみ、以下でコラボレーター一覧を取得して選択肢を提示:

```bash
gh api repos/:owner/:repo/collaborators --jq '.[].login'
```

## Issue 作成

スコープ確認の結果に応じてコマンドを使い分ける。本文は改行を含むため `--body-file` で渡す。

### project スコープがある場合

```bash
gh issue create \
  --title "タイトル" \
  --body-file 本文ファイル \
  --assignee "@me" \
  --project "<Project 名>"
```

### project スコープがない場合

```bash
gh issue create \
  --title "タイトル" \
  --body-file 本文ファイル \
  --assignee "@me"
```

**注意**: `--project` を省略した場合、Issue 作成後に GUI で Project に追加する必要がある。

## Issue Type 自動設定

Issue 作成後、イシューのタイトル・本文の内容から適切な Type を自動判定し、GraphQL API で設定する。リポジトリに Issue Type が無い（一覧が空の）場合はスキップする。

### 手順

1. リポジトリの Issue Type 一覧（name, description, id）を取得し、各 Type の description を判定基準としてイシューの内容に最も合う Type を選択する:

```bash
gh api graphql -f query='{
  repository(owner: "OWNER", name: "REPO") {
    issueTypes(first: 20) {
      nodes { id name description }
    }
  }
}'
```

2. Issue の Node ID を取得:

```bash
gh api graphql -f query='{
  repository(owner: "OWNER", name: "REPO") {
    issue(number: ISSUE_NUMBER) { id }
  }
}'
```

3. 判定した Type を設定:

```bash
gh api graphql -f query='mutation {
  updateIssue(input: {
    id: "ISSUE_NODE_ID",
    issueTypeId: "ISSUE_TYPE_ID"
  }) {
    issue { number issueType { name } }
  }
}'
```

## Project ステータス設定

project スコープがある場合のみ実行する。Issue 作成時に `--project` で追加された Project Item のステータスをユーザーが選択した値に設定する。

### ステータス選択

Status の選択肢は Project ごとに異なるため、下記手順 2 で実際のオプション一覧を取得してから提示する。よくある構成（`Backlog` / `Ready` / `In progress` / `In review` / `Done`）では、Issue 作成時に選ぶのは通常次の 3 つ:

- **Backlog**: いつかやる。すぐには着手しない場合
- **Ready**: 着手できる状態。近いうちに取り掛かる場合
- **In progress**: 今からこのイシューに取り掛かる場合

### 手順

1. Issue の Project Item ID と Project ID を取得:

```bash
gh api graphql -f query='{
  repository(owner: "OWNER", name: "REPO") {
    issue(number: ISSUE_NUMBER) {
      projectItems(first: 5) {
        nodes {
          id
          project { id }
        }
      }
    }
  }
}'
```

2. Status フィールドの ID と各 Option ID を取得:

```bash
gh api graphql -f query='{
  node(id: "PROJECT_ID") {
    ... on ProjectV2 {
      field(name: "Status") {
        ... on ProjectV2SingleSelectField {
          id
          options { id name }
        }
      }
    }
  }
}'
```

3. ステータスをユーザーが選択した値に設定:

```bash
gh api graphql -f query='mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PROJECT_ID",
    itemId: "PROJECT_ITEM_ID",
    fieldId: "STATUS_FIELD_ID",
    value: { singleSelectOptionId: "SELECTED_OPTION_ID" }
  }) {
    projectV2Item { id }
  }
}'
```

## 完了メッセージ

### project スコープがある場合

```
Issue を作成しました: <Issue URL>
- Type: <自動判定した Type>
- Project ステータス: <選択したステータス>
```

### project スコープがない場合

```
Issue を作成しました: <Issue URL>
- Type: <自動判定した Type>

⚠️ Project への追加とステータス設定は、トークンに project スコープがないためスキップしました。
GUI から手動で設定するか、`gh auth refresh -s project` を実行してスコープを追加してください。
```
