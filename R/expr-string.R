# The env for storing all expr str methods
polars_expr_str_methods <- new.env(parent = emptyenv())

namespace_expr_str <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  lapply(names(polars_expr_str_methods), function(name) {
    fn <- polars_expr_str_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c(
    "polars_namespace_expr", "polars_object"
  )
  self
}

#' Convert a String column into a Date/Datetime/Time column.
#'
#' Similar to the [strptime()] function.
#'
#' When parsing a Datetime the column precision will be inferred from the format
#' string, if given, e.g.: `"%F %T%.3f"` => [`pl$Datetime("ms")`][pl_Datetime].
#' If no fractional second component is found then the default is `"us"` (microsecond).
# TODO: link to data type docs
#' @param dtype The data type to convert into. Can be either `pl$Date`,
#' `pl$Datetime`, or `pl$Time`.
#' @param format Format to use for conversion. Refer to
#' [the chrono crate documentation](https://docs.rs/chrono/latest/chrono/format/strftime/index.html)
#' for the full specification. Example: `"%Y-%m-%d %H:%M:%S"`.
#' If `NULL` (default), the format is inferred from the data.
#' Notice that time zone `%Z` is not supported and will just ignore timezones.
#' Numeric time zones like `%z` or `%:z` are supported.
#' @inheritParams rlang::args_dots_empty
#' @param strict If `TRUE` (default), raise an error if a single string cannot
#' be parsed. If `FALSE`, produce a polars `null`.
#' @param exact If `TRUE` (default), require an exact format match. If `FALSE`,
#' allow the format to match anywhere in the target string.
#' Conversion to the Time type is always exact.
#' Note that using `exact = FALSE` introduces a performance penalty -
#' cleaning your data beforehand will almost certainly be more performant.
#' @param cache Use a cache of unique, converted dates to apply the datetime
#' conversion.
#' @inheritParams expr_dt_replace_time_zone
#' @inherit as_polars_expr return
#' @seealso
#' - [`<Expr>$str$to_date()`][expr_str_to_date]
#' - [`<Expr>$str$to_datetime()`][expr_str_to_datetime]
#' - [`<Expr>$str$to_time()`][expr_str_to_time]
#' @examples
#' # Dealing with a consistent format
#' s <- as_polars_series(c("2020-01-01 01:00Z", "2020-01-01 02:00Z"))
#'
#' s$str$strptime(pl$Datetime(), "%Y-%m-%d %H:%M%#z")
#'
#' # Auto infer format
#' s$str$strptime(pl$Datetime())
#'
#' # Datetime with timezone is interpreted as UTC timezone
#' as_polars_series("2020-01-01T01:00:00+09:00")$str$strptime(pl$Datetime())
#'
#' # Dealing with different formats.
#' s <- as_polars_series(
#'   c(
#'     "2021-04-22",
#'     "2022-01-04 00:00:00",
#'     "01/31/22",
#'     "Sun Jul  8 00:34:60 2001"
#'   ),
#'   "date"
#' )
#'
#' s$to_frame()$select(
#'   pl$coalesce(
#'     pl$col("date")$str$strptime(pl$Date, "%F", strict = FALSE),
#'     pl$col("date")$str$strptime(pl$Date, "%F %T", strict = FALSE),
#'     pl$col("date")$str$strptime(pl$Date, "%D", strict = FALSE),
#'     pl$col("date")$str$strptime(pl$Date, "%c", strict = FALSE)
#'   )
#' )
#'
#' # Ignore invalid time
#' s <- as_polars_series(
#'   c(
#'     "2023-01-01 11:22:33 -0100",
#'     "2023-01-01 11:22:33 +0300",
#'     "invalid time"
#'   )
#' )
#'
#' s$str$strptime(
#'   pl$Datetime("ns"),
#'   format = "%Y-%m-%d %H:%M:%S %z",
#'   strict = FALSE
#' )
expr_str_strptime <- function(
    dtype,
    format = NULL,
    ...,
    strict = TRUE,
    exact = TRUE,
    cache = TRUE,
    ambiguous = "raise") {
  wrap({
    check_dots_empty0(...)
    check_polars_dtype(dtype)

    dtype_class <- class(dtype)
    if ("polars_dtype_datetime" %in% dtype_class) {
      self$`_rexpr`$str_to_datetime(
        format, dtype$time_unit, dtype$time_zone, strict, exact, cache, ambiguous
      )$dt_cast_time_unit(expr, dtype$time_unit)
    } else if ("polars_dtype_date" %in% dtype_class) {
      self$`_rexpr`$str_to_date(format, strict, exact, cache)
    } else if ("polars_dtype_time" %in% dtype_class) {
      self$`_rexpr`$str_to_time(format, strict, cache)
    } else {
      abort("`dtype` must be of type Date, Datetime, or Time.")
    }
  })
}

#' Convert a String column into a Date column
#'
#' @inheritParams expr_str_strptime
#'
#' @inherit as_polars_expr return
#' @seealso
#' - [`<Expr>$str$strptime()`][expr_str_strptime]
#' @examples
#' s <- as_polars_series(c("2020/01/01", "2020/02/01", "2020/03/01"))
#'
#' s$str$to_date()
#'
#' # by default, this errors if some values cannot be converted
#' s <- as_polars_series(c("2020/01/01", "2020 02 01", "2020-03-01"))
#' try(s$str$to_date())
#' s$str$to_date(strict = FALSE)
expr_str_to_date <- function(format = NULL, ..., strict = TRUE, exact = TRUE, cache = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_to_date(format, strict, exact, cache)
  })
}

