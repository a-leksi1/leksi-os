# #!/bin/bash

# set -ouex pipefail

# ### Install packages

# # Packages can be installed from any enabled yum repo on the image.
# # RPMfusion repos are available by default in ublue main images
# # List of rpmfusion packages can be found here:
# # https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# # this installs a package from fedora repos
# # dnf5 install -y tmux 

# # Use a COPR Example:
# #
# # dnf5 -y copr enable ublue-os/staging
# # dnf5 -y install package
# # Disable COPRs so they don't end up enabled on the final image:
# # dnf5 -y copr disable ublue-os/staging

# ### GNOME desktop (Silverblue-like), with GDM as the login manager

# dnf5 -y install @gnome-desktop

# systemctl enable gdm.service
# systemctl set-default graphical.target

# ### Clean up dnf cache/logs so they don't bloat the image (see lint warnings)

# dnf5 clean all
# rm -rf /var/log/dnf5.log* /var/cache/libdnf5 /run/dnf

# # These are runtime-regenerated caches, safe to drop at build time
# rm -rf /var/cache/libX11 /var/cache/swcatalog /var/cache/ldconfig/aux-cache
# rm -f /var/lib/dnf/repos/*/countme

# #### Example for enabling a System Unit File

# # systemctl enable podman.socket

# ### Enable the MT7925 Wi-Fi retry service (script/unit installed from system/)

# # systemctl enable mt7925-retry.service