#!/usr/bin/env bash

set -e


export ROOT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.."
cd "$ROOT_DIR"

[ "$(id -u)" -eq 0 ] && echo >&2 "ERR: Running as root is not allowed" && exit 1

function PrepareRepo(){
    cat << EOF

=========================
 Downloading submodules
=========================
EOF
    cd ~/git/atorrescogollo/personal-desktop
    git submodule update --init
    cd "$ROOT_DIR"
}

function InstallPkgs(){
    cat << EOF

=========================
     Apt upgrading
=========================
EOF
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get dist-upgrade -y

    cat << EOF

=========================
  Apt install basics
=========================
EOF
    sudo apt-get install -y \
        tmux \
        vim \
        build-essential
}

function InstallConfigs(){
    cat << EOF

=========================
  Installing bashrc
=========================
EOF
    [ -L ~/.bashrc.d ] || ln -sf ~/git/atorrescogollo/personal-desktop/bashrc.d/ ~/.bashrc.d
    (
      set -x
      ls -la --color=auto ~/.bashrc.d
    )
    fgrep -q 'source ~/.bashrc.d/bashrc.sh' ~/.bashrc || {
        cat >> ~/.bashrc <<'EOF'
source ~/.bashrc.d/bashrc.sh
EOF
        (
          set -x
          tail -1 ~/.bashrc
        )
    }

    cat << EOF

=========================
  Configuring tmux/vim
=========================
EOF
    ln -sf ~/git/atorrescogollo/personal-desktop/.tmux.conf ~/.tmux.conf
    [ -L ~/.tmux ] \
      || ln -sf ~/git/atorrescogollo/personal-desktop/tmux  ~/.tmux
    ln -sf ~/git/atorrescogollo/personal-desktop/.vimrc     ~/.vimrc
    (
      set -x
      ls -la --color=auto ~/{.tmux.conf,.tmux,.vimrc}
    )

    cat << EOF

=========================
  Configuring git
=========================
EOF
    ln -sf ~/git/atorrescogollo/personal-desktop/git/.gitconfig ~/.gitconfig
    (
      set -x
      ls -la --color=auto ~/.gitconfig
    )
    find ~/git/atorrescogollo/personal-desktop/git/ -mindepth 2 -maxdepth 2 -name ".gitconfig" -exec dirname {} \; \
      | while read profile
        do
          profile=$(basename "$profile")
          echo
          echo "---> Profile: $profile"
          mkdir -p ~/git/$profile
          ln -sf ~/git/atorrescogollo/personal-desktop/git/$profile/.gitconfig ~/git/$profile/.gitconfig
          (
            set -x
            ls -la --color=auto ~/git/$profile/.gitconfig
          )
        done
}

function Main(){
    PrepareRepo
    InstallPkgs
    InstallConfigs
}

Main $@
