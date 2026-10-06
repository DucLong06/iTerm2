# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git
        zsh-autosuggestions 
        zsh-syntax-highlighting
        you-should-use 
        zsh-bat
        # poetry
        # pyenv
        nvm
	    fzf
	    kubectl	
        )

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('$HOME/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "$HOME/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="$HOME/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<
#<<<<<<<<<<<<<<<<<<<<Python system path>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# # 
# export PATH="/usr/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
# Alias for python to use python3
alias python=python3
#<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Proxy (optional): created by linux/install.sh when you answer "y" to the proxy question
[[ -f ~/.zsh_proxy ]] && source ~/.zsh_proxy
export PYENV_ROOT="$HOME/.pyenv"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform
alias lzd=lazydocker    
# Machine-specific aliases (VPN names, work hosts...) live in ~/.zsh_local (not committed)
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


export PATH="$HOME/.local/bin:$PATH"
# starship intentionally disabled: the prompt is powerlevel10k
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
alias vi='nvim'
alias vim='nvim'
export EDITOR='nvim'
export VISUAL='nvim'

# Go toolchain (installed to ~/.local/go by linux/install.sh)
export GOPATH="$HOME/go"
export PATH="$HOME/.local/go/bin:$GOPATH/bin:$PATH"

# === Modern CLI tools (~/.local/bin) ===
eval "$(zoxide init zsh)"            # z <name> -> jump to a frequently used dir; zi -> pick with fzf
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --git --group-directories-first'
alias la='eza -la --icons --git --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
export BAT_THEME="tokyonight_night"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
y() { local tmp; tmp="$(mktemp -t yazi-cwd.XXXXXX)"; yazi "$@" --cwd-file="$tmp"; local d; d="$(cat -- "$tmp")" && [ -n "$d" ] && [ "$d" != "$PWD" ] && builtin cd -- "$d"; rm -f -- "$tmp"; }  # y: open yazi; quitting with q cds into the last directory

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
