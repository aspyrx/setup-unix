# set PATH so it includes MacPorts executable paths
if [ -d "/opt/local/bin" ] && [ -d "/opt/local/sbin" ] ; then
    PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi

# set PATH so it includes MacPorts coreutils overrides
if [ -d "/opt/local/libexec/gnubin" ] ; then
    PATH="/opt/local/libexec/gnubin:$PATH"
fi

# set PATH so it includes Python 3.6 binaries
if [ -d "/Library/Frameworks/Python.framework/Versions/3.6/bin" ] ; then
    PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
fi

