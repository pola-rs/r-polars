# Output (ND)JSON functions: sink_json, sink_ndjson, write_json, write_ndjson

# TODO: add sink_json / sink_ndjson

#' Serialize to JSON representation
#'
#' @param file File path to which the result will be written.
#'
#' @inherit dataframe__write_parquet return
#' @examplesIf requireNamespace("jsonlite", quiet = TRUE)
#' dat <- as_polars_df(head(mtcars))
#' destination <- tempfile()
#'
#' dat$select(pl$col("drat", "mpg"))$write_json(destination)
#' jsonlite::fromJSON(destination)
dataframe__write_json <- function(file) {
  wrap({
    self$`_df`$write_json(file)
    invisible(self)
  })
}

#' Serialize to newline delimited JSON representation
#'
#' @inheritParams dataframe__write_ndjson
#' @inherit dataframe__write_parquet return
#' @examplesIf requireNamespace("jsonlite", quiet = TRUE)
#' dat <- as_polars_df(head(mtcars))
#' destination <- tempfile()
#'
#' dat$select(pl$col("drat", "mpg"))$write_ndjson(destination)
#' jsonlite::stream_in(file(destination))
dataframe__write_ndjson <- function(file) {
  wrap({
    self$`_df`$write_ndjson(file)
    invisible(self)
  })
}
