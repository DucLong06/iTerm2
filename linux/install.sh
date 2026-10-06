#!/usr/bin/env bash
# =============================================================================
#  One-click Linux (Ubuntu/Debian) terminal + editor setup
#  Ghostty + zsh/powerlevel10k + Neovim (LazyVim) + VS Code (vscode-neovim)
#  + zellij/tmux + modern CLI tools (eza, bat, zoxide, atuin, yazi, ...)
#
#  Author : DucLong06 <https://github.com/DucLong06>
#  Source : https://github.com/DucLong06/iTerm2  (linux/ directory)
#
#  Usage  : ./install.sh [--proxy URL [--no-proxy-list LIST] | --no-proxy] [--skip-apt] [--only STEP[,STEP]] [--list-steps]
#           --proxy applies the URL to shell, git, npm, pip, docker (client + daemon), apt, snap, sudo env and VS Code.
#
#  The script is idempotent: run it again any time (and after the reboot it
#  asks for). Steps that are already done are skipped or refreshed in place.
#  Nothing is deleted; existing files are backed up as <file>.bak-<date>.
# =============================================================================
set -euo pipefail

# ----------------------------------------------------------------------------- paths
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # .../linux
STATE_DIR="$HOME/.cache/dotfiles-install"
LOCAL_BIN="$HOME/.local/bin"
FONT_DIR="$HOME/.local/share/fonts"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$STATE_DIR" "$LOCAL_BIN" "$FONT_DIR"
export PATH="$LOCAL_BIN:$HOME/.local/go/bin:/opt/nvim-linux-x86_64/bin:$PATH"

# ----------------------------------------------------------------------------- pinned versions
NVIM_VER="v0.12.2"
GO_VER="go1.27.1"
LAZYGIT_VER="0.66.0"
FD_VER="v10.5.0"
EZA_VER="v0.23.5"
BAT_VER="v0.26.1"
ZOXIDE_VER="0.10.0"
FASTFETCH_VER="2.69.0"
DELTA_VER="0.20.1"
YAZI_VER="v26.9.1"
TLDR_VER="v1.9.0"
ATUIN_VER="v18.23.0"
ZELLIJ_VER="v0.45.1"
GLOW_VER="3.0.0"
LAZYDOCKER_VER="0.24.1"
BLESH_VER="v0.3.4"
NERD_FONT_VER="v3.4.0"

# ----------------------------------------------------------------------------- ui helpers
C_BLUE='\033[1;34m'; C_GREEN='\033[1;32m'; C_YELLOW='\033[1;33m'; C_RED='\033[1;31m'; C_DIM='\033[2m'; C_OFF='\033[0m'
step()  { printf "\n${C_BLUE}==> %s${C_OFF}\n" "$*"; }
ok()    { printf "${C_GREEN}  ✔ %s${C_OFF}\n" "$*"; }
info()  { printf "${C_DIM}  · %s${C_OFF}\n" "$*"; }
warn()  { printf "${C_YELLOW}  ! %s${C_OFF}\n" "$*"; }
die()   { printf "${C_RED}  ✖ %s${C_OFF}\n" "$*" >&2; exit 1; }
have()  { command -v "$1" >/dev/null 2>&1; }
NEEDS_RELOGIN=()                                   # collected notes shown at the end
note_relogin() { NEEDS_RELOGIN+=("$*"); warn "$* (takes effect after logout/reboot)"; }

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
fetch() { curl -fsSL --retry 5 --retry-all-errors --retry-delay 5 -o "$2" "$1"; }   # retry-all-errors: proxies return 502/503 now and then
retry() {  # retry <n> <cmd...>
  local n="$1" i; shift; for ((i=1;i<=n;i++)); do "$@" && return 0; warn "attempt $i/$n failed: $*"; sleep 5; done; return 1
}
gh_bin() {  # gh_bin <name> <url> <archive-type: tgz|zip|xz|raw> [path-inside-archive]
  local name="$1" url="$2" kind="$3" inner="${4:-$1}" tmp
  if [[ -x "$LOCAL_BIN/$name" ]] && [[ -f "$STATE_DIR/bin-$name" ]] && [[ "$(cat "$STATE_DIR/bin-$name")" == "$url" ]]; then
    info "$name already installed"; return 0
  fi
  tmp="$(mktemp -d)"
  case "$kind" in
    tgz) fetch "$url" "$tmp/a.tgz"; tar -xzf "$tmp/a.tgz" -C "$tmp" ;;
    xz)  fetch "$url" "$tmp/a.txz"; tar -xJf "$tmp/a.txz" -C "$tmp" ;;
    zip) fetch "$url" "$tmp/a.zip"; unzip -qo "$tmp/a.zip" -d "$tmp" ;;
    raw) fetch "$url" "$tmp/$inner" ;;
  esac
  local found; found="$(find "$tmp" -type f -name "$inner" | head -1)"
  [[ -n "$found" ]] || die "could not find '$inner' inside $url"
  install -m755 "$found" "$LOCAL_BIN/$name"; echo "$url" > "$STATE_DIR/bin-$name"; rm -rf "$tmp"
  ok "$name -> $LOCAL_BIN/$name"
}
apt_retry() {  # apt_retry <apt-get args...>: corporate proxies return the odd 502; retry a few times
  local i; for i in 1 2 3 4; do sudo DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Retries=3 "$@" && return 0; warn "apt-get $1 failed (attempt $i/4), retrying in 10s"; sleep 10; done; return 1
}
git_clone_or_pull() {  # git_clone_or_pull <repo-url> <dir> [--depth1]
  if [[ -d "$2/.git" ]]; then git -C "$2" pull -q --ff-only >/dev/null 2>&1 || warn "could not update $2"; info "updated $2"
  else retry 3 git clone -q --depth 1 "$1" "$2"; ok "cloned $2"; fi
}

