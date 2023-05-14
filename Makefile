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
	Rscript -e 'pak::repo_add(extendr = "https://extendr.r-universe.dev"); pak::local_install_deps(dependencies = c("all", "Config/Needs/dev", "Config/Needs/website"), upgrade = FALSE)'

.venv:
	python3 -m venv $(VENV)

.PHONY: requirements-py
requirements-py: .venv
	$(VENV_BIN)/python -m pip install --upgrade pip
	$(VENV_BIN)/pip install --upgrade mkdocs-material

.PHONY: requirements-rs # TODO: Windows support?
requirements-rs:
	rustup toolchain install nightly-2023-04-11
	rustup default nightly-2023-04-11

.PHONY: build
build: ## Compile polars R package and generate Rd files
	Rscript -e 'if (!(require(arrow)&&require(nanoarrow))) warning("could not load arrow/nanoarrow, igonore changes to nanoarrow.Rd"); rextendr::document()'


.PHONY: all
all: fmt build test README.md ## build -> test -> Update README.md

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

.PHONY: fmt
fmt: fmt-r ## Format files

GIT_DIF_TARGET ?=
MODIFIED_R_FILES ?= $(shell R -s -e 'setdiff(system("git diff $(GIT_DIF_TARGET) --name-only | grep -e .*R$$ -e .*Rmd$$", intern = TRUE), "R/extendr-wrappers.R") |> cat()')

.PHONY: fmt-r
fmt-r: $(MODIFIED_R_FILES) ## Format R files
	$(foreach file, $^, $(shell R -q -e 'styler::style_file("$(file)"); styler.equals::style_file("$(file)")' >/dev/null))
