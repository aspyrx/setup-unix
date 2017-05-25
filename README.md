# setup-unix
My standard setup on UNIX-like systems.

### Installation

####  macOS-specific instructions

1. Skip this section if you are not running macOS.
2. Install [MacPorts](https://www.macports.org/install.php). Other macOS
   package managers work too, but I use MacPorts.
3. Install the `coreutils`, `tmux`, and `tmux-pasteboard` ports:
   `sudo port install coreutils tmux tmux-pasteboard`

#### 0. Preparation

1. Install [Neovim](https://github.com/neovim/neovim/wiki/Installing-Neovim).
2. Install [Python 3](https://www.python.org/downloads/).
    - Your package manager may have a relevant package.
3. Install the `neovim` pip package: `pip3 install neovim`.

#### II. General instructions

1. Clone the repo and move the files into your home directory.
2. **IMPORTANT** Modify all the following files with your own name/email:
    - In `.gitconfig`:
        - `name` and `email` should have your own name and email.
3. Get the submodules (this may take a while):
   `git submodule update --init --recursive`
4. Restart your shell.
5. Install the desired version of Node.js: `n <node version>`
6. Update npm: `npm install -g npm`
7. Install "global" npm modules: `npm_g install`
    - See [.npm_global](https://github.com/aspyrx/.npm_global) for more details
8. Restart your shell.

That's it!

