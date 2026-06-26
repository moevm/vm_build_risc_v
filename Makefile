IMAGE_NAME = yocto-riscv-build
VOLUME_NAME = yocto
DEPLOY_DIR = $(VOLUME_NAME)/poky/build/tmp/deploy/images/licheepi4a
.DEFAULT_GOAL = help

DOCKER_RUN = docker run --rm -it \
	--memory=12g \
	--cpus=8 \
	-v $(PWD)/$(VOLUME_NAME)/:/home/builder/$(VOLUME_NAME)/:Z \
	-v $(PWD)/meta-licheepi4a:/home/builder/meta-licheepi4a:Z \
	-v $(PWD)/scripts/build/:/home/builder/scripts/:Z \
	$(IMAGE_NAME)

build:
	docker buildx build -t $(IMAGE_NAME) .

.PHONY: yocto
yocto:
	$(DOCKER_RUN) /home/builder/scripts/build.sh

# Rebuild kernel and reassemble boot partition
.PHONY: rebuild-kernel
rebuild-kernel:
	$(DOCKER_RUN) /bin/bash -c \
		"source /home/builder/$(VOLUME_NAME)/poky/oe-init-build-env /home/builder/$(VOLUME_NAME)/poky/build && \
		bitbake -c cleansstate linux-revyos-th1520 && \
		bitbake linux-revyos-th1520 && \
		bitbake licheepi4a-dpdk-image && \
		/home/builder/scripts/mkboot.sh"

# Rebuild entire image from scratch
.PHONY: rebuild
rebuild:
	$(DOCKER_RUN) /bin/bash -c \
		"source /home/builder/$(VOLUME_NAME)/poky/oe-init-build-env /home/builder/$(VOLUME_NAME)/poky/build && \
		bitbake -c cleansstate licheepi4a-dpdk-image && \
		bitbake licheepi4a-dpdk-image && \
		/home/builder/scripts/mkboot.sh"

# Reassemble boot partition only
.PHONY: mkboot
mkboot:
	$(DOCKER_RUN) /home/builder/scripts/mkboot.sh

# Flash to board
.PHONY: flash
flash:
	./scripts/flash.sh

# Interactive shell in build container
.PHONY: shell
shell:
	$(DOCKER_RUN) /bin/bash

# Clean everything
clean:
	docker rmi $(IMAGE_NAME) || true
	rm -rf $(VOLUME_NAME)

help:
	@echo "Makefile for building Yocto image for Lichee Pi 4A"
	@echo ""
	@echo "  build           - build the Docker container image"
	@echo "  yocto           - full Yocto build (first time or after layer changes)"
	@echo "  rebuild-kernel  - rebuild kernel + image (after kernel/config changes)"
	@echo "  rebuild         - clean + rebuild image (after recipe changes)"
	@echo "  mkboot          - reassemble boot partition only (extlinux.conf changes)"
	@echo "  flash           - flash to Lichee Pi 4A via fastboot"
	@echo "  shell           - interactive shell in build container"
	@echo "  clean           - delete Docker image and build directory"
