#' knit print polars DataFrame
#' @name knit_print.DataFrame
#' @param x a polars DataFrame to knit_print
#' @param ... additional arguments, not used
#' @keywords DataFrame
#' @export
knit_print.DataFrame = function(x, ...) {
  if (identical(knitr::opts_knit$get("rmarkdown.df_print"), "kable") || (getOption("polars.df_print", "default") == "kable")) {
    kable_print_pl_df(x)
  } else {
    print(x)
  }
}

#' @param x polars DataFrame
#' @noRd
kable_print_pl_df = function(x, ...) {
  .env_formatting = Sys.getenv("POLARS_FMT_TABLE_FORMATTING")
  .env_inline_data_type = Sys.getenv("POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE")
  .env_shape_below = Sys.getenv("POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW")

  on.exit({
    Sys.setenv(POLARS_FMT_TABLE_FORMATTING = .env_formatting)
    Sys.setenv(POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE = .env_inline_data_type)
    Sys.setenv(POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW = .env_shape_below)
  })

  # Ensure `shape: (n, m)` above
  Sys.unsetenv("POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW")

  Sys.setenv(POLARS_FMT_TABLE_FORMATTING = "ASCII_MARKDOWN")
  Sys.setenv(POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE = "1")

  out = capture.output(print(x))

  if (grepl(r"(^shape:\s\(\d+,\s\d+\)$)", out[1], perl = TRUE)) {
    # Needs to insert a blank line
    .table_shape = c("<small>", out[1], "</small>", "")
    .table_body = out[-1]
  } else {
    .table_shape = NULL
    .table_body = out
  }

  c(.table_shape, "", '<div class="kable-table">', "", .table_body, "", "</div>") |>
    paste0(collapse = "\n") |>
    knitr::asis_output()
}
