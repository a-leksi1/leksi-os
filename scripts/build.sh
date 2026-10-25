#!/bin/bash

set -ouex pipefail

### Third-party repos (only used during the build, removed at the end)

cp /ctx/files/yum.repos.d/*.repo /etc/yum.repos.d/

### /opt handling

# On ostree systems /opt is a symlink to /var/opt, and bootc never updates
# /var after the first install. Install into a real /opt, then move it under
# /usr/lib/opt (part of the image) the same way rpm-ostree does for layering.
rm /opt
mkdir /opt

### Install packages

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

### Move /opt content into the image

mkdir -p /usr/lib/opt
for dir in /opt/*; do
    name=$(basename "$dir")
    mv "$dir" "/usr/lib/opt/$name"
    echo "L+ /var/opt/$name - - - - /usr/lib/opt/$name" >> /usr/lib/tmpfiles.d/leksi-opt.conf
done
rmdir /opt
ln -s var/opt /opt

### Image signature verification

# Updates of ghcr.io/a-leksi1/leksi-os must be signed with cosign.key
# (checked when the system follows ostree-image-signed:docker://...)
install -Dm644 /ctx/cosign.pub /etc/pki/containers/leksi-os.pub
cp /ctx/files/registries.d/leksi-os.yaml /etc/containers/registries.d/
jq '.transports.docker["ghcr.io/a-leksi1/leksi-os"] = [{
        "type": "sigstoreSigned",
        "keyPath": "/etc/pki/containers/leksi-os.pub",
        "signedIdentity": {"type": "matchRepository"}
    }]' /etc/containers/policy.json > /tmp/policy.json
mv /tmp/policy.json /etc/containers/policy.json

### Clean up

rm -f /etc/yum.repos.d/{google-chrome,lens,microsoft-edge,vscode}.repo

# Chrome and Edge ship daily cron jobs that re-add their repo files
rm -f /etc/cron.daily/{google-chrome,microsoft-edge}

dnf5 clean all
rm -rf /var/log/dnf5.log* /var/cache/libdnf5 /run/dnf

# These are runtime-regenerated caches, safe to drop at build time
rm -rf /var/cache/libX11 /var/cache/swcatalog /var/cache/ldconfig/aux-cache
rm -rf /var/lib/dnf/repos

#### Example for enabling a System Unit File

# systemctl enable podman.socket
