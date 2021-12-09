#!/usr/bin/env bash

set -e


export ROOT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.."
cd "$ROOT_DIR"

[ "$(id -u)" -eq 0 ] && echo >&2 "ERR: Running as root is not allowed" && exit 1

function PrepareRepo(){
    echo "[*] Downloading submodules..."
    cd ~/git/atorrescogollo/personal-desktop
    git submodule update --init
    cd "$ROOT_DIR"
}

function InstallPkgs(){
    echo "[*] Apt upgrading..."
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get dist-upgrade -y
    echo "[*] Apt install basics..."
    sudo apt-get install -y \
        tmux \
        vim \
        build-essential
}

function InstallConfigs(){
    echo "[*] Installing bashrc.d from atorrescogollo/personal-desktop..."
    ln -sf ~/git/atorrescogollo/personal-desktop/bashrc.d/ ~/bashrc.d
    grep -q '^source ~/bashrc.d/bashrc.sh$' ~/.bashrc || {
        cat >> ~/.bashrc <<'EOF'
source ~/bashrc.d/bashrc.sh
EOF
    }
    echo "[*] Installing tmux & vim configs"
    ln -sf ~/git/atorrescogollo/personal-desktop/.tmux.conf ~/.tmux.conf
    ln -sf ~/git/atorrescogollo/personal-desktop/.tmux      ~/.tmux
    ln -sf ~/git/atorrescogollo/personal-desktop/.vimrc     ~/.vimrc
}

function Main(){
    PrepareRepo
    InstallPkgs
    InstallConfigs
}

Main $@
