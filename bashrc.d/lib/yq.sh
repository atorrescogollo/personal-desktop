#!/bin/bash

command -v yq &> /dev/null \
  && source <(yq completion bash)
