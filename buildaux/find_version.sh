#!/bin/bash
#

function set_poetry_version() {
  if [[ "$1" == "master" || -z "$1" ]]; then
    local poetry_version=""
  else
    local poetry_version="--version $1"
  fi
  #  local poetry_version="1"
  echo "$poetry_version"
}

set_poetry_version $1
