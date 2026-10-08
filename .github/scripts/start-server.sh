#!/usr/bin/env bash
set -euo pipefail

: "${MC_SERVER_DIR:?MC_SERVER_DIR is required}"
: "${MC_TMUX_SESSION:?MC_TMUX_SESSION is required}"
: "${MC_READY_PATTERN:?MC_READY_PATTERN is required}"

MC_STARTUP_TIMEOUT="${MC_STARTUP_TIMEOUT:-300}"
LOG_FILE="$MC_SERVER_DIR/server.log"
JVM_ARGS_FILE="$MC_SERVER_DIR/user_jvm_args.txt"

cd "$MC_SERVER_DIR"

if [[ ! -f run.sh || ! -f "$JVM_ARGS_FILE" ]]; then
  echo "run.sh and user_jvm_args.txt are required in $MC_SERVER_DIR" >&2
  exit 1
fi

if [[ -z "${MC_RAM:-}" ]]; then
  MC_RAM="$(awk '/^[[:space:]]*-Xmx/ { value=$1 } END { sub(/^-Xmx/, "", value); print value }' "$JVM_ARGS_FILE")"
  if [[ -z "$MC_RAM" ]]; then
    echo "MC_RAM is required when user_jvm_args.txt has no active -Xmx value" >&2
    exit 1
  fi
fi

temporary_args_file="$(mktemp)"
awk '!/^[[:space:]]*-Xmx/' "$JVM_ARGS_FILE" > "$temporary_args_file"
printf '%s\n' "-Xmx${MC_RAM}" >> "$temporary_args_file"
mv "$temporary_args_file" "$JVM_ARGS_FILE"

touch "$LOG_FILE"
LOG_START_LINE=$(( $(wc -l < "$LOG_FILE") + 1 ))

echo "Starting Minecraft server"
tmux new-session -d -s "$MC_TMUX_SESSION" \
  "cd $(printf '%q' "$MC_SERVER_DIR") && exec bash ./run.sh nogui 2>&1 | tee -a $(printf '%q' "$LOG_FILE")"

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
