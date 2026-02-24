# Makefile for dbt-workbench Helm Chart Packaging
# ==============================================

# Configuration
CHART_NAME := dbt-workbench-trino
CHART_DIR := dbt/chart
CHART_VERSION := $(shell grep -E '^version:' $(CHART_DIR)/Chart.yaml | awk '{print $$2}')
APP_VERSION := $(shell grep -E '^appVersion:' $(CHART_DIR)/Chart.yaml | awk '{print $$2}')
PACKAGE_DIR := pkg
INDEX_FILE := index.yaml
REPO_URL ?= https://raw.githubusercontent.com/$(ORG)/$(REPO)/gh-pages
GITHUB_PAGES_BRANCH ?= gh-pages

# GitHub configuration (set via environment or override)
ORG ?= $(shell git remote get-url origin 2>/dev/null | sed -n 's|.*github.com/\([^/]*\)/.*|\1|p')
REPO ?= $(shell git remote get-url origin 2>/dev/null | sed -n 's|.*github.com/.*/\(.*\)\.git|\1|p')

# Colors
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
.PHONY: help
help:
	@echo ""
	@echo "$(BLUE)========================================$(NC)"
	@echo "$(BLUE)  dbt-workbench Helm Chart Makefile$(NC)"
	@echo "$(BLUE)========================================$(NC)"
	@echo ""
	@echo "$(GREEN)Chart Info:$(NC)"
	@echo "  Name:         $(CHART_NAME)"
	@echo "  Version:      $(CHART_VERSION)"
	@echo "  App Version:  $(APP_VERSION)"
	@echo "  Chart Path:   $(CHART_DIR)"
	@echo ""
	@echo "$(GREEN)Available Targets:$(NC)"
	@echo "  $(YELLOW)make lint$(NC)         - Validate chart syntax"
	@echo "  $(YELLOW)make template$(NC)     - Render templates locally"
	@echo "  $(YELLOW)make dry-run$(NC)      - Dry-run install with defaults"
	@echo "  $(YELLOW)make package$(NC)      - Create .tgz archive"
	@echo "  $(YELLOW)make index$(NC)        - Generate/update index.yaml"
	@echo "  $(YELLOW)make validate$(NC)     - Full validation (lint + template)"
	@echo "  $(YELLOW)make serve$(NC)        - Start local helm repo server"
	@echo "  $(YELLOW)make release$(NC)      - Create GitHub release"
	@echo "  $(YELLOW)make clean$(NC)        - Remove generated files"
	@echo "  $(YELLOW)make all$(NC)          - Validate, package, and index"
	@echo ""
	@echo "$(GREEN)Usage:$(NC)"
	@echo "  make package VERSION=0.2.0      # Package specific version"
	@echo "  make release VERSION=0.2.0      # Create release"
	@echo "  make index REPO_URL=https://... # Custom repo URL"
	@echo ""

# ===========================================
# Validation Targets
# ===========================================

.PHONY: lint
lint: ## Validate chart syntax with helm lint
	@echo "$(GREEN)Running helm lint...$(NC)"
	@helm lint $(CHART_DIR)
	@echo "$(GREEN)✓ Lint passed$(NC)"

.PHONY: template
template: ## Render templates locally (dry-run)
	@echo "$(GREEN)Rendering templates...$(NC)"
	@helm template test-release $(CHART_DIR)
	@echo "$(GREEN)✓ Templates rendered successfully$(NC)"

.PHONY: dry-run
dry-run: ## Dry-run install with default values
	@echo "$(GREEN)Running dry-run install...$(NC)"
	@helm install --dry-run --debug test-release $(CHART_DIR)
	@echo "$(GREEN)✓ Dry-run completed$(NC)"

.PHONY: validate
validate: lint template ## Full validation (lint + template)
	@echo "$(GREEN)✓ Full validation passed$(NC)"

# ===========================================
# Packaging Targets
# ===========================================

.PHONY: package
package: clean-pkg ## Create .tgz archive
	@echo "$(GREEN)Packaging chart...$(NC)"
	@mkdir -p $(PACKAGE_DIR)
	@helm package $(CHART_DIR) --destination $(PACKAGE_DIR) --app-version $(APP_VERSION)
	@echo "$(GREEN)✓ Chart packaged: $(PACKAGE_DIR)/$(CHART_NAME)-$(CHART_VERSION).tgz$(NC)"

.PHONY: index
index: ## Generate/update index.yaml
	@echo "$(GREEN)Generating index.yaml...$(NC)"
	@mkdir -p $(PACKAGE_DIR)
	@helm repo index $(PACKAGE_DIR) --url $(REPO_URL)
	@echo "$(GREEN)✓ Index generated: $(PACKAGE_DIR)/$(INDEX_FILE)$(NC)"

