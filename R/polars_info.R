#' Report information of the package
#'
#' @description `r lifecycle::badge("experimental")`
#' This function reports the following information:
#'
#' - Package versions (the Polars R package version and the dependent Rust
#'   Polars crate version)
#' - Number of threads used by Polars
#' - Rust feature flags (See `vignette("install", "polars")` for details)
#'
#' @return A list with information of the package
#' @export
#' @examples
#' polars_info()
#'
#' polars_info()$versions
#'
#' polars_info()$features$nightly
polars_info <- function() {
  # Similar to arrow::arrow_info()
  out <- list(
    versions = list(
      r_package = .self_version,
      rust_crate = rust_polars_version()
    ),
    thread_pool_size = thread_pool_size(),
    features = list(
      nightly = feature_nightly_enabled()
    )
  )
  structure(out, class = "polars_info_list")
}

#' @export
print.polars_info_list <- function(x, ...) {
  # Copied from the arrow package
  # https://github.com/apache/arrow/blob/6f3bd2524c2abe3a4a278fc1c62fc5c49b56cab3/r/R/arrow-info.R#L149-L157 # nolint
  print_key_values <- function(title, vals, ...) {
    df <- data.frame(vals, ...)
    names(df) <- ""

    cat(title, ":", sep = "")
    print(df)
    cat("\n")
  }

  cat("Polars R package version : ", format(x$versions$r_package), "\n", sep = "")
  cat("Rust Polars crate version: ", format(x$versions$rust_crate), "\n", sep = "")
  cat("\n")
  cat("Thread pool size:", x$thread_pool_size, "\n")
  cat("\n")
  print_key_values("Features", unlist(x$features))
}
