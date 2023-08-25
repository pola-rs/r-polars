#' load polars with environment variables and packages
#'
#' @param ALL_FEATURES bool, to compile with e.g. simd, only for nightly toolchain
#' @param NOT_CRAN bool, do not delete compiled target objects. Next compilation much faster.
#' @param RPOLARS_CARGO_CLEAN_DEPS bool, do clean up cargo cache. Slows down next compilation
#' @param ... other environment args to add
#' @details in general Makevars check if bool-like envvars are not 'true'.
#'
#' @return no return
#'
#' @examples load_polars(ALL_FEATURES = "", SOME_OTHER_ENVVAR = "true")
load_polars = function(
    RPOLARS_FULL_FEATURES = "true",
    NOT_CRAN = "true",
    RPOLARS_CARGO_CLEAN_DEPS = "false",
    ...,
    .packages = c("arrow", "nanoarrow")) {
  # bundle all envvars
  args = c(
    list(
      RPOLARS_FULL_FEATURES = RPOLARS_FULL_FEATURES,
      NOT_CRAN = NOT_CRAN,
      RPOLARS_CARGO_CLEAN_DEPS = RPOLARS_CARGO_CLEAN_DEPS
    ),
    list(...),
    .packages = list(.packages)
  )

  do.call(with_polars, c(list(rextendr::document), args))
}


#' load polars with environment variables and packages
#'
#' @param ALL_FEATURES bool, to compile with e.g. simd, only for nightly toolchain
#' @param NOT_CRAN bool, do not delete compiled target objects. Next compilation much faster.
#' @param RPOLARS_CARGO_CLEAN_DEPS bool, do clean up cargo cache. Slows down next compilation
#' @param ... other environment args to add
#' @details in general Makevars check if bool-like envvars are not 'true'.
#'
#' @return no return
#'
#' @examples load_polars(ALL_FEATURES = "", SOME_OTHER_ENVVAR = "true")
build_polars = function(
    RPOLARS_FULL_FEATURES = "true",
    NOT_CRAN = "true",
    RPOLARS_CARGO_CLEAN_DEPS = "false",
    ...,
    .packages = c("arrow", "nanoarrow")) {
  # bundle all envvars
  args = c(
    list(
      RPOLARS_FULL_FEATURES = RPOLARS_FULL_FEATURES,
      NOT_CRAN = NOT_CRAN,
      RPOLARS_CARGO_CLEAN_DEPS = RPOLARS_CARGO_CLEAN_DEPS
    ),
    list(...),
    .packages = list(.packages)
  )

  do.call(with_polars, c(list(\() system("cd ..; R CMD INSTALL --preclean --no-multiarch --with-keep.source r-polars")), args))
}

#' check polars with environment variables, filter errors, symlink  precompiled target
#'
#' @param RPOLARS_RUST_SOURCE where check can find precomiled target, set to '' if not use,
#' DEFAULT is `paste0(getwd(),"/src/rust")`.
#' @param ALL_FEATURES bool, to compile with e.g. simd, only for nightly toolchain
#' @param NOT_CRAN bool, do not delete compiled target objects. Next compilation much faster.
#' @param RPOLARS_CARGO_CLEAN_DEPS bool, do clean up cargo cache. Slows down next compilation
#' @param ... other environment args to add
#' @details in general Makevars check if bool-like envvars are not 'true'.
#'
#' @return no return
#'
#' @examples load_polars(ALL_FEATURES = "", SOME_OTHER_ENVVAR = "true")
check_polars = function(
    RPOLARS_RUST_SOURCE = paste0(getwd(), "/src/rust"),
    RPOLARS_FULL_FEATURES = "true",
    NOT_CRAN = "true",
    RPOLARS_CARGO_CLEAN_DEPS = "false",
    FILTER_CHECK_NO_FILTER = "false",
    ...,
    check_dir = "./check/",
    .packages = character()) {
  # bundle all envvars
  envvars = c(
    list(
      RPOLARS_RUST_SOURCE = RPOLARS_RUST_SOURCE,
      RPOLARS_FULL_FEATURES = RPOLARS_FULL_FEATURES,
      NOT_CRAN = NOT_CRAN,
      RPOLARS_CARGO_CLEAN_DEPS = RPOLARS_CARGO_CLEAN_DEPS
    ),
    list(...)
  )
  not_cran = identical(NOT_CRAN, "true")
  cat("check in not_cran mode:", not_cran, "\n")
  with_polars(
    \() {
      devtools::check(
        env_vars = envvars, check_dir = check_dir,
        vignettes = FALSE, cran = !not_cran
      )
      rextendr::document() # restore nanoarrow.Rd
    },
    RPOLARS_FULL_FEATURES = RPOLARS_FULL_FEATURES,
    NOT_CRAN = NOT_CRAN,
    RPOLARS_CARGO_CLEAN_DEPS = RPOLARS_CARGO_CLEAN_DEPS,
    RPOLARS_RUST_SOURCE = RPOLARS_RUST_SOURCE,
    ...
  )

  on.exit({
    unlink("check", recursive = TRUE)
  })
  source("./inst/misc/filter_rcmdcheck.R")
  print("check polars is done")
}

