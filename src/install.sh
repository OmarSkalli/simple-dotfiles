#!/bin/bash

set -e

# Check OS compatibility
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

# Determine whether we need to use sudo
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  echo "This script must be run as root or with sudo installed." >&2
  exit 1
fi

# Install packages
echo "Detected OS: $PRETTY_NAME"
echo "Updating package lists..."
$SUDO apt update

echo "Installing packages..."
$SUDO apt install -y stow fzf git zoxide unzip curl

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
TARGET_DIR="$HOME/.dotfiles"

# Check if we're running from a complete repo or just the standalone script
if [ ! -d "$SCRIPT_DIR/bash" ]; then
  echo "Downloading dotfiles repository..."
  # We're running standalone (via curl), need to clone the repo
  if [ -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR already exists and will be replaced."
    read -p "Continue? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
      echo "Installation cancelled."
      exit 1
    fi
    rm -rf "$TARGET_DIR"
  fi
  
  git clone https://github.com/OmarSkalli/simple-dotfiles.git "$TARGET_DIR"
  DOTFILES_DIR="$TARGET_DIR"
  echo "Repository cloned to $TARGET_DIR"
fi

# Check if we need to move dotfiles to ~/.dotfiles (only if not already cloned there)
if [ "$DOTFILES_DIR" != "$TARGET_DIR" ]; then
  echo "Current location: $DOTFILES_DIR"
  echo "Target location: $TARGET_DIR"
  
  if [ -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR already exists and will be replaced."
  fi
  
  read -p "Move dotfiles to $TARGET_DIR? (Y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Cannot continue without moving dotfiles to ~/.dotfiles"
    echo "Stow requires dotfiles to be in the home directory structure."
    exit 1
  else
    if [ -d "$TARGET_DIR" ]; then
      rm -rf "$TARGET_DIR"
    fi
    cp -r "$DOTFILES_DIR" "$TARGET_DIR"
    echo "Dotfiles moved to $TARGET_DIR"
    DOTFILES_DIR="$TARGET_DIR"
  fi
fi

# Setup dotfiles
echo "Setting up dotfiles..."
cd "$DOTFILES_DIR"
stow bash

echo "Installation complete."
echo "Restart your shell or run 'source ~/.bashrc' to apply changes."

# Source new config
source ~/.bashrc