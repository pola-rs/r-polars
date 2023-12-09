# this file sources list-expression functions to be bundled in the 'expr$bin' sub namespace
# the sub name space is instantiated from Expr_bin- function
# bundling these functions into an environment, depends on a macro call in zzz.R
# expr_bin_make_sub_ns = macro_new_subnamespace("^ExprBin_", "RPolarsExprBinNameSpace")


#' contains
#' @name ExprBin_contains
#' @aliases expr_bin_contains
#' @description R Check if binaries in Series contain a binary substring.
#' @keywords ExprBin
#' @param lit The binary substring to look for
#' @return Expr returning a Boolean
ExprBin_contains = function(lit) {
  unwrap(.pr$Expr$bin_contains(self, lit))
}


#' starts_with
#' @name ExprBin_starts_with
#' @aliases expr_bin_starts_with
#' @description   Check if values starts with a binary substring.
#' @keywords ExprBin
#' @param sub Prefix substring.
#' @return Expr returing a Boolean
ExprBin_starts_with = function(sub) {
  unwrap(.pr$Expr$bin_starts_with(self, sub))
}


#' ends_with
#' @name ExprBin_ends_with
#' @aliases expr_bin_ends_with
#' @description   Check if string values end with a binary substring.
#' @keywords ExprBin
#' @return Expr returning a Boolean
ExprBin_ends_with = function(sub) {
  unwrap(.pr$Expr$bin_ends_with(self, sub))
}



#' encode
#' @name ExprBin_encode
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

#' decode
#' @name ExprBin_decode
#' @aliases expr_bin_decode
#' @description Decode a value using the provided encoding.
#' @keywords ExprBin
#' @param encoding binary choice either 'hex' or 'base64'
#' @param strict  Raise an error if the underlying value cannot be decoded,
#'  otherwise mask out with a null value.
#'
#' @return binary array with values decoded using provided encoding
ExprBin_decode = function(encoding, strict = TRUE) {
  pcase(
    !is_string(encoding), stop("encoding must be a string, it was: %s", str_string(encoding)),
    encoding == "hex", .pr$Expr$bin_decode_hex(self, strict),
    encoding == "base64", .pr$Expr$bin_decode_base64(self, strict),
    or_else = stop("encoding must be one of 'hex' or 'base64', got %s", encoding)
  )
}
