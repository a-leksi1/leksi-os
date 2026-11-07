#!/bin/bash

# Image signature verification: updates of ghcr.io/a-leksi1/leksi-os must be
# signed with cosign.key (checked when the system follows
# ostree-image-signed:docker://...). The registries.d entry that tells podman
# where the signatures are comes from system_files.

set -ouex pipefail

install -Dm644 /ctx/cosign.pub /etc/pki/containers/leksi-os.pub

# rpm-ostree refuses signed images while the global default is
# insecureAcceptAnything, so reject by default and accept everything else
# per transport instead (same behaviour for all other images).
# Since Fedora 45, containers-common ships its default policy in /usr/share;
# /etc/containers/policy.json still takes precedence, so the result goes there.
POLICY=/etc/containers/policy.json
[ -f "$POLICY" ] || POLICY=/usr/share/containers/policy.json
jq '.default = [{"type": "reject"}]
    | reduce ("docker", "atomic", "containers-storage", "dir", "docker-archive",
              "docker-daemon", "oci", "oci-archive", "sif", "tarball") as $t
        (.; .transports[$t][""] //= [{"type": "insecureAcceptAnything"}])
    | .transports.docker["ghcr.io/a-leksi1/leksi-os"] = [{
        "type": "sigstoreSigned",
        "keyPath": "/etc/pki/containers/leksi-os.pub",
        "signedIdentity": {"type": "matchRepository"}
    }]' "$POLICY" > /tmp/policy.json
install -Dm644 /tmp/policy.json /etc/containers/policy.json
