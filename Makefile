DOCKER_HUB:=ghcr.io/babbage88/init-infradb:
DOCKER_HUB_TEST:=jtrahan88/infradb-test:
ENV_FILE:=.env
MIG:=$(shell date '+%m%d%Y.%H%M%S')
SHELL := /bin/bash

buildandpushdev: 
	docker buildx use infradb
	docker buildx build --platform linux/amd64,linux/arm64 -t $(DOCKER_HUB)$(tag) . --push

buildandpushlocalk3:
	docker buildx use infradb
	docker buildx build --platform linux/amd64,linux/arm64 -t $(DOCKER_HUB_TEST)$(tag) . --push

deploydev: buildandpushdev
	kubectl apply -f deployment/kubernetes/infra-db.yaml
	kubectl rollout restart deployment infra-db

deploylocalk3: buildandpushlocalk3
	kubelocal apply -f deployment/kubernetes/localdev/infra-db-dev.yaml
	kubelocal rollout restart deployment infra-db

