#!/bin/bash

set -e

# Determine whether we need to use sudo
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  echo "❌ This script must be run as root or with sudo installed." >&2
  exit 1
fi

# Check OS compatibility
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
    echo "❌ Unsupported distro: $ID"
    echo "This script only supports Debian and Ubuntu."
    exit 1
  fi
else
  echo "❌ Cannot detect OS. /etc/os-release not found."
  exit 1
fi

echo "✅ Detected OS: $PRETTY_NAME"
echo "📦 Updating package lists..."
$SUDO apt update

echo "📦 Installing packages"
$SUDO apt install -y stow fzf git eza zoxide unzip curl

echo "✅ All done!"
