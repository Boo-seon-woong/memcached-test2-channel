#!/usr/bin/env bash
# Lightweight commit monitor for memcached-test2-channel.
#
# It detects origin/main changes from the other side and records a pending wake
# under state/. It does not run Claude or execute experiment commands by default.
#
# Usage:
#   SELF=ariel ./tools/commit-monitor.sh
#   SELF=genie POLL_SECONDS=10 ./tools/commit-monitor.sh
#
# Optional:
#   HOOK=/path/to/script SELF=ariel ./tools/commit-monitor.sh
# The hook is called as: HOOK <old_head> <new_head> <summary_file>
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
STATE=${STATE:-"$ROOT/state/monitor"}
SELF=${SELF:?set SELF=ariel|genie}
POLL_SECONDS=${POLL_SECONDS:-15}
REMOTE_REF=${REMOTE_REF:-origin/main}
HOOK=${HOOK:-}

mkdir -p "$STATE"

log() {
  printf '[%s] %s\n' "$(date -u '+%F %T UTC')" "$*" | tee -a "$STATE/monitor.log" >&2
}

remote_exists() {
  git -C "$ROOT" remote get-url origin >/dev/null 2>&1
}

read_head() {
  cat "$STATE/handled_head" 2>/dev/null || true
}

write_head() {
  printf '%s\n' "$1" > "$STATE/handled_head"
}

summarize_range() {
  local old=$1 new=$2 out=$3
  {
    printf 'range=%s..%s\n' "$old" "$new"
    git -C "$ROOT" log --reverse --format='%h %s' "$old..$new"
  } > "$out"
}

is_self_only_range() {
  local old=$1 new=$2
  local subjects
  subjects=$(git -C "$ROOT" log --format='%s' "$old..$new" 2>/dev/null || true)
  [ -n "$subjects" ] && ! printf '%s\n' "$subjects" | grep -qv "^\[$SELF\]"
}

handle_change() {
  local old=$1 new=$2 summary="$STATE/pending_summary.txt"
  summarize_range "$old" "$new" "$summary"

  if is_self_only_range "$old" "$new"; then
    write_head "$new"
    rm -f "$STATE/pending_wake"
    log "self-only range handled: $old..$new"
    return
  fi

  printf '%s\n' "$new" > "$STATE/pending_wake"
  date -u '+%F %T UTC' > "$STATE/pending_since"
  log "new remote work detected: $old..$new"
  cat "$summary" >&2

  if [ -n "$HOOK" ]; then
    "$HOOK" "$old" "$new" "$summary" >> "$STATE/hook.log" 2>&1 || log "hook failed: $HOOK"
  fi
}

log "monitor start SELF=$SELF ROOT=$ROOT POLL_SECONDS=$POLL_SECONDS"

while true; do
  if ! remote_exists; then
    log "no origin remote yet; waiting"
    sleep "$POLL_SECONDS"
    continue
  fi

  if git -C "$ROOT" fetch -q origin; then
    date -u '+%F %T UTC' > "$STATE/last_fetch"
    tip=$(git -C "$ROOT" rev-parse "$REMOTE_REF" 2>/dev/null || true)
    if [ -z "$tip" ]; then
      log "cannot resolve $REMOTE_REF"
      sleep "$POLL_SECONDS"
      continue
    fi

    handled=$(read_head)
    if [ -z "$handled" ]; then
      write_head "$tip"
      log "initialized handled_head=$tip"
    elif [ "$handled" != "$tip" ]; then
      if git -C "$ROOT" merge-base --is-ancestor "$handled" "$tip" 2>/dev/null; then
        handle_change "$handled" "$tip"
      else
        log "handled_head is not ancestor of $REMOTE_REF; resetting handled_head=$tip"
        write_head "$tip"
      fi
    fi
  else
    log "fetch failed"
  fi

  sleep "$POLL_SECONDS"
done
