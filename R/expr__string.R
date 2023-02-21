# this file sources list-expression functions to be bundled in the 'expr$str' sub namespace
# the sub name space is instantiated from Expr_str- function
# bundling these functions into an environment, depends on a macro call in zzz.R
# expr_str_make_sub_ns = macro_new_subnamespace("^ExprStr_", "ExprStrNameSpace")


#' strptime
#' @description  Parse a Series of dtype Utf8 to a Date/Datetime Series.
#' @name ExprStr_strptime
#' @param datatype a temporal data type either pl$Date, pl$Time or pl$Datetime
#' @param fmt fmt string for parsenig see
#' see details here https://docs.rs/chrono/latest/chrono/format/strftime/index.html#fn6
#' Notice time_zone %Z is not supported and will just ignore timezones. Numeric tz  like
#' %z, %:z  .... are supported.
#' @param strict bool, if true raise error if a single string cannot be parsed, else produce a
#' polars `null`.
#' @param exact bool , If True, require an exact format match. If False, allow the format to match
#' anywhere in the target string.
#' @param cache Use a cache of unique, converted dates to apply the datetime conversion.
#' @param tz_aware bool, Parse timezone aware datetimes. This may be automatically toggled by the
#' ‘fmt’ given.
#' @param utc bool Parse timezone aware datetimes as UTC. This may be useful if you have data with
#' mixed offsets.
#' @details Notes When parsing a Datetime the column precision will be inferred from the format
#' string, if given, eg: “%F %T%.3f” => Datetime(“ms”). If no fractional second component is found
#' then the default is “us”.
#' @keywords ExprStr
#' @return Expr of a Data, Datetime or Time Series
#' @examples
#' s = pl$Series(c(
#'         "2021-04-22",
#'         "2022-01-04 00:00:00",
#'         "01/31/22",
#'         "Sun Jul  8 00:34:60 2001"
#'   ),
#'   "date"
#' )
#' #' #join multiple passes with different fmt
#' s$to_frame()$with_columns(
#'     pl$col("date")
#'     $str$strptime(pl$Date, "%F", strict=FALSE)
#'     $fill_null(pl$col("date")$str$strptime(pl$Date, "%F %T", strict=FALSE))
#'     $fill_null(pl$col("date")$str$strptime(pl$Date, "%D", strict=FALSE))
#'     $fill_null(pl$col("date")$str$strptime(pl$Date, "%c", strict=FALSE))
#' )
#'
#' txt_datetimes = c(
#'   "2023-01-01 11:22:33 -0100",
#'   "2023-01-01 11:22:33 +0300",
#'   "invalid time"
#' )
#'
#' pl$lit(txt_datetimes)$str$strptime(
#'   pl$Datetime("ns"),fmt = "%Y-%m-%d %H:%M:%S %z", strict = FALSE,
#'   tz_aware = TRUE, utc =TRUE
#' )$lit_to_s()
ExprStr_strptime = function(
  datatype,#: PolarsTemporalType,
  fmt,#: str | None = None,
  strict = TRUE,#: bool = True,
  exact = TRUE,#: bool = True,
  cache = TRUE,#: bool = True,
  tz_aware = FALSE,#: bool = False,
  utc = FALSE
) { #-> Expr:

  #match on datatype, return Result<Expr, String>
  expr_result = pcase(

    !is_polars_dtype(datatype), Err("arg datatype is not an RPolarsDataType"),

    #Datetime
    pl$same_outer_dt(datatype,pl$Datetime()), {
      tu = .pr$DataType$get_insides(datatype)$tu

      .pr$Expr$str_parse_datetime(
        self, fmt, strict, exact, cache, tz_aware, utc, tu
      ) |> and_then(
        \(expr) .pr$Expr$dt_cast_time_unit(expr, tu) #cast if not an err
      )
    },

    #Date
    datatype == pl$Date, Ok(.pr$Expr$str_parse_date(self, fmt, strict, exact, cache)),

    #Time
    datatype == pl$Time, Ok(.pr$Expr$str_parse_time(self, fmt, strict, exact, cache)),

    #Other
    or_else = Err("datatype should be of type {Date, Datetime, Time}")

  ) |> map_err(
    \(err) paste("in str$strptime:", err)
  )

  #raise any error or return unwrapped ok value
  unwrap(expr_result)
}


