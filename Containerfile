# Fedora release, Silverblue tag and its kernel (from its ostree.linux label),
# all picked by scripts/find-base.sh
ARG FEDORA_VERSION
ARG BASE_TAG
ARG KERNEL_VERSION

# Prebuilt NVIDIA kernel module for that exact kernel, signed by Universal Blue
FROM ghcr.io/ublue-os/akmods-nvidia-open:main-${FEDORA_VERSION}-${KERNEL_VERSION} AS akmods-nvidia

# Build inputs, mounted at /ctx during the build and never copied into the image
FROM scratch AS ctx
COPY scripts /scripts
COPY system_files /system_files
COPY cosign.pub /cosign.pub
COPY --from=akmods-nvidia /rpms /akmods-nvidia

FROM quay.io/fedora-ostree-desktops/silverblue:${BASE_TAG}

# One layer for everything; smaller updates come from rechunking after the
# build (rpm-ostree compose build-chunked-oci, in the CI and the Makefile),
# not from more layers. Package caches, logs and temp files go to
# build-time mounts so they never land in the image.
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/scripts/build.sh

RUN bootc container lint
