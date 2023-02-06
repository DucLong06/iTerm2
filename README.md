# Setup iTerm for my mac

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