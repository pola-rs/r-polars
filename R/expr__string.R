# this file sources list-expression functions to be bundled in the 'expr$str' sub namespace
# the sub name space is instantiated from Expr_str- function
# bundling these functions into an environment, depends on a macro call in zzz.R
# expr_str_make_sub_ns = macro_new_subnamespace("^ExprStr_", "ExprStrNameSpace")


#' Convert a Utf8 column into a Date/Datetime/Time column.
#'
#' @name ExprStr_strptime
#' @param datatype The data type to convert into. Can be either Date, Datetime,
#' or Time.
#' @param format Format to use for conversion. See `?strptime` for possible
#' values. Example: "%Y-%m-%d %H:%M:%S". If `NULL` (default), the format is
#' inferred from the data. Notice that time zone `%Z` is not supported and will
#' just ignore timezones. Numeric time zones like `%z` or `%:z`  are supported.
#' @param strict If `TRUE` (default), raise an error if a single string cannot
#' be parsed. Otherwise, produce a polars `null`.
#' @param exact If `TRUE` (default), require an exact format match. Otherwise,
#' allow the format to match anywhere in the target string.
#' @param cache Use a cache of unique, converted dates to apply the datetime
#' conversion.
#' @param ambiguous Determine how to deal with ambiguous datetimes:
#' * `"raise"` (default): raise
#' * `"earliest"`: use the earliest datetime
#' * `"latest"`: use the latest datetime
#' @details
#' When parsing a Datetime the column precision will be inferred from the format
#' string, if given, eg: “%F %T%.3f" => Datetime("ms"). If no fractional second
#' component is found then the default is "us" (microsecond).
#' @keywords ExprStr
#' @return Expr of a Date, Datetime or Time Series
#' @examples
#' s = pl$Series(
#'   c(
#'     "2021-04-22",
#'     "2022-01-04 00:00:00",
#'     "01/31/22",
#'     "Sun Jul  8 00:34:60 2001"
#'   ),
#'   "date"
#' )
#' #' #join multiple passes with different format
#' s$to_frame()$with_columns(
#'   pl$col("date")
#'   $str$strptime(pl$Date, "%F", strict = FALSE)
#'   $fill_null(pl$col("date")$str$strptime(pl$Date, "%F %T", strict = FALSE))
#'   $fill_null(pl$col("date")$str$strptime(pl$Date, "%D", strict = FALSE))
#'   $fill_null(pl$col("date")$str$strptime(pl$Date, "%c", strict = FALSE))
#' )
#'
#' txt_datetimes = c(
#'   "2023-01-01 11:22:33 -0100",
#'   "2023-01-01 11:22:33 +0300",
#'   "invalid time"
#' )
#'
#' pl$lit(txt_datetimes)$str$strptime(
#'   pl$Datetime("ns"),
#'   format = "%Y-%m-%d %H:%M:%S %z", strict = FALSE,
#' )$lit_to_s()
ExprStr_strptime = function(
    datatype,
    format,
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
    .pr$Expr$str_to_date(self, format, strict, exact, cache, ambiguous),

    # Time
    datatype == pl$Time,
    .pr$Expr$str_to_time(self, format, strict, exact, cache, ambiguous),

    # Other
    or_else = Err_plain("datatype should be of type {Date, Datetime, Time}")
  ) |>
    unwrap("in str$strptime():")
}


#' Get the number of bytes in strings
#' @description
#' Get length of the strings as UInt32 (as number of bytes). Use `$str$len_chars()`
#' to get the number of characters.
#' @name ExprStr_len_bytes
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
#' @name ExprStr_len_chars
#' @keywords ExprStr
#' @inherit ExprStr_len_bytes examples details return
ExprStr_len_chars = function() {
  .pr$Expr$str_len_chars(self)
}

#' Vertically concatenate values of a Series
#' @name ExprStr_concat
#' @description Vertically concatenate the values in the Series to a single
#' string value.
#' @param delimiter The delimiter to insert between consecutive string values.
#' @keywords ExprStr
#' @return Expr of Utf8 concatenated
#' @examples
#' # concatenate a Series of strings to a single string
#' df = pl$DataFrame(foo = c("1", NA, 2))
#' df$select(pl$col("foo")$str$concat("-"))
#'
#' # Series list of strings to Series of concatenated strings
#' df = pl$DataFrame(list(bar = list(c("a", "b", "c"), c("1", "2", NA))))
#' df$select(pl$col("bar")$list$eval(pl$col()$str$concat())$list$first())
ExprStr_concat = function(delimiter = "-") {
  .pr$Expr$str_concat(self, delimiter)
}

