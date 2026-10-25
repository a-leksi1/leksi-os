# Rebasing to LeksiOS

Switch an existing Fedora Atomic desktop (Silverblue, Kinoite, …) to LeksiOS. Your files, Flatpaks and settings are kept. Layered packages are removed.

```bash
# 1. Switch
sudo rpm-ostree reset
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/a-leksi1/leksi-os:latest
systemctl reboot

# 2. Turn on signature checks
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/a-leksi1/leksi-os:latest
systemctl reboot
```

**Update:** `sudo bootc upgrade`, then reboot (or use GNOME Software).

**Roll back:** pick the previous entry in the boot menu.
