.DEFAULT_GOAL := help

SHELL := /bin/bash
VENV := .venv_altdoc

RUST_TOOLCHAIN_VERSION := $(shell Rscript -e 'read.dcf("DESCRIPTION", fields = "Config/polars/RustToolchainVersion", all = TRUE)[1, 1] |> cat()')

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
	$(VENV_BIN)/pip install --upgrade mkdocs
	$(VENV_BIN)/pip install --upgrade mkdocs-material

.PHONY: requirements-rs
requirements-rs:
	rustup toolchain install $(RUST_TOOLCHAIN)
	rustup default $(RUST_TOOLCHAIN)
	rustup component add rustfmt
	rustup component add clippy
	if [[ -z "$(CI)" ]]; then \
		cargo install cargo-license; \
	fi

.PHONY: build
build: ## Compile polars R package with all features and generate Rd files
	export NOT_CRAN=true \
	&& export LIBR_POLARS_BUILD=true \
	&& export RPOLARS_FULL_FEATURES=true \
	&& Rscript -e 'if (!(require(arrow) && require(nanoarrow) && require(knitr))) warning("could not load arrow/nanoarrow/knitr, ignore changes to nanoarrow.Rd or knit_print.Rd"); rextendr::document()'

.PHONY: install
install: ## Install the R package
	export NOT_CRAN=true \
	&& export LIBR_POLARS_BUILD=true \
	&& export RPOLARS_FULL_FEATURES=true \
	&& R CMD INSTALL --no-multiarch --with-keep.source .

.PHONY: all
all: fmt tools/lib-sums.tsv build test README.md LICENSE.note ## build -> test -> Update README.md, LICENSE.note

.PHONY: docs
docs: build install README.md altdoc/reference_home.md ## Generate docs
	Rscript -e 'future::plan(future::multicore); source("altdoc/altdoc_preprocessing.R"); altdoc::render_docs(freeze = FALSE, parallel = TRUE, verbose = TRUE)'

.PHONY: docs-preview
docs-preview: ## Preview docs on local server. Needs `make docs`
	Rscript -e 'altdoc::preview_docs()'

README.md: README.Rmd build ## Update README.md
	Rscript -e 'devtools::load_all(); rmarkdown::render("README.Rmd")'

altdoc/reference_home.md: altdoc/reference_home.Rmd build ## Update the reference home page source
	Rscript -e 'devtools::load_all(); rmarkdown::render("altdoc/reference_home.Rmd")'

LICENSE.note: src/rust/Cargo.lock ## Update LICENSE.note
	Rscript -e 'rextendr::write_license_note(force = TRUE)'

.PHONY: tools/lib-sums.tsv
tools/lib-sums.tsv: ## Update the lib-sums.tsv file for pointing to the latest versions of the binary libraries
	Rscript dev/generate-lib-sums.R

.PHONY: test
test: build install ## Run fast unittests
	Rscript -e 'devtools::test(); devtools::run_examples(document = FALSE)'

.PHONY: fmt
fmt: fmt-rs fmt-r ## Format files

.PHONY: fmt-r
fmt-r: ## Format R files, set envvar GIT_DIF_TARGET to git diff branch target. Default is "main".
	Rscript -e 'source("./dev/styler_utils.R"); style_files()'

.PHONY: fmt-rs
fmt-rs: ## Format Rust files
	cargo fmt --manifest-path $(MANIFEST_PATH)
