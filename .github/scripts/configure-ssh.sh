#!/usr/bin/env bash
set -euo pipefail

: "${MC_VM_HOST:?MC_VM_HOST is required}"
: "${MC_VM_USER:?MC_VM_USER is required}"
: "${MC_VM_SSH_KEY:?MC_VM_SSH_KEY is required}"
: "${MC_VM_PORT:?MC_VM_PORT is required}"

SSH_DIR="$HOME/.ssh"
SSH_KEY_FILE="$SSH_DIR/minecraft_deploy"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
printf '%s\n' "$MC_VM_SSH_KEY" > "$SSH_KEY_FILE"
chmod 600 "$SSH_KEY_FILE"
ssh-keyscan -p "$MC_VM_PORT" "$MC_VM_HOST" >> "$SSH_DIR/known_hosts"

if [[ -n "${GITHUB_ENV:-}" ]]; then
  {
    echo "MC_VM_HOST=$MC_VM_HOST"
    echo "MC_VM_USER=$MC_VM_USER"
  } >> "$GITHUB_ENV"
fi
