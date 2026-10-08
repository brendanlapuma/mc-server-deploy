#!/usr/bin/env bash
set -euo pipefail

: "${MC_TMUX_SESSION:?MC_TMUX_SESSION is required}"

MC_SHUTDOWN_TIMEOUT="${MC_SHUTDOWN_TIMEOUT:-60}"

if ! tmux has-session -t "$MC_TMUX_SESSION" 2>/dev/null; then
  echo "Minecraft server is not running"
  exit 0
fi

echo "Requesting graceful server shutdown"
tmux send-keys -t "$MC_TMUX_SESSION" "stop" Enter
shutdown_deadline=$((SECONDS + MC_SHUTDOWN_TIMEOUT))

while tmux has-session -t "$MC_TMUX_SESSION" 2>/dev/null; do
  if (( SECONDS >= shutdown_deadline )); then
    echo "Graceful shutdown timed out; terminating tmux session" >&2
    tmux kill-session -t "$MC_TMUX_SESSION"
    exit 0
  fi
  sleep 1
done

echo "Minecraft server stopped"
