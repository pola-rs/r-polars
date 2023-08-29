.DEFAULT_GOAL := help

SHELL := /bin/bash
VENV := .venv

RUST_TOOLCHAIN_VERSION := nightly-2023-07-27

MANIFEST_PATH := src/rust/Cargo.toml

ifeq ($(OS),Windows_NT)
	VENV_BIN := $(VENV)/Scripts
	RUST_TOOLCHAIN := $(RUST_TOOLCHAIN_VERSION)-gnu
else
	VENV_BIN := $(VENV)/bin
	RUST_TOOLCHAIN := $(RUST_TOOLCHAIN_VERSION)
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
	Rscript -e 'pak::local_install_deps(dependencies = c("all", "Config/Needs/dev", "Config/Needs/website"), upgrade = FALSE)'

.venv:
	python3 -m venv $(VENV)

.PHONY: requirements-py
requirements-py: .venv
	$(VENV_BIN)/python -m pip install --upgrade pip
	$(VENV_BIN)/pip install --upgrade mkdocs-material

.PHONY: requirements-rs
requirements-rs:
	rustup toolchain install $(RUST_TOOLCHAIN)
	rustup default $(RUST_TOOLCHAIN)
	rustup component add rustfmt
	rustup component add clippy
	cargo install cargo-license

.PHONY: build
build: ## Compile polars R package with all features and generate Rd files
	export RPOLARS_FULL_FEATURES=true \
	&& Rscript -e 'if (!(require(arrow)&&require(nanoarrow))) warning("could not load arrow/nanoarrow, igonore changes to nanoarrow.Rd"); rextendr::document()'

.PHONY: install
install: ## Install the R package
	export RPOLARS_FULL_FEATURES=true \
	&& R CMD INSTALL --no-multiarch --with-keep.source .

.PHONY: all
all: fmt build test README.md LICENSE.note ## build -> test -> Update README.md, LICENSE.note

.PHONY: docs
docs: build install README.md docs/docs/reference_home.md ## Generate docs
	cp docs/mkdocs.orig.yml docs/mkdocs.yml
	Rscript -e 'altdoc::update_docs(custom_reference = "docs/make-docs.R")'
	cd docs && ../$(VENV_BIN)/python3 -m mkdocs build

.PHONY: docs-preview
docs-preview: ## Preview docs on local server. Needs `make docs`
	cd docs && ../$(VENV_BIN)/python3 -m mkdocs serve

README.md: README.Rmd build ## Update README.md
	Rscript -e 'devtools::load_all(); rmarkdown::render("README.Rmd")'

docs/docs/reference_home.md: docs/docs/reference_home.Rmd build ## Update the reference home page source
	Rscript -e 'devtools::load_all(); rmarkdown::render("docs/docs/reference_home.Rmd")'

LICENSE.note: src/rust/Cargo.lock ## Update LICENSE.note
	Rscript -e 'rextendr::write_license_note(force = TRUE)'

.PHONY: test
test: build install ## Run fast unittests
	Rscript -e 'devtools::test()'

.PHONY: fmt
fmt: fmt-rs fmt-r ## Format files

GIT_DIF_TARGET ?=
MODIFIED_R_FILES ?= $(shell R -s -e 'setdiff(system("git diff $(GIT_DIF_TARGET) --name-only | grep -e .*R$$ -e .*Rmd$$", intern = TRUE), "R/extendr-wrappers.R") |> cat()')

.PHONY: fmt-r
fmt-r: $(MODIFIED_R_FILES) ## Format R files
	$(foreach file, $^, $(shell R -q -e 'styler::style_file("$(file)"); styler.equals::style_file("$(file)")' >/dev/null))

.PHONY: fmt-rs
fmt-rs: ## Format Rust files
	cargo fmt --manifest-path $(MANIFEST_PATH)
