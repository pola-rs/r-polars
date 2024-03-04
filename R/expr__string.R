# this file sources list-expression functions to be bundled in the 'expr$str' sub namespace
# the sub name space is instantiated from Expr_str- function
# bundling these functions into an environment, depends on a macro call in zzz.R
# expr_str_make_sub_ns = macro_new_subnamespace("^ExprStr_", "RPolarsExprStrNameSpace")


# TODO for 0.16.0: rename arguments, should not allow positional arguments except for the first two
#' Convert a String column into a Date/Datetime/Time column.
#'
#' Similar to the [strptime()] function.
#'
#' When parsing a Datetime the column precision will be inferred from the format
#' string, if given, eg: `"%F %T%.3f"` => [`pl$Datetime("ms")`][pl_Datetime].
#' If no fractional second component is found then the default is `"us"` (microsecond).
#' @param datatype The data type to convert into. Can be either Date, Datetime,
#' or Time.
#' @param format Format to use for conversion. Refer to
#' [the chrono crate documentation](https://docs.rs/chrono/latest/chrono/format/strftime/index.html)
#' for the full specification. Example: `"%Y-%m-%d %H:%M:%S"`.
#' If `NULL` (default), the format is inferred from the data.
#' Notice that time zone `%Z` is not supported and will just ignore timezones.
#' Numeric time zones like `%z` or `%:z` are supported.
#' @param strict If `TRUE` (default), raise an error if a single string cannot
#' be parsed. If `FALSE`, produce a polars `null`.
#' @param exact If `TRUE` (default), require an exact format match. If `FALSE`,
#' allow the format to match anywhere in the target string.
#' Conversion to the Time type is always exact.
#' Note that using `exact = FALSE` introduces a performance penalty -
#' cleaning your data beforehand will almost certainly be more performant.
#' @param cache Use a cache of unique, converted dates to apply the datetime
#' conversion.
#' @param ambiguous Determine how to deal with ambiguous datetimes:
#' * `"raise"` (default): raise
#' * `"earliest"`: use the earliest datetime
#' * `"latest"`: use the latest datetime
#' @return [Expr][Expr_class] of Date, Datetime or Time type
#' @seealso
#' - [`<Expr>$str$to_date()`][ExprStr_to_date]
#' - [`<Expr>$str$to_datetime()`][ExprStr_to_datetime]
#' - [`<Expr>$str$to_time()`][ExprStr_to_time]
#' @examples
#' # Dealing with a consistent format
#' s = pl$Series(c("2020-01-01 01:00Z", "2020-01-01 02:00Z"))
#'
#' s$str$strptime(pl$Datetime(), "%Y-%m-%d %H:%M%#z")
#'
#' # Auto infer format
#' s$str$strptime(pl$Datetime())
#'
#' # Datetime with timezone is interpreted as UTC timezone
#' pl$Series("2020-01-01T01:00:00+09:00")$str$strptime(pl$Datetime())
#'
#' # Dealing with different formats.
#' s = pl$Series(
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
#' s = pl$Series(
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
#'   strict = FALSE,
#' )
ExprStr_strptime = function(
    datatype,
    format = NULL,
    strict = TRUE,
    exact = TRUE,
    cache = TRUE,
    ambiguous = "raise") {
  pcase(
    # not a datatype
    !is_polars_dtype(datatype),
    Err_plain("arg datatype is not an RPolarsDataType"),
    # Datetime
    pl$same_outer_dt(datatype, pl$Datetime()),
    {
      datetime_type = .pr$DataType$get_insides(datatype)
      .pr$Expr$str_to_datetime(
        self, format, datetime_type$tu, datetime_type$tz, strict, exact, cache, ambiguous
      ) |> and_then(
        \(expr) .pr$Expr$dt_cast_time_unit(expr, datetime_type$tu) # cast if not an err
      )
    },
    # Date
    datatype == pl$Date,
    .pr$Expr$str_to_date(self, format, strict, exact, cache),
    # Time
    datatype == pl$Time,
    .pr$Expr$str_to_time(self, format, strict, cache),
    # Other
    or_else = Err_plain("datatype should be of type {Date, Datetime, Time}")
  ) |>
    unwrap("in str$strptime():")
}

