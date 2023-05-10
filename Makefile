.DEFAULT_GOAL := help

SHELL := /bin/bash
VENV = .venv

ifeq ($(OS),Windows_NT)
	VENV_BIN=$(VENV)/Scripts
else
	VENV_BIN=$(VENV)/bin
endif

.PHONY: help
help:  ## Display this help screen
	@echo -e "\033[1mAvailable commands:\033[0m\n"
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' | sort

.PHONY: requirements
requirements: requirements-r requirements-py requirements-rs ## Install all project requirements

.PHONY: requirements-r
requirements-r:
	Rscript -e 'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/stable/%s/%s/%s", .Platform$$pkgType, R.Version()$$os, R.Version()$$arch))'
	Rscript -e 'pak::repo_add(extendr = "https://extendr.r-universe.dev"); pak::local_install_deps(dependencies = c("all", "Config/Needs/dev", "Config/Needs/website"))'

.venv:
	python3 -m venv $(VENV)

.PHONY: requirements-py
requirements-py: .venv
	$(VENV_BIN)/python -m pip install --upgrade pip
	$(VENV_BIN)/pip install --upgrade mkdocs-material

.PHONY: requirements-rs # TODO: Windows support?
requirements-rs:
	rustup toolchain install nightly
	rustup default nightly

.PHONY: build
build: ## Compile polars R package and generate Rd files
	Rscript -e 'rextendr::document()'

.PHONY: all
all: build test README.md ## build -> test -> Update README.md

.PHONY: docs
docs: build README.md ## Generate docs
	cp docs/mkdocs.orig.yml docs/mkdocs.yml
	Rscript -e 'altdoc::update_docs(custom_reference = "docs/make-docs.R")'
	cd docs && ../$(VENV_BIN)/python3 -m mkdocs build

.PHONY: docs-preview
docs-preview: ## Preview docs on local server. Needs `make docs`
	cd docs && ../$(VENV_BIN)/python3 -m mkdocs serve

README.md: README.Rmd build ## Update README.md
	Rscript -e 'devtools::load_all(); rmarkdown::render("README.Rmd")'

.PHONY: test
test: build ## Run fast unittests
	Rscript -e 'devtools::load_all(); devtools::test()'

.PHONY: install
install: ## Install this R package locally
	Rscript -e 'devtools::install(pkg = ".", dependencies = TRUE)'


.PHONY: git_untrack
git_untrack: ## Some files renders differently often, but should not change. Untrack to not see/commit.
	git update-index --skip-worktree ./man/nanoarrow.Rd

.PHONY: git_retrack
git_retrack: ## Retrack untracked files to see changes and/or commit file in a PR.
	git update-index --no-skip-worktree ./man/nanoarrow.Rd
