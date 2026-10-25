# Kernel of the base image (from its ostree.linux label), passed by the build
ARG KERNEL_VERSION

# Prebuilt NVIDIA kernel module for that exact kernel, signed by Universal Blue
FROM ghcr.io/ublue-os/akmods-nvidia-open:main-44-${KERNEL_VERSION} AS akmods-nvidia

FROM scratch AS ctx
COPY scripts /scripts
COPY files /files
COPY cosign.pub /cosign.pub
COPY --from=akmods-nvidia /rpms /akmods-nvidia

FROM quay.io/fedora-ostree-desktops/silverblue:44

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    bash /ctx/scripts/build.sh

RUN bootc container lint
