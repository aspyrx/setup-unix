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

    _black=`tput setaf 0`
    _red=`tput setaf 1`
    _green=`tput setaf 2`
    _yellow=`tput setaf 3`
    _blue=`tput setaf 4`
    _magenta=`tput setaf 5`
    _cyan=`tput setaf 6`
    _white=`tput setaf 7`
    _bold=`tput bold`
    _reset=`tput sgr0`

    _prompt_line_char='─'
    _prompt_git_status_prefix_branch="\[$_magenta\]"
    _prompt_git_status_prefix_changed="\[$_blue\]✚$changed"
    _prompt_git_status_prefix_conflicts="\[$_red\]✘$conflicts"
    _prompt_git_status_prefix_untracked="\[$_cyan\]…$untracked"
    _prompt_git_status_prefix_staged="\[$_yellow\]●$staged"

    _prompt_git_status_prefix() {
        local stat
        eval stat=\$$1

        if [ "$stat" == "0" ]; then
            eval $1=''
        else
            eval $1="\$_prompt_git_status_prefix_$1\$$1"
        fi
    }

    prompt_callback() {
        local exitcode=$?
        if [ $exitcode -eq 0 ]; then
            local exitstr="\[$_green\]\$\[$_reset\] "
        elif [ 128 -lt $exitcode ] && [ $exitcode -lt 255 ]; then
            local signal=`kill -l $(($exitcode - 128))`
            local exitstr="\[$_red\]$signal \$\[$_reset\] "
            unset signal
        else
            local exitstr="\[$_red\]$exitcode \$\[$_reset\] "
        fi
        unset exitcode

        # re-implement PROMPT_DIRTRIM trimming
        local wdlong=${PWD/$HOME/\~}
        local wd=`echo $wdlong \
            | sed -e "s/.*\(\(\/.*\)\{$PROMPT_DIRTRIM\}\)/\1/"`


        if [ -d '.git' ]; then
            local gitdir='.git'
        else
            local gitdir=`git rev-parse --git-dir > /dev/null 2>&1`
            [ $? -ne 0 ] && unset $gitdir
        fi

        if [ -n $gitdir ]; then
            # Determine git status
            local line statx staty branch
            local changed=0 conflicts=0 untracked=0 staged=0
            while read line; do
                statx=${line:0:1}
                staty=${line:1:1}
                while [ -n "$statx$staty" ]; do
                    case $statx$staty in
                        #two fixed character matches, loop finished
                        \#\#) branch=${line:3}; branch=${branch%%...*}; break ;;
                        \?\?) ((untracked++)); break ;;
                        U?) ((conflicts++)); break ;;
                        ?U) ((conflicts++)); break ;;
                        DD) ((conflicts++)); break ;;
                        AA) ((conflicts++)); break ;;
                        #two character matches, first loop
                        ?M) ((changed++)); unset staty ;;
                        ?D) ((changed++)); unset staty ;;
                        ?\ ) unset staty ;;
                        #single character matches, second loop
                        U) ((conflicts++)); unset statx ;;
                        \ ) unset statx ;;
                        *) ((staged++)); unset statx ;;
                    esac
                done
            done < <(LC_ALL=C git status --porcelain --branch --untracked-files=normal)

            _prompt_git_status_prefix branch
            _prompt_git_status_prefix changed
            _prompt_git_status_prefix conflicts
            _prompt_git_status_prefix untracked
            _prompt_git_status_prefix staged

            local gitstatus
            printf -v gitstatus "%s%s%s%s%s\[$reset\] " \
                $branch $changed $conflicts $untracked $staged

            unset line statx staty branch
            unset changed conflicts untracked staged
        fi

        if [ "${wdlong:0:1}" = '~' ]; then
            wd="~/...$wd";
        else
            wd="...$wd";
        fi
        [ ${#wd} -ge ${#wdlong} ] && wd=$wdlong

        local status="$USER@$HOSTNAME `date +%H:%M:%S`"
        local linelen=$((COLUMNS - ${#status} - ${#wd}))
        if [ $linelen -lt 1 ]; then
            # tty not wide enough, show abbreviated single-line prompt
            PS1="\[$_bold$_cyan\]$wd $exitstr"
        else
            # create padding line
            local line
            printf -v line %${linelen}s
            line=${line// /$_prompt_line_char}
            local statusline="\[$_bold$_cyan\]$wd\[$_black\]$line$status\[$_reset\]"
            PS1="\r$statusline\n$gitstatus$exitstr"
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