#' Convert a String column into a Time column
#'
#' @inheritParams expr_str_strptime
#'
#' @inherit as_polars_expr return
#' @seealso
#' - [`<Expr>$str$strptime()`][expr_str_strptime]
#' @examples
#' s <- as_polars_series(c("01:00", "02:00", "03:00"))
#'
#' s$str$to_time("%H:%M")
expr_str_to_time <- function(format = NULL, ..., strict = TRUE, cache = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_to_time(format, strict, cache)
  })
}

#' Convert a String column into a Datetime column
#'
#' @inheritParams expr_str_strptime
#' @param time_unit Unit of time for the resulting Datetime column. If `NULL` (default),
#' the time unit is inferred from the format string if given,
#' e.g.: `"%F %T%.3f"` => [`pl$Datetime("ms")`][pl_Datetime].
#' If no fractional second component is found, the default is `"us"` (microsecond).
#' @param time_zone for the resulting [Datetime][pl_Datetime] column.
#' @param exact If `TRUE` (default), require an exact format match. If `FALSE`, allow the format to match
#' anywhere in the target string. Note that using `exact = FALSE` introduces a performance
#' penalty - cleaning your data beforehand will almost certainly be more performant.
#' @inherit as_polars_expr return
#' @seealso
#' - [`<Expr>$str$strptime()`][expr_str_strptime]
#' @examples
#' s <- as_polars_series(c("2020-01-01 01:00Z", "2020-01-01 02:00Z"))
#'
#' s$str$to_datetime("%Y-%m-%d %H:%M%#z")
#' s$str$to_datetime(time_unit = "ms")
expr_str_to_datetime <- function(
    format = NULL,
    ...,
    time_unit = NULL,
    time_zone = NULL,
    strict = TRUE,
    exact = TRUE,
    cache = TRUE,
    ambiguous = "raise") {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_to_datetime(
      self, format, time_unit, time_zone, strict, exact, cache, ambiguous
    )
  })
}

#' Get the number of bytes in strings
#' @description
#' Get length of the strings as UInt32 (as number of bytes). Use `$str$len_chars()`
#' to get the number of characters.
#'
#' @details
#' If you know that you are working with ASCII text, `lengths` will be
#' equivalent, and faster (returns length in terms of the number of bytes).
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(
#'   s = c("Café", NA, "345", "æøå")
#' )$select(
#'   pl$col("s"),
#'   pl$col("s")$str$len_bytes()$alias("lengths"),
#'   pl$col("s")$str$len_chars()$alias("n_chars")
#' )
expr_str_len_bytes <- function() {
  self$`_rexpr`$str_len_bytes() |>
    wrap()
}

#' Get the number of characters in strings
#' @description
#' Get length of the strings as UInt32 (as number of characters). Use
#' `$str$len_bytes()` to get the number of bytes.
#'
#' @inherit expr_str_len_bytes examples details return
expr_str_len_chars <- function() {
  self$`_rexpr`$str_len_chars() |>
    wrap()
}

#' Vertically concatenate the string values in the column to a single string value.
#'
#' @param delimiter The delimiter to insert between consecutive string values.
#' @inheritParams rlang::args_dots_empty
#' @param ignore_nulls Ignore null values (default). If `FALSE`, null values will be
#' propagated: if the column contains any null values, the output is null.
#' @inherit as_polars_expr return
#' @examples
#' # concatenate a Series of strings to a single string
#' df <- pl$DataFrame(foo = c(1, NA, 2))
#'
#' df$select(pl$col("foo")$str$join("-"))
#'
#' df$select(pl$col("foo")$str$join("-", ignore_nulls = FALSE))
expr_str_join <- function(
    delimiter = "",
    ...,
    ignore_nulls = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_join(delimiter, ignore_nulls)
  })
}

expr_str_concat <- function(
    delimiter = "",
    ...,
    ignore_nulls = TRUE) {
  deprecate_warn("$str$concat() is deprecated as of 0.18.0. Use $str$join() instead.")
  self$`_rexpr`$str_join(delimiter, ignore_nulls) |>
    wrap()
}

#' Convert a string to uppercase
#'
#' @description Transform to uppercase variant.
#' @inherit as_polars_expr return
#' @examples
#' pl$lit(c("A", "b", "c", "1", NA))$str$to_uppercase()$to_series()
expr_str_to_uppercase <- function() {
  self$`_rexpr`$str_to_uppercase() |>
    wrap()
}

#' Convert a string to lowercase
#'
#' @description Transform to lowercase variant.
#' @inherit as_polars_expr return
#' @examples
#' pl$lit(c("A", "b", "c", "1", NA))$str$to_lowercase()$to_series()
expr_str_to_lowercase <- function() {
  self$`_rexpr`$str_to_lowercase() |>
    wrap()
}

