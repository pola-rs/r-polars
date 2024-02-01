# Developer Scripts

This repository houses opinionated scripts to simplify the development process. For CI workflows,
it is recommended to exclusively use the `./Makefile`.

## `source(styler_utils.R)`

The `styler_utils.R` script is derived from `styler` and has been optimized for parallel execution.
It utilizes `git diff`, `git status`, and identification of untracked files to determine which new
files require styling.

- `style_files()`: Automatically formats all modified files in parallel in a few seconds.
- `style_entire_pkg()`: Restyles any file in the repository. Primarily used for chore pull requests
to reset all files.

## `source(develop_polars.R)`

The `develop_polars.R` script provides opinionated presets for building polars during development,
addressing 95% of use cases. It is unnecessary to run this script in a new R session, as all
environment variables and loaded packages are reverted upon completion.

- `load_polars()`: Invokes `extendr::document()` with preset environment variables and loaded
packages.
- `build_polars()`: Initiates `R CMD install` with preset environment variables.
- `check_polars()`: Executes `devtools::check()` with preset environment variables and loaded
packages. Additionally, it reuses the Rust cache and target files, even when the `check` command
moves the working directory. The script deletes the temporary check directory afterward.
- `run_all_examples_collect_errors()`: Calls `pkgload::run_example()` and captures all errors.
Useful for running all examples at once without the need to manage restarts in case of errors.

Feel free to modify the formatting and details according to your preferences and the specific needs
of your project.
