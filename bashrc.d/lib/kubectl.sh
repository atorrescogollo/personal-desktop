#!/usr/bin/env bash

command -v kustomize &> /dev/null \
  && source <(kustomize completion bash)

command -v kind &> /dev/null \
  && source <(kind completion bash)

command -v kubectl &> /dev/null \
  && alias k=kubectl \
  && complete -F __start_kubectl k
