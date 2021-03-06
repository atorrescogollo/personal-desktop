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
       Apt repos
=========================
EOF
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

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
        build-essential \
        python3-venv \
        xclip \
        gnome-tweak-tool \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        htop \
        tree \
        thunderbird \
        awscli \
        rclone \
        terraform \
        jq
    sudo snap install telegram-desktop
    sudo snap install slack --classic
    sudo snap install spotify
    sudo snap install dyff


    cat << EOF

==========================
Install tools from sources
==========================
EOF
    echo "- Terragrunt ..."
    local TERRAGRUNT_VERSION=$(getGithubLatestRelease "gruntwork-io/terragrunt")
    sudo curl -sL -o /usr/local/bin/terragrunt_$TERRAGRUNT_VERSION https://github.com/gruntwork-io/terragrunt/releases/download/$TERRAGRUNT_VERSION/terragrunt_linux_amd64
    sudo chmod 755 /usr/local/bin/terragrunt_$TERRAGRUNT_VERSION
    sudo ln -vsf terragrunt_$TERRAGRUNT_VERSION /usr/local/bin/terragrunt

    echo "- YQ ..."
    local YQ_VERSION=$(getGithubLatestRelease "mikefarah/yq")
    sudo curl -sL -o /usr/local/bin/yq_$YQ_VERSION https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_amd64
    sudo chmod 755 /usr/local/bin/yq_$YQ_VERSION
    sudo ln -vsf yq_$YQ_VERSION /usr/local/bin/yq

    echo "- kubectl-krew ..."
    # https://krew.sigs.k8s.io/docs/user-guide/setup/install/
    (
      set -x; cd "$(mktemp -d)" &&
      OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
    )
    ! command -v kubectl-krew &> /dev/null && export PATH="$HOME/.krew/bin:$PATH"

    echo "- kubectl-slice ..."
    # https://github.com/patrickdappollonio/kubectl-slice#using-krew
    kubectl krew install slice


    cat << EOF

================================
Ensure execution of custom-tools
================================
EOF
    find "$HOME/git/atorrescogollo/personal-desktop/custom-tools" -mindepth 1 -maxdepth 1 \
      -exec chmod -vv 755 {} \;
}

function getGithubLatestRelease(){
  local repo="$1" # E.g.: gruntwork-io/terragrunt
  curl -sL https://api.github.com/repos/$repo/releases | jq -r '.[0].name'
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


    cat << EOF

=========================
 Configuring thunderbird
=========================
EOF
    [ -L ~/.thunderbird ] \
      || ln -sf ~/git/atorrescogollo/personal-desktop/thunderbird  ~/.thunderbird

    (
      set -x
      ls -la --color=auto ~/.thunderbird
    )
}

function ConfigureGnome(){
  cat << EOF

=========================
  Configuring gnome
=========================
EOF
  (
    set -xe
    cat ~/git/atorrescogollo/personal-desktop/gnome/gnome-terminal.conf | dconf load /org/gnome/terminal/
    cat ~/git/atorrescogollo/personal-desktop/gnome/media-keys.conf     | dconf load /org/gnome/settings-daemon/plugins/media-keys/
    cat ~/git/atorrescogollo/personal-desktop/gnome/mutter.conf         | dconf load /org/gnome/mutter/
    cat ~/git/atorrescogollo/personal-desktop/gnome/background.conf     | dconf load /org/gnome/desktop/background/
    cat ~/git/atorrescogollo/personal-desktop/gnome/screensaver.conf    | dconf load /org/gnome/desktop/screensaver/
  )
}

function InstallDocker(){
  cat << EOF

=========================
  Installing Docker
=========================
EOF
  command -v docker &> /dev/null \
    && echo "Docker already installed" \
    || {
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install docker-ce docker-ce-cli containerd.io -y
      sudo usermod -aG docker $(id -un)
      (
        set -x
        grep "^docker" /etc/group
      )
    }

  command -v docker-compose &> /dev/null \
    && echo "Docker Compose already installed" \
    || {
      sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
    }
}

function InstallVSCode(){
  cat << EOF

=========================
  Installing VSCode
=========================
EOF
  command -v code &> /dev/null \
    && echo "VScode already installed" \
    || {
      wget -O /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
      sudo dpkg -i /tmp/vscode.deb
      rm /tmp/vscode.deb
    }
}


function Main(){
    PrepareRepo
    InstallPkgs
    InstallDocker
    InstallConfigs
    ConfigureGnome
    InstallVSCode
}

Main $@
