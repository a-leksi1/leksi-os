#!/bin/bash

# Runs every step in scripts/build.d in order. Each step is a standalone
# script; the number prefix sets the order and the name says what it does.

set -ouex pipefail

for step in /ctx/scripts/build.d/*.sh; do
    echo "=== $(basename "$step")"
    bash "$step"
done