.PHONY: index-github
index-github: ## Generate index.yaml for GitHub Pages
	@echo "$(GREEN)Generating index.yaml for GitHub Pages...$(NC)"
	@mkdir -p $(PACKAGE_DIR)
	@helm repo index $(PACKAGE_DIR) --url https://$(ORG).github.io/$(REPO)
	@echo "$(GREEN)✓ Index generated for GitHub Pages$(NC)"

# ===========================================
# Release Targets
# ===========================================

.PHONY: release
release: package index-github ## Create GitHub release with chart
	@if [ -z "$(VERSION)" ]; then \
		echo "$(YELLOW)VERSION not specified, using chart version: $(CHART_VERSION)$(NC)"; \
		VERSION=$(CHART_VERSION); \
	fi
	@echo "$(GREEN)Creating release for version $(VERSION)...$(NC)"
	@if [ -z "$(GITHUB_TOKEN)" ]; then \
		echo "$(YELLOW)WARNING: GITHUB_TOKEN not set. Create release manually.$(NC)"; \
		echo "Upload these files to the release:"; \
		echo "  - $(PACKAGE_DIR)/$(CHART_NAME)-$(VERSION).tgz"; \
		echo "  - $(PACKAGE_DIR)/$(INDEX_FILE)"; \
	else \
		echo "$(GREEN)Release would be created with GITHUB_TOKEN$(NC)"; \
		echo "gh release create v$(VERSION) \
			--title 'Helm Chart v$(VERSION)' \
			--notes 'Release of $(CHART_NAME) v$(VERSION)' \
			$(PACKAGE_DIR)/$(CHART_NAME)-$(VERSION).tgz"; \
	fi

.PHONY: publish
publish: ## Publish to GitHub Pages (requires gh CLI)
	@echo "$(GREEN)Publishing to GitHub Pages...$(NC)"
	@if ! command -v gh &> /dev/null; then \
		echo "$(YELLOW)gh CLI not found. Install from https://cli.github.com/$(NC)"; \
		exit 1; \
	fi
	@gh auth status || exit 1
	@git checkout $(GITHUB_PAGES_BRANCH) 2>/dev/null || git checkout -b $(GITHUB_PAGES_BRANCH)
	@cp $(PACKAGE_DIR)/* .
	@git add .
	@git commit -m "Release $(CHART_VERSION)" || echo "No changes to commit"
	@git push origin $(GITHUB_PAGES_BRANCH)
	@git checkout -
	@echo "$(GREEN)✓ Published to GitHub Pages$(NC)"

# ===========================================
# Development Targets
# ===========================================

.PHONY: serve
serve: ## Start local helm repo server
	@echo "$(GREEN)Starting helm serve on http://127.0.0.1:8879$(NC)"
	@helm serve --repo-path $(PACKAGE_DIR) --address 127.0.0.1:8879

.PHONY: deps
deps: ## Update chart dependencies
	@echo "$(GREEN)Updating dependencies...$(NC)"
	@helm dependency update $(CHART_DIR)
	@echo "$(GREEN)✓ Dependencies updated$(NC)"

.PHONY: clean
clean: clean-pkg ## Remove all generated files
	@echo "$(GREEN)Cleaning generated files...$(NC)"

.PHONY: clean-pkg
clean-pkg: ## Remove package directory
	@rm -rf $(PACKAGE_DIR)
	@echo "$(GREEN)✓ Cleaned package directory$(NC)"

.PHONY: all
all: validate package index ## Full build: validate, package, and index

# ===========================================
# Installation Targets (for testing)
# ===========================================

.PHONY: install
install: package ## Install chart to Kubernetes (requires kubeconfig)
	@echo "$(GREEN)Installing chart...$(NC)"
	@helm install $(CHART_NAME) $(PACKAGE_DIR)/$(CHART_NAME)-$(CHART_VERSION).tgz

.PHONY: upgrade
upgrade: package ## Upgrade existing installation
	@echo "$(GREEN)Upgrading chart...$(NC)"
	@helm upgrade $(CHART_NAME) $(PACKAGE_DIR)/$(CHART_NAME)-$(CHART_VERSION).tgz

.PHONY: uninstall
uninstall: ## Uninstall chart from Kubernetes
	@echo "$(GREEN)Uninstalling chart...$(NC)"
	@helm uninstall $(CHART_NAME) || true

# ===========================================
# CI/CD Targets
# ===========================================

.PHONY: ci-release
ci-release: ## CI/CD release target (used by GitHub Actions)
	@echo "$(GREEN)Running CI release...$(NC)"
	@echo "ORG=$(ORG) REPO=$(REPO)"
	@make validate
	@make package
	@make index-github
	@echo "$(GREEN)✓ CI release completed$(NC)"
	@echo "Package: $(PACKAGE_DIR)/$(CHART_NAME)-$(CHART_VERSION).tgz"
	@echo "Index: $(PACKAGE_DIR)/$(INDEX_FILE)"
