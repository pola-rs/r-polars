#' @export
print.polars_data_frame <- function(x, ...) {
  x$`_df`$print()
  invisible(x)
}

#' @export
dim.polars_data_frame <- function(x) x$shape

#' @export
length.polars_data_frame <- function(x) x$width

#' Export the polars object as an R list
#'
#' This S3 method calls [`<DataFrame>$get_columns()`][dataframe__get_columns] or
#' [`<DataFrame>$to_r_list()`][dataframe__to_r_list] depending on the `as_series` argument.
#'
#' Arguments other than `x` and `as_series` are passed to [`<Series>$to_r_vector()`][series__to_r_vector],
#' so they are ignored when `as_series=TRUE`.
#' @inheritParams dataframe__to_r_list
#' @param x A polars object
#' @param ... Ignored
#' @param as_series Whether to convert each column to an [R vector][vector] or a [Series].
#' If `TRUE`, return a list of [Series], otherwise a list of [vectors][vector] (default).
#' @return A [list]
#' @seealso
#' - [`<DataFrame>$get_columns()`][dataframe__get_columns]
#' - [`<DataFrame>$to_r_list()`][dataframe__to_r_list]
#' @examples
#' df <- as_polars_df(list(a = 1:3, b = 4:6))
#'
#' as.list(df, as_series = TRUE)
#' as.list(df, as_series = FALSE)
#' @export
#' @rdname s3-as.list
as.list.polars_data_frame <- function(
    x, ...,
    as_series = FALSE,
    int64 = "double",
    struct = "dataframe",
    decimal = "double",
    as_clock_class = FALSE,
    ambiguous = "raise",
    non_existent = "raise") {
  if (isTRUE(as_series)) {
    x$get_columns()
  } else {
    x$to_r_list(
      int64 = int64,
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
#' @details
#' ## S3 method for [polars_data_frame][DataFrame]
#'
#' This S3 method is a shortcut for
#' [`<DataFrame>$to_struct()$to_r_vector(ensure_vector = FALSE, struct = "dataframe")`][series__to_r_vector].
#'
#' ## S3 method for [polars_lazy_frame][LazyFrame]
#'
#' This S3 method is a shortcut for `as_polars_df(x, ...) |> as.data.frame()`.
#' Additional arguments `...` are passed to [as_polars_df()].
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
    x, ...,
    int64 = "double",
    decimal = "double",
    as_clock_class = FALSE,
    ambiguous = "raise",
    non_existent = "raise") {
  x$to_struct()$to_r_vector(
    ensure_vector = FALSE,
    int64 = int64,
    struct = "dataframe",
    decimal = decimal,
    as_clock_class = as_clock_class,
    ambiguous = ambiguous,
    non_existent = non_existent
  )
}
