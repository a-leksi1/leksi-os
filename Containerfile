FROM quay.io/fedora/fedora-bootc:44

COPY system/ /
COPY scripts/build.sh /tmp/build.sh
RUN chmod +x /tmp/build.sh && /tmp/build.sh && rm /tmp/build.sh

RUN bootc container lint