#' lengths
#' @description  Get length of the strings as UInt32 (as number of bytes).
#' @name ExprStr_lengths
#' @aliases expr_str_lengths
#' @format function
#' @keywords ExprStr
#' @details The returned lengths are equal to the number of bytes in the UTF8 string. If you
#' need the length in terms of the number of characters, use ``n_chars`` instead.
#' @return Expr of u32 lengths
#' @examples
#' pl$DataFrame(
#'   s = c("Café", NA, "345", "東京", "æøå")
#' )$select(
#'   pl$col("s"),
#'   pl$col("s")$str$lengths()$alias("lengths"),
#'   pl$col("s")$str$n_chars()$alias("n_chars")
#' )
ExprStr_lengths = function() {
  .pr$Expr$str_lengths(self)
}

#' n_chars
#' @description   Get length of the strings as UInt32 (as number of chars).
#' @name ExprStr_n_chars
#' @aliases expr_str_n_chars
#' @format function
#' @keywords ExprStr
#' @details  If you know that you are working with ASCII text, ``lengths`` will be
#' equivalent, and faster (returns length in terms of the number of bytes).
#' @keywords ExprStr
#' @return Expr of u32 n_chars
#' @examples
#' pl$DataFrame(
#'   s = c("Café", NA, "345", "東京")
#' )$select(
#'   pl$col("s"),
#'   pl$col("s")$str$lengths()$alias("lengths"),
#'   pl$col("s")$str$n_chars()$alias("n_chars")
#' )
ExprStr_n_chars = function() {
  .pr$Expr$str_n_chars(self)
}



#' Concat
#' @name ExprStr_concat
#' @description Vertically concat the values in the Series to a single string value.
#' @param delimiter string The delimiter to insert between consecutive string values.
#' @aliases expr_str_concat
#' @keywords ExprStr
#' @return Expr of Utf8 concatenated
#' @examples
#' #concatenate a Series of strings to a single string
#' df = pl$DataFrame(foo = c("1", NA, 2))
#' df$select(pl$col("foo")$str$concat("-"))
#'
#' #Series list of strings to Series of concatenated strings
#' df = pl$DataFrame(list(bar = list(c("a","b", "c"), c("1","2",NA))))
#' df$select(pl$col("bar")$arr$eval(pl$col()$str$concat())$arr$first())
ExprStr_concat = function(delimiter = "-") {
  .pr$Expr$str_concat(self, delimiter)
}

#' To uppercase
#' @name ExprStr_to_uppercase
#' @description Transform to uppercase variant.
#' @aliases expr_str_to_uppercase
#' @keywords ExprStr
#' @return Expr of Utf8 uppercase chars
#' @examples
#' pl$lit(c("A","b", "c", "1", NA))$str$to_uppercase()$lit_to_s()
ExprStr_to_uppercase = function() {
  .pr$Expr$str_to_uppercase(self)
}

#' To lowercase
#' @name ExprStr_to_lowercase
#' @description Transform to lowercase variant.
#' @aliases expr_str_to_lowercase
#' @keywords ExprStr
#' @return Expr of Utf8 lowercase chars
#' @examples
#' pl$lit(c("A","b", "c", "1", NA))$str$to_lowercase()$lit_to_s()
ExprStr_to_lowercase = function() {
  .pr$Expr$str_to_lowercase(self)
}


