# nolint start: object_name_linter

# exported in zzz.R
#' Export the polars object as a tibble data frame
#'
#' This S3 method is basically a shortcut of
#' [`as_polars_df(x, ...)$to_struct()$to_r_vector(struct = "tibble")`]
#' [series__to_r_vector].
#' Additionally, you can check or repair the column names by specifying the `.name_repair` argument.
#' Because polars [DataFrame] allows empty column name, which is not generally valid column name
#' in R data frame.
#' @inheritParams as.data.frame.polars_data_frame
#' @inheritParams tibble::as_tibble
#' @return A [tibble][tibble::tbl_df]
#' @seealso
#' - [`as.data.frame(<polars_object>)`][as.data.frame.polars_data_frame]:
#'   Export the polars object as a basic data frame.
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
  x,
  ...,
  .name_repair = c("check_unique", "unique", "universal", "minimal"),
  uint8 = c("integer", "raw"),
  int64 = c("double", "character", "integer", "integer64"),
  date = c("Date", "IDate"),
  time = c("hms", "ITime"),
  decimal = c("double", "character"),
  as_clock_class = FALSE,
  ambiguous = c("raise", "earliest", "latest", "null"),
  non_existent = c("raise", "null")
) {
  if (missing(uint8)) {
    uint8 <- missing_arg()
  }
  if (missing(int64)) {
    int64 <- missing_arg()
  }
  if (missing(date)) {
    date <- missing_arg()
  }
  if (missing(time)) {
    time <- missing_arg()
  }
  if (missing(decimal)) {
    decimal <- missing_arg()
  }
  if (missing(as_clock_class)) {
    as_clock_class <- missing_arg()
  }
  if (missing(ambiguous)) {
    ambiguous <- missing_arg()
  }
  if (missing(non_existent)) {
    non_existent <- missing_arg()
  }

  as_polars_df(x, ...)$to_struct()$to_r_vector(
    uint8 = uint8,
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

# nolint end
