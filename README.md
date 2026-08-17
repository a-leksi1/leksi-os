# LeksiOS

An experimental desktop operating system image built as an [OCI container image](https://containers.github.io/bootc/) with Fedora `bootc`.

LeksiOS is intended to provide an immutable, updateable Linux desktop. The operating system is built from a versioned container image and installed or updated with `bootc`, rather than assembled as a traditional package-based installation.

> [!WARNING]
> This project is under active development. The current `Containerfile` is only a Fedora bootc base image and does not yet install a complete desktop environment. Do not install it on important hardware until the image and hardware support have been tested.

## Current image

The current image is based on:

```text
quay.io/fedora/fedora-bootc:44
```

The GitHub Actions workflow builds and publishes:

```text
ghcr.io/a-leksi1/leksi-os:latest
```

The `latest` tag is convenient for testing, but a digest or release tag should be preferred for reproducible installations once releases are available.

## Repository layout

```text
.
├── Containerfile            # Base image and image build instructions
├── packages/                # Package lists or package-install snippets
├── scripts/                 # Build and maintenance utilities
│   └── build.sh             # Local customization hook
├── services/                # Custom systemd units and service configuration
├── system/                  # Files installed into the image filesystem
│   ├── etc/                 # System configuration
│   ├── usr/                 # System-wide files and applications
│   └── ...
├── guides/                  # User and contributor documentation
├── cosign.pub               # Public key for image-signature verification
└── .github/workflows/       # Automated image builds and publishing
```

The directories are extension points even when they are empty today:

- **`packages/`** contains the desktop, firmware, driver, codec, and utility packages that are layered into the image. Keep package changes explicit and reviewable.
- **`scripts/`** contains repeatable build actions. `build.sh` is the place for package installation, repository setup, cleanup, and systemd enablement that must happen during the image build.
- **`services/`** contains custom systemd unit files and related service configuration. Units should be copied into the image and enabled from the build script when appropriate.
- **`system/`** mirrors paths inside the final operating system. For example, `system/etc/...` is installed below `/etc` and `system/usr/...` below `/usr`.
- **`guides/`** contains more detailed operator and contributor documentation as the project grows.

## Build locally

### Requirements

Install the following on a Fedora, Debian, or Ubuntu development host:

- Podman
- `bootc` (needed for installation and inspection)
- Git
- A Linux environment with enough disk space for container layers and the test VM

Build the image from the repository root:

```bash
podman build -t localhost/leksi-os:dev .
```

Check the image metadata:

```bash
podman image inspect localhost/leksi-os:dev
```

Run the image as a container for basic inspection. This does not boot it as an operating system:

```bash
podman run --rm -it --privileged localhost/leksi-os:dev bash
```

For a realistic test, export the image to a local registry or use it with a disposable virtual machine. Always test image changes in a VM before writing them to physical storage.

## Install the image

`bootc install to-disk` writes an operating system to a disk. It can erase the selected target, so verify the target device carefully before running the command and keep backups of any data on it.

### Install from the published registry image

Boot a Fedora live environment or another supported Linux environment with Podman and `bootc` available. Replace `/dev/sdX` with the actual target disk, not a partition such as `/dev/sdX1`:

```bash
sudo bootc install to-disk \
	--source-img ghcr.io/a-leksi1/leksi-os:latest \
	/dev/sdX
```

Reboot after the installation completes, remove the live USB, and select the new disk in the firmware boot menu if necessary.

### Install a locally built image

Make the image available to the installation environment. For example, push it to a registry reachable by the live environment, then use that registry reference:

```bash
podman tag localhost/leksi-os:dev registry.example.com/leksi-os:dev
podman push registry.example.com/leksi-os:dev

sudo bootc install to-disk \
	--source-img registry.example.com/leksi-os:dev \
	/dev/sdX
```

Registry authentication, storage layout, bootloader options, and filesystem choices vary by host. Consult `bootc install to-disk --help` and the [bootc installation documentation](https://containers.github.io/bootc/installation/) before adapting this command.

## Update an installed system

After booting LeksiOS, configure the installed system to follow a specific image reference:

```bash
sudo bootc switch ghcr.io/a-leksi1/leksi-os:latest
```

Updates are staged as a new deployment and normally take effect after reboot:

```bash
sudo bootc upgrade
sudo reboot
```

Inspect deployments and status with:

```bash
bootc status
```

If an update does not work, select the previous deployment from the boot menu. Do not delete the previous deployment until the new one has been verified.

## Image signing

`cosign.pub` is the repository's public verification key. The private signing key must never be committed to this repository or stored in the image. Signature verification is not yet wired into the build workflow; treat the published image as experimental until signed release artifacts and a documented verification command are provided.

## Continuous integration

The workflow in `.github/workflows/build-image.yaml` currently runs on manual dispatch, builds the `Containerfile` with Podman, and pushes the `latest` image to GitHub Container Registry. Push and scheduled triggers are present as commented placeholders.

Before enabling unattended publishing, add package installation and desktop configuration, configure image signing, use immutable release tags or digests, and test the resulting image in a virtual machine.

## Credits

LeksiOS is heavily inspired by:

- [sigulete/kde-bootc](https://github.com/sigulete/kde-bootc)
- [ublue-os/image-template](https://github.com/ublue-os/image-template)

Thanks to both projects for the bootc image patterns this repository builds on.

## Contributing

1. Make a focused change in the appropriate directory.
2. Build the image locally with Podman.
3. Test it in a disposable VM or container where applicable.
4. Record user-visible behavior and migration steps in `guides/` or this README.
5. Open a pull request with the image tag or digest that was tested.

## License

No license has been selected for this project yet.