# TODO-REWRITE: uncomment this
# #' Convert a string to titlecase
# #'
# #' @description Transform to titlecase variant.
# #' @inherit as_polars_expr return
# #' @details
# #' This method is only available with the "nightly" feature.
# #' See [polars_info()] for more details.
# #' @examplesIf polars_info()$features$nightly
# #' pl$lit(c("hello there", "HI, THERE", NA))$str$to_titlecase()$to_series()
# expr_str_to_titlecase <- function() {
#   check_feature("nightly", "in $to_titlecase():")

#   self$`_rexpr`$str_to_titlecase(self) |>
#     wrap()
# }


#' Strip leading and trailing characters
#'
#'
#' @aliases expr_str_strip_chars
#' @description  Remove leading and trailing characters.
#'
#' @param matches The set of characters to be removed. All combinations of this
#' set of characters will be stripped. If `NULL` (default), all whitespace is
#' removed instead. This can be an Expr.
#'
#' @details
#' This function will not strip any chars beyond the first char not matched.
#' `strip_chars()` removes characters at the beginning and the end of the string.
#' Use `strip_chars_start()` and `strip_chars_end()` to remove characters only
#' from left and right respectively.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip_chars())
#' df$select(pl$col("foo")$str$strip_chars(" hel rld"))
expr_str_strip_chars <- function(matches = NULL) {
  self$`_rexpr`$str_strip_chars(as_polars_expr(matches, as_lit = TRUE)$`_rexpr`) |>
    wrap()
}

#' Strip leading characters
#'
#'
#' @aliases expr_str_strip_chars_start
#' @description  Remove leading characters.
#'
#' @param matches The set of characters to be removed. All combinations of this
#' set of characters will be stripped. If `NULL` (default), all whitespace is
#' removed instead. This can be an Expr.
#'
#' @details
#' This function will not strip any chars beyond the first char not matched.
#' `strip_chars_start()` removes characters at the beginning of the string only.
#' Use `strip_chars()` and `strip_chars_end()` to remove characters from the left
#' and right or only from the right respectively.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip_chars_start(" hel rld"))
expr_str_strip_chars_start <- function(matches = NULL) {
  self$`_rexpr`$str_strip_chars_start(as_polars_expr(matches, as_lit = TRUE)$`_rexpr`) |>
    wrap()
}

#' Strip trailing characters
#'
#'
#' @aliases expr_str_strip_chars_end
#' @description  Remove trailing characters.
#'
#' @param matches The set of characters to be removed. All combinations of this
#' set of characters will be stripped. If `NULL` (default), all whitespace is
#' removed instead. This can be an Expr.
#'
#' @details
#' This function will not strip any chars beyond the first char not matched.
#' `strip_chars_end()` removes characters at the end of the string only.
#' Use `strip_chars()` and `strip_chars_start()` to remove characters from the left
#' and right or only from the left respectively.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip_chars_end(" hel\trld"))
#' df$select(pl$col("foo")$str$strip_chars_end("rldhel\t "))
expr_str_strip_chars_end <- function(matches = NULL) {
  self$`_rexpr`$str_strip_chars_end(as_polars_expr(matches, as_lit = TRUE)$`_rexpr`) |>
    wrap()
}


#' Fills the string with zeroes.
#'
#' @aliases expr_str_zfill
#' @description Add zeroes to a string until it reaches `n` characters. If the
#' number of characters is already greater than `n`, the string is not modified.
#' @param alignment Fill the value up to this length. This can be an Expr or
#' something coercible to an Expr. Strings are parsed as column names.
#' @details
#' Return a copy of the string left filled with ASCII '0' digits to make a string
#' of length width.
#'
#' A leading sign prefix ('+'/'-') is handled by inserting the padding after the
#' sign character rather than before. The original string is returned if width is
#' less than or equal to `len(s)`.
#'
#' @inherit as_polars_expr return
#' @examples
#' some_floats_expr <- pl$lit(c(0, 10, -5, 5))
#'
#' # cast to String and ljust alignment = 5, and view as R char vector
#' some_floats_expr$cast(pl$String)$str$zfill(5)$to_r()
#'
#' # cast to int and the to utf8 and then ljust alignment = 5, and view as R
#' # char vector
#' some_floats_expr$cast(pl$Int64)$cast(pl$String)$str$zfill(5)$to_r()
expr_str_zfill <- function(alignment) {
  self$`_rexpr`$str_zfill(as_polars_expr(alignment)$`_rexpr`) |>
    wrap()
}


#' Left justify strings
#'
#' @description Return the string left justified in a string of length `width`.
#' @param width Justify left to this length.
#' @param fillchar Fill with this ASCII character.
#' @details Padding is done using the specified `fillchar`. The original string
#' is returned if `width` is less than or equal to `len(s)`.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
#' df$select(pl$col("a")$str$pad_end(8, "*"))
expr_str_pad_end <- function(width, fillchar = " ") {
  self$`_rexpr`$str_pad_end(width, fillchar) |>
    wrap()
}


