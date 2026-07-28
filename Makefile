IMAGE_NAME = yocto-riscv-build
VOLUME_NAME = yocto
QEMU_VOLUME_NAME = qemu
DEPLOY_DIR = $(VOLUME_NAME)/poky/build/tmp/deploy/images/licheepi4a
QEMU_DEPLOY_DIR = $(QEMU_VOLUME_NAME)/poky/build/tmp/deploy/images/qemuriscv64
.DEFAULT_GOAL = help

DOCKER_RUN = docker run --rm -it \
	--memory=12g \
	--cpus=8 \
	-v $(PWD)/$(VOLUME_NAME)/:/home/builder/$(VOLUME_NAME)/:Z \
	-v $(PWD)/meta-licheepi4a:/home/builder/meta-licheepi4a:Z \
	-v $(PWD)/meta-cluster:/home/builder/meta-cluster:Z \
	-v $(PWD)/scripts/build/:/home/builder/scripts/:Z \
	$(IMAGE_NAME)

DOCKER_RUN_QEMU = docker run --rm -it \
	--memory=12g \
	--cpus=8 \
	-v $(PWD)/$(QEMU_VOLUME_NAME)/:/home/builder/$(QEMU_VOLUME_NAME)/:Z \
	-v $(PWD)/meta-cluster:/home/builder/meta-cluster:Z \
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

.PHONY: qemu
qemu:
	$(DOCKER_RUN_QEMU) /home/builder/scripts/build-qemu.sh

.PHONY: qemu-sdk
qemu-sdk:
	$(DOCKER_RUN_QEMU) /bin/bash -c \
		"source /home/builder/$(QEMU_VOLUME_NAME)/poky/oe-init-build-env /home/builder/$(QEMU_VOLUME_NAME)/poky/build && \
		bitbake -c populate_sdk cluster-image"

.PHONY: qemu-rebuild
qemu-rebuild:
	$(DOCKER_RUN_QEMU) /bin/bash -c \
		"source /home/builder/$(QEMU_VOLUME_NAME)/poky/oe-init-build-env /home/builder/$(QEMU_VOLUME_NAME)/poky/build && \
		bitbake -c cleansstate cluster-image && \
		bitbake cluster-image"

.PHONY: qemu-shell
qemu-shell:
	$(DOCKER_RUN_QEMU) /bin/bash

# Clean everything
clean:
	docker rmi $(IMAGE_NAME) || true
	rm -rf $(VOLUME_NAME)

clean-qemu:
	rm -rf $(QEMU_VOLUME_NAME)

help:
	@echo "Makefile for building Yocto images"
	@echo ""
	@echo "Lichee Pi 4A:"
	@echo "  build           - build the Docker container image"
	@echo "  yocto           - full Yocto build (first time or after layer changes)"
	@echo "  rebuild-kernel  - rebuild kernel + image (after kernel/config changes)"
	@echo "  rebuild         - clean + rebuild image (after recipe changes)"
	@echo "  mkboot          - reassemble boot partition only (extlinux.conf changes)"
	@echo "  flash           - flash to Lichee Pi 4A via fastboot"
	@echo "  shell           - interactive shell in build container"
	@echo ""
	@echo "QEMU RISC-V 64:"
	@echo "  qemu            - full Yocto build for qemuriscv64"
	@echo "  qemu-sdk        - generate SDK with cross-compilation sysroot"
	@echo "  qemu-rebuild    - clean + rebuild qemu image"
	@echo "  qemu-shell      - interactive shell for qemu build"
	@echo ""
	@echo "Common"
	@echo "  clean           - delete Docker image and licheepi4a build"
	@echo "  clean-qemu      - delete qemu build directory"
