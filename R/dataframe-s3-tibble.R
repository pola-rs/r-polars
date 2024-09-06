# exported in zzz.R
#' Export the polars object as a tibble data frame
#'
#' This S3 method is basically a shortcut of
#' [`<DataFrame>$to_struct()$to_r_vector(ensure_vector = FALSE, struct = "tibble")`][series__to_r_vector].
#' Additionally, you can check or repair the column names by specifying the `.name_repair` argument.
#' Because polars [DataFrame] allows empty column name, which is not generally valid column name in R data frame.
#' @inheritParams as.data.frame.polars_data_frame
#' @inheritParams tibble::as_tibble
#' @return A [tibble][tibble::tbl_df]
#' @seealso
#' - [`as.data.frame(<polars_data_frame>)`][as.data.frame.polars_data_frame]: Export the polars object as a basic data frame.
#' @examplesIf requireNamespace("tibble", quietly = TRUE)
#' # Polars DataFrame may have empty column name
#' df <- pl$DataFrame(x = 1:2, c("a", "b"))
#' df
#'
#' # Without checking or repairing the column names
#' tibble::as_tibble(df, .name_repair = "minimal")
#'
#' # You can make that unique
#' tibble::as_tibble(df, .name_repair = "unique")
#' @rdname s3_as_tibble
as_tibble.polars_data_frame <- function(
    x, ...,
    .name_repair = "check_unique",
    int64 = "double",
    as_clock_class = FALSE,
    ambiguous = "raise",
    non_existent = "raise") {
  x$to_struct()$to_r_vector(
    ensure_vector = FALSE,
    int64 = int64,
    struct = "tibble",
    as_clock_class = as_clock_class,
    ambiguous = ambiguous,
    non_existent = non_existent
  ) |>
    tibble::as_tibble(.name_repair = .name_repair)
}