# ----------------------------------------------------------------------------- args
PROXY_MODE="ask"; PROXY_URL=""; NP=""; SKIP_APT=0; ONLY=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --proxy)      PROXY_MODE="yes"; PROXY_URL="$2"; shift ;;
    --no-proxy)   PROXY_MODE="no" ;;
    --no-proxy-list) NP="$2"; shift ;;
    --skip-apt)   SKIP_APT=1 ;;
    --only)       ONLY="$2"; shift ;;
    --list-steps) printf '%s\n' prereqs proxy ghostty vscode neovim fonts zsh node tools configs vscode-config ime gssh shell summary; exit 0 ;;
    -h|--help)    sed -n '2,16p' "$0"; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac; shift
done
want() { [[ -z "$ONLY" ]] || [[ ",$ONLY," == *",$1,"* ]]; }

[[ "$(uname -s)" == "Linux" ]] || die "This script is for Linux. For macOS use the root of the repo (iTerm2 setup)."
[[ "$(uname -m)" == "x86_64" ]] || die "Only x86_64 binaries are pinned here. Adjust the *_VER urls for $(uname -m)."

# pip + docker client proxy need python3 (for safe merging); called once python3 is guaranteed (after apt step)
apply_user_app_proxy() {
  local url np; url="$(cat "$STATE_DIR/proxy" 2>/dev/null || true)"; np="$(cat "$STATE_DIR/no_proxy" 2>/dev/null || true)"
  [[ -n "$url" ]] || return 0
  have python3 || { warn "python3 missing; pip/docker-client proxy will be applied on the next run"; return 0; }
  mkdir -p "$HOME/.config/pip"; python3 - "$HOME/.config/pip/pip.conf" "$url" <<'EOF'
import sys,configparser,pathlib
p=pathlib.Path(sys.argv[1]); c=configparser.ConfigParser(); c.read(p)
c.setdefault("global",{}); c["global"]["proxy"]=sys.argv[2]
with p.open("w") as f: c.write(f)
EOF
  mkdir -p "$HOME/.docker"; python3 - "$HOME/.docker/config.json" "$url" "$np" <<'EOF'
import sys,json,pathlib
p=pathlib.Path(sys.argv[1]); d=json.loads(p.read_text()) if p.exists() and p.read_text().strip() else {}
d.setdefault("proxies",{})["default"]={"httpProxy":sys.argv[2],"httpsProxy":sys.argv[2],"noProxy":sys.argv[3]}
p.write_text(json.dumps(d,indent=2)+"\n")
EOF
  ok "user proxy: ~/.config/pip/pip.conf, ~/.docker/config.json"
}

