# Add `~/bin` and `~/.local/bin` to the `$PATH`
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

for file in ~/.dotfiles/bash_includes/*; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file
