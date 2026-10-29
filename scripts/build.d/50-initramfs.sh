#!/bin/bash

# Rebuild the initramfs so it picks up what the packages above added
# (the nouveau blacklist from the NVIDIA driver).

set -ouex pipefail

KERNEL=$(ls /usr/lib/modules)

dracut --no-hostonly --kver "$KERNEL" --reproducible --zstd -v --add ostree \
    -f "/usr/lib/modules/$KERNEL/initramfs.img"
chmod 0600 "/usr/lib/modules/$KERNEL/initramfs.img"