# ============================================================================= 1. proxy
# Applies one proxy URL everywhere that matters on a dev box:
#   user:   ~/.zsh_proxy (shell env), git, ~/.npmrc, pip, docker client (~/.docker/config.json), VS Code (later step)
#   system: sudo env_keep, apt, docker daemon (systemd drop-in), snap
# Everything created here is marked in $STATE_DIR so `--no-proxy` can cleanly remove it again.
DEFAULT_NO_PROXY="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.svc,.cluster.local,.local"
if want proxy; then
step "Proxy"
if [[ "$PROXY_MODE" == "ask" ]]; then
  read -r -p "  Configure an HTTP proxy for shell, git, npm, pip, docker, apt, snap and VS Code? [y/N] " ans
  if [[ "${ans,,}" == "y" ]]; then
    read -r -p "  Proxy URL [http://127.0.0.1:3129]: " PROXY_URL; PROXY_URL="${PROXY_URL:-http://127.0.0.1:3129}"; PROXY_MODE="yes"
    read -r -p "  NO_PROXY list [$DEFAULT_NO_PROXY]: " NP; NP="${NP:-$DEFAULT_NO_PROXY}"
  else PROXY_MODE="no"; fi
fi
NP="${NP:-$DEFAULT_NO_PROXY}"
if [[ "$PROXY_MODE" == "yes" ]]; then
  # --- user level ---
  cat > "$HOME/.zsh_proxy" <<EOF
# HTTP proxy for this machine (not committed to dotfiles). Delete this file (or rerun install.sh --no-proxy) to disable.
export HTTP_PROXY="$PROXY_URL"
export HTTPS_PROXY="$PROXY_URL"
export http_proxy="$PROXY_URL"
export https_proxy="$PROXY_URL"
export NO_PROXY="$NP"
export no_proxy="$NP"
EOF
  # shellcheck disable=SC1090
  source "$HOME/.zsh_proxy"
  git config --global http.proxy "$PROXY_URL"; git config --global https.proxy "$PROXY_URL"
  { grep -v -E '^(proxy|https-proxy|noproxy)=' "$HOME/.npmrc" 2>/dev/null || true
    echo "proxy=$PROXY_URL"; echo "https-proxy=$PROXY_URL"; echo "noproxy=$NP"; } > "$HOME/.npmrc.tmp" && mv "$HOME/.npmrc.tmp" "$HOME/.npmrc"
  ok "user proxy: ~/.zsh_proxy, git, ~/.npmrc"
  # --- system level (sudo) ---
  if sudo -n true 2>/dev/null || sudo -v; then
    printf 'Defaults env_keep += "HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy"\n' | sudo tee /etc/sudoers.d/90-keep-proxy-env >/dev/null
    sudo chmod 0440 /etc/sudoers.d/90-keep-proxy-env; sudo visudo -cf /etc/sudoers.d/90-keep-proxy-env >/dev/null || { sudo rm -f /etc/sudoers.d/90-keep-proxy-env; die "sudoers drop-in failed validation"; }
    # Pipeline-Depth 0 + Queue-Mode access: sequential requests, kinder to corporate/local proxies that 502 under parallel load
    printf 'Acquire::http::Proxy "%s";\nAcquire::https::Proxy "%s";\nAcquire::http::Pipeline-Depth "0";\nAcquire::Queue-Mode "access";\n' "$PROXY_URL" "$PROXY_URL" | sudo tee /etc/apt/apt.conf.d/80proxy >/dev/null
    ok "system proxy: sudo keeps proxy env, apt (/etc/apt/apt.conf.d/80proxy)"
    if have docker && have systemctl && [[ -d /run/systemd/system ]]; then
      sudo mkdir -p /etc/systemd/system/docker.service.d
      printf '[Service]\nEnvironment="HTTP_PROXY=%s"\nEnvironment="HTTPS_PROXY=%s"\nEnvironment="http_proxy=%s"\nEnvironment="https_proxy=%s"\nEnvironment="NO_PROXY=%s"\nEnvironment="no_proxy=%s"\n' \
        "$PROXY_URL" "$PROXY_URL" "$PROXY_URL" "$PROXY_URL" "$NP" "$NP" | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf >/dev/null
      sudo systemctl daemon-reload && sudo systemctl restart docker && ok "docker daemon proxy (service restarted)"
    else info "docker daemon not managed here (no docker or no systemd); client proxy is set"; fi
    if have snap; then sudo snap set system proxy.http="$PROXY_URL" proxy.https="$PROXY_URL" && ok "snap proxy"; fi
  else warn "no sudo: skipped apt/sudoers/docker-daemon/snap proxy"; fi
  echo "$PROXY_URL" > "$STATE_DIR/proxy"; echo "$NP" > "$STATE_DIR/no_proxy"
  apply_user_app_proxy
