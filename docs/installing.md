# Installing LeksiOS from the ISO

> [!CAUTION]
> The installer is automatic and **erases every disk** in the computer. Back up first.

```bash
# 1. Build the ISO
sudo podman pull ghcr.io/a-leksi1/leksi-os:latest
make iso IMAGE=ghcr.io/a-leksi1/leksi-os:latest
```

2. Write `disk-images/bootiso/install.iso` to a USB stick with Fedora Media Writer.
3. Boot the computer from the USB stick. The install runs and reboots on its own.
4. Create your account in GNOME's welcome screen.

```bash
# 5. Turn on signature checks
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/a-leksi1/leksi-os:latest
systemctl reboot
```

**Update:** `sudo bootc upgrade`, then reboot (or use GNOME Software).