#' Convert a string to uppercase
#' @name ExprStr_to_uppercase
#' @description Transform to uppercase variant.
#' @keywords ExprStr
#' @return Expr of Utf8 uppercase chars
#' @examples
#' pl$lit(c("A", "b", "c", "1", NA))$str$to_uppercase()$lit_to_s()
ExprStr_to_uppercase = function() {
  .pr$Expr$str_to_uppercase(self)
}

#' Convert a string to lowercase
#' @name ExprStr_to_lowercase
#' @description Transform to lowercase variant.
#' @keywords ExprStr
#' @return Expr of Utf8 lowercase chars
#' @examples
#' pl$lit(c("A", "b", "c", "1", NA))$str$to_lowercase()$lit_to_s()
ExprStr_to_lowercase = function() {
  .pr$Expr$str_to_lowercase(self)
}

#' Convert a string to titlecase
#' @name ExprStr_to_titlecase
#' @description Transform to titlecase variant.
#' @keywords ExprStr
#' @return Expr of Utf8 titlecase chars
#' @details
#' This method is only available with rust compiler flag "full_features" which can
#' be set via envvar "RPOLARS_FULL_FEATURES" and it requires rust nightly to compile.
#' Polars GitHub binary releases are compiled with "full_features".
#' @examples
#' f = \() pl$lit(c("hello there", "HI, THERE", NA))$str$to_titlecase()$lit_to_s()
#' if (pl$polars_info()$features$full_features) {
#'   f()
#' } else {
#'   tryCatch(f(), error = as.character)
#' }
ExprStr_to_titlecase = function() {
  .pr$Expr$str_to_titlecase(self) |>
    unwrap("in $to_titlecase():")
}


#' Strip leading and trailing characters
#'
#' @name ExprStr_strip_chars
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
#' @return Expr of Utf8 lowercase chars
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
#' @name ExprStr_strip_chars_start
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
#' @return Expr of Utf8 lowercase chars
#' @examples
#' df = pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip_chars_start(" hel rld"))
ExprStr_strip_chars_start = function(matches = NULL) {
  .pr$Expr$str_strip_chars_start(self, matches) |>
    unwrap("in $str$strip_chars_start():")
}

#' Strip trailing characters
#'
#' @name ExprStr_strip_chars_end
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
#' @return Expr of Utf8 lowercase chars
#' @examples
#' df = pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip_chars_end(" hel\trld"))
#' df$select(pl$col("foo")$str$strip_chars_end("rldhel\t "))
ExprStr_strip_chars_end = function(matches = NULL) {
  .pr$Expr$str_strip_chars_end(self, matches) |>
    unwrap("in $str$strip_chars_end():")
}


#' Fills the string with zeroes.
#' @name ExprStr_zfill
#' @aliases expr_str_zfill
#' @description Add zeroes to a string until it reaches `n` characters. If the
#' number of characters is already greater than `n`, the string is not modified.
#' @keywords ExprStr
#' @param alignment Fill the value up to this length.
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
#' # cast to Utf8 and ljust alignment = 5, and view as R char vector
#' some_floats_expr$cast(pl$Utf8)$str$zfill(5)$to_r()
#'
#' # cast to int and the to utf8 and then ljust alignment = 5, and view as R
#' # char vector
#' some_floats_expr$cast(pl$Int64)$cast(pl$Utf8)$str$zfill(5)$to_r()
ExprStr_zfill = function(alignment) {
  .pr$Expr$str_zfill(self, alignment) |>
    unwrap("in str$zfill():")
}


#' Left justify strings
#' @name ExprStr_pad_end
#' @description Return the string left justified in a string of length `width`.
#' @keywords ExprStr
#' @param width Justify left to this length.
#' @param fillchar Fill with this ASCII character.
#' @details Padding is done using the specified `fillchar`. The original string
#' is returned if `width` is less than or equal to `len(s)`.
#' @return Expr of Utf8
#' @examples
#' df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
#' df$select(pl$col("a")$str$pad_end(8, "*"))
ExprStr_pad_end = function(width, fillchar = " ") {
  .pr$Expr$str_pad_end(self, width, fillchar) |>
    unwrap("in str$ljust(): ")
}


