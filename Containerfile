FROM scratch AS ctx
COPY scripts /

FROM quay.io/fedora-ostree-desktops/kinoite:43

RUN rm /opt && mkdir /opt

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh


RUN bootc container lint