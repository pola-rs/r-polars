.dependencies <- c(
  "bit64",
  "blob",
  "clock",
  "hms",
  "tibble",
  "vctrs"
)

.platform <- R.version$platform

.r_version <- R.version$version.string

.get_dependency_version <- function(pkg) {
  tryCatch(
    as.character(utils::packageVersion(pkg)),
    error = function(e) "<not installed>"
  )
}

# TODO: what the difference between this and `polars_info()`?
pl__show_versions <- function() {
  main_data <- c(
    `Polars:` = .get_dependency_version("neopolars"),
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
}
