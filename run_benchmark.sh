#!/bin/bash

set -e

ITER=3

run_with_repeat() {
  local bin="$1"
  echo "=== Running $bin ==="
  for i in $(seq 1 $ITER); do
    $bin
  done
  echo
}

run_with_repeat "build_baseline/app"
run_with_repeat "build_pgo/app"
run_with_repeat "build_lto/app"
run_with_repeat "build_lto_pgo/app"
