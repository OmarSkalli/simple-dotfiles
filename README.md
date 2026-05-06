# Server dotfiles

Minimal dotfile for use in a server environment.

To install:

```bash
curl -fsSL https://raw.githubusercontent.com/OmarSkalli/simple-dotfiles/main/install.sh | bash
```

## Optional: developer CLI tools

On workstations where you want the GitHub CLI (`gh`) and Claude Code (`claude`),
also run:

```bash
curl -fsSL https://raw.githubusercontent.com/OmarSkalli/simple-dotfiles/main/install-devtools.sh | bash
```

This adds third-party apt repositories for both tools. Skip on bare servers.
