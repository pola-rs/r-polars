# this file sources list-expression functions to be bundled in the 'expr$bin' sub namespace
# the sub name space is instantiated from Expr_bin- function
# bundling these functions into an environment, depends on a macro call in zzz.R
# expr_bin_make_sub_ns = macro_new_subnamespace("^ExprBin_", "RPolarsExprBinNameSpace")


#' contains
#'
#' @aliases expr_bin_contains
#' @description R Check if binaries in Series contain a binary substring.
#' @keywords ExprBin
#' @param lit The binary substring to look for
#' @return Expr returning a Boolean
ExprBin_contains = function(lit) {
  unwrap(.pr$Expr$bin_contains(self, lit))
}


#' starts_with
#'
#' @aliases expr_bin_starts_with
#' @description   Check if values starts with a binary substring.
#' @keywords ExprBin
#' @param sub Prefix substring.
#' @return Expr returing a Boolean
ExprBin_starts_with = function(sub) {
  unwrap(.pr$Expr$bin_starts_with(self, sub))
}


#' ends_with
#'
#' @aliases expr_bin_ends_with
#' @description Check if string values end with a binary substring.
#' @param suffix Suffix substring.
#' @keywords ExprBin
#' @return Expr returning a Boolean
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
