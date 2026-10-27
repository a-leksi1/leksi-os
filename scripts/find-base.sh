#!/bin/bash

# Prints BASE_TAG and KERNEL_VERSION for the newest Silverblue 44 image whose
# kernel has a prebuilt NVIDIA module in ublue-os/akmods-nvidia-open.
# ublue publishes the module a few hours to a day after Fedora ships a new
# kernel, so the latest base can briefly be ahead of it.

set -euo pipefail

BASE=quay.io/fedora-ostree-desktops/silverblue
AKMODS=ghcr.io/ublue-os/akmods-nvidia-open

akmods_tags=$(skopeo list-tags "docker://$AKMODS" | jq -r '.Tags[]')
base_tags=$(skopeo list-tags "docker://$BASE" | jq -r '.Tags[]' \
    | grep -E '^44\.[0-9]{8}\.[0-9]+$' | sort -rV | head -n 14)

for tag in $base_tags; do
    kernel=$(skopeo inspect --no-tags "docker://$BASE:$tag" | jq -r '.Labels["ostree.linux"]')
    if grep -qxF "main-44-$kernel" <<<"$akmods_tags"; then
        echo "BASE_TAG=$tag"
        echo "KERNEL_VERSION=$kernel"
        exit 0
    fi
    echo "No NVIDIA module yet for $tag (kernel $kernel), trying an older base" >&2
done

echo "No recent Silverblue 44 base has a matching NVIDIA module" >&2
exit 1
