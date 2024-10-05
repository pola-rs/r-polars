# exported in zzz.R
#' Export the polars object as a tibble data frame
#'
#' @details
#' ## S3 method for [polars_data_frame][DataFrame]
#'
#' This S3 method is basically a shortcut of
#' [`<DataFrame>$to_struct()$to_r_vector(ensure_vector = FALSE, struct = "tibble")`][series__to_r_vector].
#' Additionally, you can check or repair the column names by specifying the `.name_repair` argument.
#' Because polars [DataFrame] allows empty column name, which is not generally valid column name in R data frame.
#'
#' ## S3 method for [polars_lazy_frame][LazyFrame]
#'
#' This S3 method is a shortcut for `as_polars_df(x, ...) |> tibble::as_tibble()`.
#' Additional arguments `...` are passed to [as_polars_df()].
#' @inheritParams as.data.frame.polars_data_frame
#' @inheritParams tibble::as_tibble
#' @return A [tibble][tibble::tbl_df]
#' @seealso
#' - [`as.data.frame(<polars_object>)`][as.data.frame.polars_data_frame]: Export the polars object as a basic data frame.
#' @examplesIf requireNamespace("tibble", quietly = TRUE)
#' # Polars DataFrame may have empty column name
#' df <- pl$DataFrame(x = 1:2, c("a", "b"))
#' df
#'
#' # Without checking or repairing the column names
#' tibble::as_tibble(df, .name_repair = "minimal")
#' tibble::as_tibble(df$lazy(), .name_repair = "minimal")
#'
#' # You can make that unique
#' tibble::as_tibble(df, .name_repair = "unique")
#' tibble::as_tibble(df$lazy(), .name_repair = "unique")
#' @rdname s3-as_tibble
as_tibble.polars_data_frame <- function(
    x, ...,
    .name_repair = c("check_unique", "unique", "universal", "minimal"),
    int64 = c("double", "character", "integer", "integer64"),
    date = c("Date", "IDate"),
    time = c("hms", "ITime"),
    decimal = c("double", "character"),
    as_clock_class = FALSE,
    ambiguous = c("raise", "earliest", "latest", "null"),
    non_existent = c("raise", "null")) {
  x$to_struct()$to_r_vector(
    ensure_vector = FALSE,
    int64 = int64,
    date = date,
    time = time,
    struct = "tibble",
    decimal = decimal,
    as_clock_class = as_clock_class,
    ambiguous = ambiguous,
    non_existent = non_existent
  ) |>
    tibble::as_tibble(.name_repair = .name_repair)
}
