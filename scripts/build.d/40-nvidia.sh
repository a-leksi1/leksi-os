#!/bin/bash

# NVIDIA driver: prebuilt kernel module signed by Universal Blue, plus the
# matching userspace driver, from ghcr.io/ublue-os/akmods-nvidia-open (same
# steps as ublue's nvidia-install.sh, without 32-bit libs and supergfxctl).
# The matching public key is shipped in system_files (etc/pki/akmods/certs)
# and must be enrolled in the firmware (MOK) for Secure Boot.

set -ouex pipefail

AKMODS=/ctx/akmods-nvidia
source "$AKMODS/kmods/nvidia-vars"

KERNEL=$(ls /usr/lib/modules)
if [ "$KERNEL" != "$KERNEL_VERSION" ]; then
    echo "NVIDIA module is built for $KERNEL_VERSION but the image kernel is $KERNEL"
    exit 1
fi

dnf5 install -y "$AKMODS"/ublue-os/ublue-os-nvidia-addons-*.rpm
dnf5 install -y --enablerepo=fedora-nvidia --enablerepo=nvidia-container-toolkit \
    "$AKMODS"/nvidia/*.x86_64.rpm \
    "$AKMODS"/nvidia/*.noarch.rpm \
    "$AKMODS/kmods/kmod-nvidia-$KERNEL_VERSION-$NVIDIA_AKMOD_VERSION.$DIST_ARCH.rpm" \
    egl-wayland \
    libva-nvidia-driver \
    nvidia-container-toolkit

KMOD_VERSION=$(rpm -q --queryformat '%{VERSION}' kmod-nvidia)
DRIVER_VERSION=$(rpm -q --queryformat '%{VERSION}' nvidia-driver)
if [ "$KMOD_VERSION" != "$DRIVER_VERSION" ]; then
    echo "kmod-nvidia ($KMOD_VERSION) does not match nvidia-driver ($DRIVER_VERSION)"
    exit 1
fi

# Hide the driver from GNOME Software, which would offer to "enable" it
# with its own akmods key (the driver is already part of the image)
rm -f /usr/share/metainfo/com.nvidia.driver.metainfo.xml

# GPU access from Podman containers
systemctl enable nvidia-cdi-refresh.path nvidia-cdi-refresh.service
semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp
