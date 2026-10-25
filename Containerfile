FROM scratch AS ctx
COPY scripts /scripts
COPY files /files
COPY cosign.pub /cosign.pub

FROM quay.io/fedora-ostree-desktops/silverblue:44

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    bash /ctx/scripts/build.sh

RUN bootc container lint
