select_rows_by_index <- function(df, key) {
  df$`_df`$gather_with_series(key$`_s`) |>
    wrap()
}
