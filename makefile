# Image values
REGISTRY := "localhost"
IMAGE := "palworld-test"
IMAGE_REF := $(REGISTRY)/$(IMAGE)

# Git commit hash
HASH := $(shell git rev-parse --short HEAD)

# Buildah/Podman Options
CONTAINER_NAME := "palworld-test"
VOLUME_NAME := "palworld-data-test"
BUILDAH_BUILD_OPTS := --format docker -f ./container/Containerfile
PODMAN_RUN_OPTS := --name $(CONTAINER_NAME) -d --mount type=volume,source=$(VOLUME_NAME),target=/home/steam/palworld/Pal/Saved -p 8211:8211/udp --env=SERVER_NAME='Palworld Server Test' --env=SERVER_PASSWORD='PleaseChangeMe' --env=GAME_PORT=7777 --env=SERVER_SLOTS=32

# Makefile targets
.PHONY: build run cleanup

build:
	buildah build $(BUILDAH_BUILD_OPTS) -t $(IMAGE_REF):$(HASH) ./container

run:
	podman volume create $(VOLUME_NAME)
	podman run $(PODMAN_RUN_OPTS) $(IMAGE_REF):$(HASH)

cleanup:
	podman rm -f $(CONTAINER_NAME)
	podman rmi -f $(IMAGE_REF):$(HASH)
	podman volume rm $(VOLUME_NAME)
