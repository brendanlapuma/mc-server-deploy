#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="${1:-/srv/minecraft}"

if [[ "$(id -u)" -eq 0 ]]; then
  OWNER="${SUDO_USER:-root}"
else
  OWNER="$(id -un)"
fi

if ! command -v java >/dev/null 2>&1; then
  echo "java is required; install the Java version compatible with your Minecraft server" >&2
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required; install it with: sudo apt-get install -y tmux" >&2
  exit 1
fi

if ! command -v timeout >/dev/null 2>&1; then
  echo "timeout is required; install it with: sudo apt-get install -y coreutils" >&2
  exit 1
fi

mkdir -p "$SERVER_DIR"
chown "$OWNER" "$SERVER_DIR"
chmod 755 "$SERVER_DIR"

echo "Minecraft server directory ready: $SERVER_DIR"
echo "Server owner: $OWNER"
