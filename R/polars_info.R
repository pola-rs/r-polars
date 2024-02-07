#' Report information of the package
#'
#' This function reports the following information:
#' - Package versions (the R package version and the dependent Rust Polars version)
#' - [Number of threads used by Polars][pl_thread_pool_size]
#' - Rust feature flags (See `vignette("install", "polars")` for details)
#' @return A list with information of the package
#' @export
#' @examples
#' polars_info()
#'
#' polars_info()$rust_polars
#'
#' polars_info()$features$simd
polars_info = function() {
  # Similar to arrow::arrow_info()
  out = list(
    version = utils::packageVersion("polars"),
    rust_polars = rust_polars_version(),
    thread_pool_size = thread_pool_size(),
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
  cat("Thread pool size:", x$thread_pool_size, "\n")
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
#' It cannot be modified once `polars` is loaded.
#' It is strongly recommended not to override this value as it will be
#' set automatically by the engine.
#'
#' For compatibility with CRAN, the threadpool size is set to 2 by default.
#' To disable this behavior and let the engine determine the threadpool size,
#' one of the following ways can be used:
#'
#' - Enable the `disable_limit_max_threads` feature of the library.
#'   This can be done by setting the feature flag when installing the package.
#'   See the installation vignette (`vignette("install", "polars")`)
#'   for details.
#' - Set the `polars.limit_max_threads` option to `FALSE` with
#'   the [options()] function. Same as setting the `POLARS_MAX_THREADS` environment
#'   variable, this option must be set before loading the package.
#'
#' @return The number of threads
#' @examples
#' pl$thread_pool_size()
pl_thread_pool_size = function() thread_pool_size()

#' @rdname pl_thread_pool_size
pl_threadpool_size = function() {
  warning("`pl$threadpool_size()` is deprecated and will be removed in 0.15.0. Use `pl$thread_pool_size()` instead.")
  thread_pool_size()
}
