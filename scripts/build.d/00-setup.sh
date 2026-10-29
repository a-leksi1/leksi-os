#!/bin/bash

# Prepare the filesystem before any package is installed.

set -ouex pipefail

# On Fedora bootc images /opt is a symlink to /var/opt, and /var is user
# state that bootc never updates after the first install. Packages that
# install into /opt (Chrome, Edge, Lens) would lose their files on deploy.
# Make /opt a real, read-only directory that is part of the image instead.
rm /opt
mkdir /opt

# Static files, laid out as in the root filesystem: kernel arguments,
# signing policy, MOK certificate, and the third-party repos used by the
# package steps (those repos are removed again in 90-cleanup.sh).
cp -a /ctx/system_files/. /
