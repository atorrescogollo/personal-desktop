#!/usr/bin/env bash

function parse_git_branch () {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

alias wdiff='git diff --word-diff --word-diff-regex=.'

function diffxml(){
  if [ "$#" -ne 2 ] || [ ! -f "$1" ] || [ ! -f "$2" ]
  then
    echo >&2 "Usage: diffxml <file1> <file2>"
    return 1
  fi
  diff --color -u <(xmllint --format "$1") <(xmllint --format "$2" )
}

alias g="cd ~/git"
alias t="cd /tmp"