#' Right justify strings
#'
#' @description Return the string right justified in a string of length `width`.
#' @param width Justify right to this length.
#' @param fillchar Fill with this ASCII character.
#' @inherit expr_str_pad_end details return
#' @examples
#' df <- pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
#' df$select(pl$col("a")$str$pad_start(8, "*"))
expr_str_pad_start <- function(width, fillchar = " ") {
  self$`_rexpr`$str_pad_start(width, fillchar) |>
    wrap()
}


#' Check if string contains a substring that matches a pattern
#'
#' @details To modify regular expression behaviour (such as case-sensitivity)
#' with flags, use the inline `(?iLmsuxU)` syntax. See the regex crate’s section
#' on [grouping and flags](https://docs.rs/regex/latest/regex/#grouping-and-flags)
#' for additional information about the use of inline expression modifiers.
#'
#' @param pattern A character or something can be coerced to a string [Expr][Expr_class]
#' of a valid regex pattern, compatible with the [regex crate](https://docs.rs/regex/latest/regex/).
#' @inheritParams rlang::args_dots_empty
#' @param literal Logical. If `TRUE` (default), treat `pattern` as a literal string,
#' not as a regular expression.
#' @param strict Logical. If `TRUE` (default), raise an error if the underlying pattern is
#' not a valid regex, otherwise mask out with a null value.
#'
#' @inherit as_polars_expr return
#' @seealso
#' - [`$str$start_with()`][expr_str_starts_with]: Check if string values
#'   start with a substring.
#' - [`$str$ends_with()`][expr_str_ends_with]: Check if string values end
#'   with a substring.
#' - [`$str$find()`][expr_str_find]: Return the index position of the first
#'   substring matching a pattern.
#'
#'
#' @examples
#' # The inline `(?i)` syntax example
#' pl$DataFrame(s = c("AAA", "aAa", "aaa"))$with_columns(
#'   default_match = pl$col("s")$str$contains("AA"),
#'   insensitive_match = pl$col("s")$str$contains("(?i)AA")
#' )
#'
#' df <- pl$DataFrame(txt = c("Crab", "cat and dog", "rab$bit", NA))
#' df$with_columns(
#'   regex = pl$col("txt")$str$contains("cat|bit"),
#'   literal = pl$col("txt")$str$contains("rab$", literal = TRUE)
#' )
expr_str_contains <- function(pattern, ..., literal = FALSE, strict = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_contains(as_polars_expr(pattern, as_lit = TRUE)$`_rexpr`, literal, strict)
  })
}


#' Check if string ends with a regex
#'
#' @description Check if string values end with a substring.
#' @param sub Suffix substring or Expr.
#' @details
#' See also `$str$starts_with()` and `$str$contains()`.
#' @inherit expr_str_contains return
#' @examples
#' df <- pl$DataFrame(fruits = c("apple", "mango", NA))
#' df$select(
#'   pl$col("fruits"),
#'   pl$col("fruits")$str$ends_with("go")$alias("has_suffix")
#' )
expr_str_ends_with <- function(sub) {
  wrap({
    sub <- as_polars_expr(sub, as_lit = TRUE)
    self$`_rexpr`$str_ends_with(sub$`_rexpr`)
  })
}


#' Check if string starts with a regex
#'
#' @description Check if string values starts with a substring.
#' @param sub Prefix substring or Expr.
#' @details
#' See also `$str$contains()` and `$str$ends_with()`.
#' @inherit expr_str_contains return
#' @examples
#' df <- pl$DataFrame(fruits = c("apple", "mango", NA))
#' df$select(
#'   pl$col("fruits"),
#'   pl$col("fruits")$str$starts_with("app")$alias("has_suffix")
#' )
expr_str_starts_with <- function(sub) {
  wrap({
    sub <- as_polars_expr(sub, as_lit = TRUE)
    self$`_rexpr`$str_starts_with(sub$`_rexpr`)
  })
}

#' Parse string values as JSON.
#'
#' @param dtype The dtype to cast the extracted value to. If `NULL`, the dtype
#' will be inferred from the JSON value.
#' @param infer_schema_length How many rows to parse to determine the schema.
#' If `NULL`, all rows are used.
#' @details
#' Throw errors if encounter invalid json strings.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   json_val = c('{"a":1, "b": true}', NA, '{"a":2, "b": false}')
#' )
#' dtype <- pl$Struct(pl$Field("a", pl$Int64), pl$Field("b", pl$Boolean))
#' df$select(pl$col("json_val")$str$json_decode(dtype))
expr_str_json_decode <- function(dtype, infer_schema_length = 100) {
  self$`_rexpr`$str_json_decode(dtype, infer_schema_length) |>
    wrap()
}

#' Extract the first match of JSON string with the provided JSONPath expression
#'
#' @param json_path A valid JSON path query string.
#' @details
#' Throw errors if encounter invalid JSON strings. All return value will be
#' cast to String regardless of the original value.
#'
#' Documentation on JSONPath standard can be found here: <https://goessner.net/articles/JsonPath/>.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   json_val = c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
#' )
#' df$select(pl$col("json_val")$str$json_path_match("$.a"))
expr_str_json_path_match <- function(json_path) {
  self$`_rexpr`$str_json_path_match(as_polars_expr(json_path, as_lit = TRUE)$`_rexpr`) |>
    wrap()
}


