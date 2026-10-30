# macOS zshrc (Ghostty + oh-my-zsh + powerlevel10k). Installed by mac/install.sh.
# Same setup as linux/zsh/.zshrc minus the proxy and the Linux-only paths.

# Homebrew (Apple Silicon at /opt/homebrew, Intel at /usr/local)
if [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then eval "$(/usr/local/bin/brew shellenv)"; fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git
        zsh-autosuggestions
        zsh-syntax-highlighting
        you-should-use
        zsh-bat
        nvm
        fzf
        )
command -v kubectl >/dev/null && plugins+=(kubectl)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="$HOME/.local/bin:$PATH"
alias python=python3

# >>> conda initialize >>> (only if anaconda3 / miniforge is installed)
for _conda in "$HOME/anaconda3" "$HOME/miniforge3" "$HOMEBREW_PREFIX/Caskroom/miniforge/base"; do
  if [[ -x "$_conda/bin/conda" ]]; then
    __conda_setup="$("$_conda/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then eval "$__conda_setup"
    elif [ -f "$_conda/etc/profile.d/conda.sh" ]; then . "$_conda/etc/profile.d/conda.sh"
    else export PATH="$_conda/bin:$PATH"; fi
    unset __conda_setup; break
  fi
done; unset _conda
# <<< conda initialize <<<

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U +X bashcompinit && bashcompinit
command -v terraform >/dev/null && complete -o nospace -C "$(command -v terraform)" terraform
alias lzd=lazydocker
export ZELLIJ_CONFIG_DIR="$HOME/.config/zellij"   # macOS default would be ~/Library/Application Support
# Machine-specific aliases (work hosts, gcloud sdk path...) live in ~/.zsh_local (not committed)
[[ -f ~/.zsh_local ]] && source ~/.zsh_local

function git-sync-branches() {
  local force_delete=false
  if [[ "$1" == "--force" ]]; then
    force_delete=true
  fi

  echo "Fetching and pruning from origin..."
  git fetch origin --prune

  echo "Removing local branches that no longer exist on origin..."
  if [[ "$force_delete" == true ]]; then
    git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -I {} git branch -D {}
  else
    git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -I {} git branch -d {}
  fi

  echo "Sync complete!"
}

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias vi='nvim'
alias vim='nvim'
export EDITOR='nvim'
export VISUAL='nvim'

# Go toolchain (Homebrew)
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# === Modern CLI tools (Homebrew) ===
eval "$(zoxide init zsh)"            # z <name> -> jump to a frequently used dir; zi -> pick with fzf
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --git --group-directories-first'
alias la='eza -la --icons --git --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
export BAT_THEME="tokyonight_night"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
y() { local tmp; tmp="$(mktemp -t yazi-cwd.XXXXXX)"; yazi "$@" --cwd-file="$tmp"; local d; d="$(command cat -- "$tmp")" && [ -n "$d" ] && [ "$d" != "$PWD" ] && builtin cd -- "$d"; rm -f -- "$tmp"; }  # y: open yazi; quitting with q cds into the last directory

# atuin: smarter shell history (Ctrl+R). Up-arrow stays native
eval "$(atuin init zsh --disable-up-arrow)"


# === gssh (from ghostty-superpowers; only the gssh plugin is loaded) ===
# ssh with autosuggestions + syntax highlighting on the remote, without touching its config.
export GSP_SSH_EPHEMERAL=1   # remove the bundle from the remote on logout (no residue)
export GSP_SSH_WRAP=1        # plain `ssh` is wrapped too (scp/rsync/git/non-tty ssh still use the real ssh)
[[ -f ~/.ghostty-superpowers/plugins/remote-ssh.zsh ]] && source ~/.ghostty-superpowers/plugins/remote-ssh.zsh
# Ghostty re-wraps `ssh` at the first prompt (after .zshrc) and would shadow gssh; re-source gssh once after that.
_gsp_rewrap_ssh() {
  [[ -f ~/.ghostty-superpowers/plugins/remote-ssh.zsh ]] && source ~/.ghostty-superpowers/plugins/remote-ssh.zsh
  precmd_functions=(${precmd_functions:#_gsp_rewrap_ssh})
}
precmd_functions+=(_gsp_rewrap_ssh)