#' Strip
#' @name ExprStr_strip
#' @aliases expr_str_strip
#' @description  Remove leading and trailing characters.
#' @keywords ExprStr
#' @param matches The set of characters to be removed. All combinations of this set of
#' characters will be stripped. If set to NULL (default), all whitespace is removed instead.
#' @details will not strip anyt chars beyond the first char not matched. `strip()` starts from
#' both left and right. Whereas `lstrip()`and `rstrip()` starts from left and right respectively.
#' @return Expr of Utf8 lowercase chars
#' @examples
#' df = pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip())
#' df$select(pl$col("foo")$str$strip(" hel rld"))
#' df$select(pl$col("foo")$str$lstrip(" hel rld"))
#' df$select(pl$col("foo")$str$rstrip(" hel\trld"))
#' df$select(pl$col("foo")$str$rstrip("rldhel\t "))
ExprStr_strip = function(matches = NULL) {
  .pr$Expr$str_strip(self, matches)
}

#' lstrip
#' @name ExprStr_lstrip
#' @aliases expr_str_lstrip
#' @description  Remove leading characters.
#' @keywords ExprStr
#' @param matches The set of characters to be removed. All combinations of this set of
#' characters will be stripped. If set to NULL (default), all whitespace is removed instead.
#' @details will not strip anyt chars beyond the first char not matched. `strip()` starts from
#' both left and right. Whereas `lstrip()`and `rstrip()` starts from left and right respectively.
#' @return Expr of Utf8 lowercase chars
#' @examples
#' df = pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip())
#' df$select(pl$col("foo")$str$strip(" hel rld"))
#' df$select(pl$col("foo")$str$lstrip(" hel rld"))
#' df$select(pl$col("foo")$str$rstrip(" hel\trld"))
#' df$select(pl$col("foo")$str$rstrip("rldhel\t "))
ExprStr_lstrip = function(matches = NULL) {
  .pr$Expr$str_lstrip(self, matches)
}

#' rstrip
#' @name ExprStr_rstrip
#' @aliases expr_str_rstrip
#' @description  Remove leading characters.
#' @keywords ExprStr
#' @param matches The set of characters to be removed. All combinations of this set of
#' characters will be stripped. If set to NULL (default), all whitespace is removed instead.
#' @details will not strip anyt chars beyond the first char not matched. `strip()` starts from
#' both left and right. Whereas `rstrip()`and `rstrip()` starts from left and right respectively.
#' @return Expr of Utf8 lowercase chars
#' @examples
#' df = pl$DataFrame(foo = c(" hello", "\tworld"))
#' df$select(pl$col("foo")$str$strip())
#' df$select(pl$col("foo")$str$strip(" hel rld"))
#' df$select(pl$col("foo")$str$lstrip(" hel rld"))
#' df$select(pl$col("foo")$str$rstrip(" hel\trld"))
#' df$select(pl$col("foo")$str$rstrip("rldhel\t "))
ExprStr_rstrip = function(matches = NULL) {
  .pr$Expr$str_rstrip(self, matches)
}


#' zfill
#' @name ExprStr_zfill
#' @aliases expr_str_zfill
#' @description   Fills the string with zeroes.
#' @keywords ExprStr
#' @param alignment Fill the value up to this length
#' @details
#' Return a copy of the string left filled with ASCII '0' digits to make a string
#' of length width.
#'
#' A leading sign prefix ('+'/'-') is handled by inserting the padding after the
#' sign character rather than before. The original string is returned if width is
#' less than or equal to ``len(s)``.
#'
#' @return Expr
#' @examples
#' some_floats_expr = pl$lit(c(0,10,-5,5))
#'
#' #cast to Utf8 and ljust alignment = 5, and view as R char vector
#' some_floats_expr$cast(pl$Utf8)$str$zfill(5)$to_r()
#'
#' #cast to int and the to utf8 and then ljust alignment = 5, and view as R char vector
#' some_floats_expr$cast(pl$Int64)$cast(pl$Utf8)$str$zfill(5)$to_r()
ExprStr_zfill = function(alignment) {
  unwrap(.pr$Expr$str_zfill(self,alignment))
}


