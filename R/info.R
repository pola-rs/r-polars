#' Report information of the package
#'
#' @return A list with information of the package
#' @name polars_info
#' @examples
#' polars_info()
pl$polars_info = function() {
  # Similar to arrow::arrow_info()
  out = list(
    version = utils::packageVersion("polars"),
    features = FeatureInfo$new()$to_r()
  )

  structure(out, class = "polars_info")
}

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

  cat("R Polars package version: ", format(x$version), "\n\n", sep = "")
  print_key_values("Features", unlist(x$features))
}