#' submit polars with environment variables, filter errors, symlink  precompiled target
#'
#' @param RPOLARS_RUST_SOURCE where check can find precomiled target, set to '' if not use,
#' DEFAULT is `paste0(getwd(),"/src/rust")`.
#' @param ALL_FEATURES bool, to compile with e.g. simd, only for nightly toolchain
#' @param NOT_CRAN bool, do not delete compiled target objects. Next compilation much faster.
#' @param RPOLARS_CARGO_CLEAN_DEPS bool, do clean up cargo cache. Slows down next compilation
#' @param ... other environment args to add
#' @details in general Makevars check if bool-like envvars are not 'true'.
#'
#' @return no return
#'
#' @examples load_polars(ALL_FEATURES = "", SOME_OTHER_ENVVAR = "true")
submit_polars = function(
    RPOLARS_RUST_SOURCE = paste0(getwd(), "/src/rust"),
    RPOLARS_FULL_FEATURES = "false",
    NOT_CRAN = "true",
    RPOLARS_CARGO_CLEAN_DEPS = "false",
    ...,
    temp_dir = tempdir(check = TRUE),
    .packages = character(),
    unlink_temp = TRUE) {
  # bundle all envvars
  envvars = c(
    list(
      RPOLARS_RUST_SOURCE = RPOLARS_RUST_SOURCE,
      RPOLARS_FULL_FEATURES = RPOLARS_FULL_FEATURES,
      NOT_CRAN = NOT_CRAN,
      RPOLARS_CARGO_CLEAN_DEPS = RPOLARS_CARGO_CLEAN_DEPS
    ),
    list(...)
  )
  not_cran = identical(NOT_CRAN, "true")
  cat("in not_cran mode:", not_cran, "\n")
  with_polars(
    \() {
      temp_dir = paste0(temp_dir, "/polars_submission")
      unlink(temp_dir, recursive = TRUE, force = TRUE)
      dir.create(temp_dir)
      # copy repo except target folders
      all_files = list.files(path = ".", full.names = TRUE, recursive = TRUE)
      non_target_files = setdiff(all_files, grep("^\\./src/rust/target", all_files, value = TRUE))
      non_target_dirs = gregexpr("/", non_target_files) |>
        lapply(tail, 1) |>
        substr(x = non_target_files, start = 1) |>
        unique() |>
        (\(x){
          x[order(nchar(x))][-1]
        })()
      for (i in paste0(temp_dir, "/", non_target_dirs)) dir.create(i)
      res = file.copy(non_target_files, paste0(temp_dir, "/", non_target_files))
      if (!all(res)) warning("copy incomplete")

      oldwd = getwd()
      setwd(temp_dir)
      on.exit({
        setwd(oldwd)
        if (unlink_temp) unlink(temp_dir, recursive = TRUE)
      })
      devtools::submit_cran()
    },
    RPOLARS_FULL_FEATURES = RPOLARS_FULL_FEATURES,
    NOT_CRAN = NOT_CRAN,
    RPOLARS_CARGO_CLEAN_DEPS = RPOLARS_CARGO_CLEAN_DEPS,
    RPOLARS_RUST_SOURCE = RPOLARS_RUST_SOURCE,
    ...
  )
}

with_polars = function(
    f,
    ...,
    .packages = character()) {
  # bundle all envvars
  envvar = list(...)
  stopifnot(all(sapply(names(envvar), nchar)))


  # write envvar to environment, store old
  old_tmp = list()
  for (i in seq_along(envvar)) {
    key = names(envvar)[i]
    old_val = Sys.getenv(key)
    old_tmp[[key]] = old_val
    do.call(Sys.setenv, envvar[key])
  }

  # add packages to search path
  if (length(.packages)) {
    not_in_search = .packages[!paste0("package:", .packages) %in% search()]
    for (i in not_in_search) {
      if (!require(i, character.only = TRUE)) warning(paste("did not preload package:", i))
    }
  } else {
    not_in_search = character()
  }

  # plan to restore old envvar and search()
  on.exit({
    # restore args
    do.call(Sys.setenv, old_tmp)

    # restore search
    for (i in not_in_search) {
      message(paste("detaching ", i))
      detach(paste0("package:", i), character.only = TRUE)
    }
  })

  # build

  out = f()

  invisible(out)
}


#' find compiled *.Rd files for missing return value
#'
#' @return char vec
#'
#' @examples
#' find_missing_return()
find_missing_return = function() {
  has_value = function(x) {
    found = character()

    has_value_recursive = function(x, lvl = 0) {
      for (i in x) {
        if (is.list(i)) has_value_recursive(i, lvl = lvl + 1)
        if (identical("\\value", attr(i, "Rd_tag"))) {
          found <<- c(found, substr(paste(unlist(i), collapse = " | "), 1, 25))
        }
      }
    }
    has_value_recursive(x)
    found
  }

  all_doc_values = list.files("./man/", full.names = TRUE) |>
    sapply(\(x) {
      tools::parse_Rd(x) |>
        unclass() |>
        has_value()
    })

  names(all_doc_values[sapply(all_doc_values, length) < 1])
}



#' run_all_examples collect error
#' @details reloading polars can be slow. For faster development running all
#'
#' pass return $oks to skip_these to not rerun oks again
#' @param skip_these names of doc files to skip, use for for not running non failed again
#' @return list of errors: list of all captured errors + print, oks names of files with no errors
#'
#' @export
#'
#' @examples
run_all_examples_collect_errors = \(skip_these=character()) {
  paths = list.files(full.names = TRUE, path = "./man/.")
  fnames = list.files(full.names = FALSE, path = "./man/.")
  names(paths) = fnames

  paths = paths[!fnames %in% skip_these]


  out = lapply(paths, \(path) {
    print(path)
    txt = capture.output(
      {err = polars:::result(pkgload::run_example(path=path))$err}
    )
    if(!is.null(err)) list(err=err,txt=txt)
  })

  list(errors = out[!sapply(out, is.null)], oks = names(out)[sapply(out, is.null)])
}