else
  if [[ -f "$STATE_DIR/proxy" ]]; then   # we configured a proxy earlier -> remove it everywhere
    rm -f "$HOME/.zsh_proxy"
    git config --global --unset http.proxy 2>/dev/null || true; git config --global --unset https.proxy 2>/dev/null || true
    [[ -f "$HOME/.npmrc" ]] && sed -i -E '/^(proxy|https-proxy|noproxy)=/d' "$HOME/.npmrc"
    [[ -f "$HOME/.config/pip/pip.conf" ]] && sed -i -E '/^proxy *=/d' "$HOME/.config/pip/pip.conf"
    [[ -f "$HOME/.docker/config.json" ]] && python3 - "$HOME/.docker/config.json" <<'EOF'
import sys,json,pathlib
p=pathlib.Path(sys.argv[1]); d=json.loads(p.read_text()); d.get("proxies",{}).pop("default",None); p.write_text(json.dumps(d,indent=2)+"\n")
EOF
    if sudo -n true 2>/dev/null || sudo -v; then
      sudo rm -f /etc/sudoers.d/90-keep-proxy-env /etc/apt/apt.conf.d/80proxy /etc/systemd/system/docker.service.d/http-proxy.conf
      have systemctl && [[ -d /run/systemd/system ]] && have docker && { sudo systemctl daemon-reload; sudo systemctl restart docker; } || true
      have snap && sudo snap unset system proxy.http proxy.https || true
    fi
    rm -f "$STATE_DIR/proxy" "$STATE_DIR/no_proxy"; ok "proxy removed everywhere"
  else ok "no proxy"; fi
fi
fi

# ============================================================================= 2. apt prerequisites
if want prereqs && [[ $SKIP_APT -eq 0 ]]; then
step "System packages (sudo)"
sudo -v || die "sudo is required for apt/snap steps (or rerun with --skip-apt)"
( while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null & )   # keep sudo alive
apt_retry update -qq
apt_retry install -y -qq \
  git curl wget unzip tar xz-utils build-essential ca-certificates gnupg \
  zsh tmux fzf ripgrep jq xclip xdotool x11-utils fontconfig \
  python3 python3-pip python3-venv rsync >/dev/null
ok "apt packages installed"
apply_user_app_proxy
fi

# ============================================================================= 3. Ghostty
if want ghostty; then
step "Ghostty"
if have ghostty; then info "ghostty $(ghostty --version 2>/dev/null | head -1 | awk '{print $2}') already installed"
else
  if have snap && [[ -d /run/systemd/system ]]; then sudo snap install ghostty --classic; ok "ghostty installed via snap"
  else warn "snap/systemd not available (container?) - skipping Ghostty; install it from https://ghostty.org/docs/install/binary"; fi
fi
fi

# ============================================================================= 4. VS Code
if want vscode; then
step "VS Code"
if have code; then info "code $(code --version | head -1) already installed"
else
  sudo install -d -m 0755 /etc/apt/keyrings
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
  apt_retry update -qq && apt_retry install -y -qq code >/dev/null; ok "VS Code installed from Microsoft apt repo"
fi
fi

# ============================================================================= 5. Neovim
if want neovim; then
step "Neovim $NVIM_VER -> /opt/nvim-linux-x86_64"
if [[ -x /opt/nvim-linux-x86_64/bin/nvim ]] && /opt/nvim-linux-x86_64/bin/nvim --version | head -1 | grep -q "${NVIM_VER#v}"; then
  info "already $NVIM_VER"