#' ljust
#' @name ExprStr_ljust
#' @aliases expr_str_ljust
#' @description Return the string left justified in a string of length ``width``.
#' @keywords ExprStr
#' @param width Justify left to this length.
#' @param fillchar Fill with this ASCII character.
#' @details Padding is done using the specified ``fillchar``. The original string is returned if
#' ``width`` is less than or equal to ``len(s)``.
#' @return Expr of Utf8
#' @examples
#' df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
#' df$select(pl$col("a")$str$ljust(8, "*"))
ExprStr_ljust = function(width, fillchar = " ") {
  unwrap(.pr$Expr$str_ljust(self, width, fillchar))
}


#' rjust
#' @name ExprStr_rjust
#' @aliases expr_str_rjust
#' @description Return the string left justified in a string of length ``width``.
#' @keywords ExprStr
#' @param width Justify left to this length.
#' @param fillchar Fill with this ASCII character.
#' @details Padding is done using the specified ``fillchar``. The original string is returned if
#' ``width`` is less than or equal to ``len(s)``.
#' @return Expr of Utf8
#' @examples
#' df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
#' df$select(pl$col("a")$str$rjust(8, "*"))
ExprStr_rjust = function(width, fillchar = " ") {
  unwrap(.pr$Expr$str_rjust(self, width, fillchar))
}


#' contains
#' @name ExprStr_contains
#' @aliases expr_str_contains
#' @description R Check if string contains a substring that matches a regex.
#' @keywords ExprStr
#' @param pattern String or Expr of a string, a valid regex pattern.
#' @param literal bool, treat pattern as a literal string. NULL is aliased with FALSE.
#' @param strict bool, raise an error if the underlying pattern is not a valid
#' regex expression, otherwise mask out with a null value.
#' @details
#'   starts_with : Check if string values start with a substring.
#'   ends_with : Check if string values end with a substring.
#' @return Expr returning a Boolean
#' @examples
#' df = pl$DataFrame(a = c("Crab", "cat and dog", "rab$bit", NA))
#' df$select(
#'   pl$col("a"),
#'   pl$col("a")$str$contains("cat|bit")$alias("regex"),
#'   pl$col("a")$str$contains("rab$", literal=TRUE)$alias("literal")
#' )
ExprStr_contains = function(pattern, literal = FALSE, strict = TRUE) {
  .pr$Expr$str_contains(self, wrap_e(pattern, str_to_lit = TRUE), literal, strict)
}

#' ends_with
#' @name ExprStr_ends_with
#' @aliases expr_str_ends_with
#' @description   Check if string values end with a substring.
#' @keywords ExprStr
#' @param sub Suffix substring or Expr.
#' @details
#'    contains : Check if string contains a substring that matches a regex.
#'    starts_with : Check if string values start with a substring.
#' @return Expr returning a Boolean
#' @examples
#' df = pl$DataFrame(fruits = c("apple", "mango", NA))
#' df$select(
#'   pl$col("fruits"),
#'   pl$col("fruits")$str$ends_with("go")$alias("has_suffix")
#' )
ExprStr_ends_with = function(sub) {
  .pr$Expr$str_ends_with(self, wrap_e(sub, str_to_lit = TRUE))
}


#' starts_with
#' @name ExprStr_starts_with
#' @aliases expr_str_starts_with
#' @description   Check if string values starts with a substring.
#' @keywords ExprStr
#' @param sub Prefix substring or Expr.
#' @details
#' contains : Check if string contains a substring that matches a regex.
#' ends_with : Check if string values end with a substring.
#' @return Expr returning a Boolean
#' @examples
#' df = pl$DataFrame(fruits = c("apple", "mango", NA))
#' df$select(
#'   pl$col("fruits"),
#'   pl$col("fruits")$str$starts_with("app")$alias("has_suffix")
#' )
ExprStr_starts_with = function(sub) {
  .pr$Expr$str_starts_with(self, wrap_e(sub, str_to_lit = TRUE))
}

