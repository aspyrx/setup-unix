if [ -f ~/.bashrc.local ]; then
    # local configuration
    source ~/.bashrc.local
fi

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
command -v lesspipe > /dev/null && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
color_prompt=
case "$TERM" in
    tmux*|xterm*|screen*) color_prompt=yes;;
esac
if \
    [ -z "$color_prompt" ] && \
    command -v tput > /dev/null && \
    tput setaf 1 >&/dev/null
then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
fi

if [ "$color_prompt" == yes ]; then
    source ~/.bash_color_prompt.sh
else
    PS1='\u@\h:\w \$ '
fi
unset color_prompt

# enable color support of ls and also add handy aliases
if command -v dircolors > /dev/null ; then
    if [ -r ~/.dircolors ]; then
        DIRCOLORS=~/.dircolors
    elif [ -r /etc/DIR_COLORS ]; then
        DIRCOLORS=/etc/DIR_COLORS
    fi
    eval "$(dircolors -b $DIRCOLORS)"
    unset DIRCOLORS

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