else
  tmp="$(mktemp -d)"; fetch "https://github.com/neovim/neovim/releases/download/$NVIM_VER/nvim-linux-x86_64.tar.gz" "$tmp/nvim.tgz"
  sudo rm -rf /opt/nvim-linux-x86_64 && sudo tar -C /opt -xzf "$tmp/nvim.tgz"; rm -rf "$tmp"; ok "nvim $NVIM_VER installed"
fi
fi

# ============================================================================= 6. Fonts
if want fonts; then
step "Fonts (JetBrainsMono Nerd Font for Ghostty, MesloLGS NF for powerlevel10k)"
if ! fc-list | grep -q "JetBrainsMono Nerd Font"; then
  tmp="$(mktemp -d)"; fetch "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONT_VER/JetBrainsMono.zip" "$tmp/jb.zip"
  unzip -qo "$tmp/jb.zip" -d "$FONT_DIR/JetBrainsMonoNerd" '*.ttf' && rm -rf "$tmp"; ok "JetBrainsMono Nerd Font"
else info "JetBrainsMono Nerd Font present"; fi
if ! fc-list | grep -q "MesloLGS NF"; then
  for f in Regular Bold Italic "Bold Italic"; do fetch "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20${f// /%20}.ttf" "$FONT_DIR/MesloLGS NF $f.ttf"; done; ok "MesloLGS NF"
else info "MesloLGS NF present"; fi
fc-cache -f >/dev/null; ok "font cache refreshed"
fi

# ============================================================================= 7. zsh + oh-my-zsh + powerlevel10k
if want zsh; then
step "oh-my-zsh, powerlevel10k, plugins"
ZSH_DIR="$HOME/.oh-my-zsh"; ZSH_CUSTOM="$ZSH_DIR/custom"
if [[ ! -d "$ZSH_DIR" ]]; then
  tmp="$(mktemp)"; fetch https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh "$tmp"; RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "$tmp" >/dev/null 2>&1; rm -f "$tmp"; ok "oh-my-zsh installed"
else info "oh-my-zsh present"; fi
git_clone_or_pull https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
git_clone_or_pull https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git_clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git_clone_or_pull https://github.com/MichaelAquilina/zsh-you-should-use "$ZSH_CUSTOM/plugins/you-should-use"
git_clone_or_pull https://github.com/fdellwing/zsh-bat "$ZSH_CUSTOM/plugins/zsh-bat"
# fzf shell bindings (~/.fzf.zsh is sourced by .zshrc)
if [[ ! -f "$HOME/.fzf.zsh" ]]; then git_clone_or_pull https://github.com/junegunn/fzf.git "$HOME/.fzf"; "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish >/dev/null 2>&1; ok "fzf keybindings"; fi
# tmux plugin manager + tmux-power theme
git_clone_or_pull https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
git_clone_or_pull https://github.com/wfxr/tmux-power "$HOME/tmux-power"
fi

# ============================================================================= 8. Node (nvm), uv, Go
if want node; then
step "Runtimes: nvm + Node LTS, uv (Python tools), Go $GO_VER"
export NVM_DIR="$HOME/.nvm"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then tmp="$(mktemp)"; fetch https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh "$tmp"; PROFILE=/dev/null bash "$tmp" >/dev/null; rm -f "$tmp"; ok "nvm installed"; fi
# shellcheck disable=SC1091
source "$NVM_DIR/nvm.sh"; retry 3 nvm install --lts >/dev/null 2>&1 && nvm alias default 'lts/*' >/dev/null; ok "node $(node --version)"
if ! have uv; then tmp="$(mktemp)"; fetch https://astral.sh/uv/install.sh "$tmp"; UV_NO_MODIFY_PATH=1 retry 3 sh "$tmp" >/dev/null 2>&1; rm -f "$tmp"; ok "uv installed"; else info "uv present"; fi
if [[ -x "$HOME/.local/go/bin/go" ]] && "$HOME/.local/go/bin/go" version | grep -q "$GO_VER"; then info "$GO_VER present"
else
  tmp="$(mktemp -d)"; fetch "https://go.dev/dl/$GO_VER.linux-amd64.tar.gz" "$tmp/go.tgz"
  rm -rf "$HOME/.local/go" && tar -C "$HOME/.local" -xzf "$tmp/go.tgz"; rm -rf "$tmp"; ok "$GO_VER -> ~/.local/go"
fi
fi

