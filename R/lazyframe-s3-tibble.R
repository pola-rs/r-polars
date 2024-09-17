# exported in zzz.R
#' @rdname s3-as_tibble
as_tibble.polars_lazy_frame <- function(
    x, ...,
    .name_repair = "check_unique",
    int64 = "double",
    decimal = "double",
    as_clock_class = FALSE,
    ambiguous = "raise",
    non_existent = "raise") {
  as_polars_df(x, ...) |>
    as_tibble.polars_data_frame(
      .name_repair = .name_repair,
      int64 = int64,
      decimal = decimal,
      as_clock_class = as_clock_class,
      ambiguous = ambiguous,
      non_existent = non_existent
    )
}