#' Decode a value using the provided encoding
#'
#' @param encoding Either 'hex' or 'base64'.
#' @inheritParams rlang::args_dots_empty
#' @param strict If `TRUE` (default), raise an error if the underlying value
#' cannot be decoded. Otherwise, replace it with a null value.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(strings = c("foo", "bar", NA))
#' df$select(pl$col("strings")$str$encode("hex"))
#' df$with_columns(
#'   pl$col("strings")$str$encode("base64")$alias("base64"), # notice DataType is not encoded
#'   pl$col("strings")$str$encode("hex")$alias("hex") # ... and must restored with cast
#' )$with_columns(
#'   pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$String),
#'   pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$String)
#' )
expr_str_decode <- function(encoding, ..., strict = TRUE) {
  wrap({
    check_dots_empty0(...)
    encoding <- arg_match0(encoding, values = c("hex", "base64"))
    switch(encoding,
      "hex" = self$`_rexpr`$str_hex_decode(strict),
      "base64" = self$`_rexpr`$str_base64_decode(strict),
      abort("Unreachable")
    )
  })
}

#' Encode a value using the provided encoding
#'
#' @param encoding Either 'hex' or 'base64'.
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(strings = c("foo", "bar", NA))
#' df$select(pl$col("strings")$str$encode("hex"))
#' df$with_columns(
#'   pl$col("strings")$str$encode("base64")$alias("base64"), # notice DataType is not encoded
#'   pl$col("strings")$str$encode("hex")$alias("hex") # ... and must restored with cast
#' )$with_columns(
#'   pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$String),
#'   pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$String)
#' )
expr_str_encode <- function(encoding) {
  wrap({
    encoding <- arg_match0(encoding, values = c("hex", "base64"))
    switch(encoding,
      "hex" = self$`_rexpr`$str_hex_encode(),
      "base64" = self$`_rexpr`$str_base64_encode(),
      abort("Unreachable")
    )
  })
}


#' Extract the target capture group from provided patterns
#'
#' @param pattern A valid regex pattern. Can be an Expr or something coercible
#' to an Expr. Strings are parsed as column names.
#' @param group_index Index of the targeted capture group. Group 0 means the whole
#' pattern, first group begin at index 1 (default).
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = c(
#'     "http://vote.com/ballon_dor?candidate=messi&ref=polars",
#'     "http://vote.com/ballon_dor?candidat=jorginho&ref=polars",
#'     "http://vote.com/ballon_dor?candidate=ronaldo&ref=polars"
#'   )
#' )
#' df$with_columns(
#'   extracted = pl$col("a")$str$extract(pl$lit(r"(candidate=(\w+))"), 1)
#' )
expr_str_extract <- function(pattern, group_index) {
  self$`_rexpr`$str_extract(as_polars_expr(pattern)$`_rexpr`, group_index) |>
    wrap()
}


#' Extract all matches for the given regex pattern
#'
#' @description Extracts all matches for the given regex pattern. Extracts each
#' successive non-overlapping regex match in an individual string as an array.
#' @param pattern A valid regex pattern
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(foo = c("123 bla 45 asd", "xyz 678 910t"))
#' df$select(
#'   pl$col("foo")$str$extract_all(r"((\d+))")$alias("extracted_nrs")
#' )
expr_str_extract_all <- function(pattern) {
  self$`_rexpr`$str_extract_all(as_polars_expr(pattern)$`_rexpr`) |>
    wrap()
}

#' Count all successive non-overlapping regex matches
#'
#' @inheritParams expr_str_contains
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(foo = c("12 dbc 3xy", "cat\\w", "1zy3\\d\\d", NA))
#'
#' df$with_columns(
#'   count_digits = pl$col("foo")$str$count_matches(r"(\d)"),
#'   count_slash_d = pl$col("foo")$str$count_matches(r"(\d)", literal = TRUE)
#' )
expr_str_count_matches <- function(pattern, ..., literal = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_count_matches(as_polars_expr(pattern, as_lit = TRUE)$`_rexpr`, literal)
  })
}


#' Split the string by a substring
#'
#' @param by Substring to split by. Can be an Expr.
#' @param inclusive If `TRUE`, include the split character/string in the results.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(s = c("foo bar", "foo-bar", "foo bar baz"))
#' df$select(pl$col("s")$str$split(by = " "))
#'
#' df <- pl$DataFrame(
#'   s = c("foo^bar", "foo_bar", "foo*bar*baz"),
#'   by = c("_", "_", "*")
#' )
#' df
#' df$select(pl$col("s")$str$split(by = pl$col("by"))$alias("split"))
expr_str_split <- function(by, inclusive = FALSE) {
  self$`_rexpr`$str_split(result(by), result(inclusive)) |>
    wrap()
}

