DOCKER_COMPOSE      ?= docker compose
DOCKER_COMPOSE_FILE ?= docker/docker-compose.yml
PROJECT_NAME        ?= $(notdir $(CURDIR))
ENV_FILE            ?= .env

MK_OS := debian
ifdef FORCE_OS
  MK_OS := $(FORCE_OS)
else ifdef OS
  # Windows uses OS=Windows_NT
  ifeq ($(OS),Windows_NT)
    MK_OS := windows
  endif
else
  # Non-Windows: safe to call uname
  UNAME_S := $(shell uname -s)
  ifeq ($(UNAME_S),Darwin)
    MK_OS := macos
  endif
endif
-include .make/$(MK_OS).mk

.PHONY: help check-env setup run lint format test build package clean up
.DEFAULT_GOAL := help

help:        help-$(MK_OS)        	## Show available commands
setup:       setup-$(MK_OS)       	## Install project dependencies
run:         run-$(MK_OS)         	## Run the project locally
lint:        lint-$(MK_OS)        	## Run lint checks
format:      format-$(MK_OS)      	## Auto-format code
test:        test-$(MK_OS)        	## Run tests
build:       build-$(MK_OS)       	## Build the project
package:     build package-$(MK_OS) ## Package the project for distribution (tarballs, docker images, etc.)
clean:       clean-$(MK_OS)       	## Remove caches, containers, images, volumes
up:          up-$(MK_OS)          	## Start project via Docker Compose
check-env:   check-env-$(MK_OS)
