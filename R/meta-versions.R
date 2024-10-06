.dependencies <- c(
  "bit64",
  "blob",
  "clock",
  "data.table",
  "hms",
  "tibble",
  "vctrs"
)

.platform <- R.version$platform

.r_version <- R.version$version.string

.self_version <- as.character(utils::packageVersion("neopolars"))

.get_dependency_version <- function(pkg) {
  tryCatch(
    as.character(utils::packageVersion(pkg)),
    error = function(e) "<not installed>"
  )
}

# TODO: what the difference between this and `polars_info()`?
#' Print out the version of Polars and its optional dependencies
#'
#' `r lifecycle::badge("experimental")`
#' Print out the version of Polars and its optional dependencies.
#'
#' These packages may be used for exporting [Series] to R.
#' See [`<Series>$to_r_vector()`][series__to_r_vector] for details.
#' - [bit64][bit64::bit64-package]
#' - [blob][blob::blob]
#' - [clock][clock::clock-package]
#' - [data.table][data.table::data.table-package]
#' - [hms][hms::hms-package]
#' - [tibble][tibble::tibble-package]
#' - [vctrs][vctrs::vctrs-package]
#' @return `NULL` invisibly.
#' @examples
#' pl$show_versions()
pl__show_versions <- function() {
  main_data <- c(
    `Polars:` = .self_version,
    `Platform:` = .platform,
    `R:` = .r_version
  ) |>
    data.frame()

  dep_data <- .dependencies |>
    lapply(.get_dependency_version) |>
    as.character() |>
    set_names(paste0(.dependencies, ":")) |>
    data.frame()

  names(main_data) <- ""
  names(dep_data) <- ""

  cat("--------Version info---------")
  print(main_data, right = FALSE)
  cat("\n----Optional dependencies----")
  print(dep_data, right = FALSE)
  cat("\n")

  invisible()
}
