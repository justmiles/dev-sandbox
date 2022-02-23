#!/bin/bash

# load custom entrypoints
function _entrypoint_hooks() {
  for f in $(ls $1/*.sh); do
    source $f
    if [ "$?" -gt "0" ]; then
      echo "Problem loading $f" && exit 1
    fi
  done
}

[ ! -z ENTRYPOINT_HOOKS ] && _entrypoint_hooks $ENTRYPOINT_HOOKS

dumb-init /usr/local/code-server/bin/code-server
