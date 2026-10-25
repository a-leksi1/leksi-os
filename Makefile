# Usage:
#   make          build the container image, then the disk image
#   make build    build the container image only
#   make iso      build the disk image from the existing container image
#   make push     push the container image to the local registry (for the VM)
#   make clean    remove the disk-images output folder
#
# Override any variable on the command line, e.g. `make iso TYPE=qcow2`.
#
# Everything runs as root (sudo) because bootc-image-builder reads the
# container image from root's storage (/var/lib/containers/storage).

IMAGE   ?= localhost/leksi-os:dev
BUILDER ?= quay.io/centos-bootc/bootc-image-builder:latest
TYPE    ?= anaconda-iso
ROOTFS  ?= xfs
OUTPUT  ?= disk-images
# The VM pulls from this registry (as 10.0.2.2:5000 from GNOME Boxes)
REGISTRY ?= localhost:5000

.PHONY: all build iso push clean

all: build iso

# The NVIDIA module must match the base image kernel, so always build from the
# latest base and read its kernel version from the registry
build:
	sudo podman build --pull=newer \
		--build-arg KERNEL_VERSION=$$(skopeo inspect docker://quay.io/fedora-ostree-desktops/silverblue:44 | jq -r '.Labels["ostree.linux"]') \
		-t $(IMAGE) .

iso:
	mkdir -p $(OUTPUT)
	sudo podman run --rm -it --privileged --pull=newer \
		--security-opt label=type:unconfined_t \
		-v $(CURDIR)/$(OUTPUT):/output \
		-v /var/lib/containers/storage:/var/lib/containers/storage \
		$(BUILDER) \
		--type $(TYPE) \
		--rootfs $(ROOTFS) \
		--chown $(shell id -u):$(shell id -g) \
		$(IMAGE)

push:
	podman start registry 2>/dev/null || \
		podman run -d --name registry -p 5000:5000 docker.io/library/registry:2
	sudo podman push --tls-verify=false $(IMAGE) $(REGISTRY)/leksi-os:dev

clean:
	sudo rm -rf $(OUTPUT)
