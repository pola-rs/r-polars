# nolint start: object_name_linter

#' knit print polars DataFrame
#'
#' Mimics Python Polars' NotebookFormatter
#' for HTML outputs.
#'
#' Outputs HTML tables if the output format is HTML
#' and the document's `df_print` option is not `"default"` or `"tibble"`.
#'
#' Or, the output format can be enforced with R's `options` function as follows:
#'
#' - `options(polars.df_knitr_print  = "default")` for the default print method.
#' - `options(polars.df_knitr_print  = "html")` for the HTML table.
#'
#' @inheritParams knitr::knit_print
#' @param x A polars object
#' @return `x` invisibly or [knit_asis][knitr::asis_output] object.
#' @examplesIf requireNamespace("knitr", quietly = TRUE) && requireNamespace("withr", quietly = TRUE)
#' # Using the default print method
#' withr::with_options(
#'   list(polars.df_knitr_print = "default"),
#'   knitr::knit_print(as_polars_df(mtcars))
#' )
#'
#' # Returning HTML table
#' withr::with_options(
#'   list(polars.df_knitr_print = "html"),
#'   knitr::knit_print(as_polars_df(mtcars))
#' )
#' @rdname s3-knit_print
# exported in zzz.R
knit_print.polars_data_frame <- function(x, ...) {
  knit_print_impl(x, ..., from_series = FALSE)
}

# nolint end