#' json_extract
#' @name ExprStr_json_extract
#' @aliases expr_str_json_extract
#' @description Parse string values as JSON.
#' @keywords ExprStr
#' @param dtype The dtype to cast the extracted value to. If None, the dtype will be
#' inferred from the JSON value.
#' @details
#' Throw errors if encounter invalid json strings.
#'
#' @return Expr returning a boolean
#' @examples
#' df = pl$DataFrame(
#'   json_val =  c('{"a":1, "b": true}', NA, '{"a":2, "b": false}')
#' )
#' dtype = pl$Struct(pl$Field("a", pl$Int64), pl$Field("b", pl$Boolean))
#' df$select(pl$col("json_val")$str$json_extract(dtype))
ExprStr_json_extract = function(pat) {
  .pr$Expr$str_json_extract(self, pat)
}

#' json_path_match
#' @name ExprStr_json_path_match
#' @aliases expr_json_path_match
#' @description Extract the first match of json string with provided JSONPath expression.
#' @keywords ExprStr
#' @param  json_path A valid JSON path query string.
#' @details
#' Throw errors if encounter invalid json strings.
#' All return value will be casted to Utf8 regardless of the original value.
#' Documentation on JSONPath standard can be found
#' `here <https://goessner.net/articles/JsonPath/>`_.
#' @return Utf8 array. Contain null if original value is null or the json_path return nothing.
#' @examples
#' df = pl$DataFrame(
#'   json_val =  c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
#' )
#' df$select(pl$col("json_val")$str$json_path_match("$.a"))
ExprStr_json_path_match = function(pat) {
  unwrap(.pr$Expr$str_json_path_match(self, pat))
}


#' decode
#' @name ExprStr_decode
#' @aliases expr_str_decode
#' @description Decode a value using the provided encoding.
#' @keywords ExprStr
#' @param encoding string choice either 'hex' or 'base64'
#' @param ... not used currently
#' @param strict  Raise an error if the underlying value cannot be decoded,
#'  otherwise mask out with a null value.
#'
#' @return Utf8 array with values decoded using provided encoding
#'
#' @examples
#' df = pl$DataFrame( strings = c("foo", "bar", NA))
#' df$select(pl$col("strings")$str$encode("hex"))
#' df$with_columns(
#'   pl$col("strings")$str$encode("base64")$alias("base64"), #notice DataType is not encoded
#'   pl$col("strings")$str$encode("hex")$alias("hex")       #... and must restored with cast
#' )$with_columns(
#'   pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$Utf8),
#'   pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$Utf8)
#' )
ExprStr_decode = function(
    encoding,#: TransferEncoding,
    ...,
    strict = TRUE
){
  pcase(
    !is_string(encoding) ,stopf("encoding must be a string, it was: %s", str_string(encoding)),
    encoding == "hex", .pr$Expr$str_hex_decode(self, strict),
    encoding == "base64", .pr$Expr$str_base64_decode(self, strict),
    or_else = stopf("encoding must be one of 'hex' or 'base64', got %s", encoding)
  )
}

#' encode
#' @name ExprStr_encode
#' @aliases expr_str_encode
#' @description  Encode a value using the provided encoding.
#' @keywords ExprStr
#' @param encoding string choice either 'hex' or 'base64'
#'
#' @return Utf8 array with values encoded using provided encoding
#'
#' @examples
#' df = pl$DataFrame( strings = c("foo", "bar", NA))
#' df$select(pl$col("strings")$str$encode("hex"))
#' df$with_columns(
#'   pl$col("strings")$str$encode("base64")$alias("base64"), #notice DataType is not encoded
#'   pl$col("strings")$str$encode("hex")$alias("hex")       #... and must restored with cast
#' )$with_columns(
#'   pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$Utf8),
#'   pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$Utf8)
#' )
ExprStr_encode = function(encoding){
  pcase(
    !is_string(encoding), stopf("encoding must be a string, it was: %s", str_string(encoding)),
    encoding == "hex", .pr$Expr$str_hex_encode(self),
    encoding == "base64", .pr$Expr$str_base64_encode(self),
    or_else = stopf("encoding must be one of 'hex' or 'base64', got %s", encoding)
  )
}


