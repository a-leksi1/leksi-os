#!/bin/bash

set -ouex pipefail

# Dev tools (Fedora repos)
dnf5 install -y \
    cmake \
    gcc \
    gcc-c++ \
    make \
    podman-compose

# Apps (third-party repos)
dnf5 install -y \
    code \
    google-chrome-stable \
    lens \
    microsoft-edge-stable
