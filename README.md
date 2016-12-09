# setup-unix
My standard setup on UNIX-like systems.

### Installation
1. Clone the repo and move the files into your home directory.
2. **IMPORTANT** Modify all the following files with your own name/email:
    - In `.gitconfig`:
        - `name` and `email` should have your own name and email.
3. Get the submodules (this may take a while): `git submodule update --init --recursive`
4. Restart your shell.
5. Install the desired version of Node.js: `nvm install <node version>`
6. Update npm: `npm install -g npm`
7. Install "global" npm modules: `npm_g install`
    - See [.npm_global](https://github.com/aspyrx/.npm_global) for more details
8. Restart your shell.

That's it!

##### Optional steps
- [Build Neovim from source](https://github.com/neovim/neovim/wiki/Building-Neovim)

