#!/usr/bin/env bash
# =============================================================================
#  One-click macOS terminal setup (personal machine, no proxy)
#  Ghostty + zsh/powerlevel10k + Neovim (LazyVim) + zellij/tmux + XPipe
#  + modern CLI tools (eza, bat, zoxide, atuin, yazi, ...) via Homebrew
#
#  Author : DucLong06 <https://github.com/DucLong06>
#  Source : https://github.com/DucLong06/iTerm2  (mac/ directory)
#
#  Usage  : ./install.sh [--skip-brew] [--only STEP[,STEP]] [--list-steps]
#
#  Mirrors linux/install.sh: shared configs (p10k, nvim, zellij, tmux) are read
#  from ../linux, the Mac-specific ones (zshrc, Ghostty) from this directory.
#  Idempotent: run it again any time. Existing files are backed up as <file>.bak-<date>.
# =============================================================================
set -euo pipefail

# ----------------------------------------------------------------------------- paths
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../mac
SHARED="$(cd "$DOTFILES/../linux" && pwd)"                  # configs shared with Linux
LOCAL_BIN="$HOME/.local/bin"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$LOCAL_BIN"

BLESH_VER="v0.3.4"

# ----------------------------------------------------------------------------- ui helpers
C_BLUE='\033[1;34m'; C_GREEN='\033[1;32m'; C_YELLOW='\033[1;33m'; C_RED='\033[1;31m'; C_DIM='\033[2m'; C_OFF='\033[0m'
step()  { printf "\n${C_BLUE}==> %s${C_OFF}\n" "$*"; }
ok()    { printf "${C_GREEN}  ✔ %s${C_OFF}\n" "$*"; }
info()  { printf "${C_DIM}  · %s${C_OFF}\n" "$*"; }
warn()  { printf "${C_YELLOW}  ! %s${C_OFF}\n" "$*"; }
die()   { printf "${C_RED}  ✖ %s${C_OFF}\n" "$*" >&2; exit 1; }
have()  { command -v "$1" >/dev/null 2>&1; }

backup() {  # backup <path>: keep a copy before overwriting a user file
  [[ -e "$1" && ! -L "$1" ]] || return 0
  cp -a "$1" "$1.bak-$STAMP"; info "backup: $1.bak-$STAMP"
}
install_file() {  # install_file <src> <dst> [mode]: copy with backup, expand the /home/USER placeholder
  local src="$1" dst="$2" mode="${3:-644}"
  mkdir -p "$(dirname "$dst")"
  if [[ -f "$dst" ]] && cmp -s <(sed "s|/home/USER|$HOME|g" "$src") "$dst"; then
    info "unchanged: $dst"; return 0
  fi
  backup "$dst"
  sed "s|/home/USER|$HOME|g" "$src" > "$dst"; chmod "$mode" "$dst"; ok "installed $dst"
}
fetch() { curl -fsSL --retry 3 --retry-delay 3 -o "$2" "$1"; }
git_clone_or_pull() {  # git_clone_or_pull <repo-url> <dir>
  if [[ -d "$2/.git" ]]; then git -C "$2" pull -q --ff-only >/dev/null 2>&1 || warn "could not update $2"; info "updated $2"
  else git clone -q --depth 1 "$1" "$2"; ok "cloned $2"; fi
}

# ----------------------------------------------------------------------------- args
SKIP_BREW=0; ONLY=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-brew)  SKIP_BREW=1 ;;
    --only)       ONLY="$2"; shift ;;
    --list-steps) printf '%s\n' brew zsh node tools configs gssh summary; exit 0 ;;
    -h|--help)    sed -n '2,15p' "$0"; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac; shift
done
want() { [[ -z "$ONLY" ]] || [[ ",$ONLY," == *",$1,"* ]]; }

[[ "$(uname -s)" == "Darwin" ]] || die "This script is for macOS. For Ubuntu use ../linux/install.sh."

# ============================================================================= 1. Homebrew packages
if want brew && [[ $SKIP_BREW -eq 0 ]]; then
step "Homebrew packages"
if ! have brew; then
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [[ -x "$b" ]] && eval "$("$b" shellenv)" && break; done
fi
if ! have brew; then
  info "installing Homebrew (asks for your password once)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [[ -x "$b" ]] && eval "$("$b" shellenv)" && break; done
fi
have brew || die "Homebrew not found after install"
# XPipe (SSH/connection manager, syncs through a git repo) ships from its own tap; its .pkg asks for your password
brew tap xpipe-io/tap >/dev/null
brew trust xpipe-io/tap >/dev/null 2>&1 || true   # newer Homebrew refuses untrusted third-party taps
brew bundle --file=- <<'EOF'
cask "ghostty"
cask "xpipe-io/tap/xpipe"
cask "font-jetbrains-mono-nerd-font"
cask "font-maple-mono-nf"
brew "git"
brew "zsh"
brew "tmux"
brew "fzf"
brew "ripgrep"
brew "jq"
brew "neovim"
brew "zellij"
brew "lazygit"
brew "fd"
brew "eza"
brew "bat"
brew "zoxide"
brew "fastfetch"
brew "git-delta"
brew "yazi"
brew "tealdeer"
brew "atuin"
brew "glow"
brew "lazydocker"
brew "uv"
brew "go"
EOF
ok "brew packages installed"
fi
have brew && eval "$(brew shellenv)"

