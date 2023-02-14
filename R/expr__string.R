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
#' @description  Return the string left justified in a string of length ``width``.
#' @keywords ExprStr
#' @param width Justify left to this length.
#' @param fillchar  Fill with this ASCII character.
#' @details  Padding is done using the specified ``fillchar``.
#' The original string is returned if ``width`` is less than or equal to
#' ``len(s)``.
#'
#' A leading sign prefix ('+'/'-') is handled by inserting the padding after the
#' sign character rather than before. The original string is returned if width is
#' less than or equal to ``len(s)``.
#' @return Expr of Utf8
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




#' #' ljust
#' #' @name ExprStr_ljust
#' #' @aliases expr_str_ljust
#' #' @description  Fills the string with zeroes.
#' #' @keywords ExprStr
#' #' @param alignment  Fill the value up to this length
#' #' @details  Return a copy of the string left filled with ASCII '0' digits to make a string
#' #' of length width.
#' #'
#' #' A leading sign prefix ('+'/'-') is handled by inserting the padding after the
#' #' sign character rather than before. The original string is returned if width is
#' #' less than or equal to ``len(s)``.
#' #' @return Expr of Utf8
#' #' @examples
#' #' some_floats_expr = pl$lit(c(0,10,-5,5))
#' #'
#' #' #cast to Utf8 and ljust alignment = 5, and view as R char vector
#' #' some_floats_expr$cast(pl$Utf8)$str$ljust(5)$to_r()
#' #'
#' #' #cast to int and the to utf8 and then ljust alignment = 5, and view as R char vector
#' #' some_floats_expr$cast(pl$Int64)$cast(pl$Utf8)$str$ljust(5)$to_r()
#' ExprStr_ljust = function(alignment) {
#'   unwrap(.pr$Expr$str_ljust(self,alignment))
#' }