# ============================================================================= 9. CLI tools -> ~/.local/bin
if want tools; then
step "CLI tools -> $LOCAL_BIN"
gh_bin lazygit   "https://github.com/jesseduffield/lazygit/releases/download/v$LAZYGIT_VER/lazygit_${LAZYGIT_VER}_linux_x86_64.tar.gz" tgz
gh_bin fd        "https://github.com/sharkdp/fd/releases/download/$FD_VER/fd-$FD_VER-x86_64-unknown-linux-gnu.tar.gz" tgz
gh_bin eza       "https://github.com/eza-community/eza/releases/download/$EZA_VER/eza_x86_64-unknown-linux-gnu.tar.gz" tgz
gh_bin bat       "https://github.com/sharkdp/bat/releases/download/$BAT_VER/bat-$BAT_VER-x86_64-unknown-linux-gnu.tar.gz" tgz
gh_bin zoxide    "https://github.com/ajeetdsouza/zoxide/releases/download/v$ZOXIDE_VER/zoxide-$ZOXIDE_VER-x86_64-unknown-linux-musl.tar.gz" tgz
gh_bin fastfetch "https://github.com/fastfetch-cli/fastfetch/releases/download/$FASTFETCH_VER/fastfetch-linux-amd64.tar.gz" tgz
gh_bin delta     "https://github.com/dandavison/delta/releases/download/$DELTA_VER/delta-$DELTA_VER-x86_64-unknown-linux-gnu.tar.gz" tgz
gh_bin yazi      "https://github.com/sxyazi/yazi/releases/download/$YAZI_VER/yazi-x86_64-unknown-linux-gnu.zip" zip
gh_bin ya        "https://github.com/sxyazi/yazi/releases/download/$YAZI_VER/yazi-x86_64-unknown-linux-gnu.zip" zip
gh_bin tldr      "https://github.com/tealdeer-rs/tealdeer/releases/download/$TLDR_VER/tealdeer-linux-x86_64-musl" raw tealdeer-linux-x86_64-musl
gh_bin atuin     "https://github.com/atuinsh/atuin/releases/download/$ATUIN_VER/atuin-x86_64-unknown-linux-gnu.tar.gz" tgz
gh_bin zellij    "https://github.com/zellij-org/zellij/releases/download/$ZELLIJ_VER/zellij-x86_64-unknown-linux-musl.tar.gz" tgz
gh_bin glow      "https://github.com/charmbracelet/glow/releases/download/v$GLOW_VER/glow_${GLOW_VER}_Linux_x86_64.tar.gz" tgz
gh_bin lazydocker "https://github.com/jesseduffield/lazydocker/releases/download/v$LAZYDOCKER_VER/lazydocker_${LAZYDOCKER_VER}_Linux_x86_64.tar.gz" tgz
if have uv && ! have sqlfluff; then retry 3 uv tool install -q sqlfluff && ok "sqlfluff (uv tool)"; fi
# bat theme matching tokyonight
mkdir -p "$(bat --config-dir)/themes"
fetch https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme "$(bat --config-dir)/themes/tokyonight_night.tmTheme"; bat cache --build >/dev/null; ok "bat theme tokyonight_night"
# git + delta
git config --global core.pager delta; git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true; git config --global delta.side-by-side true; git config --global delta.line-numbers true; git config --global merge.conflictStyle zdiff3
ok "git configured to use delta"
fi

# ============================================================================= 10. dotfiles: zsh, ghostty, nvim, zellij, tmux
if want configs; then
step "Config files"
install_file "$DOTFILES/zsh/.zshrc"      "$HOME/.zshrc"
install_file "$DOTFILES/zsh/.p10k.zsh"   "$HOME/.p10k.zsh"
[[ -f "$HOME/.zsh_local" ]] || { printf '# Machine-specific aliases (not committed to dotfiles)\n# alias vpnon="sudo nmcli connection up <VPN_NAME>"\n' > "$HOME/.zsh_local"; ok "created ~/.zsh_local template"; }
install_file "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"
install_file "$DOTFILES/ghostty/config"  "$HOME/.config/ghostty/config"
git_clone_or_pull https://github.com/sahaj-b/ghostty-cursor-shaders "$HOME/.config/ghostty/shaders"
git_clone_or_pull https://github.com/hackr-sh/ghostty-shaders        "$HOME/.config/ghostty/shaders-bg"
# upstream moved the .glsl files into shaders/ghostty/ (Oct 2026); the config references shaders/<name>.glsl, so link them
if [[ -d "$HOME/.config/ghostty/shaders/ghostty" ]]; then
  for f in "$HOME/.config/ghostty/shaders/ghostty/"*.glsl; do ln -sf "ghostty/$(basename "$f")" "$HOME/.config/ghostty/shaders/$(basename "$f")"; done
  info "cursor shaders linked from shaders/ghostty/"
