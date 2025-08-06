#!/bin/bash

set -e

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

# Determine whether we need to use sudo
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  echo "❌ This script must be run as root or with sudo installed." >&2
  exit 1
fi

# Install packages
echo "✅ Detected OS: $PRETTY_NAME"
echo "📦 Updating package lists..."
$SUDO apt update

echo "📦 Installing packages"
$SUDO apt install -y stow fzf git eza zoxide unzip curl


# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="$HOME/.dotfiles"

# Check if we need to move dotfiles to ~/.dotfiles
if [ "$DOTFILES_DIR" != "$TARGET_DIR" ]; then
  echo "📁 Current dotfiles location: $DOTFILES_DIR"
  echo "📁 Target location: $TARGET_DIR"
  
  if [ -d "$TARGET_DIR" ]; then
    echo "⚠️  Directory $TARGET_DIR already exists and will be replaced."
  fi
  
  read -p "📦 Move dotfiles to $TARGET_DIR? (Y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "⚠️  Continuing with current location: $DOTFILES_DIR"
  else
    if [ -d "$TARGET_DIR" ]; then
      echo "🗑️  Removing existing $TARGET_DIR..."
      rm -rf "$TARGET_DIR"
    fi
    echo "📦 Moving dotfiles to $TARGET_DIR..."
    cp -r "$DOTFILES_DIR" "$TARGET_DIR"
    echo "✅ Dotfiles moved to $TARGET_DIR"
    # Update the dotfiles directory path for the rest of the script
    DOTFILES_DIR="$TARGET_DIR"
  fi
fi


echo "🔗 Setting up dotfiles with stow..."
cd "$DOTFILES_DIR"
stow bash

echo "✅ All done!"
echo "📝 Your dotfiles have been installed. Please restart your shell or run 'source ~/.bashrc' to apply changes."
