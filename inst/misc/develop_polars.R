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
#' @examples load_polars(ALL_FEATURES = '', SOME_OTHER_ENVVAR = 'true')
load_polars = function(
  RPOLARS_ALL_FEATURES = 'true',
  NOT_CRAN = 'true',
  RPOLARS_CARGO_CLEAN_DEPS = 'false',
  ...,
  .packages = c("arrow","nanoarrow")
) {

  # bundle all envvars
  args = c(
    list(
      RPOLARS_ALL_FEATURES = RPOLARS_ALL_FEATURES,
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
#' @examples load_polars(ALL_FEATURES = '', SOME_OTHER_ENVVAR = 'true')
build_polars = function(
  RPOLARS_ALL_FEATURES = 'true',
  NOT_CRAN = 'true',
  RPOLARS_CARGO_CLEAN_DEPS = 'false',
  ...,
  .packages = c("arrow","nanoarrow")
) {

  # bundle all envvars
  args = c(
    list(
      RPOLARS_ALL_FEATURES = RPOLARS_ALL_FEATURES,
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
#' @examples load_polars(ALL_FEATURES = '', SOME_OTHER_ENVVAR = 'true')
check_polars = function(
  RPOLARS_RUST_SOURCE = paste0(getwd(),"/src/rust"),
  RPOLARS_ALL_FEATURES = 'true',
  NOT_CRAN = 'true',
  RPOLARS_CARGO_CLEAN_DEPS = 'false',
  FILTER_CHECK_NO_FILTER = 'false',
  ...,
  check_dir = "./check/",
  .packages = character()
) {

  # bundle all envvars
  envvars = c(
    list(
      RPOLARS_RUST_SOURCE = RPOLARS_RUST_SOURCE,
      RPOLARS_ALL_FEATURES = RPOLARS_ALL_FEATURES,
      NOT_CRAN = NOT_CRAN,
      RPOLARS_CARGO_CLEAN_DEPS = RPOLARS_CARGO_CLEAN_DEPS
    ),
    list(...)
  )
  not_cran = identical(NOT_CRAN,'true')
  cat("check in not_cran mode:", not_cran ,"\n")
  with_polars(
    \() {
      devtools::check(
        env_vars = envvars, check_dir = check_dir,
        vignettes = FALSE, cran = !not_cran
      )
      rextendr::document() # restore nanoarrow.Rd
    },
    RPOLARS_ALL_FEATURES = RPOLARS_ALL_FEATURES,
    NOT_CRAN = NOT_CRAN,
    RPOLARS_CARGO_CLEAN_DEPS = RPOLARS_CARGO_CLEAN_DEPS,
    RPOLARS_RUST_SOURCE = RPOLARS_RUST_SOURCE,
    ...
  )

  on.exit({unlink("check",recursive = TRUE)})
  source("./inst/misc/filter_rcmdcheck.R")
  print("check polars is done")
}

with_polars = function(
  f,
  ...,
  .packages = character()
) {
  # bundle all envvars
  envvar = list(...)
  stopifnot(all(sapply(names(envvar),nchar)))


  # write envvar to environment, store old
  old_tmp = list()
  for(i in seq_along(envvar)) {
    key = names(envvar)[i]
    old_val = Sys.getenv(key)
    old_tmp[[key]] = old_val
    do.call(Sys.setenv, envvar[key])
  }

  # add packages to search path
  if(length(.packages)) {
    not_in_search = .packages[!paste0("package:",.packages) %in% search()]
    for(i in not_in_search) {
      if(!require(i, character.only = TRUE))  warning(paste("did not preload package:", i))
    }
  } else {
    not_in_search = character()
  }

  #plan to restore old envvar and search()
  on.exit({
    # restore args
    do.call(Sys.setenv, old_tmp)

    # restore search
    for(i in not_in_search) {
      message(paste("detaching ", i))
      detach(paste0("package:",i),character.only = TRUE)
    }
  })

  # build

  out = f()

  invisible(out)
}

