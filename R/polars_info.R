#' @export
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
  structure(out, class = "polars_info")
}

#' @export
print.polars_info <- function(x, ...) {
  # Copied from the arrow package
  # https://github.com/apache/arrow/blob/6f3bd2524c2abe3a4a278fc1c62fc5c49b56cab3/r/R/arrow-info.R#L149-L157
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
