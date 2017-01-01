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
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm*|screen*) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /opt/local/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    # only show last 3 directories in path
    PROMPT_DIRTRIM=3

    black=`tput setaf 0`
    red=`tput setaf 1`
    green=`tput setaf 2`
    yellow=`tput setaf 3`
    blue=`tput setaf 4`
    magenta=`tput setaf 5`
    cyan=`tput setaf 6`
    white=`tput setaf 7`
    bold=`tput bold`
    reset=`tput sgr0`

    git_status_number() {
        if [ $1 -eq 0 ]; then
            local $result=''
        else
            local $result="\[$2\]$3$num_changed"
        fi
        eval $1=$result
    }

    prompt_callback() {
        local exitcode=$?
        if [ $exitcode -eq 0 ]; then
            local exitstr="\[$green\]✔ "
        elif [ $exitcode -gt 128 ]; then
            local signal=`kill -l $(($exitcode - 128))`
            local exitstr="\[$red\]✘-$signal "
            unset signal
        else
            local exitstr="\[$red\]✘-$exitcode "
        fi
        unset exitcode

        # re-implement PROMPT_DIRTRIM trimming
        local wdlong=${PWD/$HOME/\~}
        local wd=`echo $wdlong \
            | sed -e "s/.*\(\(\/.*\)\{$PROMPT_DIRTRIM\}\)/\1/"`

        if [ "${wdlong:0:1}" = '~' ]; then
            wd="~/...$wd";
        else
            wd="...$wd";
        fi
        if [ ${#wd} -ge ${#wdlong} ]; then
            wd=$wdlong
        fi

        local status="$USER@$HOSTNAME `date +%H:%M:%S`"
        local linelen=$((COLUMNS - ${#status} - ${#wd}))
        if [ $linelen -lt 1 ]; then
            # tty not wide enough, show abbreviated single-line prompt
            PS1="\[$bold$cyan\]$wd $exitstr\[$cyan\]\$\[$reset\] "
        else
            # create padding line
            local line
            printf -v line %${linelen}s
            line=${line// /─}
            local statusline="\[$bold$cyan\]$wd\[$black\]$line$status\[$reset\]"
            PS1="\r$statusline\n$exitstr\[$cyan\]\$\[$reset\] "
        fi
    }

    PROMPT_COMMAND=prompt_callback
else
    PS1='\u@\h:\w \$ '
fi
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

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

