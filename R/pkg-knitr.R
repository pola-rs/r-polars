#' knit print polars DataFrame
#' @name knit_print.DataFrame
#' @param x a polars DataFrame to knit_print
#' @param ... additional arguments, not used
#' @keywords DataFrame
#' @export
knit_print.DataFrame = function(x, ...) {
  .env_formatting = Sys.getenv("POLARS_FMT_TABLE_FORMATTING")
  .env_inline_data_type = tolower(Sys.getenv("POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE"))

  on.exit({
    Sys.setenv(POLARS_FMT_TABLE_FORMATTING = .env_formatting)
    Sys.setenv(POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE = .env_inline_data_type)
  })

  if (.env_formatting %in% c("", "ASCII_MARKDOWN") && .env_inline_data_type %in% c("", "true", "1")) {
    Sys.setenv(POLARS_FMT_TABLE_FORMATTING = "ASCII_MARKDOWN")
    Sys.setenv(POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE = "1")
  }

  out = capture.output(print(x))

  # Needs to insert a blank line
  out = c(out[1], "", out[-1]) |>
    paste(collapse = "\n")

  knitr::asis_output(out)
}
