# Dotfiles Setup Guide

Step-by-step instructions for bootstrapping this dotfiles repo on a fresh machine. Assumes WSL2 on Ubuntu (or a native Ubuntu/Debian system). For macOS, most steps translate — skip the WSL-specific notes and use `brew` where `apt` is called out.

## Table of Contents

1. [Base System Packages](#1-base-system-packages)
2. [Homebrew (linuxbrew)](#2-homebrew-linuxbrew)
3. [Nerd Font](#3-nerd-font)
4. [Core CLI Tools](#4-core-cli-tools)
5. [Zsh as Default Shell](#5-zsh-as-default-shell)
6. [Tmux Plugin Manager (TPM)](#6-tmux-plugin-manager-tpm)
7. [Neovim External Requirements](#7-neovim-external-requirements)
8. [Node.js via NVM + pnpm](#8-nodejs-via-nvm--pnpm)
9. [Claude Code](#9-claude-code)
10. [Python](#10-python)
11. [PostgreSQL 18](#11-postgresql-18)
12. [Docker (WSL)](#12-docker-wsl)
13. [SSH Keys](#13-ssh-keys)
14. [Link the Dotfiles](#14-link-the-dotfiles)
15. [Verification](#15-verification)
16. [Recommended Order of Operations](#recommended-order-of-operations)
17. [Known Gotchas](#known-gotchas)

---

## 1. Base System Packages

Start with the build tools and basic utilities everything else depends on:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget git unzip zip \
  stow bc xclip software-properties-common ca-certificates
```

- `stow` is used for symlinking the dotfiles repo (optional if the bootstrap script handles it).
- `xclip` bridges tmux's `set-clipboard on` and Neovim's `unnamedplus` clipboard to the Windows clipboard via WSL.
- `bc` is required by `.tmux.conf` for its version comparison logic.

## 2. Homebrew (linuxbrew)

The `.zshrc` sources `brew shellenv`, so Homebrew is the primary package manager for most CLI tools:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

> **Do not install Python via Homebrew on WSL.** It causes a compiler/linuxbrew Python mismatch that breaks tools like `pipx`. Keep Python on `apt` or `pyenv`.

## 3. Nerd Font

The Neovim config sets `vim.g.have_nerd_font = true`, and tmux / powerlevel10k expect the glyphs. On WSL, install the font **on Windows**, not Linux — the terminal emulator (Windows Terminal, WezTerm, Ghostty, etc.) is what renders text.

Download a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/) and install it in Windows, then set it as the terminal font. Recommended:

- **MesloLGS NF** — powerlevel10k's recommended font
- **JetBrainsMono Nerd Font** — popular alternative

If the bootstrap script handles font installation, that path is fine too.

## 4. Core CLI Tools

Install the tools referenced directly in the configs:

```bash
brew install ripgrep fd fzf tree-sitter gcc make \
  lazygit lazydocker tmux neovim zsh stow
```

| Tool | Purpose |
| --- | --- |
| `ripgrep`, `fd`, `fzf`, `tree-sitter` | Required by kickstart.nvim and Telescope |
| `lazygit`, `lazydocker` | Powers the `lg` and `lzd` aliases |
| `tmux`, `neovim`, `zsh` | Latest versions (apt's are often stale) |
| `stow` | Optional — symlink management |

The `.zshrc` already includes `source <(fzf --zsh)`, which is the modern shell-integration method, so there's no need to run fzf's legacy `install` script.

## 5. Zsh as Default Shell

```bash
chsh -s $(which zsh)
```

Log out and back in, or restart WSL from PowerShell:

```powershell
wsl --shutdown
```

> **Do NOT run `zsh` and choose an option from the new-user wizard before symlinking the dotfiles.** The wizard will overwrite `.zshrc`. Exit immediately with `q` if it appears.

Zinit bootstraps itself on first shell launch thanks to the clone-if-missing block in `.zshrc`. No manual install needed for zinit, powerlevel10k, the three big plugins (`zsh-syntax-highlighting`, `zsh-completions`, `zsh-autosuggestions`), or `fzf-tab`.

A `~/.p10k.zsh` file is required — either copy the one from the dotfiles repo, or run `p10k configure` once on first launch.

## 6. Tmux Plugin Manager (TPM)

The `.tmux.conf` ends with `run '~/.tmux/plugins/tpm/tpm'` but TPM itself is not auto-installed:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

After symlinking `.tmux.conf`, launch tmux and press `prefix + I` (i.e., `Ctrl-a` then `Shift-i` with the remapped prefix) to install the plugins:

- tmux-resurrect
- tmux-continuum
- tmux-battery
- tmux-cpu
- tmux-yank

## 7. Neovim External Requirements

Neovim is installed in Step 4. Kickstart needs `gcc`, `make`, `unzip`, `ripgrep`, `fd`, and `tree-sitter` at runtime — all covered by Homebrew above.

Verify the version:

```bash
nvim --version   # must be 0.11+ for the init.lua version check
```

If below 0.11:

```bash
brew upgrade neovim
```

**First launch:** run `nvim` and wait. In order:

1. lazy.nvim clones itself
2. All ~35 plugins install from `lazy-lock.json`
3. Mason installs `stylua` and `lua_ls`
4. Treesitter compiles parsers

Watch for red errors. Afterwards, run `:checkhealth` to catch anything missing.

## 8. Node.js via NVM + pnpm

The shell lazy-loads NVM (see the `__init_nvm` function in `.zshrc`), but `NVM_DIR` must exist first:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

Restart the shell, then:

```bash
nvm install --lts
nvm use --lts
npm install -g pnpm
```

## 9. Claude Code

The `cc="claude"` alias points to Claude Code, which installs via npm:

```bash
npm install -g @anthropic-ai/claude-code
```

Run `claude` once to complete auth.

## 10. Python

Use system Python + pip (avoid the linuxbrew Python trap):

```bash
sudo apt install -y python3 python3-pip python3-venv
```

The `.zshrc` has a commented-out pyenv section. To enable pyenv:

```bash
curl https://pyenv.run | bash
```

Then uncomment the pyenv block in `.zshrc`.

## 11. PostgreSQL 18

The `PATH` explicitly adds `/usr/lib/postgresql/18/bin`, so install PG 18 via the official PGDG repo:

```bash
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install -y postgresql-18 postgresql-client-18
```

If only the client is needed (e.g., connecting to a remote DB), install `postgresql-client-18` alone.

## 12. Docker (WSL)

The `.zshrc` sets `DOCKER_HOST=unix:///var/run/docker.sock`, which is the Docker Desktop + WSL2 integration path:

1. Install Docker Desktop on Windows
2. Open Settings → Resources → WSL Integration and enable the distro

For native Docker inside WSL instead, follow Docker's Ubuntu install guide and add the user to the `docker` group.

## 13. SSH Keys

The `ssh-agent` OMZ plugin loads these identities:

```
DO_WheelerDesktop
WheelerDesktop@GordonPalmer
devops
id_ed25519
id_rsa
known_hosts
wheeler_linux_wbknight1_id_ed25519
```

Either restore them from backup into `~/.ssh/` (with `chmod 600` on private keys, `chmod 644` on `.pub` files), or trim the `zstyle ':omz:plugins:ssh-agent' identities` line to keys that actually exist. Missing keys cause a complaint on every shell start.

## 14. Link the Dotfiles

```bash
git clone https://github.com/WKnight19/dotfiles-v2 ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

**Manual symlinking (if not using the bootstrap script):**

```bash
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/nvim/.config/nvim ~/.config/nvim
chmod +x ~/dotfiles/tmux/*.sh
```

The `tmux-sessionizer.sh`, `tmux-worktreeizer.sh`, `is-vim.sh`, and `session-fzf.sh` scripts all need to be executable.

## 15. Verification

Run each of these and confirm no errors:

```bash
zsh --version        # 5.9+
nvim --version       # 0.11+
tmux -V              # 3.3+
git --version
brew --version
fzf --version
rg --version
fd --version
node --version
pnpm --version
```

Then:

- Launch `nvim` → `:checkhealth` → `:Lazy` → `:Mason`
- Launch `tmux new -s test` → `prefix + I` for TPM plugin install

---

## Recommended Order of Operations

For a fresh machine, follow this order:

1. apt packages (Step 1)
2. Homebrew (Step 2)
3. brew-installed CLI tools (Step 4)
4. Nerd Font on Windows side (Step 3)
5. Change shell to zsh (Step 5) — do **not** launch zsh yet
6. Clone dotfiles repo (Step 14)
7. Symlink configs
8. Restart shell → zinit auto-bootstraps plugins
9. TPM clone (Step 6) + `prefix + I` inside tmux
10. NVM → Node → pnpm (Step 8)
11. Claude Code (Step 9)
12. Python / PostgreSQL / Docker as needed (Steps 10–12)
13. SSH keys restored (Step 13)
14. First `nvim` launch → let lazy.nvim finish installing

---

## Known Gotchas

- **Do not install Python via Homebrew on WSL.** Compiler mismatch breaks `pipx` and friends.
- **Do not launch `zsh` before symlinking `.zshrc`.** The new-user wizard will create a config that overrides or conflicts with the dotfiles version.
- **fzf double-install.** If fzf gets installed via both Homebrew and the old `~/.fzf.zsh` installer, duplicate key bindings cause weirdness. Stick with brew-only plus `source <(fzf --zsh)`.
- **Nerd Font confusion on WSL.** The font has to be installed on the Windows side; installing it inside Linux does nothing visible.
- **Neovim 0.11 floor.** The `init.lua` has a version check. Older neovim installs (like apt's default) will fail.
- **Missing SSH keys.** The `ssh-agent` plugin references specific identity files — trim the list if not all are present, otherwise every new shell prints errors.
