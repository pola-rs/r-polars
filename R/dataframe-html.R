knit_print_impl <- function(x, ..., from_series = FALSE, call = caller_env()) {
  polars_df_knitr_print <- getOption("polars.df_knitr_print", "auto")
  rmarkdown_df_print <- knitr::opts_knit$get("rmarkdown.df_print")

  if (
    isTRUE(polars_df_knitr_print == "html") ||
      isTRUE(polars_df_knitr_print != "default") &&
        !isTRUE(rmarkdown_df_print %in% c("default", "tibble")) &&
        knitr::is_html_output()
  ) {
    x |>
      format_df_as_html(
        max_cols = as.integer(Sys.getenv("POLARS_FMT_MAX_COLS", "75")),
        max_rows = as.integer(Sys.getenv("POLARS_FMT_MAX_ROWS", "10")),
        from_series = from_series,
        call = call
      ) |>
      knitr::raw_html() |>
      knitr::asis_output()
  } else {
    print(x)
  }
}

#' @inheritParams rlang::args_dots_empty
#' @inheritParams rlang::abort
#' @param df A polars [DataFrame] or an R DataFrame.
#' @param max_cols An integer representing the number of columns.
#' @param max_rows An integer representing the number of rows.
#' @param from_series A logical indicating if treating `x` as polars [Series].
#' @noRd
format_df_as_html <- function(
  df,
  ...,
  max_cols = 75L,
  max_rows = 40L,
  from_series = FALSE,
  call = caller_env()
) {
  check_dots_empty0(..., call = call)
  check_number_whole(max_cols, min = 0, call = call)
  check_number_whole(max_rows, min = 0, call = call)

  omit_chr <- "&hellip;"

  .dim <- dim(df)

  df_height <- .dim[1]
  df_width <- .dim[2]

  row_idx <- .idx(max_rows, df_height)
  col_idx <- .idx(max_cols, df_width)

  cols <- names(df)[col_idx]
  col_names <- cols |>
    html_escape()
  col_types <- df |>
    get_dtype_chrs(call = call) |>
    html_escape()

  if (max_cols <= df_width) {
    col_names <- .cut_off(col_names, max_cols, omit_chr)
    col_types <- .cut_off(col_types, max_cols, omit_chr)
  }

  .header_names <- col_names |>
    .tag("th") |>
    .tag("tr")

  .header_dtypes <- col_types |>
    .tag("td") |>
    .tag("tr")

  .header_all <- .header_names |>
    paste0(.header_dtypes) |>
    .tag("thead")

  .env_str_len <- Sys.getenv("POLARS_FMT_STR_LEN")
  .str_len <- ifelse(.env_str_len == "", 15, as.integer(.env_str_len))

  chr_mat <- sapply(cols, \(col) {
    if (is_polars_df(df)) {
      df[row_idx, col, drop = TRUE]$`_s`$get_fmt(.str_len)
    } else {
      as.character(df[row_idx, col, drop = TRUE])
    }
  }) |>
    html_escape() |>
    matrix(nrow = length(row_idx))

  if (max_cols < df_width) {
    .seq <- seq_along(cols)
    chr_mat <- cbind(
      chr_mat[, head(.seq, max_cols %/% 2), drop = FALSE],
      omit_chr,
      chr_mat[, tail(.seq, max_cols %/% 2), drop = FALSE]
    )
  }

  if (max_rows < df_height) {
    .seq <- seq_along(row_idx)
    half <- max_rows %/% 2
    rest <- max_rows %% 2
    chr_mat <- rbind(
      chr_mat[head(.seq, half + rest), , drop = FALSE],
      omit_chr,
      chr_mat[tail(.seq, half), , drop = FALSE]
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
  white-space: pre-wrap;
}
</style>
"

  .shape <- if (isTRUE(from_series)) {
    sprintf(
      "<small>shape: (%s)</small>",
      prettyNum(.dim[1], big.mark = "_")
    )
  } else {
    sprintf(
      "<small>shape: (%s, %s)</small>",
      prettyNum(.dim[1], big.mark = "_"),
      prettyNum(.dim[2], big.mark = "_")
    )
  }

  paste0(.header_all, .body) |>
    .tag("table", c(border = "1", class = "dataframe")) |>
    (\(x) (paste0(.style, .shape, x)))() |>
    .tag("div")
}

# Copied from the xfun package
# https://github.com/yihui/xfun/blob/fbdb93b48ab07d9f7e460e9a6508bce7ebca18c5/R/string.R#L458-L476
html_escape <- function(x) {
  x |>
    gsub("&", "&amp;", x = _, fixed = TRUE) |>
    gsub("<", "&lt;", x = _, fixed = TRUE) |>
    gsub(">", "&gt;", x = _, fixed = TRUE)
}

.idx <- function(.max, .length) {
  if (.max <= .length) {
    out <- c(seq_len(.max %/% 2), seq(.length - .max %/% 2 + 1L, .length))
  } else {
    out <- seq_len(.length)
  }
  out
}

.cut_off <- function(.vec, .max, omit_chr) {
  c(head(.vec, .max %/% 2), omit_chr, tail(.vec, .max %/% 2))
}

#' @param .elements chr vector
#' @param .tag single chr
#' @param .attr named chr vector
#' @return single charactor
#' @examples
#' .tag(letters[1:2], "tr")
#' @noRd
.tag <- function(.elements, .tag, .attr = NULL) {
  if (!is.null(.attr)) {
    .pre <- paste0(
      "<",
      .tag,
      " ",
      paste0(sprintf('%s="%s"', names(.attr), .attr), collapse = " "),
      ">"
    )
  } else {
    .pre <- c(paste0("<", .tag, ">"))
  }

  .post <- paste0("</", .tag, ">")

  paste0(.pre, .elements, .post, collapse = "")
}

#' Get types of each column
#' @param df DataFrame like object
#' @return string vector of column type names
#' @noRd
get_dtype_chrs <- function(df, ..., call = caller_env()) {
  if (is_polars_df(df)) {
    df$dtypes |>
      vapply(\(x) format(x, abbreviated = TRUE), character(1L))
  } else {
    if (!requireNamespace("pillar", quietly = TRUE)) {
      abort(
        "The `pillar` package is required to use `format_df_as_html` for non-polars objects.",
        call = call
      )
    }
    sapply(names(df), \(x) pillar::type_sum(df[, x, drop = TRUE])) |>
      unname()
  }
}