# TODO for 0.16.0: should not allow positional arguments except for the first one
#' Convert a String column into a Date column
#'
#' @inheritParams ExprStr_strptime
#' @format Format to use for conversion. Refer to
#' [the chrono crate documentation](https://docs.rs/chrono/latest/chrono/format/strftime/index.html)
#' for the full specification. Example: `"%Y-%m-%d"`.
#' If `NULL` (default), the format is inferred from the data.
#' @return [Expr][Expr_class] of Date type
#' @seealso
#' - [`<Expr>$str$strptime()`][ExprStr_strptime]
#' @examples
#' s = pl$Series(c("2020/01/01", "2020/02/01", "2020/03/01"))
#'
#' s$str$to_date()
ExprStr_to_date = function(format = NULL, strict = TRUE, exact = TRUE, cache = TRUE) {
  .pr$Expr$str_to_date(self, format, strict, exact, cache) |>
    unwrap("in $str$to_date():")
}

# TODO for 0.16.0: should not allow positional arguments except for the first one
#' Convert a String column into a Time column
#'
#' @inheritParams ExprStr_strptime
#' @format Format to use for conversion. Refer to
#' [the chrono crate documentation](https://docs.rs/chrono/latest/chrono/format/strftime/index.html)
#' for the full specification. Example: `"%H:%M:%S"`.
#' If `NULL` (default), the format is inferred from the data.
#' @return [Expr][Expr_class] of Time type
#' @seealso
#' - [`<Expr>$str$strptime()`][ExprStr_strptime]
#' @examples
#' s = pl$Series(c("01:00", "02:00", "03:00"))
#'
#' s$str$to_time("%H:%M")
ExprStr_to_time = function(format = NULL, strict = TRUE, cache = TRUE) {
  .pr$Expr$str_to_time(self, format, strict, cache) |>
    unwrap("in $str$to_time():")
}

# TODO for 0.16.0: should not allow positional arguments except for the first one
#' Convert a String column into a Datetime column
#'
#' @inheritParams ExprStr_strptime
#' @param time_unit Unit of time for the resulting Datetime column. If `NULL` (default),
#' the time unit is inferred from the format string if given,
#' eg: `"%F %T%.3f"` => [`pl$Datetime("ms")`][pl_Datetime].
#' If no fractional second component is found, the default is `"us"` (microsecond).
#' @param time_zone for the resulting [Datetime][pl_Datetime] column.
#' @param exact If `TRUE` (default), require an exact format match. If `FALSE`, allow the format to match
#' anywhere in the target string. Note that using `exact = FALSE` introduces a performance
#' penalty - cleaning your data beforehand will almost certainly be more performant.
#' @return [Expr][Expr_class] of [Datetime][pl_Datetime] type
#' @seealso
#' - [`<Expr>$str$strptime()`][ExprStr_strptime]
#' @examples
#' s = pl$Series(c("2020-01-01 01:00Z", "2020-01-01 02:00Z"))
#'
#' s$str$to_datetime("%Y-%m-%d %H:%M%#z")
#' s$str$to_datetime(time_unit = "ms")
ExprStr_to_datetime = function(
    format = NULL,
    time_unit = NULL,
    time_zone = NULL,
    strict = TRUE,
    exact = TRUE,
    cache = TRUE,
    ambiguous = "raise") {
  .pr$Expr$str_to_datetime(
    self, format, time_unit, time_zone, strict, exact, cache, ambiguous
  ) |>
    unwrap("in $str$to_datetime():")
}

