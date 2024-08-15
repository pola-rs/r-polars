# this file sources list-expression functions to be bundled in the 'expr$bin' sub namespace
# the sub name space is instantiated from Expr_bin- function
# bundling these functions into an environment, depends on a macro call in zzz.R
# expr_bin_make_sub_ns = macro_new_subnamespace("^ExprBin_", "RPolarsExprBinNameSpace")


#' Check if binaries contain a binary substring
#'
#' @param literal The binary substring to look for.
#'
#' @return Expr returning a Boolean
#'
#' @examples
#' colors = pl$DataFrame(
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
ExprBin_contains = function(literal) {
  unwrap(.pr$Expr$bin_contains(self, literal))
}


#' Check if values start with a binary substring
#'
#' @param sub Prefix substring.
#'
#' @return Expr returing a Boolean
#'
#' @examples
#' colors = pl$DataFrame(
#'   name = c("black", "yellow", "blue"),
#'   code = as_polars_series(c("x00x00x00", "xffxffx00", "x00x00xff"))$cast(pl$Binary),
#'   lit = as_polars_series(c("x00", "xffx00", "xffxff"))$cast(pl$Binary)
#' )
#'
#' colors$select(
#'   "name",
#'   starts_with_lit = pl$col("code")$bin$starts_with("xff"),
#'   starts_with_expr = pl$col("code")$bin$starts_with(pl$col("prefix"))
#' )
ExprBin_starts_with = function(sub) {
  unwrap(.pr$Expr$bin_starts_with(self, sub))
}


#' Check if string values end with a binary substring
#'
#' @param suffix Suffix substring.
#'
#' @return Expr returning a Boolean
#'
#' @examples
#' colors = pl$DataFrame(
#'   name = c("black", "yellow", "blue"),
#'   code = as_polars_series(c("x00x00x00", "xffxffx00", "x00x00xff"))$cast(pl$Binary),
#'   lit = as_polars_series(c("x00", "xffx00", "xffxff"))$cast(pl$Binary)
#' )
#'
#' colors$select(
#'   "name",
#'   ends_with_lit = pl$col("code")$bin$ends_with("xff"),
#'   ends_with_expr = pl$col("code")$bin$ends_with(pl$col("prefix"))
#' )
ExprBin_ends_with = function(suffix) {
  unwrap(.pr$Expr$bin_ends_with(self, suffix))
}


#' Encode a value using the provided encoding
#'
#' @inheritParams ExprBin_decode
#' @inherit ExprBin_decode return
#' @examples
#' df = pl$DataFrame(
#'   name = c("black", "yellow", "blue"),
#'   code = as_polars_series(
#'     c("000000", "ffff00", "0000ff")
#'   )$cast(pl$Binary)$bin$decode("hex")
#' )
#'
#' df$with_columns(encoded = pl$col("code")$bin$encode("hex"))
ExprBin_encode = function(encoding) {
  if (identical(encoding, "hex")) {
    .pr$Expr$bin_hex_encode(self)
  } else if (identical(encoding, "base64")) {
    .pr$Expr$bin_base64_encode(self)
  } else {
    Err_plain(sprintf("The `encoding` argument must be one of 'hex' or 'base64'. Got: %s", str_string(encoding))) |>
      unwrap("in $bin$encode():")
  }
}


#' Decode values using the provided encoding
#'
#' @param encoding A character, `"hex"` or `"base64"`. The encoding to use.
#' @param ... Ignored.
#' @param strict  Raise an error if the underlying value cannot be decoded,
#'  otherwise mask out with a `null` value.
#' @return [Expr][Expr_class] of data type String.
#' @examples
#' df = pl$DataFrame(
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
#' df = pl$DataFrame(
#'   colors = as_polars_series(c("000000", "ffff00", "invalid_value"))$cast(pl$Binary)
#' )
#' df$select(pl$col("colors")$bin$decode("hex", strict = FALSE))
ExprBin_decode = function(encoding, ..., strict = TRUE) {
  if (identical(encoding, "hex")) {
    res = .pr$Expr$bin_hex_decode(self, strict)
  } else if (identical(encoding, "base64")) {
    res = .pr$Expr$bin_base64_decode(self, strict)
  } else {
    res = Err_plain(sprintf("The `encoding` argument must be one of 'hex' or 'base64'. Got: %s", str_string(encoding)))
  }

  unwrap(res, "in $bin$decode():")
}

#' Get the size of binary values in the given unit
#'
#' @param unit Size unit. Can be `"b" / "bytes"` and all variants (`"kb"` or
#' `"kilobytes"`, etc.) until `"terabytes"`.
#'
#' @return [Expr][Expr_class] of data type UInt or Float.
#'
#' @examples
#' df = pl$DataFrame(
#'   name = c("black", "yellow", "blue"),
#'   code_hex = as_polars_series(c("000000", "ffff00", "0000ff"))$cast(pl$Binary)
#' )
#'
#' df$with_columns(
#'   n_bytes = pl$col("code_hex")$bin$size(),
#'   n_kilobytes = pl$col("code_hex")$bin$size("kb")
#' )
ExprBin_size = function(unit = "b") {
  sz = .pr$Expr$bin_size_bytes(self)
  switch(unit,
    "b" = ,
    "bytes" = sz,
    "kb" = ,
    "kilobytes" = sz / 1024,
    "mb" = ,
    "megabytes" = sz / 1024**2,
    "gb" = ,
    "gigabytes" = sz / 1024**3,
    "tb" = ,
    "terabytes" = sz / 1024**4,
    Err_plain("`unit` must be one of 'b', 'kb', 'mb', 'gb', 'tb'") |>
      unwrap("in $bin$size():")
  )
}
