#!/bin/bash

set -e

echo "Updating package lists..."
sudo apt update

echo "Installing apt packages..."
sudo apt install -y \
  stow \
  fzf \
  git \
  eza \
  zoxide \
  unzip \
  curl \
  neovim

echo "✅ All done!"