#' Split the string by a substring using `n` splits
#'
#' @description This results in a struct of `n+1` fields. If it cannot make `n`
#' splits, the remaining field elements will be null.
#' @param by Substring to split by.
#' @param n Number of splits to make.
#' @param inclusive If `TRUE`, include the split character/string in the results.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(s = c("a_1", NA, "c", "d_4"))
#' df$with_columns(
#'   split = pl$col("s")$str$split_exact(by = "_", 1),
#'   split_inclusive = pl$col("s")$str$split_exact(by = "_", 1, inclusive = TRUE)
#' )
expr_str_split_exact <- function(by, n, inclusive = FALSE) {
  self$`_rexpr`$str_split_exact(by, result(n), result(inclusive)) |>
    wrap()
}


#' Split the string by a substring, restricted to returning at most `n` items
#'
#' @description
#' If the number of possible splits is less than `n-1`, the remaining field
#' elements will be null. If the number of possible splits is `n-1` or greater,
#' the last (nth) substring will contain the remainder of the string.
#' @param by Substring to split by.
#' @param n Number of splits to make.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(s = c("a_1", NA, "c", "d_4_e"))
#' df$with_columns(
#'   s1 = pl$col("s")$str$splitn(by = "_", 1),
#'   s2 = pl$col("s")$str$splitn(by = "_", 2),
#'   s3 = pl$col("s")$str$splitn(by = "_", 3)
#' )
expr_str_splitn <- function(by, n) {
  self$`_rexpr`$str_splitn(as_polars_expr(by, as_lit = TRUE)$`_rexpr`, n) |> wrap()
}


#' Replace first matching regex/literal substring with a new string value
#'
#' @inherit expr_str_contains details params
#' @section Capture groups:
#' The dollar sign (`$`) is a special character related to capture groups.
#' To refer to a literal dollar sign, use `$$` instead or set `literal` to `TRUE`.
#' @param value A character or an [Expr][Expr_class] of string
#' that will replace the matched substring.
#' @param n A number of matches to replace.
#' Note that regex replacement with `n > 1` not yet supported,
#' so raise an error if `n > 1` and `pattern` includes regex pattern
#' and `literal = FALSE`.
#' @inherit as_polars_expr return
#' @seealso
#' - [`<Expr>$str$replace_all()`][expr_str_replace_all]
#' @examples
#' df <- pl$DataFrame(id = 1L:2L, text = c("123abc", "abc456"))
#' df$with_columns(pl$col("text")$str$replace(r"(abc\b)", "ABC"))
#'
#' # Capture groups are supported.
#' # Use `${1}` in the value string to refer to the first capture group in the pattern,
#' # `${2}` to refer to the second capture group, and so on.
#' # You can also use named capture groups.
#' df <- pl$DataFrame(word = c("hat", "hut"))
#' df$with_columns(
#'   positional = pl$col("word")$str$replace("h(.)t", "b${1}d"),
#'   named = pl$col("word")$str$replace("h(?<vowel>.)t", "b${vowel}d")
#' )
#'
#' # Apply case-insensitive string replacement using the `(?i)` flag.
#' df <- pl$DataFrame(
#'   city = "Philadelphia",
#'   season = c("Spring", "Summer", "Autumn", "Winter"),
#'   weather = c("Rainy", "Sunny", "Cloudy", "Snowy")
#' )
#' df$with_columns(
#'   pl$col("weather")$str$replace("(?i)foggy|rainy|cloudy|snowy", "Sunny")
#' )
expr_str_replace <- function(pattern, value, ..., literal = FALSE, n = 1L) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_replace(as_polars_expr(pattern, as_lit = TRUE)$`_rexpr`, as_polars_expr(value, as_lit = TRUE)$`_rexpr`, literal, n)
  })
}



#' Replace all matching regex/literal substrings with a new string value
#'
#' @inherit expr_str_replace details sections params return
#' @seealso
#' - [`<Expr>$str$replace()`][expr_str_replace]
#' @examples
#' df <- pl$DataFrame(id = 1L:2L, text = c("abcabc", "123a123"))
#' df$with_columns(pl$col("text")$str$replace_all("a", "-"))
#'
#' # Capture groups are supported.
#' # Use `${1}` in the value string to refer to the first capture group in the pattern,
#' # `${2}` to refer to the second capture group, and so on.
#' # You can also use named capture groups.
#' df <- pl$DataFrame(word = c("hat", "hut"))
#' df$with_columns(
#'   positional = pl$col("word")$str$replace_all("h(.)t", "b${1}d"),
#'   named = pl$col("word")$str$replace_all("h(?<vowel>.)t", "b${vowel}d")
#' )
#'
#' # Apply case-insensitive string replacement using the `(?i)` flag.
#' df <- pl$DataFrame(
#'   city = "Philadelphia",
#'   season = c("Spring", "Summer", "Autumn", "Winter"),
#'   weather = c("Rainy", "Sunny", "Cloudy", "Snowy")
#' )
#' df$with_columns(
#'   pl$col("weather")$str$replace_all(
#'     "(?i)foggy|rainy|cloudy|snowy", "Sunny"
#'   )
#' )
expr_str_replace_all <- function(pattern, value, ..., literal = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_replace_all(as_polars_expr(pattern, as_lit = TRUE)$`_rexpr`, as_polars_expr(value, as_lit = TRUE)$`_rexpr`, literal)
  })
}


