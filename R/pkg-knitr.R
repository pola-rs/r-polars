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
#' @name knit_print.RPolarsDataFrame
#' @param x a polars DataFrame to knit_print
#' @param ... additional arguments, not used
#' @return invisible x or NULL
#' @keywords DataFrame
#' @rdname S3_knit_print
# exported in zzz.R
knit_print.RPolarsDataFrame = function(x, ...) {
  .print_opt = polars_options()$df_knitr_print
  .rmd_df_print = knitr::opts_knit$get("rmarkdown.df_print")
  if (isTRUE(.print_opt == "html") ||
    (isTRUE(.print_opt != "default") &&
      !isTRUE(.rmd_df_print %in% c("default", "tibble")) &&
      knitr::is_html_output())) {
    x |>
      to_html_table(
        max_cols = as.integer(Sys.getenv("POLARS_FMT_MAX_COLS", "75")),
        max_rows = as.integer(Sys.getenv("POLARS_FMT_MAX_ROWS", "10"))
      ) |>
      knitr::raw_html() |>
      knitr::asis_output()
  } else {
    print(x)
  }
}

#' Generate HTML table from a DataFrame
#' @param x DataFrame
#' @param max_cols an integer of maximum number of columns to display
#' @param max_rows an integer of maximum number of rows to display
#' @return A string of HTML code
#' @examples
#' to_html_table(mtcars, 3, 3)
#' @noRd
to_html_table = function(x, max_cols = 75, max_rows = 40) {
  if (!requireNamespace("knitr", quietly = TRUE)) {
    stop("Please install the `knitr` package to use `to_html_table`.")
  }

  # escape_html will be removed from knitr (> 1.49)
  if (exists("html_escape", where = asNamespace("xfun"), mode = "function")) {
    escape_html = xfun::html_escape
  } else {
    escape_html = getFromNamespace("escape_html", "knitr")
  }

  omit_chr = "&hellip;"

  .dim = dim(x)

  df_height = .dim[1]
  df_width = .dim[2]

  row_idx = .idx(max_rows, df_height)
  col_idx = .idx(max_cols, df_width)

  cols = names(x)[col_idx]
  col_names = cols |>
    escape_html()
  col_types = x |>
    .get_dtype_strings() |>
    escape_html()

  if (max_cols <= df_width) {
    col_names = .cut_off(col_names, max_cols, omit_chr)
    col_types = .cut_off(col_types, max_cols, omit_chr)
  }

  .header_names = col_names |>
    .tag("th") |>
    .tag("tr")

  .header_dtypes = col_types |>
    .tag("td") |>
    .tag("tr")

  .header_all = .header_names |>
    paste0(.header_dtypes) |>
    .tag("thead")

  .env_str_len = Sys.getenv("POLARS_FMT_STR_LEN")
  .str_len = ifelse(.env_str_len == "", 15, as.integer(.env_str_len))

  chr_mat = sapply(cols, \(col) as.character(x[row_idx, col, drop = TRUE], str_length = .str_len)) |>
    escape_html() |>
    matrix(nrow = length(row_idx))

  if (max_cols < df_width) {
    .seq = seq_along(cols)
    chr_mat = cbind(
      chr_mat[, head(.seq, max_cols %/% 2)],
      omit_chr,
      chr_mat[, tail(.seq, max_cols %/% 2)]
    )
  }

  if (max_rows < df_height) {
    .seq = seq_along(row_idx)
    half = max_rows %/% 2
    rest = max_rows %% 2
    chr_mat = rbind(
      chr_mat[head(.seq, half + rest), ],
      omit_chr,
      chr_mat[tail(.seq, half), ]
    )
  }

  .body = chr_mat |>
    t() |>
    as.data.frame() |>
    sapply(\(x) .tag(x, "td")) |>
    .tag("tr") |>
    .tag("tbody")

  .style = "<style>
.dataframe > thead > tr > th,
.dataframe > tbody > tr > td {
  text-align: right;
  white-space: pre-wrap;
}
</style>
"

  .shape = sprintf(
    "<small>shape: (%s, %s)</small>",
    prettyNum(.dim[1], big.mark = "_"),
    prettyNum(.dim[2], big.mark = "_")
  )

  paste0(.header_all, .body) |>
    .tag("table", c(border = "1", class = "dataframe")) |>
    (\(x) (paste0(.style, .shape, x)))() |>
    .tag("div")
}

.idx = function(.max, .length) {
  if (.max <= .length) {
    out = c(seq_len(.max %/% 2), seq(.length - .max %/% 2 + 1L, .length))
  } else {
    out = seq_len(.length)
  }
  out
}

.cut_off = function(.vec, .max, omit_chr) {
  c(head(.vec, .max %/% 2), omit_chr, tail(.vec, .max %/% 2))
}

#' @param .elements chr vector
#' @param .tag single chr
#' @param .attr named chr vector
#' @return single charactor
#' @examples
#' .tag(letters[1:2], "tr")
#' @noRd
.tag = function(.elements, .tag, .attr = NULL) {
  if (!is.null(.attr)) {
    .pre = paste0("<", .tag, " ", paste0(sprintf('%s="%s"', names(.attr), .attr), collapse = " "), ">")
  } else {
    .pre = c(paste0("<", .tag, ">"))
  }

  .post = paste0("</", .tag, ">")

  paste0(.pre, .elements, .post, collapse = "")
}

#' Get types of each column
#' @param df DataFrame like object
#' @return string vector of column type names
#' @noRd
.get_dtype_strings = function(df) {
  if (inherits(df, "RPolarsDataFrame")) {
    df$dtype_strings()
  } else {
    if (!requireNamespace("pillar", quietly = TRUE)) {
      stop("Please install the `pillar` package to use `to_html_table` for non-polars objects.")
    }
    sapply(names(df), \(x) pillar::type_sum(df[, x, drop = TRUE])) |>
      unname()
  }
}
