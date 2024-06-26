# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/jedp/.oh-my-zsh"
export GPG_TTY=$(tty)
# Set python to correct version (3.9)
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
# Allow writing code <filename> in terminal
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}
# Add psql to path
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="dstufft"
# ZSH_THEME="jonathan"
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

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
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
	# zsh-completions
	# zsh-syntax-highlighting
	git
	pyenv
	zsh-autosuggestions
	brew
	python
	docker
	docker-compose
	node
	npm
	themes
	virtualenv
	sudo
	web-search
	copypath
	copyfile
	jsontools
	gpg-agent
)
# fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
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

alias python="python3"

alias branchclean="bash ~/Desktop/scripts/branchClean.sh"
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"

alias zshconfig="code ~/.zshrc"
alias srczsh="source ~/.zshrc"
alias ls="exa"

### GIT
alias gresetm='g reset --soft $(git merge-base master HEAD)'
alias psh='poetry shell'
### DOCKER
# Docker ls
alias dockerls='docker ps -a'
alias dockerps='docker ps -a --format "table {{ .ID }}\t{{.Image}}\t{{ .Status }}\t{{ .Ports }}"'
# Stop Containers
alias dockerstop='docker stop $(docker ps -a -q)'
#Remove containers
alias dockerrm='docker rm $(docker ps -a -q)'

### FLOAT STUFF
alias rpayments='bash ~/Desktop/scripts/Float/payments.sh'
alias rcore='bash ~/Desktop/scripts/Float/core.sh'

alias ngrokcore="ngrok http --region=us --hostname=jedp.ngrok.io 8000"
alias ngrokdb="ngrok tcp --region=us --remote-addr=5.tcp.ngrok.io:26054 5432"
alias _be="cd ~/float/core-backend && poetry shell"
alias _fe="cd ~/float/app-frontend"
alias coretest="~/float/core-backend/bin/non_docker_run_all_tests.sh"

## COOL STUFF
alias weather="curl wttr.in/Fredericton\?m"

# MAC STUFF
alias openfinder='function _openfinder() { open -a Finder $1; }; _openfinder'
alias openapp='function _openapp() { open /Applications/$1.app; }; _openapp'
alias lock='function _lock() { /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend; }; _lock'
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias battery="pmset -g batt | grep -Eo '[0-9]+%' | sed 's/%//'"

### POST BLOCKS
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
eval $(thefuck --alias)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

export PATH="/opt/homebrew/opt/postgresql@12/bin:$PATH"

# source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
# source /opt/homebrew/opt/chruby/share/chruby/auto.sh
# chruby ruby-3.2.2
eval source <(/opt/homebrew/bin/starship init zsh --print-full-init)

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"
