#!/usr/bin/env bash

alias urlencode='python3 -c "import urllib.parse,sys;print(urllib.parse.quote_plus(sys.stdin.read()))"'
alias urldecode='python3 -c "import urllib.parse,sys;print(urllib.parse.unquote(sys.stdin.read()))"'
