# Installing LeksiOS

LeksiOS isn't installed directly from an installer image today. Instead, install a standard Fedora Atomic desktop first, then switch that system to the LeksiOS container image.

> [!WARNING]
> LeksiOS is experimental and does not yet ship a complete desktop environment. Do not do this on hardware you depend on until the image has been tested.

## 1. Install a Fedora Atomic desktop

Download and install any Fedora Atomic desktop edition (e.g. [Fedora Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/), [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/), or another edition close to what LeksiOS is based on) using the normal Fedora installer. Follow the [official Fedora installation guide](https://docs.fedoraproject.org/en-US/fedora/latest/install-guide/) for that edition.

## 2. Switch to the LeksiOS image

Once you're booted into the Fedora Atomic system, follow the [rebasing guide](./rebasing.md) to switch it to `ghcr.io/a-leksi1/leksi-os:latest` with `bootc switch` or `rpm-ostree rebase`.

## Next steps

- See the [rebasing guide](./rebasing.md) for the switch/rebase commands and how to roll back.
- See the main [README](../README.md) for how to update an installed LeksiOS system afterwards with `bootc upgrade`.
