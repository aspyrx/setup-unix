#!/bin/bash
#
# Implements some nice color prompt features, including git status.
#

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
_brightblack=`tput setaf 8`
_brightred=`tput setaf 9`
_brightblue=`tput setaf 12`
_bg_brightred=`tput setab 9`
_bold=`tput bold`
_reset=`tput sgr0`

_prompt_git_status_prefix_branch="\[$_magenta\]"
_prompt_git_status_prefix_changed="\[$_brightblue\]✚"
_prompt_git_status_prefix_conflicts="\[$_red\]✘"
_prompt_git_status_prefix_untracked="\[$_cyan\]…"
_prompt_git_status_prefix_staged="\[$_yellow\]●"
_prompt_git_status_prefix_stashed="\[$_magenta\]■"
_prompt_git_status_prefix_ahead="\[$_white\]↑"
_prompt_git_status_prefix_behind="\[$_white\]↓"
_prompt_git_status_clean="\[$_green\]✔"

_prompt_git_status_prefix() {
    local stat prefix="_prompt_git_status_prefix_$1"
    eval stat="\$$1"

    if [ "$stat" == "0" ]; then
        eval $1=''
    else
        eval $1="\${$prefix}$stat"
    fi
}

prompt_callback() {
    local exitcode=$?
    if [ $exitcode -eq 0 ]; then
        local exitstr="\[$_brightblack\]\[$_green\] \$\[$_reset\] "
    else
        if [ 128 -lt $exitcode ] && [ $exitcode -lt 192 ]; then
            exitcode=`kill -l $(($exitcode - 128))`
        fi
        local exitstr="\[$_black$_bg_brightred\]\[$_black\] $exitcode \[$_reset$_brightred\] \$\[$_reset\] "
    fi
    unset exitcode

    # re-implement PROMPT_DIRTRIM trimming
    local wdlong=${PWD/$HOME/\~}
    local wd=`echo $wdlong \
        | sed -e "s/.*\(\(\/.*\)\{$PROMPT_DIRTRIM\}\)/\1/"`


    if [ -d '.git' ]; then
        local gitdir='.git'
    else
        local gitdir=`git rev-parse --git-dir 2>/dev/null`
        [ $? -ne 0 ] && unset $gitdir
    fi

    # inspired by https://github.com/magicmonty/bash-git-prompt/blob/master/gitstatus.sh
    if [ -n "$gitdir" ]; then
        # Determine git status
        local line statx staty branch upstream
        local changed=0 conflicts=0 untracked=0 staged=0 stashed=0
        while IFS='' read line; do
            statx=${line:0:1}
            staty=${line:1:1}
            while [ -n "$statx$staty" ]; do
                case "$statx$staty" in
                    #two fixed character matches, loop finished
                    '##')
                        branch="${line#### }"
                        case "$branch" in
                            *...*) upstream="${branch##*...}";;
                            *) upstream='';;
                        esac
                        branch="${branch%%...*}"
                        break ;;
                    \?\?) ((untracked++)); break ;;
                    U?) ((conflicts++)); break ;;
                    ?U) ((conflicts++)); break ;;
                    DD) ((conflicts++)); break ;;
                    AA) ((conflicts++)); break ;;
                    #two character matches, first loop
                    ?M) ((changed++)); ;;
                    ?D) ((changed++)); ;;
                    ?\ ) ;;
                    #single character matches, second loop
                    U) ((conflicts++)); unset statx ;;
                    \ ) unset statx ;;
                    *) ((staged++)); unset statx ;;
                esac
                unset staty
            done
        done < <(LC_ALL=C git status --porcelain --branch --untracked-files=normal)
        unset line

        local stashfile="$gitdir/logs/refs/stash" wcline
        if [ -e $stashfile ]; then
            while IFS='' read -r wcline || [ -n "$wcline" ]; do
                ((stashed++))
            done < $stashfile
        fi
        unset stashfile wcline

        local ahead=0 behind=0

        if [[ $branch == *'Initial commit on'* ]]; then
            local fields
            IFS=" " read -ra fields <<< "$branch"
            branch="${fields[3]}"
            remote="L"
            unset fields
        elif [[ $branch == *'no branch'* ]]; then
            local tag=`git describe --tags --exact-match 2>/dev/null`
            if [ -n "$tag" ]; then
                branch="$tag"
            else
                branch=":`git rev-parse --short HEAD`"
            fi
            unset tag
        else
            if [ -z "$upstream" ]; then
                remote="L"
            else
                local remote_fields remote_field
                IFS="[,]" read -ra remote_fields <<< "$upstream"
                for remote_field in "${remote_fields[@]}"; do
                    if [[ $remote_field == *'ahead'* ]]; then
                        ahead=${remote_field:6}
                    fi
                    if [[ $remote_field == *'behind'* ]]; then
                        behind=${remote_field:7}
                        behind=${behind# }
                    fi
                done
                _prompt_git_status_prefix ahead
                _prompt_git_status_prefix behind
                remote="$ahead$behind"
                unset remote_fields remote_field
            fi
        fi

        remote="\[$_reset\]$remote"

        _prompt_git_status_prefix branch

        local dirty=$((changed + conflicts + untracked + staged + stashed))
        local gitstatus
        if [ $dirty -gt 0 ]; then
            _prompt_git_status_prefix changed
            _prompt_git_status_prefix conflicts
            _prompt_git_status_prefix untracked
            _prompt_git_status_prefix staged
            _prompt_git_status_prefix stashed
            printf -v gitstatus "%s%s %s%s%s%s%s" \
                "$branch" "$remote" \
                "$changed" "$conflicts" "$untracked" "$staged" "$stashed"
        else
            gitstatus="$branch$remote $_prompt_git_status_clean"
        fi

        gitstatus="\[$_reset$_brightblack\]\[$_white\] $gitstatus "
        unset branch dirty
        unset changed conflicts untracked staged stashed
    fi

    if [ "${wdlong:0:1}" == '~' ]; then
        wd="~/...$wd";
    else
        wd="...$wd";
    fi
    [ ${#wd} -ge ${#wdlong} ] && wd=$wdlong

    local title="\[\e]2;$USER@$HOSTNAME:$wd\a\]"
    local statusline="\[$_cyan$_bold\]$wd \[$_reset\]"
    PS1="$title\[\r\]$statusline$gitstatus$exitstr"
}

PROMPT_COMMAND=prompt_callback
