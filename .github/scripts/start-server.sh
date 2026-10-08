#!/usr/bin/env bash
set -euo pipefail

: "${MC_SERVER_DIR:?MC_SERVER_DIR is required}"
: "${MC_TMUX_SESSION:?MC_TMUX_SESSION is required}"
: "${MC_READY_PATTERN:?MC_READY_PATTERN is required}"

MC_STARTUP_TIMEOUT="${MC_STARTUP_TIMEOUT:-300}"
LOG_FILE="$MC_SERVER_DIR/server.log"
START_SCRIPT="$MC_SERVER_DIR/start.sh"

cd "$MC_SERVER_DIR"

if [[ ! -f "$START_SCRIPT" ]]; then
  echo "start.sh is required in $MC_SERVER_DIR" >&2
  exit 1
fi

if [[ -z "${MC_RAM:-}" ]]; then
  MC_RAM="$(sed -n 's/.*MC_RAM:-\([^}]*\).*/\1/p' "$START_SCRIPT" | head -n 1)"
  if [[ -z "$MC_RAM" ]]; then
    echo "MC_RAM is required when start.sh has no default RAM value" >&2
    exit 1
  fi
fi

touch "$LOG_FILE"
LOG_START_LINE=$(( $(wc -l < "$LOG_FILE") + 1 ))

echo "Starting Minecraft server"
tmux new-session -d -s "$MC_TMUX_SESSION" \
  "cd $(printf '%q' "$MC_SERVER_DIR") && MC_RAM=$(printf '%q' "$MC_RAM") exec bash ./start.sh 2>&1 | tee -a $(printf '%q' "$LOG_FILE")"

export MC_READY_PATTERN LOG_FILE LOG_START_LINE
if ! timeout "$MC_STARTUP_TIMEOUT" bash -c '
  while IFS= read -r line; do
    printf "%s\n" "$line"
    if [[ "$line" =~ $MC_READY_PATTERN ]]; then
      exit 0
    fi
  done < <(tail -n +"$LOG_START_LINE" -F "$LOG_FILE")
  exit 1
'; then
  echo "Server did not report readiness pattern within ${MC_STARTUP_TIMEOUT}s: $MC_READY_PATTERN" >&2
  exit 1
fi

echo "Minecraft server is ready and running in tmux session: $MC_TMUX_SESSION"