#' Create subslices of the string values of a String Series
#'
#' @param offset Start index. Negative indexing is supported.
#' @param length Length of the slice. If `NULL` (default), the slice is taken to
#' the end of the string.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(s = c("pear", NA, "papaya", "dragonfruit"))
#' df$with_columns(
#'   pl$col("s")$str$slice(-3)$alias("s_sliced")
#' )
expr_str_slice <- function(offset, length = NULL) {
  self$`_rexpr`$str_slice(as_polars_expr(offset)$`_rexpr`, as_polars_expr(length)$`_rexpr`) |>
    wrap()
}


#' Convert a String column into an Int64 column with base radix
#'
#' @inheritParams rlang::args_dots_empty
#' @param base A positive integer or expression which is the base of the string
#' we are parsing. Characters are parsed as column names. Default: `10L`.
#' @param strict A logical. If `TRUE` (default), parsing errors or integer overflow will
#' raise an error. If `FALSE`, silently convert to `null`.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(bin = c("110", "101", "010", "invalid"))
#' df$with_columns(
#'   parsed = pl$col("bin")$str$to_integer(base = 2, strict = FALSE)
#' )
#'
#' df <- pl$DataFrame(hex = c("fa1e", "ff00", "cafe", NA))
#' df$with_columns(
#'   parsed = pl$col("hex")$str$to_integer(base = 16, strict = TRUE)
#' )
expr_str_to_integer <- function(..., base = 10L, strict = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_to_integer(as_polars_expr(base)$`_rexpr`, strict)
  })
}

#' Returns string values in reversed order
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(text = c("foo", "bar", NA))
#' df$with_columns(reversed = pl$col("text")$str$reverse())
expr_str_reverse <- function() {
  self$`_rexpr`$str_reverse() |>
    wrap()
}

#' Use the aho-corasick algorithm to find matches
#'
#' This function determines if any of the patterns find a match.
#' @inherit expr_str_contains params return
#' @param patterns Character vector or something can be coerced to strings [Expr][Expr_class]
#' of a valid regex pattern, compatible with the [regex crate](https://docs.rs/regex/latest/regex/).
#' @param ascii_case_insensitive Enable ASCII-aware case insensitive matching.
#' When this option is enabled, searching will be performed without respect to
#' case for ASCII letters (a-z and A-Z) only.
#' @seealso
#' - [`<Expr>$str$contains()`][expr_str_contains]
#' @examples
#' df <- pl$DataFrame(
#'   lyrics = c(
#'     "Everybody wants to rule the world",
#'     "Tell me what you want, what you really really want",
#'     "Can you feel the love tonight"
#'   )
#' )
#'
#' df$with_columns(
#'   contains_any = pl$col("lyrics")$str$contains_any(c("you", "me"))
#' )
expr_str_contains_any <- function(patterns, ..., ascii_case_insensitive = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_contains_any(as_polars_expr(patterns, as_lit = TRUE)$`_rexpr`, ascii_case_insensitive)
  })
}

#' Use the aho-corasick algorithm to replace many matches
#'
#' This function replaces several matches at once.
#'
#' @param patterns String patterns to search. Can be an Expr.
#' @param replace_with A vector of strings used as replacements. If this is of
#' length 1, then it is applied to all matches. Otherwise, it must be of same
#' length as the `patterns` argument.
#' @param ascii_case_insensitive Enable ASCII-aware case insensitive matching.
#' When this option is enabled, searching will be performed without respect to
#' case for ASCII letters (a-z and A-Z) only.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   lyrics = c(
#'     "Everybody wants to rule the world",
#'     "Tell me what you want, what you really really want",
#'     "Can you feel the love tonight"
#'   )
#' )
#'
#' # a replacement of length 1 is applied to all matches
#' df$with_columns(
#'   remove_pronouns = pl$col("lyrics")$str$replace_many(c("you", "me"), "")
#' )
#'
#' # if there are more than one replacement, the patterns and replacements are
#' # matched
#' df$with_columns(
#'   fake_pronouns = pl$col("lyrics")$str$replace_many(c("you", "me"), c("foo", "bar"))
#' )
expr_str_replace_many <- function(patterns, replace_with, ascii_case_insensitive = FALSE) {
  self$`_rexpr`$str_replace_many(
    as_polars_expr(patterns, as_lit = TRUE)$`_rexpr`,
    as_polars_expr(replace_with, as_lit = TRUE)$`_rexpr`,
    ascii_case_insensitive
  ) |>
    wrap()
}