#' Get the number of bytes in strings
#' @description
#' Get length of the strings as UInt32 (as number of bytes). Use `$str$len_chars()`
#' to get the number of characters.
#'
#' @keywords ExprStr
#' @details
#' If you know that you are working with ASCII text, `lengths` will be
#' equivalent, and faster (returns length in terms of the number of bytes).
#' @return Expr of u32
#' @examples
#' pl$DataFrame(
#'   s = c("Café", NA, "345", "æøå")
#' )$select(
#'   pl$col("s"),
#'   pl$col("s")$str$len_bytes()$alias("lengths"),
#'   pl$col("s")$str$len_chars()$alias("n_chars")
#' )
ExprStr_len_bytes = function() {
  .pr$Expr$str_len_bytes(self)
}

#' Get the number of characters in strings
#' @description
#' Get length of the strings as UInt32 (as number of characters). Use
#' `$str$len_bytes()` to get the number of bytes.
#'
#' @keywords ExprStr
#' @inherit ExprStr_len_bytes examples details return
ExprStr_len_chars = function() {
  .pr$Expr$str_len_chars(self)
}

#' Vertically concatenate the string values in the column to a single string value.
#'
#' @param delimiter The delimiter to insert between consecutive string values.
#' @param ... Ignored.
#' @param ignore_nulls Ignore null values (default). If `FALSE`, null values will be
#' propagated: if the column contains any null values, the output is null.
#' @return Expr of String concatenated
#' @examples
#' # concatenate a Series of strings to a single string
#' df = pl$DataFrame(foo = c(1, NA, 2))
#'
#' df$select(pl$col("foo")$str$concat("-"))
#'
#' df$select(pl$col("foo")$str$concat("-", ignore_nulls = FALSE))
ExprStr_concat = function(
    delimiter = "",
    ...,
    ignore_nulls = TRUE) {
  .pr$Expr$str_concat(self, delimiter, ignore_nulls) |>
    unwrap("in $concat():")
}

#' Convert a string to uppercase
#'
#' @description Transform to uppercase variant.
#' @keywords ExprStr
#' @return Expr of String uppercase chars
#' @examples
#' pl$lit(c("A", "b", "c", "1", NA))$str$to_uppercase()$to_series()
ExprStr_to_uppercase = function() {
  .pr$Expr$str_to_uppercase(self)
}

#' Convert a string to lowercase
#'
#' @description Transform to lowercase variant.
#' @keywords ExprStr
#' @return Expr of String lowercase chars
#' @examples
#' pl$lit(c("A", "b", "c", "1", NA))$str$to_lowercase()$to_series()
ExprStr_to_lowercase = function() {
  .pr$Expr$str_to_lowercase(self)
}

#' Convert a string to titlecase
#'
#' @description Transform to titlecase variant.
#' @keywords ExprStr
#' @return Expr of String titlecase chars
#' @details
#' This method is only available with the "nightly" feature.
#' See [polars_info()] for more details.
#' @examplesIf polars_info()$features$nightly
#' pl$lit(c("hello there", "HI, THERE", NA))$str$to_titlecase()$to_series()
ExprStr_to_titlecase = function() {
  check_feature("nightly", "in $to_titlecase():")

  .pr$Expr$str_to_titlecase(self) |>
    unwrap("in $to_titlecase():")
}


