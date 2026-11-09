#!/bin/bash
# 指定日（ローカル時刻）に発言のあった ctx セッションを列挙し、その日の user / assistant の発言だけを transcript に書き出す
# usage: dump-sessions.sh [YYYY-MM-DD] [出力ディレクトリ]
set -euo pipefail

DATE="${1:-$(date '+%Y-%m-%d')}"
OUT="${2:-.claude/tmp/daily-note-${DATE}}"
WORK="$OUT/.work"
LAG_LIMIT_MIN=30
MAX_CHARS=12000
# 丸ごと落とす発言（注入されたスキル本文、サブエージェントの返却、Codex の環境情報など）
NOISE='Base directory for this skill|<task-notification>|<agent-message |Another Claude session sent a message|# AGENTS\.md instructions for|<environment_context>|<INSTRUCTIONS>|<local-command-stdout>|<turn_aborted>|"content_preview":'
# 記録に残さないスラッシュコマンド
SKIP_COMMANDS='^/?(clear|compact|exit|model|status|context|cost|login|resume)$'

command -v ctx >/dev/null || { echo "ctx が見つからない（curl -fsSL https://ctx.rs/install | sh で入る）" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq が見つからない" >&2; exit 1; }

START="$(date -d "${DATE} 00:00:00" +%s)"
SINCE="$(date -u -d "@${START}" +%Y-%m-%dT%H:%M:%SZ)"
UNTIL="$(date -u -d "@$((START + 86400))" +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT
find "$OUT" -maxdepth 1 -type f -regextype posix-extended \
  -regex '.*/([0-9a-f]{8}(\.filtered|\.day)?\.md|sessions\.tsv)' -delete

# ctx list events を完了レコードまで読み切る。デーモンの世代切り替えと重なると失敗するので、索引の準備を待ってやり直す
list_events() {
  local out="$1" allow_truncated="$2"
  shift 2
  for _ in 1 2 3 4 5; do
    ctx index wait --lexical --timeout-seconds 600 --quiet >/dev/null 2>&1 || true
    if ctx list events "$@" --format jsonl >"$out" 2>"$WORK/list.err" &&
      tail -n 1 "$out" | jq -e --argjson truncated_ok "$allow_truncated" \
        '.record_type == "event_range_completion" and ($truncated_ok or (.truncated | not))' >/dev/null; then
      return 0
    fi
    sleep 2
  done
  echo "ctx list events が 5 回とも完了しない: $(tail -n 1 "$WORK/list.err")" >&2
  return 1
}

# セッションの作業ディレクトリ。Codex は message、Claude は tool_call に session_cwd が付く
session_cwd() {
  local event_type cwd
  for event_type in message tool_call; do
    list_events "$WORK/cwd.jsonl" true --session "$1" --event-type "$event_type" --content full --limit 200 || continue
    cwd="$(jq -r 'select(.record_type == "event_range_event") | .event.activity.facts[]? | select(.kind == "session_cwd") | .value' \
      "$WORK/cwd.jsonl" | sed -n 1p)"
    if [ -n "$cwd" ]; then
      echo "$cwd"
      return 0
    fi
  done
}

repo_of() {
  case "$1" in
    "") echo "-" ;;
    */github.com/*/*) sed -E 's@.*/github\.com/([^/]+)/([^/]+).*@\1/\2@' <<<"$1" ;;
    *) basename "$1" ;;
  esac
}

# 索引の遅れを確認する（最新の transcript ファイルと、索引の最新イベントの差）
newest_file="$(find ~/.claude/projects ~/.codex/sessions -type f -name '*.jsonl' -mmin -2880 -printf '%T@\n' 2>/dev/null |
  sort -n | tail -n 1 | cut -d. -f1 || true)"
if [ -n "$newest_file" ] &&
  list_events "$WORK/newest.jsonl" true --direction descending --content none --limit 1 \
    --since "$(date -u -d "@$((newest_file - 172800))" +%Y-%m-%dT%H:%M:%SZ)" \
    --until "$(date -u -d "@$((newest_file + 60))" +%Y-%m-%dT%H:%M:%SZ)"; then
  newest_event="$(jq -r 'select(.record_type == "event_range_event") | .event.occurred_at_ms / 1000 | floor' "$WORK/newest.jsonl")"
  lag_min=$(((newest_file - ${newest_event:-0}) / 60))
  if [ "$lag_min" -gt "$LAG_LIMIT_MIN" ]; then
    echo "警告: ctx の索引が最新の履歴より ${lag_min} 分遅れている（ctx daemon status で確認）" >&2
  fi
fi

list_events "$WORK/events.jsonl" false --since "$SINCE" --until "$UNTIL" \
  --event-type message --content text --limit 200000

