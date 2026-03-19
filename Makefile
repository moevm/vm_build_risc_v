IMAGE_NAME = yocto-riscv-build
VOLUME_NAME = yocto
DEPLOY_DIR = $(VOLUME_NAME)/poky/build/tmp/deploy/images/licheepi4a
.DEFAULT_GOAL = help

build:
	docker buildx build -t $(IMAGE_NAME) .

.PHONY: yocto
yocto:
	docker run --rm -it \
		--memory=12g \
		--cpus=8 \
		-v $(PWD)/$(VOLUME_NAME)/:/home/builder/$(VOLUME_NAME)/:Z \
		-v $(PWD)/meta-licheepi4a:/home/builder/meta-licheepi4a:Z \
		$(IMAGE_NAME) /home/builder/scripts/build.sh

.PHONY: redeploy
redeploy:
	docker run --rm -it \
		--memory=12g \
		--cpus=8 \
		-v $(PWD)/$(VOLUME_NAME)/:/home/builder/$(VOLUME_NAME)/:Z \
		-v $(PWD)/meta-licheepi4a:/home/builder/meta-licheepi4a:Z \
		$(IMAGE_NAME) /bin/bash -c \
		"source /home/builder/$(VOLUME_NAME)/poky/oe-init-build-env /home/builder/$(VOLUME_NAME)/poky/build && \
		bitbake -f -c deploy opensbi-thead firmware-th1520 u-boot-thead linux-revyos-th1520 && \
		bitbake -f -c image licheepi4a-dpdk-image && \
		exec /home/builder/scripts/build.sh"

.PHONY: rebuild
rebuild:
	docker run --rm -it \
		--memory=12g \
		--cpus=8 \
		-v $(PWD)/$(VOLUME_NAME)/:/home/builder/$(VOLUME_NAME)/:Z \
		-v $(PWD)/meta-licheepi4a:/home/builder/meta-licheepi4a:Z \
		$(IMAGE_NAME) /bin/bash -c \
		"source /home/builder/$(VOLUME_NAME)/poky/oe-init-build-env /home/builder/$(VOLUME_NAME)/poky/build && \
		bitbake -c cleansstate licheepi4a-dpdk-image && \
		exec /home/builder/scripts/build.sh"

.PHONY: run
run:
	docker run --rm -it -v $(PWD)/$(VOLUME_NAME)/:/home/builder/$(VOLUME_NAME)/:Z -v $(PWD)/meta-licheepi4a:/home/builder/meta-licheepi4a:Z $(IMAGE_NAME) /home/builder/scripts/run.sh

test:
	docker run --rm -it -v $(PWD)/$(VOLUME_NAME)/:/home/builder/$(VOLUME_NAME)/:Z -v $(PWD)/meta-licheepi4a:/home/builder/meta-licheepi4a:Z $(IMAGE_NAME) /bin/bash

clean:
	docker rmi $(IMAGE_NAME)
	rm -rf $(VOLUME_NAME)

help:
	@echo "Makefile for building Yocto image for Lichee Pi 4A"
	@echo ""
	@echo "build     - build the Docker container image"
	@echo "yocto     - build the Lichee Pi 4A DPDK image using Yocto"
	@echo "rebuild   - clear image sstate and rebuild (e.g. after recipe change)"
	@echo "redeploy  - force re-deploy artifacts without rebuild (e.g. after deleting deploy files)"
	@echo "run       - run QEMU"
	@echo "test      - open interactive shell in container"
	@echo "clean     - delete Docker image and build directory, please? run with \"sudo\""
	@echo "help      - print help information"