#' Strip leading and trailing characters
#'
#'
#' @aliases expr_str_strip_chars
#' @description  Remove leading and trailing characters.
#'
#' @keywords ExprStr
#' @param matches The set of characters to be removed. All combinations of this
#' set of characters will be stripped. If `NULL` (default), all whitespace is
#' removed instead. This can be an Expr.
#'
#' @details
#' This function will not strip any chars beyond the first char not matched.
#' `strip_chars()` removes characters at the beginning and the end of the string.
#' Use `strip_chars_start()` and `strip_chars_end()` to remove characters only
#' from left and right respectively.
#' @return Expr of String lowercase chars
#' @examples
#' df = pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip_chars())
#' df$select(pl$col("foo")$str$strip_chars(" hel rld"))
ExprStr_strip_chars = function(matches = NULL) {
  .pr$Expr$str_strip_chars(self, matches) |>
    unwrap("in $str$strip_chars():")
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
#' @return Expr of String lowercase chars
#' @examples
#' df = pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip_chars_start(" hel rld"))
ExprStr_strip_chars_start = function(matches = NULL) {
  .pr$Expr$str_strip_chars_start(self, matches) |>
    unwrap("in $str$strip_chars_start():")
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
#' @return Expr of String lowercase chars
#' @examples
#' df = pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip_chars_end(" hel\trld"))
#' df$select(pl$col("foo")$str$strip_chars_end("rldhel\t "))
ExprStr_strip_chars_end = function(matches = NULL) {
  .pr$Expr$str_strip_chars_end(self, matches) |>
    unwrap("in $str$strip_chars_end():")
}


#' Fills the string with zeroes.
#'
#' @aliases expr_str_zfill
#' @description Add zeroes to a string until it reaches `n` characters. If the
#' number of characters is already greater than `n`, the string is not modified.
#' @keywords ExprStr
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
#' @return Expr
#' @examples
#' some_floats_expr = pl$lit(c(0, 10, -5, 5))
#'
#' # cast to String and ljust alignment = 5, and view as R char vector
#' some_floats_expr$cast(pl$String)$str$zfill(5)$to_r()
#'
#' # cast to int and the to utf8 and then ljust alignment = 5, and view as R
#' # char vector
#' some_floats_expr$cast(pl$Int64)$cast(pl$String)$str$zfill(5)$to_r()
ExprStr_zfill = function(alignment) {
  .pr$Expr$str_zfill(self, alignment) |>
    unwrap("in str$zfill():")
}


#' Left justify strings
#'
#' @description Return the string left justified in a string of length `width`.
#' @keywords ExprStr
#' @param width Justify left to this length.
#' @param fillchar Fill with this ASCII character.
#' @details Padding is done using the specified `fillchar`. The original string
#' is returned if `width` is less than or equal to `len(s)`.
#' @return Expr of String
#' @examples
#' df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
#' df$select(pl$col("a")$str$pad_end(8, "*"))
ExprStr_pad_end = function(width, fillchar = " ") {
  .pr$Expr$str_pad_end(self, width, fillchar) |>
    unwrap("in str$pad_end(): ")
}


#' Right justify strings
#'
#' @description Return the string right justified in a string of length `width`.
#' @keywords ExprStr
#' @param width Justify right to this length.
#' @param fillchar Fill with this ASCII character.
#' @inherit ExprStr_pad_end details return
#' @examples
#' df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
#' df$select(pl$col("a")$str$pad_start(8, "*"))
ExprStr_pad_start = function(width, fillchar = " ") {
  .pr$Expr$str_pad_start(self, width, fillchar) |>
    unwrap("in str$pad_start(): ")
}


#' Check if string contains a regex
#'
#' @description Check if string contains a substring that matches a regex.
#' @keywords ExprStr
#' @param pattern String or Expr of a string, a valid regex pattern.
#' @param literal Treat pattern as a literal string.
#' @param strict Raise an error if the underlying pattern is not a valid regex
#' expression, otherwise replace the invalid regex with a null value.
#' @details
#' See also `$str$starts_with()` and `$str$ends_with()`.
#' @return Expr returning a Boolean
#' @examples
#' df = pl$DataFrame(a = c("Crab", "cat and dog", "rab$bit", NA))
#' df$select(
#'   pl$col("a"),
#'   pl$col("a")$str$contains("cat|bit")$alias("regex"),
#'   pl$col("a")$str$contains("rab$", literal = TRUE)$alias("literal")
#' )
ExprStr_contains = function(pattern, literal = FALSE, strict = TRUE) {
  .pr$Expr$str_contains(self, wrap_e(pattern, str_to_lit = TRUE), literal, strict)
}

#' Check if string ends with a regex
#'
#' @description Check if string values end with a substring.
#' @keywords ExprStr
#' @param sub Suffix substring or Expr.
#' @details
#' See also `$str$starts_with()` and `$str$contains()`.
#' @inherit ExprStr_contains return
#' @examples
#' df = pl$DataFrame(fruits = c("apple", "mango", NA))
#' df$select(
#'   pl$col("fruits"),
#'   pl$col("fruits")$str$ends_with("go")$alias("has_suffix")
#' )
ExprStr_ends_with = function(sub) {
  .pr$Expr$str_ends_with(self, wrap_e(sub, str_to_lit = TRUE))
}


#' Check if string starts with a regex
#'
#' @description Check if string values starts with a substring.
#' @keywords ExprStr
#' @param sub Prefix substring or Expr.
#' @details
#' See also `$str$contains()` and `$str$ends_with()`.
#' @inherit ExprStr_contains return
#' @examples
#' df = pl$DataFrame(fruits = c("apple", "mango", NA))
#' df$select(
#'   pl$col("fruits"),
#'   pl$col("fruits")$str$starts_with("app")$alias("has_suffix")
#' )
ExprStr_starts_with = function(sub) {
  .pr$Expr$str_starts_with(self, wrap_e(sub, str_to_lit = TRUE))
}

#' Parse string values as JSON.
#'
#' @keywords ExprStr
#' @param dtype The dtype to cast the extracted value to. If `NULL`, the dtype
#' will be inferred from the JSON value.
#' @param infer_schema_length How many rows to parse to determine the schema.
#' If `NULL`, all rows are used.
#' @details
#' Throw errors if encounter invalid json strings.
#'
#' @return Expr returning a struct
#' @examples
#' df = pl$DataFrame(
#'   json_val = c('{"a":1, "b": true}', NA, '{"a":2, "b": false}')
#' )
#' dtype = pl$Struct(pl$Field("a", pl$Int64), pl$Field("b", pl$Boolean))
#' df$select(pl$col("json_val")$str$json_decode(dtype))
ExprStr_json_decode = function(dtype, infer_schema_length = 100) {
  .pr$Expr$str_json_decode(self, dtype, infer_schema_length) |>
    unwrap("in str$json_decode():")
}

#' Extract the first match of JSON string with the provided JSONPath expression
#'
#' @keywords ExprStr
#' @param json_path A valid JSON path query string.
#' @details
#' Throw errors if encounter invalid JSON strings. All return value will be
#' cast to String regardless of the original value.
#'
#' Documentation on JSONPath standard can be found here: <https://goessner.net/articles/JsonPath/>.
#' @return String array. Contain null if original value is null or the json_path
#' return nothing.
#' @examples
#' df = pl$DataFrame(
#'   json_val = c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
#' )
#' df$select(pl$col("json_val")$str$json_path_match("$.a"))
ExprStr_json_path_match = function(json_path) {
  .pr$Expr$str_json_path_match(self, json_path) |>
    unwrap("in str$json_path_match(): ")
}


#' Decode a value using the provided encoding
#'
#' @keywords ExprStr
#' @param encoding Either 'hex' or 'base64'.
#' @param ... Not used currently.
#' @param strict If `TRUE` (default), raise an error if the underlying value
#' cannot be decoded. Otherwise, replace it with a null value.
#'
#' @return String array with values decoded using provided encoding
#'
#' @examples
#' df = pl$DataFrame(strings = c("foo", "bar", NA))
#' df$select(pl$col("strings")$str$encode("hex"))
#' df$with_columns(
#'   pl$col("strings")$str$encode("base64")$alias("base64"), # notice DataType is not encoded
#'   pl$col("strings")$str$encode("hex")$alias("hex") # ... and must restored with cast
#' )$with_columns(
#'   pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$String),
#'   pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$String)
#' )
ExprStr_decode = function(encoding, ..., strict = TRUE) {
  uw = \(res) unwrap(res, "in $str$decode():")

  pcase(
    !is_string(encoding), stop("encoding must be a string, it was: ", encoding),
    encoding == "hex", uw(.pr$Expr$str_hex_decode(self, strict)),
    encoding == "base64", uw(.pr$Expr$str_base64_decode(self, strict)),
    or_else = stop("encoding must be one of 'hex' or 'base64', got ", encoding)
  )
}

#' Encode a value using the provided encoding
#'
#' @keywords ExprStr
#' @param encoding Either 'hex' or 'base64'.
#' @return String array with values encoded using provided encoding
#'
#' @examples
#' df = pl$DataFrame(strings = c("foo", "bar", NA))
#' df$select(pl$col("strings")$str$encode("hex"))
#' df$with_columns(
#'   pl$col("strings")$str$encode("base64")$alias("base64"), # notice DataType is not encoded
#'   pl$col("strings")$str$encode("hex")$alias("hex") # ... and must restored with cast
#' )$with_columns(
#'   pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$String),
#'   pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$String)
#' )
ExprStr_encode = function(encoding) {
  uw = \(res) unwrap(res, "in $str$$encode():")

  pcase(
    !is_string(encoding), stop("encoding must be a string, it was: ", encoding),
    encoding == "hex", uw(.pr$Expr$str_hex_encode(self)),
    encoding == "base64", uw(.pr$Expr$str_base64_encode(self)),
    or_else = stop("encoding must be one of 'hex' or 'base64', got ", encoding)
  )
}


#' Extract the target capture group from provided patterns
#'
#' @keywords ExprStr
#' @param pattern A valid regex pattern. Can be an Expr or something coercible
#' to an Expr. Strings are parsed as column names.
#' @param group_index Index of the targeted capture group. Group 0 means the whole
#' pattern, first group begin at index 1 (default).
#'
#' @return
#' String array. Contains null if original value is null or regex capture nothing.
#'
#' @examples
#' df = pl$DataFrame(
#'   a = c(
#'     "http://vote.com/ballon_dor?candidate=messi&ref=polars",
#'     "http://vote.com/ballon_dor?candidat=jorginho&ref=polars",
#'     "http://vote.com/ballon_dor?candidate=ronaldo&ref=polars"
#'   )
#' )
#' df$with_columns(
#'   extracted = pl$col("a")$str$extract(pl$lit(r"(candidate=(\w+))"), 1)
#' )
ExprStr_extract = function(pattern, group_index) {
  .pr$Expr$str_extract(self, pattern, group_index) |>
    unwrap("in str$extract(): ")
}


#' Extract all matches for the given regex pattern
#'
#' @description Extracts all matches for the given regex pattern. Extracts each
#' successive non-overlapping regex match in an individual string as an array.
#' @keywords ExprStr
#' @param pattern A valid regex pattern
#'
#' @return
#' `List[String]` array. Contain null if original value is null or regex capture
#' nothing.
#'
#' @examples
#' df = pl$DataFrame(foo = c("123 bla 45 asd", "xyz 678 910t"))
#' df$select(
#'   pl$col("foo")$str$extract_all(r"((\d+))")$alias("extracted_nrs")
#' )
ExprStr_extract_all = function(pattern) {
  .pr$Expr$str_extract_all(self, wrap_e(pattern))
}

#' Count all successive non-overlapping regex matches
#'
#' @keywords ExprStr
#' @param pattern A valid regex pattern
#' @param literal Treat pattern as a literal string.
#'
#' @return
#' UInt32 array. Contains null if original value is null or regex capture nothing.
#'
#' @examples
#' df = pl$DataFrame(foo = c("123 bla 45 asd", "xyz 678 910t"))
#' df$select(
#'   pl$col("foo")$str$count_matches(r"{(\d)}")$alias("count digits")
#' )
#'
#' # we can use Polars expressions as pattern so that it's not necessarily the
#' # same for all rows
#' df2 = pl$DataFrame(foo = c("hello", "hi there"), pat = c("ell", "e"))
#' df2$with_columns(
#'   pl$col("foo")$str$count_matches(pl$col("pat"))$alias("reg_count")
#' )
ExprStr_count_matches = function(pattern, literal = FALSE) {
  .pr$Expr$str_count_matches(self, wrap_e(pattern), literal) |>
    unwrap("in $str$count_matches():")
}


#' Split the string by a substring
#'
#' @keywords ExprStr
#' @param by String or Expr of a string, a valid regex pattern that will be
#' used to split the string.
#' @param inclusive If `TRUE`, include the split character/string in the results.
#'
#' @return
#' List of String type
#'
#' @examples
#' df = pl$DataFrame(s = c("foo bar", "foo-bar", "foo bar baz"))
#' df$select(pl$col("s")$str$split(by = " "))
#'
#' df = pl$DataFrame(
#'   s = c("foo^bar", "foo_bar", "foo*bar*baz"),
#'   by = c("_", "_", "*")
#' )
#' df
#' df$select(pl$col("s")$str$split(by = pl$col("by"))$alias("split"))
ExprStr_split = function(by, inclusive = FALSE) {
  unwrap(
    .pr$Expr$str_split(self, result(by), result(inclusive)),
    context = "in str$split():"
  )
}

#' Split the string by a substring using `n` splits
#'
#' @description This results in a struct of `n+1` fields. If it cannot make `n`
#' splits, the remaining field elements will be null.
#' @keywords ExprStr
#' @param by Substring to split by.
#' @param n Number of splits to make.
#' @param inclusive If `TRUE`, include the split character/string in the results.
#'
#' @return Struct where each of n+1 fields is of String type
#'
#' @examples
#' df = pl$DataFrame(s = c("a_1", NA, "c", "d_4"))
#' df$with_columns(
#'   split = pl$col("s")$str$split_exact(by = "_", 1),
#'   split_inclusive = pl$col("s")$str$split_exact(by = "_", 1, inclusive = TRUE)
#' )
ExprStr_split_exact = function(by, n, inclusive = FALSE) {
  unwrap(
    .pr$Expr$str_split_exact(self, by, result(n), result(inclusive)),
    context = "in str$split_exact():"
  )
}


#' Split the string by a substring, restricted to returning at most `n` items
#'
#' @description
#' If the number of possible splits is less than `n-1`, the remaining field
#' elements will be null. If the number of possible splits is `n-1` or greater,
#' the last (nth) substring will contain the remainder of the string.
#' @keywords ExprStr
#' @param by Substring to split by.
#' @param n Number of splits to make.
#'
#' @return
#' Struct where each of `n` fields is of String type
#'
#' @examples
#' df = pl$DataFrame(s = c("a_1", NA, "c", "d_4_e"))
#' df$with_columns(
#'   s1 = pl$col("s")$str$splitn(by = "_", 1),
#'   s2 = pl$col("s")$str$splitn(by = "_", 2),
#'   s3 = pl$col("s")$str$splitn(by = "_", 3)
#' )
ExprStr_splitn = function(by, n) {
  .pr$Expr$str_splitn(self, result(by), result(n)) |> unwrap("in str$splitn():")
}


#' Replace first matching regex/literal substring with a new string value
#'
#' @keywords ExprStr
#' @param pattern Regex pattern, can be an Expr.
#' @param value Replacement, can be an Expr.
#' @param literal Treat pattern as a literal string.
#'
#' @return Expr of String Series
#'
#' @seealso `$str$replace_all()`: Replace all matching regex/literal substrings.
#'
#' @examples
#' df = pl$DataFrame(id = c(1, 2), text = c("123abc", "abc456"))
#' df$with_columns(
#'   pl$col("text")$str$replace(r"{abc\b}", "ABC")
#' )
ExprStr_replace = function(pattern, value, literal = FALSE) {
  .pr$Expr$str_replace(self, wrap_e_result(pattern), wrap_e_result(value), result(literal)) |>
    unwrap("in str$replace():")
}



#' Replace all matching regex/literal substrings with a new string value
#'
#' @keywords ExprStr
#' @param pattern Regex pattern, can be an Expr.
#' @param value Replacement, can be an Expr.
#' @param literal Treat pattern as a literal string.
#'
#' @return Expr of String Series
#'
#' @seealso `$str$replace()`: Replace first matching regex/literal substring.
#'
#' @examples
#' df = pl$DataFrame(id = c(1, 2), text = c("abcabc", "123a123"))
#' df$with_columns(
#'   pl$col("text")$str$replace_all("a", "-")
#' )
ExprStr_replace_all = function(pattern, value, literal = FALSE) {
  .pr$Expr$str_replace_all(self, wrap_e_result(pattern), wrap_e_result(value), result(literal)) |>
    unwrap("in str$replace_all():")
}


#' Create subslices of the string values of a String Series
#'
#' @keywords ExprStr
#' @param offset Start index. Negative indexing is supported.
#' @param length Length of the slice. If `NULL` (default), the slice is taken to
#' the end of the string.
#'
#' @return Expr: Series of dtype String.
#'
#' @examples
#' df = pl$DataFrame(s = c("pear", NA, "papaya", "dragonfruit"))
#' df$with_columns(
#'   pl$col("s")$str$slice(-3)$alias("s_sliced")
#' )
ExprStr_slice = function(offset, length = NULL) {
  .pr$Expr$str_slice(self, result(offset), result(length)) |>
    unwrap("in str$slice():")
}

#' Returns a column with a separate row for every string character
#'
#' @keywords ExprStr
#' @return Expr: Series of dtype String.
#' @examples
#' df = pl$DataFrame(a = c("foo", "bar"))
#' df$select(pl$col("a")$str$explode())
ExprStr_explode = function() {
  .pr$Expr$str_explode(self) |>
    unwrap("in str$explode():")
}

#' Parse integers with base radix from strings
#'
#' @description Parse integers with base 2 by default.
#' @keywords ExprStr
#' @param radix Positive integer which is the base of the string we are parsing.
#' Default is 2.
#' @param strict If `TRUE` (default), integer overflow will raise an error.
#' Otherwise, they will be converted to `null`.
#' @return Expr: Series of dtype i32.
#' @examples
#' df = pl$DataFrame(bin = c("110", "101", "010"))
#' df$select(pl$col("bin")$str$parse_int())
#' df$select(pl$col("bin")$str$parse_int(10))
#'
#' # Convert to null if the string is not a valid integer when `strict = FALSE`
#' df = pl$DataFrame(x = c("1", "2", "foo"))
#' df$select(pl$col("x")$str$parse_int(10, FALSE))
ExprStr_parse_int = function(radix = 2, strict = TRUE) {
  .pr$Expr$str_parse_int(self, radix, strict) |> unwrap("in str$parse_int():")
}

#' Returns string values in reversed order
#'
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(text = c("foo", "bar", NA))
#' df$with_columns(reversed = pl$col("text")$str$reverse())
ExprStr_reverse = function() {
  .pr$Expr$str_reverse(self) |>
    unwrap("in str$reverse():")
}

#' Use the aho-corasick algorithm to find matches
#'
#' This function determines if any of the patterns find a match.
#' @param patterns String patterns to search. Can be an Expr.
#' @param ascii_case_insensitive Enable ASCII-aware case insensitive matching.
#' When this option is enabled, searching will be performed without respect to
#' case for ASCII letters (a-z and A-Z) only.
#'
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
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
ExprStr_contains_any = function(patterns, ascii_case_insensitive = FALSE) {
  .pr$Expr$str_contains_any(self, patterns, ascii_case_insensitive) |>
    unwrap("in str$contains_any():")
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
#' @return Expr
#'
#' @examples
#' df = pl$DataFrame(
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
ExprStr_replace_many = function(patterns, replace_with, ascii_case_insensitive = FALSE) {
  .pr$Expr$str_replace_many(self, patterns, replace_with, ascii_case_insensitive) |>
    unwrap("in str$replace_many():")
}