# 発言を整形する。system-reminder などの注入部分は削り、スラッシュコマンドは 1 行にまとめる
jq -c --arg noise "$NOISE" --arg skip "$SKIP_COMMANDS" --argjson max "$MAX_CHARS" '
  def trim: gsub("\\A\\s+|\\s+\\z"; "");
  def tag($name): (capture("<\($name)>(?<v>[^<]*)</\($name)>") // {v: ""}).v | trim;
  def dash: if . == null or . == "" then "-" else . end;
  select(.record_type == "event_range_event") | .event
  | select(.role == "user" or .role == "assistant")
  | ((.text // "")
      | gsub("<system-reminder>[\\s\\S]*?</system-reminder>"; "")
      | gsub("<local-command-caveat>[\\s\\S]*?</local-command-caveat>"; "")
      | trim) as $raw
  | select($raw != "" and ($raw | test($noise) | not))
  | (if ($raw | test("<command-name>"))
     then ($raw | tag("command-name")) as $name
       | select($name | test($skip) | not)
       | "[slash command] " + ("\($name) \($raw | tag("command-args"))" | trim)
     else $raw end) as $text
  | {sid: .ctx_session_id, provider: (.provider | dash), scope: (.agent_scope | dash), fmt: (.source_format | dash),
     psid: (.provider_session_id | dash), parent: (.parent_ctx_session_id | dash),
     role, ms: .occurred_at_ms,
     text: (if ($text | length) > $max then ($text | .[0:$max]) + "\n…（以下略）" else $text end)}
' "$WORK/events.jsonl" >"$WORK/messages.jsonl"

# セッションごとに集計し、開始時刻順に並べる。Codex の入力履歴（history.jsonl）は本体のセッションがあれば省く
jq -s -r 'group_by(.sid)[]
  | [.[0].sid, .[0].provider, .[0].scope, .[0].fmt, .[0].psid, .[0].parent, (map(.ms) | min), (map(.ms) | max), length]
  | @tsv' "$WORK/messages.jsonl" |
  sort -t $'\t' -k7,7n |
  awk -F'\t' '
    { row[NR] = $0; fmt[NR] = $4; psid[NR] = $5; if ($4 == "codex_session_jsonl") has_session[$5] = 1 }
    END { for (i = 1; i <= NR; i++) if (!(fmt[i] == "codex_history_jsonl" && (psid[i] in has_session))) print row[i] }
  ' >"$WORK/sessions.tsv"

declare -A CWD=()
while IFS=$'\t' read -r sid _ _ fmt _ _ _ _ _; do
  if [ "$fmt" != codex_history_jsonl ]; then
    CWD[$sid]="$(session_cwd "$sid")" || true
  fi
done <"$WORK/sessions.tsv"

printf '%-8s  %-8s  %-8s  %-5s  %-5s  %4s  %s\n' id provider scope first last msgs repo
while IFS=$'\t' read -r sid provider scope _ psid parent first last count; do
  cwd="${CWD[$sid]:-}"
  if [ -z "$cwd" ] && [ "$parent" != - ]; then
    cwd="${CWD[$parent]:-}"
    if [ -z "$cwd" ]; then
      cwd="$(session_cwd "$parent")" || true
    fi
  fi
  short="${sid:0:8}"
  parent_short="${parent:0:8}"
  repo="$(repo_of "$cwd")"
  first_hm="$(date -d "@$((first / 1000))" +%H:%M)"
  last_hm="$(date -d "@$((last / 1000))" +%H:%M)"
  {
    printf '# %s %s %s\n\n' "$provider" "$scope" "$short"
    printf -- '- provider_session_id: %s\n- cwd: %s\n- parent: %s\n\n' "$psid" "${cwd:--}" "$parent_short"
    jq -r --arg sid "$sid" '
      select(.sid == $sid)
      | "## \(.role) \(.ms / 1000 | floor | strflocaltime("%Y-%m-%d %H:%M %Z"))\n\n\(.text)\n"' \
      "$WORK/messages.jsonl"
  } >"$OUT/$short.md"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$short" "$provider" "$scope" "$first_hm" "$last_hm" "$count" "$repo" "$parent_short" "${cwd:--}" >>"$OUT/sessions.tsv"
  if [ "$parent" != - ]; then
    repo="$repo (parent $parent_short)"
  fi
  printf '%-8s  %-8s  %-8s  %-5s  %-5s  %4s  %s\n' "$short" "$provider" "$scope" "$first_hm" "$last_hm" "$count" "$repo"
done <"$WORK/sessions.tsv"

if [ ! -s "$OUT/sessions.tsv" ]; then
  echo "警告: ${DATE} の発言が ctx に 1 件も無い。ctx doctor と各リポジトリの git log を確認する" >&2
fi
# デーモンの取り込み中に出る一時的な状態（pending、索引の差し替え中）は表示しない
ctx doctor --format json 2>/dev/null |
  jq -r 'select(.ok == false) | .findings[]? | (if type == "string" then . else tostring end)
    | select(test("pending|generation_verification_failed") | not) | "警告: ctx doctor: \(.)"' >&2 || true

echo
echo "transcripts: ${OUT}/<id>.md（その日の user / assistant の発言のみ）、一覧: ${OUT}/sessions.tsv"