fi
[[ -f "$HOME/.config/ghostty/shaders/cursor_warp.glsl" ]] || warn "cursor_warp.glsl not found; check https://github.com/sahaj-b/ghostty-cursor-shaders layout"
have ghostty && { ghostty +validate-config >/dev/null && ok "ghostty config valid"; }
# neovim (LazyVim)
mkdir -p "$HOME/.config/nvim"
cmp -s "$DOTFILES/nvim/lazy-lock.json" "$HOME/.config/nvim/lazy-lock.json" 2>/dev/null || backup "$HOME/.config/nvim/lazy-lock.json"
rsync -a --exclude='.git' "$DOTFILES/nvim/" "$HOME/.config/nvim/"; ok "nvim config synced"
mkdir -p "$HOME/.config/nvim/spell"
if [[ ! -s "$HOME/.config/nvim/spell/vi.utf-8.spl" ]]; then
  tmp="$(mktemp -d)"; fetch https://raw.githubusercontent.com/LibreOffice/dictionaries/master/vi/vi_VN.dic "$tmp/vi_VN.dic"; fetch https://raw.githubusercontent.com/LibreOffice/dictionaries/master/vi/vi_VN.aff "$tmp/vi_VN.aff"
  nvim --headless -u NONE "+mkspell! $HOME/.config/nvim/spell/vi $tmp/vi_VN" +qa >/dev/null 2>&1; rm -rf "$tmp"; ok "Vietnamese spell file built"
fi
info "installing Neovim plugins at the versions pinned in lazy-lock.json (first run takes a few minutes)..."
nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 || warn "Lazy restore reported errors; open nvim and run :Lazy restore"
nvim --headless -c "Lazy load mason.nvim" -c "MasonInstall gopls gofumpt goimports delve codelldb prettier" -c qa >/dev/null 2>&1 || true
ln -sf "$HOME/.local/share/nvim/mason/bin/tree-sitter" "$LOCAL_BIN/tree-sitter" 2>/dev/null || true
ok "nvim plugins + Mason packages"
# zellij
install_file "$DOTFILES/zellij/config.kdl"     "$HOME/.config/zellij/config.kdl"
install_file "$DOTFILES/zellij/layouts/zj.kdl"  "$HOME/.config/zellij/layouts/zj.kdl"
install_file "$DOTFILES/zellij/layouts/dev.kdl" "$HOME/.config/zellij/layouts/dev.kdl"
mkdir -p "$HOME/.config/zellij/plugins" "$HOME/.cache/zellij"
[[ -s "$HOME/.config/zellij/plugins/zjstatus.wasm" ]] || { fetch https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm "$HOME/.config/zellij/plugins/zjstatus.wasm"; ok "zjstatus plugin"; }
[[ -s "$HOME/.config/zellij/plugins/vim-zellij-navigator.wasm" ]] || { fetch https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm "$HOME/.config/zellij/plugins/vim-zellij-navigator.wasm"; ok "vim-zellij-navigator plugin"; }
cat > "$HOME/.cache/zellij/permissions.kdl" <<EOF
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

# ============================================================================= 11. VS Code settings + extensions
if want vscode-config && have code; then
step "VS Code settings, keybindings, extensions"
# settings.json = repo file + placeholder expansion + optional proxy lines, rendered to a temp file so reruns detect "unchanged"
VSC_TMP="$(mktemp)"; sed "s|/home/USER|$HOME|g" "$DOTFILES/vscode/settings.json" > "$VSC_TMP"
if [[ -f "$STATE_DIR/proxy" ]]; then
  python3 - "$VSC_TMP" "$(cat "$STATE_DIR/proxy")" <<'EOF'
