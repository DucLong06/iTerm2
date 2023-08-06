# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel9k/powerlevel9k"
# ZSH_THEME="powerlevel10k/powerlevel10k"
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
plugins=(
	virtualenv
#	zsh-autosuggestions
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
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Add a space in the first prompt
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%f"
# Visual customisation of the second prompt line
local user_symbol="$"
if [[ $(print -P "%#") =~ "#" ]]; then
    user_symbol = "#"
fi
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{%B%F{black}%K{yellow}%} 
$user_symbol%{%b%f%k%F{yellow}%} %{%f%}"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


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


# Add the custom anaconda icon prompt segment
POWERLEVEL9K_CUSTOM_ANACONDA="echo -n $'\ue781'"
POWERLEVEL9K_CUSTOM_ANACONDA_FOREGROUND="black"
POWERLEVEL9K_CUSTOM_ANACONDA_BACKGROUND="yellow"

# PromptLine 
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%{%F{249}%}\u250f"
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{%F{249}%}\u2517%{%F{default}%} "

# Directory length
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_SHORTEN_DELIMITER=""
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"

# Directory icon
POWERLEVEL9K_DIR_HOME_BACKGROUND="black"
POWERLEVEL9K_DIR_HOME_FOREGROUND="249"
POWERLEVEL9K_DIR_HOME_VISUAL_IDENTIFIER_COLOR="220"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND="black"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="249"
POWERLEVEL9K_DIR_HOME_SUBFOLDER_VISUAL_IDENTIFIER_COLOR="220"
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND="black"
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND="249"
POWERLEVEL9K_DIR_DEFAULT_VISUAL_IDENTIFIER_COLOR="220"
POWERLEVEL9K_DIR_ETC_BACKGROUND="black"
POWERLEVEL9K_DIR_ETC_FOREGROUND="249"
POWERLEVEL9K_DIR_ETC_VISUAL_IDENTIFIER_COLOR="220"

# status check -> v
POWERLEVEL9K_STATUS_OK_BACKGROUND="black"
POWERLEVEL9K_STATUS_OK_FOREGROUND="249"
POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_COLOR="green"
POWERLEVEL9K_STATUS_ERROR_BACKGROUND="black"
POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_COLOR="red"
POWERLEVEL9K_STATUS_ERROR_FOREGROUND="249"

# battery
POWERLEVEL9K_BATTERY_STAGES=('\uf244 ' '\uf243 ' '\uf242 ' '\uf241 ' '\uf240 ')
POWERLEVEL9K_BATTERY_LOW_BACKGROUND="black"
POWERLEVEL9K_BATTERY_CHARGING_BACKGROUND="black"
POWERLEVEL9K_BATTERY_CHARGED_BACKGROUND="black"
POWERLEVEL9K_BATTERY_DISCONNECTED_BACKGROUND="black"
POWERLEVEL9K_BATTERY_LOW_FOREGROUND="249"
POWERLEVEL9K_BATTERY_VERBOSE=false
POWERLEVEL9K_BATTERY_CHARGING_FOREGROUND="249"
POWERLEVEL9K_BATTERY_CHARGED_FOREGROUND="249"
POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND="249"
POWERLEVEL9K_BATTERY_LOW_VISUAL_IDENTIFIER_COLOR="red"
POWERLEVEL9K_BATTERY_CHARGING_VISUAL_IDENTIFIER_COLOR="yellow"
POWERLEVEL9K_BATTERY_CHARGED_VISUAL_IDENTIFIER_COLOR="green"
POWERLEVEL9K_BATTERY_DISCONNECTED_VISUAL_IDENTIFIER_COLOR="067"

# clock
POWERLEVEL9K_TIME_BACKGROUND="black"
POWERLEVEL9K_TIME_FOREGROUND="249"
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M%p}"
POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_COLOR="055"

# node version
POWERLEVEL9K_NODE_ICON="\uf898"
POWERLEVEL9K_NODE_VERSION_FOREGROUND="249"
POWERLEVEL9K_NODE_VERSION_BACKGROUND="black"
POWERLEVEL9K_NODE_VERSION_VISUAL_IDENTIFIER_COLOR="green"

# git 
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='249'
POWERLEVEL9K_VCS_CLEAN_BACKGROUND='black'
POWERLEVEL9K_VCS_CLEAN_VISUAL_IDENTIFIER_COLOR="green"
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='249'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='black'
POWERLEVEL9K_VCS_UNTRACKTED_VISUAL_IDENTIFIER_COLOR="green"
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='249'
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='black'
POWERLEVEL9K_VCS_MODIFIED_VISUAL_IDENTIFIER_COLOR="yellow"

# date
POWERLEVEL9K_DATE_ICON=" \uf073 "
POWERLEVEL9K_DATE_VISUAL_IDENTIFIER_COLOR="208"
POWERLEVEL9K_DATE_FORMAT="%D{%m.%d %a}"
POWERLEVEL9K_DATE_BACKGROUND="black"
POWERLEVEL9K_DATE_FOREGROUND="177"

# wifi 
POWERLEVEL9K_CUSTOM_WIFI_SIGNAL="zsh_wifi_signal"
POWERLEVEL9K_CUSTOM_WIFI_SIGNAL_BACKGROUND="black"
POWERLEVEL9K_CUSTOM_WIFI_SIGNAL_FOREGROUND="249"
zsh_wifi_signal(){
        local output=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I) 
        local airport=$(echo $output | grep 'AirPort' | awk -F': ' '{print $2}')

        if [ "$airport" = "Off" ]; then
                local color=%F{red}
                echo -n "%{$color%}Wifi Off"
        else
                local speed=$(echo $output | grep 'lastTxRate' | awk -F': ' '{print $2}')
                local fontcolor="249"
                local color="249"
                [[ $speed -gt 100 ]] && color='%F{006}'
                [[ $speed -lt 50 ]] && color='%F{red}'

                echo -n "$speed Mb/s %{$color%}\uf1eb " 
        fi
}

