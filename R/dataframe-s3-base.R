#' @export
print.polars_data_frame <- function(x, ...) {
  x$`_df`$as_str() |>
    writeLines()
  invisible(x)
}

#' @export
dim.polars_data_frame <- function(x) x$shape

#' @export
length.polars_data_frame <- function(x) x$width

#' @export
names.polars_data_frame <- function(x) x$columns

#' Export the polars object as an R list
#'
#' This S3 method calls [`as_polars_df(x, ...)$get_columns()`][dataframe__get_columns] or
#' `as_polars_df(x, ...)$to_struct()$to_r_vector(ensure_vector = TRUE)` depending on the `as_series` argument.
#'
#' Arguments other than `x` and `as_series` are passed to [`<Series>$to_r_vector()`][series__to_r_vector],
#' so they are ignored when `as_series=TRUE`.
#' @inheritParams series__to_r_vector
#' @param x A polars object
#' @param ... Passed to [as_polars_df()].
#' @param as_series Whether to convert each column to an [R vector][vector] or a [Series].
#' If `TRUE` (default), return a list of [Series], otherwise a list of [vectors][vector].
#' @return A [list]
#' @seealso
#' - [`<DataFrame>$get_columns()`][dataframe__get_columns]
#' @examples
#' df <- as_polars_df(list(a = 1:3, b = 4:6))
#'
#' as.list(df, as_series = TRUE)
#' as.list(df, as_series = FALSE)
#'
#' as.list(df$lazy(), as_series = TRUE)
#' as.list(df$lazy(), as_series = FALSE)
#' @export
#' @rdname s3-as.list
as.list.polars_data_frame <- function(
  x,
  ...,
  as_series = TRUE,
  uint8 = c("integer", "raw"),
  int64 = c("double", "character", "integer", "integer64"),
  date = c("Date", "IDate"),
  time = c("hms", "ITime"),
  struct = c("dataframe", "tibble"),
  decimal = c("double", "character"),
  as_clock_class = FALSE,
  ambiguous = c("raise", "earliest", "latest", "null"),
  non_existent = c("raise", "null")
) {
  if (isTRUE(as_series)) {
    as_polars_df(x, ...)$get_columns()
  } else {
    as_polars_df(x, ...)$to_struct()$to_r_vector(
      ensure_vector = TRUE,
      uint8 = uint8,
      int64 = int64,
      date = date,
      time = time,
      struct = struct,
      decimal = decimal,
      as_clock_class = as_clock_class,
      ambiguous = ambiguous,
      non_existent = non_existent
    )
  }
}

#' Export the polars object as an R DataFrame
#'
#' This S3 method is a shortcut for
#' [`as_polars_df(x, ...)$to_struct()$to_r_vector(ensure_vector = FALSE, struct = "dataframe")`][series__to_r_vector].
#' @inheritParams as.list.polars_data_frame
#' @return An [R data frame][data.frame]
#' @examples
#' df <- as_polars_df(list(a = 1:3, b = 4:6))
#'
#' as.data.frame(df)
#' as.data.frame(df$lazy())
#' @export
#' @rdname s3-as.data.frame
as.data.frame.polars_data_frame <- function(
  x,
  ...,
  uint8 = c("integer", "raw"),
  int64 = c("double", "character", "integer", "integer64"),
  date = c("Date", "IDate"),
  time = c("hms", "ITime"),
  decimal = c("double", "character"),
  as_clock_class = FALSE,
  ambiguous = c("raise", "earliest", "latest", "null"),
  non_existent = c("raise", "null")
) {
  as_polars_df(x, ...)$to_struct()$to_r_vector(
    ensure_vector = FALSE,
    uint8 = uint8,
    int64 = int64,
    date = date,
    time = time,
    struct = "dataframe",
    decimal = decimal,
    as_clock_class = as_clock_class,
    ambiguous = ambiguous,
    non_existent = non_existent
  )
}
