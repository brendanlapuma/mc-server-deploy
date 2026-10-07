#!/usr/bin/env bash
set -euo pipefail

: "${MC_VM_HOST:?MC_VM_HOST is required}"
: "${MC_VM_USER:?MC_VM_USER is required}"
: "${MC_VM_PORT:?MC_VM_PORT is required}"
: "${MC_SERVER_DIR:?MC_SERVER_DIR is required}"
: "${MC_TMUX_SESSION:?MC_TMUX_SESSION is required}"
: "${MC_SHUTDOWN_TIMEOUT:?MC_SHUTDOWN_TIMEOUT is required}"

quote() {
  printf '%q' "$1"
}

remote_command="MC_TMUX_SESSION=$(quote "$MC_TMUX_SESSION")"
remote_command+=" MC_SHUTDOWN_TIMEOUT=$(quote "$MC_SHUTDOWN_TIMEOUT")"
remote_command+=" bash \"\$HOME/$(quote "$MC_SERVER_DIR")/.github/scripts/stop-server-on-vm.sh\""

ssh -i "$HOME/.ssh/minecraft_deploy" -p "$MC_VM_PORT" \
  "$MC_VM_USER@$MC_VM_HOST" "$remote_command"
