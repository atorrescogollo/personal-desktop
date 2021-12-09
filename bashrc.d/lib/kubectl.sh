#!/usr/bin/env bash

source <(kustomize completion bash)
source <(kind completion bash)
alias k=kubectl
complete -F __start_kubectl k
