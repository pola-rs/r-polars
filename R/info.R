# get version of rust-polars version from Cargo.lock at package build time
RUST_POLARS_VERSION = (\() {
  Cargo.lock = readLines("./src/rust/Cargo.lock")
  polars.idx = which(Cargo.lock == r"{name = "polars"}")[1]
  if(is.finite(polars.idx)) for(i in polars.idx + 1:10) {
    this_line = Cargo.lock[i]
    if(i > length(Cargo.lock) || this_line == "[[package]]") break()
    if(isTRUE(substr(this_line,1,7) == "version")) return(substr(this_line,12,nchar(this_line)-1))
  }
  warning("failed to find RUST_POLARS_VERSION version")
  "unknown"
})()


#' Report information of the package
#'
#' @return A list with information of the package
#' @name polars_info
#' @examples
#' pl$polars_info()
pl$polars_info = function() {
  # Similar to arrow::arrow_info()
  out = list(
    version = utils::packageVersion("polars"),
    rust_polars = RUST_POLARS_VERSION,
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

  cat("r-polars package version : ", format(x$version), "\n", sep = "")
  cat("rust-polars crate version: ", format(x$rust_polars), "\n", sep = "")
  cat("\n")
  print_key_values("Features", unlist(x$features))
}
