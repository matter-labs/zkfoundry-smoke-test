#!/usr/bin/env bash

set -o pipefail

function cleanup() {
  rm -rf "./foundry-zksync"
}

function success() {  
  echo ''
  echo '================================='
  echo -e "\e[32m> [SUCCESS]\e[0m"
  echo '================================='
  echo ''
  cleanup
  exit 0
}

function fail() {
  cat run.log
  echo ''
  echo '=================================='
  echo -e "\e[31m> [FAILURE]\e[0m ${1}"
  echo '=================================='
  echo ''
  cleanup
  exit 1
}

function build_zkforge() {
  cd "${1}"
  cargo build 
  cd ..
}

echo "Repository: ${TEST_REPO}"
echo "Directory: ${TEST_REPO_DIR}"

# Prepare repositories and exit on failure
set -e
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

# Sometimes the binary takes time to be created/renamed
# Run tests and do not exit on failure
sleep 2 && echo -e "\nRunning tests..."
set +e

# [1] Check test suite passed
RUST_LOG=debug "./foundry-zksync/target/debug/zkforge" test &>run.log || fail "\`zkforge test\` failed"

# [2] Check console logs are printed in era-test-node
grep '\[INT-TEST\] PASS' run.log &>/dev/null || fail "\`zkforge test\` console output failed"

success