#' Right justify strings
#' @name ExprStr_pad_start
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
    unwrap("in str$rjust(): ")
}


#' Check if string contains a regex
#' @name ExprStr_contains
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
#' @name ExprStr_ends_with
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
#' @name ExprStr_starts_with
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
#' @name ExprStr_json_extract
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
#' df$select(pl$col("json_val")$str$json_extract(dtype))
ExprStr_json_extract = function(dtype, infer_schema_length = 100) {
  .pr$Expr$str_json_extract(self, dtype, infer_schema_length) |>
    unwrap("in str$json_extract():")
}

#' Extract the first match of JSON string with the provided JSONPath expression
#' @name ExprStr_json_path_match
#' @keywords ExprStr
#' @param json_path A valid JSON path query string.
#' @details
#' Throw errors if encounter invalid JSON strings. All return value will be
#' cast to Utf8 regardless of the original value.
#'
#' Documentation on JSONPath standard can be found here: <https://goessner.net/articles/JsonPath/>.
#' @return Utf8 array. Contain null if original value is null or the json_path
#' return nothing.
#' @examples
#' df = pl$DataFrame(
#'   json_val = c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
#' )
#' df$select(pl$col("json_val")$str$json_path_match("$.a"))
ExprStr_json_path_match = function(pat) {
  .pr$Expr$str_json_path_match(self, pat) |>
    unwrap("in str$json_path_match(): ")
}


#' Decode a value using the provided encoding
#' @name ExprStr_decode
#' @keywords ExprStr
#' @param encoding Either 'hex' or 'base64'.
#' @param ... Not used currently.
#' @param strict If `TRUE` (default), raise an error if the underlying value
#' cannot be decoded. Otherwise, replace it with a null value.
#'
#' @return Utf8 array with values decoded using provided encoding
#'
#' @examples
#' df = pl$DataFrame(strings = c("foo", "bar", NA))
#' df$select(pl$col("strings")$str$encode("hex"))
#' df$with_columns(
#'   pl$col("strings")$str$encode("base64")$alias("base64"), # notice DataType is not encoded
#'   pl$col("strings")$str$encode("hex")$alias("hex") # ... and must restored with cast
#' )$with_columns(
#'   pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$Utf8),
#'   pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$Utf8)
#' )
ExprStr_decode = function(encoding, ..., strict = TRUE) {
  pcase(
    !is_string(encoding), stop("encoding must be a string, it was: %s", str_string(encoding)),
    encoding == "hex", .pr$Expr$str_hex_decode(self, strict),
    encoding == "base64", .pr$Expr$str_base64_decode(self, strict),
    or_else = stop("encoding must be one of 'hex' or 'base64', got %s", encoding)
  )
}

#' Encode a value using the provided encoding
#' @name ExprStr_encode
#' @keywords ExprStr
#' @param encoding Either 'hex' or 'base64'.
#' @return Utf8 array with values encoded using provided encoding
#'
#' @examples
#' df = pl$DataFrame(strings = c("foo", "bar", NA))
#' df$select(pl$col("strings")$str$encode("hex"))
#' df$with_columns(
#'   pl$col("strings")$str$encode("base64")$alias("base64"), # notice DataType is not encoded
#'   pl$col("strings")$str$encode("hex")$alias("hex") # ... and must restored with cast
#' )$with_columns(
#'   pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$Utf8),
#'   pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$Utf8)
#' )
ExprStr_encode = function(encoding) {
  pcase(
    !is_string(encoding), stop("encoding must be a string, it was: %s", str_string(encoding)),
    encoding == "hex", .pr$Expr$str_hex_encode(self),
    encoding == "base64", .pr$Expr$str_base64_encode(self),
    or_else = stop("encoding must be one of 'hex' or 'base64', got %s", encoding)
  )
}


#' Extract the target capture group from provided patterns
#' @name ExprStr_extract
#' @keywords ExprStr
#' @param pattern A valid regex pattern
#' @param group_index Index of the targeted capture group. Group 0 means the whole
#' pattern, first group begin at index 1 (default).
#'
#' @return
#' Utf8 array. Contains null if original value is null or regex capture nothing.
#'
#' @examples
#' df = pl$DataFrame(
#'   a = c(
#'     "http://vote.com/ballon_dor?candidate=messi&ref=polars",
#'     "http://vote.com/ballon_dor?candidat=jorginho&ref=polars",
#'     "http://vote.com/ballon_dor?candidate=ronaldo&ref=polars"
#'   )
#' )
#' df$select(
#'   pl$col("a")$str$extract(r"(candidate=(\w+))", 1)
#' )
ExprStr_extract = function(pattern, group_index) {
  .pr$Expr$str_extract(self, pattern, group_index) |>
    unwrap("in str$extract(): ")
}


