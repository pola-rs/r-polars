# R Polars Development Guide

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

R Polars is an R package that provides bindings to the Polars Rust library using the savvy framework. This is a hybrid R+Rust codebase that requires both R and Rust development tools.

## Working Effectively

### Bootstrap and Setup (REQUIRED FIRST)
The environment is automatically configured via GitHub Actions setup steps in `.github/workflows/copilot-setup-steps.yml`. This includes:
- R (latest version) with essential development packages (devtools, pkgbuild, testthat, lintr, pkgload)
- Rust toolchain with cargo and rustc
- savvy-cli for R wrapper generation
- Task runner for project automation
- mold linker for faster builds
- Rust cache for improved build times

If setup steps are not automatically executed, the environment may not be fully configured for r-polars development.

### Environment Variables (CRITICAL)
Always set these environment variables before building:
```bash
export NOT_CRAN=true
export LIBR_POLARS_BUILD=true
export DEBUG=true  # for debug builds, false for release builds
```

**Note**: These environment variables are automatically set by the Taskfile.yml when using `task` commands.

### Build Process (NEVER CANCEL - LONG RUNNING)
**Option 1: Using Task (Recommended)**
- `task build-rust` -- Builds Rust library with proper environment variables
- `task build-documents` -- Generates R documentation
- `task test-all` -- Runs full test suite

**Option 2: Manual Commands**
1. Generate R wrappers: `savvy-cli update .` -- takes 10-30 seconds
2. **CRITICAL**: Compile Rust library: `Rscript -e 'pkgbuild::compile_dll()'` 
   - **NEVER CANCEL**: Debug build takes ~5 minutes, release build takes ~10+ minutes
   - **ALWAYS** set timeout to 15+ minutes minimum, 25+ minutes for release builds
   - Uses significant CPU and memory resources
3. Generate documentation: `Rscript -e 'devtools::document()'` -- takes 1-2 minutes

### Testing (NEVER CANCEL - VERY LONG RUNNING)
**Option 1: Using Task (Recommended)**
- `task test-all` -- Runs full test suite with proper environment
- `task test-source` -- Runs all tests for source code

**Option 2: Manual Commands**
- **CRITICAL**: Full test suite: `Rscript -e 'devtools::test()'`
  - **NEVER CANCEL**: Takes 15-25 minutes to complete with 3100+ tests
  - **ALWAYS** set timeout to 30+ minutes minimum
  - Tests run in parallel by default
  - Expect some failures in development environment
- Single test file: `Rscript -e 'devtools::test(filter="filename")' ` -- takes 10-60 seconds per file
- Basic functionality test: `Rscript -e 'devtools::load_all(); library(polars); df <- pl$DataFrame(a=1:3, b=letters[1:3]); print(df)'`

## Validation Scenarios
After making any changes, ALWAYS run through these validation steps:

### Basic Development Workflow Validation
**Option 1: Using Task (Recommended)**
1. **ALWAYS** run the build process first: `task build-rust`
2. **ALWAYS** test basic functionality: `Rscript -e 'devtools::load_all(); df <- pl$DataFrame(x=1:3); print(df); print(as.data.frame(df))'`
3. Run a subset of tests: `Rscript -e 'devtools::test(filter="polars_options")'` (takes ~15 seconds)
4. **CRITICAL**: For major changes, run full test suite: `task test-all` with proper timeout

**Option 2: Manual Commands**
1. **ALWAYS** run the build process first: `savvy-cli update . && Rscript -e 'pkgbuild::compile_dll()'`
2. **ALWAYS** test basic functionality: `Rscript -e 'devtools::load_all(); df <- pl$DataFrame(x=1:3); print(df); print(as.data.frame(df))'`
3. Run a subset of tests: `Rscript -e 'devtools::test(filter="polars_options")'` (takes ~15 seconds)
4. **CRITICAL**: For major changes, run full test suite with proper timeout

### Linting and Formatting (REQUIRED BEFORE COMMITS)
**Option 1: Using Task (Recommended)**
- Format all files: `task format-all` or `task fmt`
- Format R code: `task format-r` 
- Format Rust code: `task format-rust`

**Option 2: Manual Commands**
- Format R code: Requires `air` tool (not available in basic environment) - use GitHub Actions
- Check R lint: `Rscript -e 'pkgload::load_all(); lintr::lint_package(cache=FALSE)'` -- takes 2-3 minutes
- Format Rust code: `cd src/rust && rustup component add rustfmt && cargo fmt --all`
- Check Rust lint: `cd src/rust && rustup component add clippy && cargo clippy --all-targets --all-features --locked`

## Critical Timing and Resource Requirements

### NEVER CANCEL Operations
These operations MUST complete and should NEVER be cancelled:

1. **Rust Compilation** (`pkgbuild::compile_dll()`):
   - Debug build: 5-7 minutes (set timeout to 15+ minutes)
   - Release build: 10-20 minutes (set timeout to 25+ minutes)
   - Uses heavy CPU and memory during compilation

2. **Full Test Suite** (`devtools::test()`):
   - Complete run: 15-25 minutes (set timeout to 40+ minutes)
   - 3100+ individual tests across ~100 test files
   - Memory intensive due to data processing tests

3. **Documentation Generation** (`devtools::document()`):
   - 1-3 minutes for full regeneration (set timeout to 10+ minutes)

### Quick Operations (under 1 minute)
- `savvy-cli update .`: ~30 seconds
- Single test file: 10-60 seconds
- Rust formatting: ~5 seconds
- R linting: 2-3 minutes

## Common Development Patterns

### Making Changes to Rust Code
1. Edit files in `src/rust/src/`
2. Run `savvy-cli update .` to regenerate R wrappers
3. Run `pkgbuild::compile_dll()` to rebuild -- **NEVER CANCEL, takes 5+ minutes**
4. Test changes with `devtools::load_all()`

### Making Changes to R Code
1. Edit files in `R/` directory (avoid auto-generated files)
2. Run `devtools::document()` if changing documentation
3. Test with `devtools::load_all()` and manual verification
4. Run targeted tests: `devtools::test(filter="relevant_test")`

### Adding New Features
1. **ALWAYS** check Python Polars documentation for API consistency
2. Implement Rust bindings in appropriate `src/rust/src/` module
3. Add R wrapper functions in appropriate `R/` file
4. Add comprehensive tests in `tests/testthat/test-*.R`
5. Update documentation with roxygen2 comments
6. **CRITICAL**: Run full build and test cycle before submitting

## Additional Resources

For comprehensive development information, see `DEVELOPMENT.md` in the repository root, which covers:
- Detailed system requirements and setup
- Translation patterns from Python Polars
- Value conversion between Polars and R
- Writing and running tests with testthat and patrick
- Repository structure and development tools

## Troubleshooting

### Build Failures
- Check Rust toolchain: `rustc --version && cargo --version`
- Verify environment variables are set correctly
- Clear cache: `rm -rf src/rust/target` and rebuild
- Check for out-of-memory issues during compilation
- **Environment Issues**: If tools are missing, the environment may not be properly configured via `.github/workflows/copilot-setup-steps.yml`

### Test Failures
- Run individual failing tests: `devtools::test(filter="test_name")`
- Check if failure is environment-specific (some tests may fail in containers)
- Verify package loads: `devtools::load_all()`

### Performance Issues
- Use debug builds during development (faster compilation)
- Consider using `mold` linker if available for faster Rust linking
- Monitor memory usage during test runs

Remember: This is a complex hybrid R+Rust package. Always allow sufficient time for build and test operations, and never cancel long-running compilation processes.