# LAN
POWERLEVEL9K_CUSTOM_LAN_SIGNAL="zsh_lan_signal"
POWERLEVEL9K_CUSTOM_LAN_SIGNAL_BACKGROUND="black"
POWERLEVEL9K_CUSTOM_LAN_SIGNAL_FOREGROUND="249"

zsh_lan_signal() {
    local wifi_output=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I)
    local airport=$(echo $wifi_output | grep 'AirPort' | awk -F': ' '{print $2}')

    if [ "$airport" = "Off" ]; then
        # Wi-Fi tắt
        local lan_interface="en8"
        local lan_output=$(ifconfig "$lan_interface" 2>/dev/null | grep 'media: ' | awk -F': ' '{print $2}')
        
        if [ -n "$lan_output" ]; then
            local lan_speed=$(echo "$lan_output" | awk -F'baseT' '{print $1}' | sed 's/[^0-9]*//g')
            local lan_color="%F{green}"
            [[ $lan_speed -gt 100 ]] && lan_color='%F{yellow}'
            [[ $lan_speed -lt 50 ]] && lan_color='%F{red}'

            echo -n "$lan_speed Mb/s %{$lan_color%}\uf1eb "
        else
            local no_internet_color="%F{red}"
            echo -n "%{$no_internet_color%}No internet"
        fi
    else
        # Wi-Fi bật
        local speed=$(echo $wifi_output | grep 'lastTxRate' | awk -F': ' '{print $2}')
        local wifi_color="%F{green}"
        [[ $speed -gt 100 ]] && wifi_color='%F{yellow}'
        [[ $speed -lt 50 ]] && wifi_color='%F{red}'

        echo -n "$speed Mb/s %{$wifi_color%}\uf1eb "
    fi
}


# os logo
POWERLEVEL9K_CUSTOM_OS="zsh_os"
POWERLEVEL9K_CUSTOM_OS_BACKGROUND="black"
POWERLEVEL9K_CUSTOM_OS_FOREGROUND="249"
zsh_os(){
    local output=$(sw_vers | grep 'ProductVersion' | awk -F':' '{print $2}' | cut -c 2-10)
    local name=$(sw_vers | grep 'ProductVersion' | awk -F':' '{print $2}' | cut -c 2-6)
    local osname
        case $name in
            10.15) osname="Catalina";;
            10.14) osname="Mojave";;
            10.13) osname="High Sierra";;
            10.12) osname="Sierra";;
            10.11) osname="El Capitan";;
            10.10) osname="Yosemite";;
        esac
    local color="%F{#fafdfd}"
    echo -n "%{$color%}\uf179 $osname Long Loe"
}

# python version
POWERLEVEL9K_CUSTOM_PYTHON="zsh_python"
POWERLEVEL9K_CUSTOM_PYTHON_BACKGROUND="black"
POWERLEVEL9K_CUSTOM_PYTHON_FOREGROUND="249"
zsh_python(){
    # local output=$(python --version | grep 'Python' | awk -F' ' '{print $2}')
    local output=$(python --version | grep 'Python' | awk -F' ' '{print $2}')
    local color="%F{094}"
    echo -n " %{$color%}\uf81f $CONDA_DEFAULT_ENV "
    # echo $CONDA_DEFAULT_ENV 
    
}


# delete hostname
prompt_context(){}

# npm version
POWERLEVEL9K_CUSTOM_NPM="zsh_npm"
POWERLEVEL9K_CUSTOM_NPM_BACKGROUND="black"
POWERLEVEL9K_CUSTOM_NPM_FOREGROUND="249"
zsh_npm(){
    local output=$(npm -v)
    local color="%F{196}"
    echo -n "$output %{$color%}\ue71e "
}


# left right prompt
 POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=( 'custom_os' 'dir' 'vcs'  )
 POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=('status' 'virtualenv' 'custom_npm' 'custom_python' 'node_version' 'custom_cra' 'custom_lan_signal' 'battery' 'time')
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(  'custom_os' 'custom_python' 'dir' 'vcs' )
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=( 'virtualenv' )


# Load Nerd Fonts with Powerlevel9k theme for Zsh
POWERLEVEL9K_MODE='nerdfont-complete'
source  ~/powerlevel9k/powerlevel9k.zsh-theme

# Set a color for iTerm2 tab title background using rgb values
function title_background_color {
  echo -ne "\033]6;1;bg;red;brightness;$ITERM2_TITLE_BACKGROUND_RED\a"
  echo -ne "\033]6;1;bg;green;brightness;$ITERM2_TITLE_BACKGROUND_GREEN\a"
  echo -ne "\033]6;1;bg;blue;brightness;$ITERM2_TITLE_BACKGROUND_BLUE\a"
}
ITERM2_TITLE_BACKGROUND_RED="18"
ITERM2_TITLE_BACKGROUND_GREEN="26"
ITERM2_TITLE_BACKGROUND_BLUE="33"
title_background_color

# Set iTerm2 tab title text
function title_text {
    echo -ne "\033]0;"$*"\007"
}
title_text LongHoangDuc


# setup vscode 
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}
() POWERLEVEL9K_MODE='nerdfont-complete'
() () POWERLEVEL9K_MODE='nerdfont-complete'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/longhoangduc/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/longhoangduc/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/longhoangduc/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/longhoangduc/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

