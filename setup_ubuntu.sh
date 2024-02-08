#!/bin/bash

set -eu

sudo apt-get update
sudo apt-get install -y unzip

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "${SCRIPT_DIR}"

export PATH=${HOME}/.local/bin:${HOME}/.local/npm/bin:${HOME}/.cargo/bin:${PATH}

# setup dotfiles
# TODO: use symlinks instead?
rsync -avh dotfiles/ ${HOME}/
echo "source .config/bash/config.sh" >> ${HOME}/.bash_aliases

# setup exa
mkdir exa
curl -L "https://github.com/ogham/exa/releases/download/v0.10.0/exa-linux-x86_64-v0.10.0.zip" -o exa/exa.zip

pushd exa

unzip exa.zip

mkdir -p ~/.local/bin
cp bin/exa ~/.local/bin/

mkdir -p ~/.local/share/bash-completion/completions
cp completions/exa.bash ~/.local/share/bash-completion/completions/exa

mkdir -p ~/.local/share/man/man{1,5}
cp man/exa.1 ~/.local/share/man/man1/
cp man/exa_colors.5 ~/.local/share/man/man5/

popd
rm -rf exa

# setup fzf
if ! [ -e ~/.fzf ]
then
    git clone --depth 1 "https://github.com/junegunn/fzf.git" ~/.fzf
    ~/.fzf/install --xdg --key-bindings --completion --no-update-rc --no-zsh --no-fish
fi

# setup zoxide
curl -sS "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh" | bash

# setup lazygit
mkdir -p ${HOME}/.local/bin
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -L "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" | tar -xzf - -C ${HOME}/.local/bin

# setup helix editor
sudo add-apt-repository -y ppa:maveonair/helix-editor
sudo apt-get update
sudo apt-get install -y helix
hx --grammar fetch || true
hx --grammar build || true

# setup zellij
mkdir -p ${HOME}/.local/bin
curl -L "https://github.com/zellij-org/zellij/releases/download/v0.39.2/zellij-x86_64-unknown-linux-musl.tar.gz" | tar -xzf - -C ${HOME}/.local/bin
mkdir -p ${HOME}/.config/zellij/plugins
curl -L "https://github.com/imsnif/monocle/releases/latest/download/monocle.wasm" -o ${HOME}/.config/zellij/plugins/monocle.wasm

# setup misc tools
sudo apt-get install -y jq moreutils ripgrep

# setup powerline
mkdir -p ${HOME}/.local/bin
curl -L "https://github.com/justjanne/powerline-go/releases/download/v1.24/powerline-go-linux-amd64" -o ${HOME}/.local/bin/powerline-go
chmod +x ${HOME}/.local/bin/powerline-go

curl -L "https://github.com/dandavison/delta/releases/download/0.16.5/git-delta-musl_0.16.5_amd64.deb" -o git-delta.deb
sudo apt-get install -y ./git-delta.deb
rm  git-delta.deb
echo '#!/bin/sh' > ${HOME}/.local/bin/delta-pager
echo 'sed "s/\t/→   /g" | less -R' >> ${HOME}/.local/bin/delta-pager
chmod +x ${HOME}/.local/bin/delta-pager

# install alacritty (only native linux, not WSL)
if ! [ -e /proc/sys/fs/binfmt_misc/WSLInterop ]
then
    curl --proto '=https' --tlsv1.2 -sSf "https://sh.rustup.rs" | sh
    sudo apt-get install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
    cargo install alacritty
fi

# install language servers
curl -fsSL "https://deb.nodesource.com/setup_21.x" | sudo -E bash -
sudo apt-get install -y nodejs python3-pip

sudo apt install -y lldb-15
cd $(dirname $(which lldb-vscode-15))
sudo ln -sf lldb-vscode-15 lldb-vscode

npm i -g bash-language-server

npm i -g dockerfile-language-server-nodejs

npm i -g @taplo/cli

sudo apt-get install -y clangd

pip install python-language-server

pip install cmake-language-server

# fixed version of oelint-parser required by bitbake-language-server
pip install oelint-parser==2.13.12 bitbake-language-server

curl -L "https://github.com/artempyanykh/marksman/releases/download/2023-12-09/marksman-linux-x64" -o ${HOME}/.local/bin/marksman
chmod +x ${HOME}/.local/bin/marksman

echo "Setup Complete"
echo "Open a new shell to reload environment"
