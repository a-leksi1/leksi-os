# Rebasing to LeksiOS

If you already run a Fedora Atomic desktop (Silverblue, Kinoite, Sericea, ublue-based images, etc.) or another `bootc`/`rpm-ostree` system, you can switch to LeksiOS in place instead of reinstalling from scratch.

> [!WARNING]
> Rebasing changes the operating system image your machine boots. LeksiOS is experimental and does not yet ship a complete desktop environment — expect a minimal system after rebasing, and keep a way back (see [Rolling back](#rolling-back) below) until you've verified it boots correctly.

## Which command do I use?

- If your current system was installed with `bootc install` (already a `bootc`-native image), use `bootc switch`.
- If your current system is a traditional `rpm-ostree` based Fedora Atomic desktop (Silverblue, Kinoite, ...), use `rpm-ostree rebase` with the container image reference. Fedora's `rpm-ostree` supports rebasing directly onto OCI/`bootc` images.

Check which you're on:

```bash
bootc status || rpm-ostree status
```

## Option A: `bootc switch`

If `bootc status` succeeds and shows a deployment, your system is already `bootc`-managed:

```bash
sudo bootc switch ghcr.io/a-leksi1/leksi-os:latest
```

Then apply the update:

```bash
sudo bootc upgrade
sudo reboot
```

## Option B: `rpm-ostree rebase` (Silverblue, Kinoite, and similar)

On a traditional Fedora Atomic desktop, rebase onto the LeksiOS container image:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/a-leksi1/leksi-os:latest
sudo systemctl reboot
```

`ostree-unverified-registry:` skips signature verification, which is expected today since LeksiOS does not yet sign published images (see `cosign.pub` in the repository root). Once signed images are available, prefer a verified transport instead.

## After rebasing

Confirm the new deployment is active:

```bash
bootc status
```

or

```bash
rpm-ostree status
```

## Rolling back

Both `bootc` and `rpm-ostree` keep the previous deployment until you clean it up. If LeksiOS doesn't boot correctly or is missing something you need:

- Select the previous deployment from the boot menu (GRUB entry for the prior image), **or**
- Roll back from a booted LeksiOS/other deployment:

  ```bash
  sudo bootc rollback
  # or
  sudo rpm-ostree rollback
  ```

Do not remove the previous deployment until you've confirmed LeksiOS works as expected on your hardware.