# ============================================================================= 2. zsh + oh-my-zsh + powerlevel10k
if want zsh; then
step "oh-my-zsh, powerlevel10k, plugins"
ZSH_DIR="$HOME/.oh-my-zsh"; ZSH_CUSTOM="$ZSH_DIR/custom"
if [[ ! -d "$ZSH_DIR" ]]; then
  tmp="$(mktemp)"; fetch https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh "$tmp"; RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "$tmp" >/dev/null 2>&1; rm -f "$tmp"; ok "oh-my-zsh installed"
else info "oh-my-zsh present"; fi
git_clone_or_pull https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
git_clone_or_pull https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git_clone_or_pull https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
git_clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git_clone_or_pull https://github.com/MichaelAquilina/zsh-you-should-use "$ZSH_CUSTOM/plugins/you-should-use"
git_clone_or_pull https://github.com/fdellwing/zsh-bat "$ZSH_CUSTOM/plugins/zsh-bat"
# tmux plugin manager + tmux-power theme
git_clone_or_pull https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
git_clone_or_pull https://github.com/wfxr/tmux-power "$HOME/tmux-power"
fi

# ============================================================================= 3. Node (nvm)
if want node; then
step "Runtimes: nvm + Node LTS (uv and Go come from Homebrew)"
export NVM_DIR="$HOME/.nvm"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then tmp="$(mktemp)"; fetch https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh "$tmp"; PROFILE=/dev/null bash "$tmp" >/dev/null; rm -f "$tmp"; ok "nvm installed"; fi
# shellcheck disable=SC1091
set +u; source "$NVM_DIR/nvm.sh"; nvm install --lts >/dev/null 2>&1 && nvm alias default 'lts/*' >/dev/null; set -u; ok "node $(node --version)"
fi

# ============================================================================= 4. tool config: bat theme, git + delta, sqlfluff
if want tools; then
step "CLI tool config"
if have uv && ! have sqlfluff; then uv tool install -q sqlfluff && ok "sqlfluff (uv tool)"; fi
# bat theme matching tokyonight
mkdir -p "$(bat --config-dir)/themes"
fetch https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme "$(bat --config-dir)/themes/tokyonight_night.tmTheme"; bat cache --build >/dev/null; ok "bat theme tokyonight_night"
# git + delta
git config --global core.pager delta; git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true; git config --global delta.side-by-side true; git config --global delta.line-numbers true; git config --global merge.conflictStyle zdiff3
ok "git configured to use delta"
fi

# ============================================================================= 5. dotfiles: zsh, ghostty, nvim, zellij, tmux
if want configs; then
step "Config files"
install_file "$DOTFILES/zsh/.zshrc"      "$HOME/.zshrc"
install_file "$SHARED/zsh/.p10k.zsh"     "$HOME/.p10k.zsh"
if [[ ! -f "$HOME/.zsh_local" ]]; then
  { echo '# Machine-specific settings (not committed to dotfiles)'
    # carry over the Google Cloud SDK from the old iTerm2 .zshrc if it is still there
    for d in "$HOME/Downloads/google-cloud-sdk" "$HOME/google-cloud-sdk"; do
      [[ -f "$d/path.zsh.inc" ]] && printf "source '%s/path.zsh.inc'\nsource '%s/completion.zsh.inc'\n" "$d" "$d" && break
    done
  } > "$HOME/.zsh_local"; ok "created ~/.zsh_local"
fi
install_file "$SHARED/tmux/.tmux.conf"   "$HOME/.tmux.conf"
install_file "$DOTFILES/ghostty/config"  "$HOME/.config/ghostty/config"
git_clone_or_pull https://github.com/sahaj-b/ghostty-cursor-shaders "$HOME/.config/ghostty/shaders"
git_clone_or_pull https://github.com/hackr-sh/ghostty-shaders        "$HOME/.config/ghostty/shaders-bg"
# upstream keeps the .glsl files in shaders/ghostty/; the config references shaders/<name>.glsl, so link them
if [[ -d "$HOME/.config/ghostty/shaders/ghostty" ]]; then
  for f in "$HOME/.config/ghostty/shaders/ghostty/"*.glsl; do ln -sf "ghostty/$(basename "$f")" "$HOME/.config/ghostty/shaders/$(basename "$f")"; done
  info "cursor shaders linked from shaders/ghostty/"
