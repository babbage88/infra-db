DOCKER_HUB:=ghcr.io/babbage88/init-infradb:
DOCKER_HUB_TEST:=jtrahan88/infradb-test:
ENV_FILE:=.env
MIG:=$(shell date '+%m%d%Y.%H%M%S')
SHELL := /bin/bash
DB_BUILD_DIR:=~/projects/infra-db
DB_BUILDER:=infradb-builder
DB_IMG:=ghcr.io/babbage88/init-infradb:
infradb-deployfile:=deployment/kubernetes/infra-db.yaml
deployfile:=deployment/kubernetes/infra-db.yaml
tag:=$(shell git rev-parse HEAD) 

check-builder:
	@if ! docker buildx inspect $(DB_BUILDER) > /dev/null 2>&1; then \
		echo "Builder $(DB_BUILDER) does not exist. Creating..."; \
		docker buildx create --name $(DB_BUILDER) --bootstrap; \
	fi

create-builder: check-builder

buildandpush: create-builder
	@echo "Building image: $(DOCKER_HUB)$(tag)"
	docker buildx use $(DB_BUILDER)
	docker buildx build --platform linux/amd64,linux/arm64 -t $(DOCKER_HUB)$(tag) . --push

#buildall: buildinitcontainer: buildandpush
#	@echo "init container image: $(INIT_IMG)$(tag)"
#	@echo "Building infra-db migration image: $(DOCKER_HUB)$(tag)"

deploy: buildandpush
	kubectl apply -f $(deployfile)
	kubectl rollout restart deployment infra-db