import sys,pathlib
p=pathlib.Path(sys.argv[1]); s=p.read_text(); url=sys.argv[2]
p.write_text(s.replace('{',f'{{\n    "http.proxy": "{url}",\n    "http.proxySupport": "override",',1))
EOF
  info "settings.json rendered with http.proxy"
fi
install_file "$VSC_TMP" "$HOME/.config/Code/User/settings.json"; rm -f "$VSC_TMP"
install_file "$DOTFILES/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
installed="$(code --list-extensions 2>/dev/null || true)"
while read -r ext; do
  [[ -z "$ext" || "$ext" == \#* ]] && continue
  if grep -qix "$ext" <<<"$installed"; then continue; fi
  retry 2 code --install-extension "$ext" --force >/dev/null 2>&1 && info "extension: $ext" || warn "could not install extension $ext"
done < "$DOTFILES/vscode/extensions.txt"
ok "VS Code extensions synced ($(wc -l < "$DOTFILES/vscode/extensions.txt") listed)"
fi

# ============================================================================= 12. IME auto-switch (X11 + ibus)
if want ime; then
step "Input-method auto switch for Ghostty (ibus, X11)"
install_file "$DOTFILES/bin/ghostty-ime-watch" "$LOCAL_BIN/ghostty-ime-watch" 755
install_file "$DOTFILES/autostart/ghostty-ime-watch.desktop" "$HOME/.config/autostart/ghostty-ime-watch.desktop"
if [[ "${XDG_SESSION_TYPE:-}" == "x11" ]] && have ibus; then
  pkill -f "^/bin/bash $LOCAL_BIN/ghostty-ime-watch" 2>/dev/null || true
  setsid nohup "$LOCAL_BIN/ghostty-ime-watch" >/dev/null 2>&1 < /dev/null &
  ok "watcher started (English in Ghostty, previous IME elsewhere); autostarts with GNOME"
else
  warn "not an X11+ibus session; the watcher is installed but only works on X11 with ibus"
fi
fi

# ============================================================================= 13. gssh (ssh with highlighting on remotes)
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

# ============================================================================= 14. default shell
if want shell; then
step "Default shell"
if [[ "$(getent passwd "$(id -un)" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  sudo chsh -s "$(command -v zsh)" "$(id -un)" && note_relogin "default shell changed to zsh"
else info "already zsh"; fi
fi

# ============================================================================= summary
if want summary; then
step "Done"
cat <<EOF
  Installed to:  ~/.local/bin (tools), ~/.local/go, /opt/nvim-linux-x86_64, ~/.config/{ghostty,nvim,zellij}
  Backups:       *.bak-$STAMP next to each replaced file
  Proxy:         $( [[ -f "$STATE_DIR/proxy" ]] && cat "$STATE_DIR/proxy" || echo "none" )  (edit ~/.zsh_proxy, delete it to disable)
  Local extras:  ~/.zsh_local for machine-specific aliases (not in the repo)

  Things that need a LOGOUT or REBOOT before they fully work:
    - fonts in Ghostty/VS Code, GNOME autostart of ghostty-ime-watch
    - Ghostty from snap: start it once from the app grid so GNOME registers it
EOF
for n in "${NEEDS_RELOGIN[@]:-}"; do [[ -n "$n" ]] && echo "    - $n"; done
cat <<'EOF'

  >>> After the reboot, run this script once more:  ./install.sh --skip-apt
      It is idempotent: it only verifies and finishes what could not run before (fonts, shell, VS Code extensions).

  First-run checklist:
    - Ghostty:   theme/padding/cursor shaders are active. Ctrl+Shift+, reloads the config.
    - zsh:       powerlevel10k prompt; run `p10k configure` if you want another style.
    - Neovim:    `nvim` -> :checkhealth lazyvim. Tools: fd, lazygit, rg are on PATH.
    - VS Code:   vscode-neovim + whichkey (Space). Reload window if the status bar shows no mode.
    - zellij:    `zellij` (status bar with key hints), `zellij -l dev` for the nvim+git layout.
    - atuin:     Ctrl+R searches history; `atuin import auto` pulls in old zsh history.
    - gssh/ssh:  `ssh user@host` ships autosuggestions + highlighting to the remote session.
EOF
fi
