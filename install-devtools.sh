#!/bin/bash

set -eo pipefail

# Optional developer CLI tools: GitHub CLI (gh) and Claude Code (claude).
# gh is installed from a third-party apt repository; Claude Code is
# installed via its native installer into ~/.local/bin (apt packages
# tend to lag behind upstream releases). Only run this on workstations
# where you want those tools, not on bare servers.

if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
    echo "Unsupported distro: $ID"
    echo "This script only supports Debian and Ubuntu."
    exit 1
  fi
else
  echo "Cannot detect OS. /etc/os-release not found."
  exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  echo "This script must be run as root or with sudo installed." >&2
  exit 1
fi

echo "Detected OS: $PRETTY_NAME"

if ! command -v curl >/dev/null 2>&1 || ! dpkg -s ca-certificates >/dev/null 2>&1; then
  $SUDO apt-get update
  $SUDO apt-get install -y curl ca-certificates
fi
$SUDO install -d -m 0755 /etc/apt/keyrings

echo "Adding GitHub CLI apt repository..."
$SUDO curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  -o /etc/apt/keyrings/githubcli-archive-keyring.gpg
$SUDO chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null

echo "Installing gh..."
$SUDO apt-get update
$SUDO apt-get install -y gh

echo "Installing Claude Code via native installer..."
curl -fsSL https://claude.ai/install.sh | bash

echo "Devtools installation complete."
echo "Run 'gh auth login' and 'claude' to get started."
echo "(If 'claude' is not found, ensure ~/.local/bin is on your PATH.)"
