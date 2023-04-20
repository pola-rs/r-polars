#' knit print polars DataFrame
#'
#' Mimics [python-polars' NotebookFormatter]
#' (https://github.com/pola-rs/polars/blob/4ffcb7461302a580255a9d910d70f1f7b2508675/py-polars/polars/dataframe/_html.py)
#' for HTML outputs.
#' @name knit_print.DataFrame
#' @param x a polars DataFrame to knit_print
#' @param ... additional arguments, not used
#' @keywords DataFrame
#' @export
knit_print.DataFrame <- function(x, ...) {
  if (knitr::is_html_output() || (getOption("polars.df_print", "default") == "html")) {
    x |>
      as.data.frame() |>
      to_html_table() |>
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
#' @export
to_html_table <- function(x, max_cols = 75, max_rows = 40) {
  escape_html <- getFromNamespace("escape_html", "knitr")
  omit_chr <- "&hellip;"

  .dim <- dim(x)

  df_height <- .dim[1]
  df_width <- .dim[2]

  row_idx <- .idx(max_rows, df_height)
  col_idx <- .idx(max_cols, df_width)

  cols <- names(x)[col_idx[col_idx > 0]] # TODO: names -> colnames
  col_names <- cols |>
    escape_html()

  if (max_cols <= df_width) {
    col_names <- c(head(cols, max_cols %/% 2), omit_chr, tail(cols, max_cols %/% 2))
  }

  .header_names <- col_names |>
    .tag("th") |>
    .tag("tr")

  .header_dtypes <- NULL |> # TODO: dtype_strings
    .tag("td") |>
    .tag("tr")

  .header_all <- .header_names |>
    # paste0(.header_dtypes) |> # TODO: dtype_strings
    .tag("thead")

  # .env_str_len <- Sys.getenv("POLARS_FMT_STR_LEN")
  # .str_len <- ifelse(.env_str_len == "", 15, as.integer(.env_str_len)) # TODO: get_fmr
  rows <- row_idx[row_idx > 0]

  chr_mat <- sapply(x[rows, cols], as.character) |>
    escape_html() |>
    matrix(nrow = length(rows))

  if (max_cols <= df_width) {
    .seq <- seq_along(cols)
    chr_mat <- cbind(
      chr_mat[, head(.seq, max_cols %/% 2)],
      omit_chr,
      chr_mat[, tail(.seq, max_cols %/% 2)]
    )
  }

  if (max_rows <= df_height) {
    .seq <- seq_along(rows)
    chr_mat <- rbind(
      chr_mat[head(.seq, max_rows %/% 2), ],
      omit_chr,
      chr_mat[tail(.seq, max_rows %/% 2), ]
    )
  }

  .body <- chr_mat |>
    t() |>
    as.data.frame() |>
    sapply(\(x) .tag(x, "td")) |>
    .tag("tr") |>
    .tag("tbody")

  .style <- "<style>
.dataframe > thead > tr > th,
.dataframe > tbody > tr > td {
  text-align: right;
}
</style>
"

  .shape <- sprintf("<small>shape: (%s, %s)</small>", .dim[1], .dim[2])

  paste0(.header_all, .body) |>
    .tag("table", c(border = "1", class = "dataframe")) |>
    (\(x) (paste0(.style, .shape, x)))() |>
    .tag("div")
}


.idx <- function(.max, .df_len) {
  if (.max <= .df_len) {
    out <- c(seq(1, .max %/% 2), -1, seq(.df_len - .max %/% 2 + 1, .df_len))
  } else {
    out <- seq(1, .df_len)
  }
  out
}

#' @param .elements chr vector
#' @param .tag single chr
#' @param .attr named chr vector
#' @return chr vector
#' @examples
#' .tag(letters[1:2], "tr")
#' @noRd
.tag <- function(.elements, .tag, .attr = NULL) {
  if (!is.null(.attr)) {
    .pre <- paste0("<", .tag, " ", paste0(sprintf('%s="%s"', names(.attr), .attr), collapse = " "), ">")
  } else {
    .pre <- c(paste0("<", .tag, ">"))
  }

  .post <- paste0("</", .tag, ">")

  paste0(.pre, .elements, .post, collapse = "")
}
