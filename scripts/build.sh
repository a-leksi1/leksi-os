#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# dnf5 install -y tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

dnf5 -y install 'dnf5-command(copr)'
dnf5 -y copr enable avengemedia/dms
dnf5 -y install niri dms
dnf5 -y copr disable avengemedia/dms

systemctl --global add-wants niri.service dms.service

### Graphical login screen (dms-greeter on greetd), launching niri

dnf5 -y copr enable avengemedia/danklinux
dnf5 -y install greetd greetd-selinux dms-greeter
dnf5 -y copr disable avengemedia/danklinux

# dms-greeter's %post already wrote /etc/greetd/config.toml for niri and
# confirmed graphical.target; "dms greeter enable" refuses to run as root,
# so just enable the service it would have enabled.
systemctl enable greetd.service

# niri/dms-greeter use libseat for session/TTY handling; only the seatd
# backend is compiled into Fedora's libseat, so without a running seatd the
# greeter panics with "Failed to open session: Function not implemented".
dnf5 -y install seatd
systemctl enable seatd.service
usermod -aG seat greeter

### Clean up dnf cache/logs so they don't bloat the image (see lint warnings)

dnf5 clean all
rm -rf /var/log/dnf5.log /var/log/dnf5.log.1 /var/cache/libdnf5 /run/dnf

# These are runtime-regenerated caches, safe to drop at build time
rm -rf /var/cache/libX11 /var/cache/swcatalog /var/cache/ldconfig/aux-cache
rm -f /var/lib/dnf/repos/*/countme

#### Example for enabling a System Unit File

# systemctl enable podman.socket

### Enable the MT7925 Wi-Fi retry service (script/unit installed from system/)

# systemctl enable mt7925-retry.service