#' Extract all matches for the given regex pattern
#' @name ExprStr_extract_all
#' @description Extracts all matches for the given regex pattern. Extracts each
#' successive non-overlapping regex match in an individual string as an array.
#' @keywords ExprStr
#' @param pattern A valid regex pattern
#'
#' @return
#' `List[Utf8]` array. Contain null if original value is null or regex capture
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
#' @name ExprStr_count_matches
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
#' @name ExprStr_split
#' @keywords ExprStr
#' @param by String or Expr of a string, a valid regex pattern that will be
#' used to split the string.
#' @param inclusive If `TRUE`, include the split character/string in the results.
#'
#' @return
#' List of Utf8 type
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

# TODO write 2nd example after expr_struct has been implemented
#' Split the string by a substring using `n` splits
#' @name ExprStr_split_exact
#' @description This results in a struct of `n+1` fields. If it cannot make `n`
#' splits, the remaining field elements will be null.
#' @keywords ExprStr
#' @param by Substring to split by.
#' @param n Number of splits to make.
#' @param inclusive If `TRUE`, include the split character/string in the results.
#'
#' @return Struct where each of n+1 fields is of Utf8 type
#'
#' @examples
#' df = pl$DataFrame(s = c("a_1", NA, "c", "d_4"))
#' df$select(pl$col("s")$str$split_exact(by = "_", 1))
ExprStr_split_exact = function(by, n, inclusive = FALSE) {
  unwrap(
    .pr$Expr$str_split_exact(self, by, result(n), result(inclusive)),
    context = "in str$split_exact():"
  )
}


#' Split the string by a substring, restricted to returning at most `n` items
#' @name ExprStr_splitn
#' @description
#' If the number of possible splits is less than `n-1`, the remaining field
#' elements will be null. If the number of possible splits is `n-1` or greater,
#' the last (nth) substring will contain the remainder of the string.
#' @keywords ExprStr
#' @param by Substring to split by.
#' @param n Number of splits to make.
#'
#' @return
#' Struct where each of `n` fields is of Utf8 type
#'
#' @examples
#' df = pl$DataFrame(s = c("a_1", NA, "c", "d_4"))
#' df$select(pl$col("s")$str$splitn(by = "_", 0))
#' df$select(pl$col("s")$str$splitn(by = "_", 1))
#' df$select(pl$col("s")$str$splitn(by = "_", 2))
ExprStr_splitn = function(by, n) {
  .pr$Expr$str_splitn(self, result(by), result(n)) |> unwrap("in str$splitn():")
}


#' Replace first matching regex/literal substring with a new string value
#' @name ExprStr_replace
#' @keywords ExprStr
#' @param pattern Regex pattern, can be an Expr.
#' @param value Replacement, can be an Expr.
#' @param literal Treat pattern as a literal string.
#'
#' @return Expr of Utf8 Series
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
#' @name ExprStr_replace_all
#' @keywords ExprStr
#' @param pattern Regex pattern, can be an Expr.
#' @param value Replacement, can be an Expr.
#' @param literal Treat pattern as a literal string.
#'
#' @return Expr of Utf8 Series
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


#' Create subslices of the string values of a Utf8 Series
#' @name ExprStr_slice
#' @keywords ExprStr
#' @param offset Start index. Negative indexing is supported.
#' @param length Length of the slice. If `NULL` (default), the slice is taken to
#' the end of the string.
#'
#' @return Expr: Series of dtype Utf8.
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
#' @name ExprStr_explode
#' @keywords ExprStr
#' @return Expr: Series of dtype Utf8.
#' @examples
#' df = pl$DataFrame(a = c("foo", "bar"))
#' df$select(pl$col("a")$str$explode())
ExprStr_explode = function() {
  .pr$Expr$str_explode(self) |>
    unwrap("in str$explode():")
}

#' Parse integers with base radix from strings
#' @name ExprStr_parse_int
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
