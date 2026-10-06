# Terminal & editor setup (macOS + Linux)

| Platform | What | Where |
|---|---|---|
| Linux (Ubuntu) | Ghostty + zsh/powerlevel10k + Neovim (LazyVim) + VS Code (vscode-neovim) + zellij + CLI tools, **one-click installer** | [`linux/`](linux/) |
| macOS | iTerm2 + zsh/powerlevel10k + VS Code settings | this README (below), `setting.json`, `keybindings.json`, `.zshrc` |

## Linux one-click setup

```bash
git clone https://github.com/DucLong06/iTerm2.git ~/dotfiles
cd ~/dotfiles/linux
./install.sh            # asks whether to configure an HTTP proxy, then installs everything
```

What it does, in order: system packages → Ghostty (snap) → VS Code (apt) → Neovim → fonts → oh-my-zsh + powerlevel10k + plugins → nvm/Node, uv, Go → CLI tools into `~/.local/bin` (lazygit, fd, eza, bat, zoxide, fastfetch, delta, yazi, tldr, atuin, zellij, glow, lazydocker) → config files (zsh, Ghostty + cursor/background shaders, LazyVim, zellij + zjstatus, tmux) → VS Code settings/keybindings/extensions → Ghostty IME auto-switch (ibus, X11) → gssh → default shell.

- Idempotent: safe to re-run. Replaced files are backed up as `*.bak-<date>`.
- After it finishes it prints what needs a **logout/reboot** (default shell, fonts, GNOME autostart). Reboot, then run `./install.sh --skip-apt` once more to verify.
- Proxy: answering **y** (or `--proxy URL`) applies the proxy to the shell (`~/.zsh_proxy`), git, npm, pip, docker client **and** daemon, apt, snap, `sudo` (env_keep) and VS Code. `--no-proxy` removes all of it again.
- Options: `--proxy URL [--no-proxy-list LIST]`, `--no-proxy`, `--skip-apt`, `--only configs,vscode-config` (see `--list-steps`).
- Tested on a clean Ubuntu 24.04 container behind a corporate proxy: `linux/test/run.sh --proxy http://proxy:port` (Ghostty/snap, docker daemon and the ibus watcher are skipped there with a warning, everything else runs end to end).
- Machine-specific things stay out of git: `~/.zsh_proxy` (written by the proxy prompt) and `~/.zsh_local` (your own aliases).

Layout of `linux/`:

```
install.sh            the installer
zsh/.zshrc .p10k.zsh  shell + prompt
ghostty/config        terminal (shaders are cloned by the installer)
nvim/                 LazyVim config (lazy-lock.json pinned, Vietnamese spell file)
vscode/               settings.json, keybindings.json, extensions.txt
zellij/               config.kdl + layouts (zjstatus bar, nvim<->zellij Ctrl+hjkl)
tmux/.tmux.conf       tpm + tmux-power
bin/, autostart/      ghostty-ime-watch (English IME inside Ghostty)
```

---

# macOS: Setup iTerm2

## 1. Install iTerm2
```bash
brew install --cask iterm2
```
## 2. Change Theme
Choice theme in [opensource iTerm2 color scheme](https://iterm2colorschemes.com/) and download  [preset’s file.](https://github.com/mbadolato/iTerm2-Color-Schemes/tree/master/schemes)
```bash
iTerm → Preferences → Profiles → Colors → Color presets → Import
```
```bash
→  Color presets → preset’s file.
```
My theme [Cobalt Neon](https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/schemes/Cobalt%20Neon.itermcolors)
## 3. Change font
Choice [fonts](https://github.com/powerline/fonts) download and Install Font.
```bash
iTerm2 → Preferences → Profiles → Text → Change Font
```
## 4. Setup Zsh and Oh my Zsh
```bash
brew install zsh zsh-completions
```
```bash
sh -c "$ (curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```
## 5. Setup theme Powerlevel9k Zsh
```bash
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
```
Edit in `~/.zshrc`
```bash
ZSH_THEME="powerlevel9k/powerlevel9k"
```
## 6. Add autosuggestions
### Option 1: Using autosuggestions
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```
Add plugins in `~/.zshrc`
```bash
plugins=(
    …
    zsh-autosuggestions
)
```

### Option 2: Using fig
```bash
Link git: https://github.com/withfig/autocomplete
```
Install using `brew`
```bash
brew install fig
```
## 7. Highlight syntax
```bash
brew install zsh-syntax-highlighting
```
Add line in `~/.zshrc`
```bash
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```
## 8. Add conda to Zsh  
Add line in `~/.zshrc`
```bash
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniforge/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniforge/base/bin:$PATH"
    fi
fi
unset __conda_setup

# <<< conda initialize <<<
```
## 9. Add tmux
```bash
brew install tmux
```
## 10. Other setup in theme
[FULL `~/.zshrc`](./.zshrc)

## 11. Install for vscode
[Link download font: MesloLGS NF](https://github.com/romkatv/powerlevel10k/issues/671#issuecomment-621031981)