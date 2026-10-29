#!/bin/bash

# /var/cache, /var/log and /tmp are build mounts (see the Containerfile) and
# never end up in the image, so only the rest needs cleaning here.

set -ouex pipefail

# Third-party repos are build-only: the system updates through the image
for repo in /ctx/system_files/etc/yum.repos.d/*.repo; do
    rm -f "/etc/yum.repos.d/$(basename "$repo")"
done

# Chrome and Edge ship daily cron jobs that re-add their repo files
rm -f /etc/cron.daily/{google-chrome,microsoft-edge}

# dnf state
rm -rf /run/dnf /var/lib/dnf/repos

# Left behind by semodule and dracut
rm -rf /run/selinux-policy /var/lib/xkb
