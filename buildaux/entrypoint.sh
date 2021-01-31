#!/bin/bash
# Docker entrypoint script
# Handles the declaration of ssh keys, repository clone and project execution.

function materialize_ssh() {
  echo "$SSH_PRV" >$HOME/.ssh/ssh_key &&
    echo "$SSH_PUB" >$HOME/.ssh/ssh_key.pub &&
    chmod 600 $HOME/.ssh/ssh_key &&
    chmod 600 $HOME/.ssh/ssh_key.pub &&
    ssh-add $HOME/.ssh/ssh_key
}

function exec() {
  git clone $1 && cd $(basename "$1" .git) && poetry install && poetry run ${@:2}
}

function entrypoint() {
  eval $(ssh-agent -s)
  if [[ -n "$SSH_PRV" && -n "$SSH_PRV" ]]; then
    materialize_ssh
  fi
  grep -slR "PRIVATE" $HOME/.ssh/ | xargs ssh-add
  exec $@
}

entrypoint $@