#' extract
#' @name ExprStr_extract
#' @aliases expr_str_extract
#' @description Extract the target capture group from provided patterns.
#' @keywords ExprStr
#' @param pattern A valid regex pattern
#' @param group_index
#' Index of the targeted capture group.
#' Group 0 mean the whole pattern, first group begin at index 1.
#' Default to the first capture group.
#'
#' @return
#' Utf8 array. Contain null if original value is null or regex capture nothing.
#'
#' @examples
#' df = pl$DataFrame(
#'   a =  c(
#'     "http://vote.com/ballon_dor?candidate=messi&ref=polars",
#'     "http://vote.com/ballon_dor?candidat=jorginho&ref=polars",
#'     "http://vote.com/ballon_dor?candidate=ronaldo&ref=polars"
#'   )
#' )
#' df$select(
#'   pl$col("a")$str$extract(r"(candidate=(\w+))", 1)
#' )
ExprStr_extract = function(pattern, group_index){
  unwrap(.pr$Expr$str_extract(self, pattern, group_index))
}


#' extract_all
#' @name ExprStr_extract_all
#' @aliases expr_str_extract_all
#' @description Extracts all matches for the given regex pattern. Extracts each successive
#' non-overlapping regex match in an individual string as an array.
#' @keywords ExprStr
#' @param pattern A valid regex pattern
#'
#' @return
#' `List[Utf8]` array. Contain null if original value is null or regex capture nothing.
#'
#' @examples
#' df = pl$DataFrame( foo = c("123 bla 45 asd", "xyz 678 910t"))
#' df$select(
#'   pl$col("foo")$str$extract_all(r"((\d+))")$alias("extracted_nrs")
#' )
ExprStr_extract_all = function(pattern){
  .pr$Expr$str_extract_all(self, wrap_e(pattern))
}

#' count_match
#' @name ExprStr_count_match
#' @aliases expr_str_count_match
#' @description Count all successive non-overlapping regex matches.
#' @keywords ExprStr
#' @param pattern A valid regex pattern
#'
#' @return
#' UInt32 array. Contain null if original value is null or regex capture nothing.
#'
#' @examples
#' df = pl$DataFrame( foo = c("123 bla 45 asd", "xyz 678 910t"))
#' df$select(
#'   pl$col("foo")$str$count_match(r"{(\d)}")$alias("count digits")
#' )
ExprStr_count_match = function(pattern){
  unwrap(.pr$Expr$str_count_match(self, pattern))
}




#' split
#' @name ExprStr_split
#' @aliases expr_str_split
#' @description Split the string by a substring.
#' @keywords ExprStr
#' @param by Substring to split by.
#' @param inclusive If True, include the split character/string in the results.
#'
#' @return
#' List of Utf8 type
#'
#' @examples
#' df = pl$DataFrame(s = c("foo bar", "foo-bar", "foo bar baz"))
#' df$select( pl$col("s")$str$split(by=" "))
ExprStr_split = function(by, inclusive = FALSE){
   unwrap(
    .pr$Expr$str_split(self, result(by), result(inclusive)),
    context = "in str$split:"
  )
}

#TODO write 2nd example after expr_struct has been implemented
#' split_exact
#' @name ExprStr_split_exact
#' @aliases expr_str_split_exact
#' @description Split the string by a substring using ``n`` splits.
#' Results in a struct of ``n+1`` fields.
#' If it cannot make ``n`` splits, the remaining field elements will be null.
#' @keywords ExprStr
#' @param by Substring to split by.
#' @param n Number of splits to make.
#' @param inclusive If True, include the split_exact character/string in the results.
#'
#' @return Struct where each of n+1 fields is of Utf8 type
#'
#' @examples
#' df = pl$DataFrame(s = c("a_1", NA, "c", "d_4"))
#' df$select( pl$col("s")$str$split_exact(by="_",1))
#'
ExprStr_split_exact = function(by, n, inclusive = FALSE){
  unwrap(
    .pr$Expr$str_split_exact(self, result(by), result(n), result(inclusive)),
    context = "in str$split_exact:"
  )
}


