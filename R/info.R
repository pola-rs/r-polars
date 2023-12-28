#' Report information of the package
#'
#' @return A list with information of the package
#' @name polars_info
#' @examples
#' pl$polars_info()
# TODO: Link to the installation vignette
pl_polars_info = function() {
  # Similar to arrow::arrow_info()
  out = list(
    version = utils::packageVersion("polars"),
    rust_polars = rust_polars_version(),
    threadpool_size = threadpool_size(),
    features = cargo_rpolars_feature_info()
  )
  structure(out, class = "polars_info")
}


#' @noRd
#' @export
print.polars_info = function(x, ...) {
  # Copied from the arrow package
  # https://github.com/apache/arrow/blob/6f3bd2524c2abe3a4a278fc1c62fc5c49b56cab3/r/R/arrow-info.R#L149-L157
  print_key_values = function(title, vals, ...) {
    df = data.frame(vals, ...)
    names(df) = ""

    cat(title, ":", sep = "")
    print(df)
    cat("\n")
  }

  cat("r-polars package version : ", format(x$version), "\n", sep = "")
  cat("rust-polars crate version: ", format(x$rust_polars), "\n", sep = "")
  cat("\n")
  cat("Thread pool size:", x$threadpool_size, "\n")
  cat("\n")
  print_key_values("Features", unlist(x$features))
}


#' Check Rust feature flag
#'
#' Raise error if the feature is not enabled
#' @noRd
#' @param feature_name name of feature to check
#' @inheritParams unwrap
#' @return TRUE invisibly if the feature is enabled
#' @examples
#' tryCatch(
#'   check_feature("simd", "in example"),
#'   error = \(e) cat(as.character(e))
#' )
#' tryCatch(
#'   check_feature("rpolars_debug_print", "in example"),
#'   error = \(e) cat(as.character(e))
#' )
check_feature = function(feature_name, context = NULL, call = sys.call(1L)) {
  if (!cargo_rpolars_feature_info()[[feature_name]]) {
    Err_plain(
      "\nFeature '", feature_name, "' is not enabled.\n",
      "Please check the documentation about installation\n",
      "and re-install with the feature enabled.\n"
    ) |>
      unwrap(context, call)
  }

  invisible(TRUE)
}


#' Get the number of threads in the Polars thread pool.
#'
#' The threadpool size can be overridden by setting the
#' `POLARS_MAX_THREADS` environment variable before process start.
#' (The thread pool is not behind a lock, so it cannot be modified once set).
#' It is strongly recommended not to override this value as it will be
#' set automatically by the engine.
#'
#' @name threadpool_size
#' @return The number of threads
#' @examples
#' pl$threadpool_size()
pl$threadpool_size = function() threadpool_size()
