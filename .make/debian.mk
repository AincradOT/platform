PROJECT_NAME ?= $(notdir $(CURDIR))
DIST         ?= dist
VERSION      ?= dev

.ONESHELL:
BASH := $(shell command -v bash 2>/dev/null || echo /bin/sh)
SHELL := $(BASH)

ifeq ($(notdir $(SHELL)),bash)
  SHELLFLAGS := -eu -o pipefail -c
else
  SHELLFLAGS := -eu -c
endif

DOCKER_COMPOSE ?= $(shell command -v docker-compose 2>/dev/null || echo "docker compose")
BOLD   := $(shell tput bold 2>/dev/null || echo "")
RED    := $(shell tput setaf 1 2>/dev/null || echo "")
GREEN  := $(shell tput setaf 2 2>/dev/null || echo "")
YELLOW := $(shell tput setaf 3 2>/dev/null || echo "")
BLUE   := $(shell tput setaf 4 2>/dev/null || echo "")
RESET  := $(shell tput sgr0 2>/dev/null || echo "")

setup-debian: ## Set up project dependencies
	@echo "$(GREEN)Setting up project dependencies...$(RESET)"
	@echo "$(BLUE)Checking and installing system dependencies...$(RESET)"
	@if ! command -v dpkg-deb >/dev/null 2>&1; then \
		echo "$(BLUE)Installing Debian build tools...$(RESET)"; \
		sudo apt-get update && sudo apt-get install -y dpkg-dev; \
	else \
		echo "$(GREEN)Debian build tools already installed$(RESET)"; \
	fi
	@echo "$(BLUE)Installing additional dependencies for cross-platform builds...$(RESET)"
	@sudo apt-get update && sudo apt-get install -y \
		libfuse2
	@echo "$(GREEN)Setup completed successfully!$(RESET)"

run-debian:
	@echo "$(YELLOW)No run command defined for this project.$(RESET)"

lint-debian:
	@echo "$(YELLOW)No lint command defined for this project.$(RESET)"

format-debian:
	@echo "$(YELLOW)No format command defined for this project.$(RESET)"

test-debian:
	@echo "$(YELLOW)No test command defined for this project.$(RESET)"

build-debian: | setup-debian
	@echo "$(YELLOW)No build command defined for this project.$(RESET)"

package-debian:
	@echo "$(YELLOW)No package command defined for this project.$(RESET)"

clean-debian:
	@echo "$(RED)WARNING: This will remove all build artifacts, caches, containers, images, and volumes!$(RESET)"
	@echo "This action cannot be undone."
	@read -p "Are you sure? Type 'yes' to continue: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo "$(GREEN)Cleaning local caches and artifacts...$(RESET)"; \
		rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov coverage dist build node_modules; \
		find . -type d -name "__pycache__" -exec rm -rf {} +; \
		find . -type f -name "*.pyc" -delete; \
		if [ -f "$(DOCKER_COMPOSE_FILE)" ]; then \
			echo "$(GREEN)Stopping and removing Docker containers, volumes, and images...$(RESET)"; \
			$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down -v --rmi all --remove-orphans; \
			echo "$(GREEN)Pruning unused Docker resources...$(RESET)"; \
			docker system prune -f; \
		else \
			echo "$(YELLOW)No docker-compose.yml found. Skipping Docker cleanup.$(RESET)"; \
		fi; \
		echo "$(GREEN)Cleanup completed successfully!$(RESET)"; \
	else \
		echo "$(YELLOW)Cleanup cancelled.$(RESET)"; \
	fi

up-debian:
	@if [ -f "$(DOCKER_COMPOSE_FILE)" ]; then \
		$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up -d; \
	else \
		echo "$(RED)No docker-compose.yml found in docker/$(RESET)"; \
	fi

check-env-debian:
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "$(RED)ERROR:$(RESET) No .env file found."; \
		echo ""; \
		if [ -f ".env.example" ]; then \
			echo "Run the following command to create it:"; \
			echo "    cp .env.example .env"; \
		else \
			echo "A .env.example file is missing, but you can still create a .env file manually:"; \
			echo "    cp /dev/null .env"; \
		fi; \
		echo ""; \
		echo "After creating the .env file, update the values inside it before continuing."; \
		exit 1; \
	fi

help-debian:
	@echo ""
	@echo "$(BOLD)$(BLUE)Available Commands for $(PROJECT_NAME)$(RESET)"
	@echo ""
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(firstword $(MAKEFILE_LIST)) | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "$(BLUE)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
