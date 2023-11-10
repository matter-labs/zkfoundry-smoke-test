#!/usr/bin/env bash

# Fail fast and on piped commands
set -o pipefail -e

TEST_REPO=${1:-$TEST_REPO}
TEST_REPO_DIR=${2:-$TEST_REPO_DIR}
SOLC_VERSION=${SOLC_VERSION:-"v0.8.20"}
SOLC="solc-${SOLC_VERSION}"

function cleanup() {
  echo "Cleaning up..."
  rm -rf "./foundry-zksync"
  rm "./${SOLC}"
}

function success() {
  echo ''
  echo '================================='
  printf "\e[32m> [SUCCESS]\e[0m\n"
  echo '================================='
  echo ''
  cleanup
  exit 0
}

function fail() {
  echo "Displaying run.log..."
  cat run.log
  echo ''
  echo '=================================='
  printf "\e[31m> [FAILURE]\e[0m %s\n" "$1"
  echo '=================================='
  echo ''
  cleanup
  exit 1
}

function download_solc() {
  wget --quiet -O "${SOLC}" "https://github.com/ethereum/solidity/releases/download/${1}/solc-static-linux"
  chmod +x "${SOLC}"
}

function wait_for_build() {
  local timeout=$1
  while ! [ -x "./foundry-zksync/target/release/zkforge" ]; do
    ((timeout--))
    if [ $timeout -le 0 ]; then
      echo "Build timed out waiting for binary to be created."
      exit 1
    fi
    sleep 1
  done
}

# We want this to fail-fast and hence are put on separate lines
# See https://unix.stackexchange.com/questions/312631/bash-script-with-set-e-doesnt-stop-on-command
function build_zkforge() {
  echo "Building ${1}..."
  cargo build --release --manifest-path="${1}/Cargo.toml"
  wait_for_build 30
}

trap cleanup ERR

echo "Repository: ${TEST_REPO}"
echo "Directory: ${TEST_REPO_DIR}"
echo "Solc: ${SOLC_VERSION}"

# Download solc
download_solc "${SOLC_VERSION}"

# Check for necessary tools
command -v cargo &>/dev/null || {
  echo "cargo not found, exiting"
  exit 1
}
command -v git &>/dev/null || {
  echo "git not found, exiting"
  exit 1
}

# Prepare repositories and exit on failure
case "${TEST_REPO}" in

"foundry-zksync")
  build_zkforge "${TEST_REPO_DIR}"
  ;;

"era-revm")
  git clone https://github.com/matter-labs/foundry-zksync
  echo -n "
[patch.'https://github.com/matter-labs/era-revm']
era_revm = { path = \"../${TEST_REPO_DIR}\" }
" >>"foundry-zksync/Cargo.toml"
  cd "foundry-zksync" && cargo build && cd ..
  build_zkforge "foundry-zksync"
  ;;

"era-test-node")
  git clone https://github.com/matter-labs/foundry-zksync
  echo -n "
[patch.'https://github.com/matter-labs/era-test-node']
era_test_node = { path = \"../${TEST_REPO_DIR}\" }
" >>"foundry-zksync/Cargo.toml"
  build_zkforge "foundry-zksync"
  ;;

*)
  git clone https://github.com/matter-labs/foundry-zksync
  build_zkforge "foundry-zksync"
  ;;

esac

echo "Building...."
RUST_LOG=debug "./foundry-zksync/target/release/zkforge" zkbuild --use "./${SOLC}" &>run.log || fail "zkforge build failed"

echo "Running tests..."
# [1] Check test suite passed
RUST_LOG=debug "./foundry-zksync/target/release/zkforge" test --use "./${SOLC}" &>run.log || fail "zkforge test failed"
# [2] Check console logs are printed in era-test-node
grep '\[INT-TEST\] PASS' run.log &>/dev/null || fail "zkforge test console output failed"

success
