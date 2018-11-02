#!/bin/bash

VERSION_FILE="$(mktemp)"

yarn list --json --depth 0 --silent | tail -n1 | jq -r ".data.trees[].name" | sort > "${VERSION_FILE}"

fix_dependency() {
  local KEY="${1:-"dependencies"}"
  local ADD_OPTION="$2"

  for PACKAGE in $(cat package.json | jq -r ".${KEY} | keys[]"); do
    PINNED="$(grep "${PACKAGE}@" "${VERSION_FILE}")"
    if [ ! -z "${PINNED}" ]; then
      echo "${PINNED}"
      yarn add ${ADD_OPTION} "${PINNED}"
    else
      echo "[ERROR] Cannot find package for ${PACKAGE}"
    fi
  done
}

echo "* dependencies"
fix_dependency "dependencies" ""

echo "* devDependencies"
fix_dependency "devDependencies" "-D"

