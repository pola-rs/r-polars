# The env for storing all expr bin methods
polars_expr_bin_methods <- new.env(parent = emptyenv())

namespace_expr_bin <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  lapply(names(polars_expr_bin_methods), function(name) {
    fn <- polars_expr_bin_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c("polars_namespace_expr", "polars_object")
  self
}

#' Check if binaries contain a binary substring
#'
#' @param literal The binary substring to look for.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' colors <- pl$DataFrame(
#'   name = c("black", "yellow", "blue"),
#'   code = as_polars_series(c("x00x00x00", "xffxffx00", "x00x00xff"))$cast(pl$Binary),
#'   lit = as_polars_series(c("x00", "xffx00", "xffxff"))$cast(pl$Binary)
#' )
#'
#' colors$select(
#'   "name",
#'   contains_with_lit = pl$col("code")$bin$contains("xff"),
#'   contains_with_expr = pl$col("code")$bin$contains(pl$col("lit"))
#' )
expr_bin_contains <- function(literal) {
  as_polars_expr(literal, as_lit = TRUE)$`_rexpr` |>
    self$`_rexpr`$bin_contains() |>
    wrap()
}

#' Check if string values end with a binary substring
#'
#' @param suffix Suffix substring.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' colors <- pl$DataFrame(
#'   name = c("black", "yellow", "blue"),
#'   code = as_polars_series(c("x00x00x00", "xffxffx00", "x00x00xff"))$cast(pl$Binary),
#'   suffix = as_polars_series(c("x00", "xffx00", "xffxff"))$cast(pl$Binary)
#' )
#'
#' colors$select(
#'   "name",
#'   ends_with_lit = pl$col("code")$bin$ends_with("xff"),
#'   ends_with_expr = pl$col("code")$bin$ends_with(pl$col("suffix"))
#' )
expr_bin_ends_with <- function(suffix) {
  as_polars_expr(suffix, as_lit = TRUE)$`_rexpr` |>
    self$`_rexpr`$bin_ends_with() |>
    wrap()
}


#' Check if values start with a binary substring
#'
#' @param sub Prefix substring.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' colors <- pl$DataFrame(
#'   name = c("black", "yellow", "blue"),
#'   code = as_polars_series(c("x00x00x00", "xffxffx00", "x00x00xff"))$cast(pl$Binary),
#'   prefix = as_polars_series(c("x00", "xffx00", "xffxff"))$cast(pl$Binary)
#' )
#'
#' colors$select(
#'   "name",
#'   starts_with_lit = pl$col("code")$bin$starts_with("xff"),
#'   starts_with_expr = pl$col("code")$bin$starts_with(pl$col("prefix"))
#' )
expr_bin_starts_with <- function(prefix) {
  as_polars_expr(prefix, as_lit = TRUE)$`_rexpr` |>
    self$`_rexpr`$bin_starts_with() |>
    wrap()
}

#' Decode values using the provided encoding
#'
#' @param encoding A character, `"hex"` or `"base64"`. The encoding to use.
#' @inheritParams rlang::args_dots_empty
#' @param strict  Raise an error if the underlying value cannot be decoded,
#'  otherwise mask out with a `null` value.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   name = c("black", "yellow", "blue"),
#'   code_hex = as_polars_series(c("000000", "ffff00", "0000ff"))$cast(pl$Binary),
#'   code_base64 = as_polars_series(c("AAAA", "//8A", "AAD/"))$cast(pl$Binary)
#' )
#'
#' df$with_columns(
#'   decoded_hex = pl$col("code_hex")$bin$decode("hex"),
#'   decoded_base64 = pl$col("code_base64")$bin$decode("base64")
#' )
#'
#' # Set `strict = FALSE` to set invalid values to `null` instead of raising an error.
#' df <- pl$DataFrame(
#'   colors = as_polars_series(c("000000", "ffff00", "invalid_value"))$cast(pl$Binary)
#' )
#' df$select(pl$col("colors")$bin$decode("hex", strict = FALSE))
expr_bin_decode <- function(encoding, ..., strict = TRUE) {
  wrap({
    check_dots_empty0(...)
    encoding <- arg_match0(encoding, c("hex", "base64"))

    # fmt: skip
    switch(encoding,
      hex = self$`_rexpr`$bin_hex_decode(strict),
      base64 = self$`_rexpr`$bin_base64_decode(strict),
      abort("Unreachable")
    )
  })
}

#' Encode a value using the provided encoding
#'
#' @inheritParams expr_bin_decode
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   name = c("black", "yellow", "blue"),
#'   code = as_polars_series(
#'     c("000000", "ffff00", "0000ff")
#'   )$cast(pl$Binary)$bin$decode("hex")
#' )
#'
#' df$with_columns(encoded = pl$col("code")$bin$encode("hex"))
expr_bin_encode <- function(encoding) {
  wrap({
    encoding <- arg_match0(encoding, c("hex", "base64"))

    # fmt: skip
    switch(encoding,
      hex = self$`_rexpr`$bin_hex_encode(),
      base64 = self$`_rexpr`$bin_base64_encode(),
      abort("Unreachable")
    )
  })
}

#' Get the size of binary values in the given unit
#'
#' @param unit Scale the returned size to the given unit. Can be `"b"`, `"kb"`,
#' `"mb"`, `"gb"`, `"tb"`.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   name = c("black", "yellow", "blue"),
#'   code_hex = as_polars_series(c("000000", "ffff00", "0000ff"))$cast(pl$Binary)
#' )
#'
#' df$with_columns(
#'   n_bytes = pl$col("code_hex")$bin$size(),
#'   n_kilobytes = pl$col("code_hex")$bin$size("kb")
#' )
expr_bin_size <- function(unit = c("b", "kb", "mb", "gb", "tb")) {
  wrap({
    unit <- arg_match0(unit, values = c("b", "kb", "mb", "gb", "tb"))
    sz <- self$`_rexpr`$bin_size_bytes()
    # fmt: skip
    switch(unit,
      "b" = sz,
      "kb" = sz$div(as_polars_expr(1024)$`_rexpr`),
      "mb" = sz$div(as_polars_expr(1024**2)$`_rexpr`),
      "gb" = sz$div(as_polars_expr(1024**3)$`_rexpr`),
      "tb" = sz$div(as_polars_expr(1024**4)$`_rexpr`),
      abort("Unreachable")
    )
  })
}
