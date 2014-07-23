# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="bullet-train"
# ZSH_THEME="agnoster"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git github homebrew node npm ruby rails pip python)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=~/.bin:/usr/local/share/npm/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# cheat ruby UTF-8
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
LC_CTYPE=en_US.UTF-8

# alis git to hub
# eval "$(hub alias -s)"

#
alias shell:clean="sudo rm -rf /private/var/log/asl/*.asl"
alias subl="subl -n --command toggle_full_screen"
alias django:manage='python manage.py'
alias django:admin='django-admin.py'
alias zshconfig="subl -w ~/.zshrc"
alias ohmyzsh="subl -w ~/.oh-my-zsh"
alias ll="ls -laFs"
alias grep="grep --color=always"

# ZSH completions
fpath=(/usr/local/share/zsh-completions $fpath)

# ZSH syntax highlighting
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# autojump
[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

# disables autocorrect
unsetopt correct_all

# virtualenv
export WORKON_HOME=$HOME/.virtualenvs
# export PROJECT_HOME=$HOME/work
source `which virtualenvwrapper.sh`

# pip
# pip should only run if there is a virtualenv currently activated
# export PIP_REQUIRE_VIRTUALENV=true
