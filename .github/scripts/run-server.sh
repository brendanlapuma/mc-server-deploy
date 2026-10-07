#!/usr/bin/env bash
set -euo pipefail

: "${MC_VM_HOST:?MC_VM_HOST is required}"
: "${MC_VM_USER:?MC_VM_USER is required}"
: "${MC_VM_PORT:?MC_VM_PORT is required}"
: "${MC_SERVER_DIR:?MC_SERVER_DIR is required}"
: "${MC_TMUX_SESSION:?MC_TMUX_SESSION is required}"
: "${MC_RAM:?MC_RAM is required}"
: "${MC_READY_PATTERN:?MC_READY_PATTERN is required}"
: "${MC_STARTUP_TIMEOUT:?MC_STARTUP_TIMEOUT is required}"

quote() {
  printf '%q' "$1"
}

remote_command="MC_SERVER_DIR=\"\$HOME/$(quote "$MC_SERVER_DIR")\""
remote_command+=" MC_TMUX_SESSION=$(quote "$MC_TMUX_SESSION")"
remote_command+=" MC_RAM=$(quote "$MC_RAM")"
remote_command+=" MC_READY_PATTERN=$(quote "$MC_READY_PATTERN")"
remote_command+=" MC_STARTUP_TIMEOUT=$(quote "$MC_STARTUP_TIMEOUT")"
remote_command+=" bash \"\$HOME/$(quote "$MC_SERVER_DIR")/.github/scripts/start-server-on-vm.sh\""

ssh -i "$HOME/.ssh/minecraft_deploy" -p "$MC_VM_PORT" \
  "$MC_VM_USER@$MC_VM_HOST" "$remote_command"