#' splitn
#' @name ExprStr_splitn
#' @aliases expr_str_splitn
#' @description Split the string by a substring, restricted to returning at most ``n`` items.
#' If the number of possible splits is less than ``n-1``, the remaining field
#' elements will be null. If the number of possible splits is ``n-1`` or greater,
#' the last (nth) substring will contain the remainder of the string.
#' @keywords ExprStr
#' @param by Substring to split by.
#' @param n Number of splits to make.
#'
#' @return
#' Struct where each of n+1 fields is of Utf8 type
#'
#' @examples
#' df = pl$DataFrame(s = c("a_1", NA, "c", "d_4"))
#' df$select( pl$col("s")$str$splitn(by="_",0))
#' df$select( pl$col("s")$str$splitn(by="_",1))
#' df$select( pl$col("s")$str$splitn(by="_",2))
ExprStr_splitn = function(by, n){
  .pr$Expr$str_splitn(self, result(by), result(n)) |> unwrap("in str$splitn")
}


#' replace
#' @name ExprStr_replace
#' @aliases expr_str_replace
#' @description
#' Replace first matching regex/literal substring with a new string value.
#' @keywords ExprStr
#' @param pattern Into<Expr>, regex pattern
#' @param value Into<Expr> replcacement
#' @param literal bool, Treat pattern as a literal string.
#'
#' @return Expr of Utf8 Series
#'
#' @seealso replace_all : Replace all matching regex/literal substrings.
#'
#' @examples
#' df = pl$DataFrame(id = c(1, 2), text = c("123abc", "abc456"))
#' df$with_columns(
#'    pl$col("text")$str$replace(r"{abc\b}", "ABC")
#' )
ExprStr_replace = function(pattern, value, literal = FALSE){
  .pr$Expr$str_replace(self, wrap_e_result(pattern), wrap_e_result(value), result(literal)) |>
    unwrap("in str$replace:")
}



#' replace_all
#' @name ExprStr_replace_all
#' @aliases expr_str_replace_all
#' @description
#' Replace all matching regex/literal substrings with a new string value.
#' @keywords ExprStr
#' @param pattern Into<Expr>, regex pattern
#' @param value Into<Expr> replcacement
#' @param literal bool, treat pattern as a literal string.
#'
#' @return Expr of Utf8 Series
#'
#' @seealso replace : Replace first matching regex/literal substring.
#'
#' @examples
#' df = pl$DataFrame(id = c(1, 2), text = c("abcabc", "123a123"))
#' df$with_columns(
#'    pl$col("text")$str$replace_all("a", "-")
#' )
ExprStr_replace_all = function(pattern, value, literal = FALSE) {
  .pr$Expr$str_replace_all(self, wrap_e_result(pattern), wrap_e_result(value), result(literal)) |>
    unwrap("in str$replace_all:")
}


#' slice
#' @name ExprStr_slice
#' @aliases expr_str_slice
#' @description
#' Create subslices of the string values of a Utf8 Series.
#' @keywords ExprStr
#' @param pattern Into<Expr>, regex pattern
#' @param value Into<Expr> replcacement
#' @param literal bool, treat pattern as a literal string.
#'
#' @return Expr: Series of dtype Utf8.
#'
#' @examples
#' df = pl$DataFrame(s = c("pear", None, "papaya", "dragonfruit"))
#' df$with_columns(
#'    pl$col("s")$str$slice(-3)$alias("s_sliced")
#' )
ExprStr_slice = function(offset, length = NULL) {
  .pr$Expr$str_slice(self, result(offset), result(length)) |>
    unwrap("in str$slice:")
}

