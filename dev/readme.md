## developer scripts
This folder contains opinionated scripts to ease development. For CI workflows use only the
Makefile.

### `source(styler_utils.R)` 
Is derived from styler and optimized to run fast in parallel. Uses git diff + git status + git
untracked files to decide what new files to style.

 - `style_files()` auto format all modified files in parallel, takes 1-8 second typically.
 - `style_entire_pkg()` Restyle any file in repo. Mainly used for a chore PR to reset all files.

### `source(develop_polars.R)` 
Some oppinionated presets for building polars for development which will work 95% of cases. I should
not be necessary to run in a new R sessions as all environment variables and loaded packages are
finally reverted when done.

 - `load_polars()` calls `extendr::document()` with preset envars and loaded packages 
 - `build_polars()` calls `R CMD install` with preset envars
 - `check_polars()` calls `devtools::check()` with preset envars and loaded packages. Also reuses
rust cache and target files even though `check` moves the workdir. Deletes the check temp dir after.
 - `run_all_examples_collect_errors()` calls `pkgload::run_example()` and catches all errors. Useful
 to just run all examples once, without fiddling with restart if error.
