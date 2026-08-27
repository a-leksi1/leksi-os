# LeksiOS agent instructions

LeksiOS is a Fedora `bootc` OCI container image (immutable desktop OS), not an application. See [README.md](../README.md) for the project overview, repository layout, and install/update workflows — don't duplicate that here.

## Architecture

- Everything is driven by the root [Containerfile](../Containerfile). It currently only does `FROM quay.io/fedora/fedora-bootc:44` + `RUN bootc container lint` — no packages or customization script are wired in yet.
- [scripts/build.sh](../scripts/build.sh) is the intended place for package installs, repo/COPR setup, and `systemctl enable` calls during the image build, but **the Containerfile does not `RUN` it yet**. If a task asks to install packages or enable a service, add/extend `scripts/build.sh` _and_ add a corresponding `RUN` (e.g. copy the script in and execute it) in the Containerfile — don't assume it's already invoked.
- [system/](../system/) mirrors the final filesystem layout exactly: `system/etc/...` installs to `/etc`, `system/usr/...` to `/usr`, etc. Files must be copied into the image from the Containerfile to take effect.
- [packages/](../packages/), [services/](../services/), [system/](../system/), and [guides/](../guides/) are intentionally empty placeholders today — adding files there is expected as the project grows, following the descriptions in the README's repository layout section.

## Build and verify

- Build the image: `podman build -t localhost/leksi-os:dev .`
- Inspect metadata: `podman image inspect localhost/leksi-os:dev`
- There is no unit test suite. Verify changes by building the image and, when relevant, running/booting it (see README's "Build locally" and "Install the image" sections) — do not claim a change works without building it.
- CI ([.github/workflows/build-image.yaml](../.github/workflows/build-image.yaml)) runs `podman build` and pushes to `ghcr.io/a-leksi1/leksi-os:latest` on manual `workflow_dispatch` only; push/schedule triggers are present but commented out.

## Conventions

- Never commit the private cosign signing key. [cosign.pub](../cosign.pub) (public key) is the only signing-related file that belongs in the repo; signature verification is not yet wired into the build workflow.
- Keep package/service changes explicit and reviewable (one concern per change) rather than bulk-editing `scripts/build.sh`.