fi
[[ -f "$HOME/.config/ghostty/shaders/cursor_warp.glsl" ]] || warn "cursor_warp.glsl not found; check https://github.com/sahaj-b/ghostty-cursor-shaders layout"
GHOSTTY_BIN="/Applications/Ghostty.app/Contents/MacOS/ghostty"
[[ -x "$GHOSTTY_BIN" ]] && { "$GHOSTTY_BIN" +validate-config >/dev/null && ok "ghostty config valid"; }
# neovim (LazyVim), shared with Linux
mkdir -p "$HOME/.config/nvim"
cmp -s "$SHARED/nvim/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json" 2>/dev/null || backup "$HOME/.config/nvim/lazy-lock.json"
rsync -a --exclude='.git' "$SHARED/nvim/" "$HOME/.config/nvim/"; ok "nvim config synced"
info "installing Neovim plugins at the versions pinned in lazy-lock.json (first run takes a few minutes)..."
nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || warn "Lazy restore reported errors; open nvim and run :Lazy restore"
nvim --headless -c "Lazy load mason.nvim" -c "MasonInstall gopls gofumpt goimports delve codelldb prettier" -c qa >/dev/null 2>&1 || true
ok "nvim plugins + Mason packages"
# zellij (reads ~/.config/zellij on macOS too)
install_file "$SHARED/zellij/config.kdl"     "$HOME/.config/zellij/config.kdl"
install_file "$SHARED/zellij/layouts/zj.kdl"  "$HOME/.config/zellij/layouts/zj.kdl"
install_file "$SHARED/zellij/layouts/dev.kdl" "$HOME/.config/zellij/layouts/dev.kdl"
mkdir -p "$HOME/.config/zellij/plugins"
[[ -s "$HOME/.config/zellij/plugins/zjstatus.wasm" ]] || { fetch https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm "$HOME/.config/zellij/plugins/zjstatus.wasm"; ok "zjstatus plugin"; }
[[ -s "$HOME/.config/zellij/plugins/vim-zellij-navigator.wasm" ]] || { fetch https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm "$HOME/.config/zellij/plugins/vim-zellij-navigator.wasm"; ok "vim-zellij-navigator plugin"; }
# plugin permissions live in the macOS cache dir
ZJ_CACHE="$HOME/Library/Caches/org.Zellij-Contributors.Zellij"; mkdir -p "$ZJ_CACHE"
cat > "$ZJ_CACHE/permissions.kdl" <<EOF
"$HOME/.config/zellij/plugins/zjstatus.wasm" {
    ReadApplicationState
    ChangeApplicationState
    RunCommands
}
"$HOME/.config/zellij/plugins/vim-zellij-navigator.wasm" {
    ReadApplicationState
    ChangeApplicationState
    RunCommands
    WriteToStdin
}
EOF
ok "zellij config + plugin permissions"
fi

# ============================================================================= 6. gssh (ssh with highlighting on remotes)
if want gssh; then
step "gssh (ghostty-superpowers remote-ssh plugin only)"
GSP="$HOME/.ghostty-superpowers"
git_clone_or_pull https://github.com/iocron/ghostty-superpowers "$GSP"
mkdir -p "$GSP/plugins_external"
ln -sfn "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"     "$GSP/plugins_external/zsh-autosuggestions"
ln -sfn "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" "$GSP/plugins_external/zsh-syntax-highlighting"
if [[ ! -f "$GSP/plugins_external/blesh/ble.sh" ]]; then
  tmp="$(mktemp -d)"; fetch "https://github.com/akinomyoga/ble.sh/releases/download/$BLESH_VER/ble-${BLESH_VER#v}.tar.xz" "$tmp/ble.txz"
  mkdir -p "$GSP/plugins_external/blesh" && tar -xJf "$tmp/ble.txz" -C "$GSP/plugins_external/blesh" --strip-components=1; rm -rf "$tmp"; ok "ble.sh bundled for bash remotes"
fi
ok "gssh ready (plain ssh is wrapped too; scp/rsync/git are untouched)"
fi

# ============================================================================= summary
if want summary; then
step "Done"
cat <<EOF
  Installed:     Homebrew packages, ~/.config/{ghostty,nvim,zellij}, ~/.zshrc, ~/.p10k.zsh, ~/.tmux.conf
  Backups:       *.bak-$STAMP next to each replaced file (your old iTerm2 ~/.zshrc is one of them)
  Local extras:  ~/.zsh_local for machine-specific settings (not in the repo)

  First-run checklist:
    - Ghostty:   open it from /Applications. Cmd+Shift+, reloads the config. Left Option = Alt.
    - zsh:       powerlevel10k prompt; run \`p10k configure\` if you want another style.
    - Neovim:    \`nvim\` -> :checkhealth lazyvim.
    - zellij:    \`zellij\` (status bar with key hints), \`zellij -l dev\` for the nvim+git layout.
    - atuin:     Ctrl+R searches history; \`atuin import auto\` pulls in old zsh history.
    - gssh/ssh:  \`ssh user@host\` ships autosuggestions + highlighting to the remote session.
    - XPipe:     Settings -> Terminal -> Ghostty; Settings -> Sync -> your private git repo (same repo on every machine).
EOF
fi
