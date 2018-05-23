if [ -f ~/.bash_profile.local.sh ] ; then
    # local configuration
    source ~/.bash_profile.local.sh
fi

if [ `uname` = "Darwin" ] ; then
    # macOS-specific configuration
    source ~/.bash_profile.darwin.sh
fi

# set PATH so it includes custom globally-installed node modules
if [ -d "$HOME/.npm_global/node_modules/.bin" ] ; then
    PATH="$HOME/.npm_global/node_modules/.bin:$PATH"
fi

# Set up the n Node version manager
if [ -x "$HOME/.n/bin/n" ] ; then
    export N_PREFIX="$HOME/.local"
    PATH="$HOME/.n/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# If not running interactively, don't do anything else
case $- in
    *i*) ;;
      *) return;;
esac

# Source .bashrc if it exists
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# use colors for less, man, etc.
export LESS="--RAW-CONTROL-CHARS"
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # cyan
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

export EDITOR='nvim'