#' Extract all capture groups for the given regex pattern
#'
#' @details
#' All group names are strings. If your pattern contains unnamed groups, their
#' numerical position is converted to a string. See examples.
#' @param pattern A character of a valid regular expression pattern containing
#' at least one capture group, compatible with the [regex crate](https://docs.rs/regex/latest/regex/).
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   url = c(
#'     "http://vote.com/ballon_dor?candidate=messi&ref=python",
#'     "http://vote.com/ballon_dor?candidate=weghorst&ref=polars",
#'     "http://vote.com/ballon_dor?error=404&ref=rust"
#'   )
#' )
#'
#' pattern <- r"(candidate=(?<candidate>\w+)&ref=(?<ref>\w+))"
#'
#' df$with_columns(
#'   captures = pl$col("url")$str$extract_groups(pattern)
#' )$unnest("captures")
#'
#' # If the groups are unnamed, their numerical position (as a string) is used:
#'
#' pattern <- r"(candidate=(\w+)&ref=(\w+))"
#'
#' df$with_columns(
#'   captures = pl$col("url")$str$extract_groups(pattern)
#' )$unnest("captures")
expr_str_extract_groups <- function(pattern) {
  self$`_rexpr`$str_extract_groups(pattern) |>
    wrap()
}

#' Return the index position of the first substring matching a pattern
#'
#' @inherit expr_str_contains params details
#'
#' @inherit as_polars_expr return
#'
#' @seealso
#' - [`$str$start_with()`][expr_str_starts_with]: Check if string values
#'   start with a substring.
#' - [`$str$ends_with()`][expr_str_ends_with]: Check if string values end
#'   with a substring.
#' - [`$str$contains()`][expr_str_contains]: Check if string contains a substring
#'   that matches a pattern.
#'
#' @examples
#' pl$DataFrame(s = c("AAA", "aAa", "aaa"))$with_columns(
#'   default_match = pl$col("s")$str$find("Aa"),
#'   insensitive_match = pl$col("s")$str$find("(?i)Aa")
#' )
expr_str_find <- function(pattern, ..., literal = FALSE, strict = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_find(as_polars_expr(pattern, as_lit = TRUE)$`_rexpr`, literal, strict)
  })
}

#' Return the first n characters of each string
#'
#' @inherit expr_str_slice return
#'
#' @param n Length of the slice (integer or expression). Strings are parsed as
#' column names. Negative indexing is supported.
#'
#' @details
#' The `n` input is defined in terms of the number of characters in the (UTF-8)
#' string. A character is defined as a Unicode scalar value. A single character
#' is represented by a single byte when working with ASCII text, and a maximum
#' of 4 bytes otherwise.
#'
#' When the `n` input is negative, `head()` returns characters up to the `n`th
#' from the end of the string. For example, if `n = -3`, then all characters
#' except the last three are returned.
#'
#' If the length of the string has fewer than `n` characters, the full string is
#' returned.
#'
#' @examples
#' df <- pl$DataFrame(
#'   s = c("pear", NA, "papaya", "dragonfruit"),
#'   n = c(3, 4, -2, -5)
#' )
#'
#' df$with_columns(
#'   s_head_5 = pl$col("s")$str$head(5),
#'   s_head_n = pl$col("s")$str$head("n")
#' )
expr_str_head <- function(n) {
  self$`_rexpr`$str_head(as_polars_expr(n)$`_rexpr`) |>
    wrap()
}

#' Return the last n characters of each string
#'
#' @inheritParams expr_str_head
#' @inherit expr_str_slice return
#'
#' @details
#' The `n` input is defined in terms of the number of characters in the (UTF-8)
#' string. A character is defined as a Unicode scalar value. A single character
#' is represented by a single byte when working with ASCII text, and a maximum
#' of 4 bytes otherwise.
#'
#' When the `n` input is negative, `tail()` returns characters starting from the
#' `n`th from the beginning of the string. For example, if `n = -3`, then all
#' characters except the first three are returned.
#'
#' If the length of the string has fewer than `n` characters, the full string is
#' returned.
#'
#' @examples
#' df <- pl$DataFrame(
#'   s = c("pear", NA, "papaya", "dragonfruit"),
#'   n = c(3, 4, -2, -5)
#' )
#'
#' df$with_columns(
#'   s_tail_5 = pl$col("s")$str$tail(5),
#'   s_tail_n = pl$col("s")$str$tail("n")
#' )
expr_str_tail <- function(n) {
  self$`_rexpr`$str_tail(as_polars_expr(n)$`_rexpr`) |>
    wrap()
}


#' Use the aho-corasick algorithm to extract matches
#'
#' @param patterns String patterns to search. This can be an Expr or something
#' coercible to an Expr. Strings are parsed as column names.
#' @inheritParams expr_str_contains_any
#' @inheritParams rlang::args_dots_empty
#' @param overlapping Whether matches can overlap.
#'
#' @inherit expr_str_slice return
#'
#' @examples
#' df <- pl$DataFrame(values = "discontent")
#' patterns <- pl$lit(c("winter", "disco", "onte", "discontent"))
#'
#' df$with_columns(
#'   matches = pl$col("values")$str$extract_many(patterns),
#'   matches_overlap = pl$col("values")$str$extract_many(patterns, overlapping = TRUE)
#' )
#'
#' df <- pl$DataFrame(
#'   values = c("discontent", "rhapsody"),
#'   patterns = list(c("winter", "disco", "onte", "discontent"), c("rhap", "ody", "coalesce"))
#' )
#'
#' df$select(pl$col("values")$str$extract_many("patterns"))
expr_str_extract_many <- function(patterns, ..., ascii_case_insensitive = FALSE, overlapping = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$str_extract_many(
      as_polars_expr(patterns)$`_rexpr`, ascii_case_insensitive, overlapping
    )
  })
}
