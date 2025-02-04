DOCKER_HUB:=ghcr.io/babbage88/init-infradb:
DOCKER_HUB_TEST:=jtrahan88/infradb-test:
INIT_IMG:=ghcr.io/babbage88/jobcheck:
ENV_FILE:=.env
MIG:=$(shell date '+%m%d%Y.%H%M%S')
SHELL := /bin/bash
INIT_BUILDER:=initbuilder
DB_BUILDER:=infradb-builder
deployfile:=deployment/kubernetes/infra-db.yaml
tag:=$(shell git rev-parse HEAD) 

check-builder:
	@if ! docker buildx inspect $(DB_BUILDER) > /dev/null 2>&1; then \
		echo "Builder $(DB_BUILDER) does not exist. Creating..."; \
		docker buildx create --name $(DB_BUILDER) --bootstrap; \
	fi

check-init-builder:
	@if ! docker buildx inspect $(INIT_BUILDER) > /dev/null 2>&1; then \
		echo "Builder $(INIT_BUILDER) does not exist. Creating..."; \
	 	docker buildx create --name $(INIT_BUILDER) --bootstrap; \
	fi

create-builder: check-builder

create-init-builder: check-init-builder

buildinitcontainer: create-init-builder
	@echo "Building init container image: $(INIT_IMG)$(tag)"
	docker buildx use $(INIT_BUILDER)
	docker buildx build --file=Init.Dockerfile --platform linux/amd64,linux/arm64 -t $(INIT_IMG)$(tag) . --push

buildandpush: create-builder
	@echo "Building image: $(DOCKER_HUB)$(tag)"
	docker buildx use $(DB_BUILDER)
	docker buildx build --platform linux/amd64,linux/arm64 -t $(DOCKER_HUB)$(tag) . --push

buildall: buildinitcontainer: buildandpush
	@echo "init container image: $(INIT_IMG)$(tag)"
	@echo "Building infra-db migration image: $(DOCKER_HUB)$(tag)"

deploy: buildandpush
	kubectl apply -f $(deployfile)
	kubectl rollout restart deployment infra-db


