# Shared look for every screenshot: same theme/font as the Ghostty config, then load ~/.zshrc off-camera.
Set Shell zsh
Set FontFamily "Maple Mono NF"
Set FontSize 16
Set Width 1400
Set Theme "tokyonight"
Set Padding 20
Set WindowBar Colorful
Set TypingSpeed 40ms
Hide
Type "source ~/.zshrc; fc -p; ZSH_AUTOSUGGEST_STRATEGY=(history); cd ~/dotfiles; clear" Enter
Sleep 4s
Show
