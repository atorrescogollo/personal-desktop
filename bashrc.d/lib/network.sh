#!/usr/bin/env bash

function wait-for-port(){
        local HOST=$1
  local PORT=$2
  while ! nc -z -w2 $HOST $PORT; do echo -n ".";sleep 5; done
  echo
}
