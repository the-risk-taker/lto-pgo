#!/bin/bash

set -e

rm -rf build*

# *** Baseline ***
cmake -S . -B build_baseline -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++
ninja -C build_baseline

# *** LTO ***
cmake -S . -B build_lto -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++ -DENABLE_LTO=ON
ninja -C build_lto

# *** PGO ***
cmake -S . -B build_pgo -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++ -DENABLE_PGO_INSTRUMENTATION=ON
ninja -C build_pgo
ninja -C build_pgo run-pgo-instrumented
ninja -C build_pgo run-pgo-instrumented
ninja -C build_pgo run-pgo-instrumented
ninja -C build_pgo run-pgo-merge-profiles

cmake -S . -B build_pgo -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++ -DENABLE_PGO_INSTRUMENTATION=OFF -DENABLE_PGO_USE=ON
ninja -C build_pgo

# *** PGO + LTO ***
cmake -S . -B build_lto_pgo -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++ -DENABLE_LTO=ON -DENABLE_PGO_INSTRUMENTATION=ON
ninja -C build_lto_pgo
ninja -C build_lto_pgo run-pgo-instrumented
ninja -C build_lto_pgo run-pgo-instrumented
ninja -C build_lto_pgo run-pgo-instrumented
ninja -C build_lto_pgo run-pgo-merge-profiles

cmake -S . -B build_lto_pgo -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++ -DENABLE_LTO=ON -DENABLE_PGO_INSTRUMENTATION=OFF -DENABLE_PGO_USE=ON
ninja -C build_lto_pgo
