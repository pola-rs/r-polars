# exported in zzz.R
#' @rdname s3-as_tibble
as_tibble.polars_lazy_frame <- function(
    x, ...,
    .name_repair = c("check_unique", "unique", "universal", "minimal"),
    int64 = c("double", "character", "integer", "integer64"),
    date = c("Date", "IDate"),
    time = c("hms", "ITime"),
    decimal = c("double", "character"),
    as_clock_class = FALSE,
    ambiguous = c("raise", "earliest", "latest", "null"),
    non_existent = c("raise", "null")) {
  as_polars_df(x, ...) |>
    as_tibble.polars_data_frame(
      .name_repair = .name_repair,
      int64 = int64,
      date = date,
      time = time,
      decimal = decimal,
      as_clock_class = as_clock_class,
      ambiguous = ambiguous,
      non_existent = non_existent
    )
}
