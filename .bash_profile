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

# Allow less, man, etc. to output certain control sequences.
export LESS="--RAW-CONTROL-CHARS"

export EDITOR='nvim'

if [ -f ~/.bash_profile.local.sh ] ; then
    # local configuration
    source ~/.bash_profile.local.sh
fi

