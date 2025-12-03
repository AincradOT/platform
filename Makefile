.ONESHELL:
.SHELL := /usr/bin/bash
.PHONY: help set-env prep plan plan-target destroy-plan apply destroy destroy-target format lint check-security documentation

PROVIDER ?= aws
ENV      ?= dev
REGION   ?= ap-southeast-2
STACK_DIR := infra/providers/$(PROVIDER)/$(ENV)
VARS      := variables/$(ENV)-$(REGION).tfvars
BOLD   := $(shell tput bold)
RED    := $(shell tput setaf 1)
GREEN  := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
RESET  := $(shell tput sgr0)

ifeq (, $(shell which terraform))
	$(error "No terraform in $(PATH), get it from https://www.terraform.io/downloads.html")
endif

TFLINT     := $(shell which tflint 2>/dev/null)
TFSEC      := $(shell which trivy 2>/dev/null)
TFDOCS     := $(shell which terraform-docs 2>/dev/null)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
	@if [ -z "$(PROVIDER)" ]; then \
		echo "$(BOLD)$(RED)PROVIDER was not set$(RESET)"; \
		ERROR=1; \
	 fi
	@if [ -z "$(ENV)" ]; then \
		echo "$(BOLD)$(RED)ENV was not set$(RESET)"; \
		ERROR=1; \
	 fi
	@if [ ! -d "$(STACK_DIR)" ]; then \
		echo "$(BOLD)$(RED)Stack directory does not exist: $(STACK_DIR)$(RESET)"; \
		ERROR=1; \
	 fi
	@if [ ! -f "$(STACK_DIR)/$(VARS)" ]; then \
		echo "$(BOLD)$(RED)Could not find variables file: $(STACK_DIR)/$(VARS)$(RESET)"; \
		ERROR=1; \
	 fi
	@if [ ! -z "$$ERROR" ] && [ "$$ERROR" -eq 1 ]; then \
		echo "$(BOLD)Example usage: \`PROVIDER=aws ENV=dev REGION=ap-southeast-2 make plan\`$(RESET)"; \
		exit 1; \
	 fi

prep: set-env ## Initialise Terraform for the selected provider/environment
	@echo "$(BOLD)Using stack directory: $(STACK_DIR)$(RESET)"
	@cd "$(STACK_DIR)" && \
		echo "$(BOLD)Running terraform init$(RESET)" && \
		terraform init -input=false -upgrade

plan: prep ## Show what terraform thinks it will do for the selected stack
	@cd "$(STACK_DIR)" && \
		terraform plan -input=false -refresh=true -var-file="$(VARS)"

format: prep ## Rewrites all Terraform configuration files to a canonical format.
	@cd "$(STACK_DIR)" && \
		terraform fmt -write=true -recursive

lint: prep ## Check for possible errors, best practices, etc in current stack!
	@if [ -z "$(TFLINT)" ]; then \
		echo "$(BOLD)$(RED)tflint not found in PATH$(RESET)"; \
		echo "Install from: https://github.com/terraform-linters/tflint"; \
		exit 1; \
	 fi
	@cd "$(STACK_DIR)" && \
		$(TFLINT)

check-security: prep ## Static analysis of your terraform templates to spot potential security issues.
	@if [ -z "$(TFSEC)" ]; then \
		echo "$(BOLD)$(RED)trivy not found in PATH$(RESET)"; \
		echo "Install from: https://github.com/aquasecurity/trivy"; \
		exit 1; \
	 fi
	@cd "$(STACK_DIR)" && \
		$(TFSEC) .

documentation: prep ## Generate README.md for the current stack using terraform-docs
	@if [ -z "$(TFDOCS)" ]; then \
		echo "$(BOLD)$(RED)terraform-docs not found in PATH$(RESET)"; \
		echo "Install from: https://terraform-docs.io/"; \
		exit 1; \
	 fi
	@cd "$(STACK_DIR)" && \
		$(TFDOCS) markdown table --sort-by-required . > README.md

plan-target: prep ## Shows what a plan looks like for applying a specific resource
	@cd "$(STACK_DIR)" && \
		echo "$(YELLOW)$(BOLD)[INFO]   $(RESET)Example: module.rds.aws_route53_record.rds-master" && \
		read -p "PLAN target: " DATA && \
		terraform plan -input=true -refresh=true -var-file="$(VARS)" -target="$$DATA"

apply: prep ## Have terraform do the things. This will cost money.
	@cd "$(STACK_DIR)" && \
		terraform apply -input=false -refresh=true -var-file="$(VARS)"

destroy: prep ## Destroy the things in the current stack
	@cd "$(STACK_DIR)" && \
		terraform destroy -input=false -refresh=true -var-file="$(VARS)"

destroy-plan: prep ## Creates a destruction plan for the current stack.
	@cd "$(STACK_DIR)" && \
		terraform plan -input=false -refresh=true -destroy -var-file="$(VARS)"

destroy-target: prep ## Destroy a specific resource in the current stack. Use with caution.
	@cd "$(STACK_DIR)" && \
		echo "$(YELLOW)$(BOLD)[INFO] Specifically destroy a piece of Terraform data.$(RESET)"; \
		echo "Example: module.rds.aws_route53_record.rds-master"; \
		read -p "Destroy target: " DATA && \
		terraform destroy -input=false -refresh=true -var-file="$(VARS)" -target="$$DATA"
