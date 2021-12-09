#!/usr/bin/env bash

# Load libs
for f in $( find ~/.bashrc.d/lib -type f ); do source "$i"; done

# Custom CLI line
export PS1="[$LIST_BLUE\$(date +'%H:%M:%S')] $WHITE\u@\h$NO_COLOR: $LIGHT_BLUE\w$YELLOW\$(parse_git_branch)$NO_COLOR \$ "
