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



#' encode
#'
#' @aliases expr_bin_encode
#' @description  Encode a value using the provided encoding.
#' @keywords ExprBin
#' @param encoding binary choice either 'hex' or 'base64'
#' @return binary array with values encoded using provided encoding
ExprBin_encode = function(encoding) {
  pcase(
    !is_string(encoding), stop("encoding must be a string, it was: %s", str_string(encoding)),
    encoding == "hex", .pr$Expr$bin_encode_hex(self),
    encoding == "base64", .pr$Expr$bin_encode_base64(self),
    or_else = stop("encoding must be one of 'hex' or 'base64', got %s", encoding)
  )
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
  pcase(
    !is_string(encoding), Err_plain(
      sprintf("The `encoding` argument must be one of 'hex' or 'base64'. But it was: %s.", str_string(encoding))
    ),
    encoding == "hex", .pr$Expr$bin_hex_decode(self, strict),
    encoding == "base64", .pr$Expr$bin_base64_decode(self, strict),
    or_else = Err_plain(
      sprintf("The `encoding` argument must be one of 'hex' or 'base64', got '%s'.", encoding)
    )
  ) |>
    unwrap("in $bin$decode():")
}
