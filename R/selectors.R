#' Polars column selector function namespace
#'
#' `cs` is an [environment class][environment-class] object that stores all
#' selector functions of the R Polars API which mimics the Python Polars API.
#' It is intended to work the same way in Python as if you had imported
#' Python Polars Selectors with `import polars.selectors as cs`.
#'
#' @section Supported operators:
#' There are 4 supported operators for selectors:
#' * `&` to combine conditions with AND, e.g. select columns that contain
#'   `"oo"` *and* end with `"t"` with `cs$contains("oo") & cs$ends_with("t")`;
#' * `|` to combine conditions with OR, e.g. select columns that contain
#'   `"oo"` *or* end with `"t"` with `cs$contains("oo") | cs$ends_with("t")`;
#' * `-` to substract conditions, e.g. select all columns that have alphanumeric
#'   names except those that contain `"a"` with
#'   `cs$alphanumeric() - cs$contains("a")`;
#' * `!` to invert the selection, e.g. select all columns that *are not* of data
#'   type `String` with `!cs$string()`.
#'
#' Note that Python Polars uses `~` instead of `!` to invert selectors.
#'
#' @examples
#' cs
#'
#' # How many members are in the `cs` environment?
#' length(cs)
#' @export
cs <- new.env(parent = emptyenv())

# The env for storing selector methods
polars_selector__methods <- new.env(parent = emptyenv())

wrap_to_selector <- function(x, name, parameters = NULL) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`
  self$`_attrs` <- list(name = name, parameters = parameters)
  self$`_print_override` <- NULL

  lapply(names(polars_selector__methods), function(name) {
    fn <- polars_selector__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  lapply(setdiff(names(polars_expr__methods), names(self)), function(name) {
    fn <- polars_expr__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  lapply(names(polars_namespaces_expr), function(namespace) {
    makeActiveBinding(namespace, function() polars_namespaces_expr[[namespace]](self), self)
  })

  class(self) <- c("polars_selector", "polars_expr", "polars_object")
  self
}

is_column <- function(obj) {
  is_polars_expr(obj) && obj$meta$is_column()
}

selector__invert <- function() {
  inverted <- cs$all()$sub(self)
  # TODO: we want to print something like `!cs$all()` when call `!cs$all()`
  # inverted$`_print_override` <- deparse1(sys.call(sys.nframe() - 1))

  inverted
}

selector__sub <- function(other) {
  if (is_polars_selector(other)) {
    wrap_to_selector(
      self$meta$`_as_selector`()$meta$`_selector_sub`(other),
      name = "sub",
      parameters = list(
        self = self,
        other = other
      )
    )
  } else {
    self$as_expr()$sub(other)
  }
}

selector__or <- function(other) {
  if (is_column(other)) {
    other <- cs$by_name(other$meta$output_name())
  }
  if (is_polars_selector(other)) {
    wrap_to_selector(
      self$meta$`_as_selector`()$meta$`_selector_add`(other),
      name = "or",
      parameters = list(
        self = self,
        other = other
      )
    )
  } else {
    self$as_expr()$or(other)
  }
}

selector__and <- function(other) {
  if (is_column(other)) {
    colname <- other$meta$output_name()
    other <- cs$by_name(colname)
  }
  if (is_polars_selector(other)) {
    wrap_to_selector(
      self$meta$`_as_selector`()$meta$`_selector_and`(other),
      name = "and",
      parameters = list(
        self = self,
        other = other
      )
    )
  } else {
    self$as_expr()$and(other)
  }
}

selector__as_expr <- function() {
  self$`_rexpr` |>
    wrap()
}

#' Select all columns
#'
#' @return A Polars selector
#' @seealso [cs] for the documentation on operators supported by Polars
#' selectors.
#' @examples
#' df <- pl$DataFrame(dt = as.Date(c("2000-1-1")), value = 10)
#'
#' # Select all columns, casting them to string:
#' df$select(cs$all()$cast(pl$String))
#'
#' # Select all columns except for those matching the given dtypes:
#' df$select(cs$all() - cs$numeric())
cs__all <- function() {
  pl$all() |>
    wrap_to_selector("all")
}

#' Select all columns with alphabetic names (e.g. only letters)
#'
#' @inheritParams rlang::args_dots_empty
#' @param ascii_only Indicate whether to consider only ASCII alphabetic
#' characters, or the full Unicode range of valid letters (accented,
#' idiographic, etc).
#' @param ignore_spaces Indicate whether to ignore the presence of spaces in
#' column names; if so, only the other (non-space) characters are considered.
#'
#' @details
#' Matching column names cannot contain any non-alphabetic characters. Note
#' that the definition of “alphabetic” consists of all valid Unicode alphabetic
#' characters (`p{Alphabetic}`) by default; this can be changed by setting
#' `ascii_only = TRUE`.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   no1 = c(100, 200, 300),
#'   café = c("espresso", "latte", "mocha"),
#'   `t or f` = c(TRUE, FALSE, NA),
#'   hmm = c("aaa", "bbb", "ccc"),
#'   都市 = c("東京", "大阪", "京都")
#' )
#'
#' # Select columns with alphabetic names; note that accented characters and
#' # kanji are recognised as alphabetic here:
#' df$select(cs$alpha())
#'
#' # Constrain the definition of “alphabetic” to ASCII characters only:
#' df$select(cs$alpha(ascii_only = TRUE))
#' df$select(cs$alpha(ascii_only = TRUE, ignore_spaces = TRUE))
#'
#' # Select all columns except for those with alphabetic names:
#' df$select(!cs$alpha())
#' df$select(!cs$alpha(ignore_spaces = TRUE))
cs__alpha <- function(ascii_only = FALSE, ..., ignore_spaces = FALSE) {
  check_dots_empty0(...)
  if (isTRUE(ascii_only)) {
    re_alpha <- r"(a-zA-Z)"
  } else {
    re_alpha <- r"(\p{Alphabetic})"
  }
  if (isTRUE(ignore_spaces)) {
    re_space <- " "
  } else {
    re_space <- ""
  }
  raw_params <- paste0("^[", re_alpha, re_space, "]+$")
  wrap_to_selector(pl$col(!!!raw_params), name = "alpha")
}

#' Select all columns with alphanumeric names (e.g. only letters and the digits 0-9)
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams cs__alpha
#'
#' @details
#' Matching column names cannot contain any non-alphabetic characters. Note
#' that the definition of “alphabetic” consists of all valid Unicode alphabetic
#' characters (`p{Alphabetic}`) and digit characters (`d`) by default; this can
#' be changed by setting `ascii_only = TRUE`.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   `1st_col` = c(100, 200, 300),
#'   flagged = c(TRUE, FALSE, TRUE),
#'   `00prefix` = c("01:aa", "02:bb", "03:cc"),
#'   `last col` = c("x", "y", "z")
#' )
#'
#' # Select columns with alphanumeric names:
#' df$select(cs$alphanumeric())
#' df$select(cs$alphanumeric(ignore_spaces = TRUE))
#'
#' # Select all columns except for those with alphanumeric names:
#' df$select(!cs$alphanumeric())
#' df$select(!cs$alphanumeric(ignore_spaces = TRUE))
cs__alphanumeric <- function(ascii_only = FALSE, ..., ignore_spaces = FALSE) {
  check_dots_empty0(...)
  if (isTRUE(ascii_only)) {
    re_alphanumeric <- r"(a-zA-Z)"
    re_digit <- "0-9"
  } else {
    re_alphanumeric <- r"(\p{Alphabetic})"
    re_digit <- r"(\d)"
  }
  if (isTRUE(ignore_spaces)) {
    re_space <- " "
  } else {
    re_space <- ""
  }
  raw_params <- paste0("^[", re_alphanumeric, re_digit, re_space, "]+$")
  wrap_to_selector(pl$col(!!!raw_params), name = "alphanumeric")
}

#' Select all binary columns
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   a = charToRaw("hello"),
#'   b = "world",
#'   c = charToRaw("!"),
#'   d = ":"
#' )
#'
#' # Select binary columns:
#' df$select(cs$binary())
#'
#' # Select all columns except for those that are binary:
#' df$select(!cs$binary())
cs__binary <- function() {
  wrap_to_selector(pl$col(pl$Binary), name = "binary")
}

#' Select all boolean columns
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   a = 1:4,
#'   b = c(FALSE, TRUE, FALSE, TRUE)
#' )
#'
#' # Select and invert boolean columns:
#' df$with_columns(inverted = cs$boolean()$not())
#'
#' # Select all columns except for those that are boolean:
#' df$select(!cs$boolean())
cs__boolean <- function() {
  wrap_to_selector(pl$col(pl$Boolean), name = "boolean")
}

#' Select all columns matching the given dtypes
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Data types to select.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   dt = as.Date(c("1999-12-31", "2024-1-1", "2010-7-5")),
#'   value = c(1234500, 5000555, -4500000),
#'   other = c("foo", "bar", "foo")
#' )
#'
#' # Select all columns with date or string dtypes:
#' df$select(cs$by_dtype(pl$Date, pl$String))
#'
#' # Select all columns that are not of date or string dtype:
#' df$select(!cs$by_dtype(pl$Date, pl$String))
#'
#' # Group by string columns and sum the numeric columns:
#' df$group_by(cs$string())$agg(cs$numeric()$sum())$sort("other")
cs__by_dtype <- function(...) {
  check_dots_unnamed()
  list_dtypes <- list2(...)
  check_list_of_polars_dtype(list_dtypes, arg = "...")

  wrap_to_selector(
    pl$col(!!!list_dtypes),
    name = "by_dtype",
    parameters = list_dtypes
  )
}

#' Select all columns matching the given indices (or range objects)
#'
#' @param indices One or more column indices (or ranges). Negative indexing is
#' supported.
#'
#' @details
#' Matching columns are returned in the order in which their indexes appear in
#' the selector, not the underlying schema order.
#'
#' @inherit cs__all return seealso
#' @examples
#' vals <- as.list(0.5 * 0:100)
#' names(vals) <- paste0("c", 0:100)
#' df <- pl$DataFrame(!!!vals)
#' df
#'
#' # Select columns by index (the two first/last columns):
#' df$select(cs$by_index(c(0, 1, -2, -1)))
#'
#' # Use seq()
#' df$select(cs$by_index(c(0, seq(1, 101, 20))))
#' df$select(cs$by_index(c(0, seq(101, 0, -25))))
#'
#' # Select only odd-indexed columns:
#' df$select(!cs$by_index(seq(0, 100, 2)))
cs__by_index <- function(indices) {
  wrap_to_selector(pl$nth(indices), name = "by_index")
}

#' Select all columns matching the given names
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Column names to select.
#' @param require_all Whether to match all names (the default) or any of the
#' names.
#'
#' @inherit cs__by_index details
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123, 456),
#'   baz = c(2.0, 5.5),
#'   zap = c(FALSE, TRUE)
#' )
#'
#' # Select columns by name:
#' df$select(cs$by_name("foo", "bar"))
#'
#' # Match any of the given columns by name:
#' df$select(cs$by_name("baz", "moose", "foo", "bear", require_all = FALSE))
#'
#' # Match all columns except for those given:
#' df$select(!cs$by_name("foo", "bar"))
cs__by_name <- function(..., require_all = TRUE) {
  check_dots_unnamed()
  dots <- list2(...)
  check_list_of_string(dots, arg = "...")

  all_names <- as.character(dots)

  selector_params <- list(
    "*names" = all_names
  )

  if (isFALSE(require_all)) {
    match_cols <- paste0(all_names, collapse = "|") |>
      (\(x) (paste0("^(", x, ")$")))()
    selector_params$require_all <- require_all
  } else {
    match_cols <- all_names
  }

  wrap_to_selector(
    pl$col(!!!match_cols),
    name = "by_name",
    parameters = selector_params
  )
}

#' Select all categorical columns
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("xx", "yy"),
#'   bar = c(123, 456),
#'   baz = c(2.0, 5.5),
#'   .schema_overrides = list(foo = pl$Categorical()),
#' )
#'
#' # Select categorical columns:
#' df$select(cs$categorical())
#'
#' # Select all columns except for those that are categorical:
#' df$select(!cs$categorical())
cs__categorical <- function() {
  wrap_to_selector(pl$col(pl$Categorical()), name = "categorical")
}

#' Select columns whose names contain the given literal substring(s)
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Substring(s) that matching
#' column names should contain.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123, 456),
#'   baz = c(2.0, 5.5),
#'   zap = c(FALSE, TRUE)
#' )
#'
#' # Select columns that contain the substring "ba":
#' df$select(cs$contains("ba"))
#'
#' # Select columns that contain the substring "ba" or the letter "z":
#' df$select(cs$contains("ba", "z"))
#'
#' # Select all columns except for those that contain the substring "ba":
#' df$select(!cs$contains("ba"))
cs__contains <- function(...) {
  check_dots_unnamed()
  dots <- list2(...)
  check_list_of_string(dots, arg = "...")

  substrings <- as.character(dots) |>
    paste0(collapse = "|")
  raw_params <- paste0("^.*", substrings, ".*$")
  wrap_to_selector(pl$col(!!!raw_params), name = "contains")
}

#' Select all date columns
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   dtm = as.POSIXct(c("2001-5-7 10:25", "2031-12-31 00:30")),
#'   dt = as.Date(c("1999-12-31", "2024-8-9"))
#' )
#'
#' # Select date columns:
#' df$select(cs$date())
#'
#' # Select all columns except for those that are dates:
#' df$select(!cs$date())
cs__date <- function() {
  wrap_to_selector(pl$col(pl$Date), name = "date")
}

#' Select all datetime columns
#'
#' @param time_unit One (or more) of the allowed time unit precision strings,
#' `"ms"`, `"us"`, and `"ns"`. Default is to select columns with any valid
#' timeunit.
#' @param time_zone One of the followings. The value or each element of the vector
#' will be passed to the `time_zone` argument of the [`pl$Datetime()`][DataType] function:
#' * A character vector of one or more timezone strings, as defined in [OlsonNames()].
#' * `NULL` to select Datetime columns that do not have a timezone.
#' * `"*"` to select Datetime columns that have any timezone.
#' * A list of single timezone strings , `"*"`, and `NULL` to select Datetime columns
#'   that do not have a timezone or have the (specific) timezone.
#'   For example, the default value `list("*", NULL)` selects all Datetime columns.
#'
#' @inherit cs__all return seealso
#' @examples
#' chr_vec <- c("1999-07-21 05:20:16.987654", "2000-05-16 06:21:21.123456")
#' df <- pl$DataFrame(
#'   tstamp_tokyo = as.POSIXlt(chr_vec, tz = "Asia/Tokyo"),
#'   tstamp_utc = as.POSIXct(chr_vec, tz = "UTC"),
#'   tstamp = as.POSIXct(chr_vec),
#'   dt = as.Date(chr_vec),
#' )
#'
#' # Select all datetime columns:
#' df$select(cs$datetime())
#'
#' # Select all datetime columns that have "ms" precision:
#' df$select(cs$datetime("ms"))
#'
#' # Select all datetime columns that have any timezone:
#' df$select(cs$datetime(time_zone = "*"))
#'
#' # Select all datetime columns that have a specific timezone:
#' df$select(cs$datetime(time_zone = "UTC"))
#'
#' # Select all datetime columns that have NO timezone:
#' df$select(cs$datetime(time_zone = NULL))
#'
#' # Select all columns except for datetime columns:
#' df$select(!cs$datetime())
cs__datetime <- function(time_unit = c("ms", "us", "ns"), time_zone = list("*", NULL)) {
  time_unit <- arg_match(time_unit, values = c("ms", "us", "ns"), multiple = TRUE)
  if (!is_character(time_zone) && !is_list(time_zone) && !is.null(time_zone)) {
    abort("`time_zone` must be a character vector, a list, or `NULL`.")
  }
  time_zone <- time_zone %||% list(NULL)

  datetime_dtypes <- time_unit |>
    lapply(\(tu) {
      time_zone |>
        lapply(\(tz) pl$Datetime(tu, tz))
    }) |>
    unlist(recursive = TRUE)

  wrap_to_selector(
    pl$col(!!!datetime_dtypes),
    name = "datetime"
  )
}

#' Select all decimal columns
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123, 456),
#'   baz = c("2.0005", "-50.5555"),
#'   .schema_overrides = list(
#'     bar = pl$Decimal(),
#'     baz = pl$Decimal(scale = 5, precision = 10)
#'   )
#' )
#'
#' # Select decimal columns:
#' df$select(cs$decimal())
#'
#' # Select all columns except for those that are decimal:
#' df$select(!cs$decimal())
cs__decimal <- function() {
  wrap_to_selector(pl$col(pl$Decimal(NULL, NULL)), name = "decimal")
}

#' Select all columns having names consisting only of digits
#'
#' @inheritParams cs__alpha
#'
#' @details
#' Matching column names cannot contain any non-digit characters. Note that the
#' definition of "digit" consists of all valid Unicode digit characters (`d`)
#' by default; this can be changed by setting `ascii_only = TRUE`.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   key = c("aaa", "bbb"),
#'   `2001` = 1:2,
#'   `2025` = 3:4
#' )
#'
#' # Select columns with digit names:
#' df$select(cs$digit())
#'
#' # Select all columns except for those with digit names:
#' df$select(!cs$digit())
#'
#' # Demonstrate use of ascii_only flag (by default all valid unicode digits
#' # are considered, but this can be constrained to ascii 0-9):
#' df <- pl$DataFrame(`१९९९` = 1999, `२०७७` = 2077, `3000` = 3000)
#' df$select(cs$digit())
#' df$select(cs$digit(ascii_only = TRUE))
cs__digit <- function(ascii_only = FALSE) {
  if (isTRUE(ascii_only)) {
    re_digit <- "[0-9]"
  } else {
    re_digit <- r"(\d)"
  }
  wrap_to_selector(pl$col(!!!paste0("^", re_digit, "+$")), name = "digit")
}

#' Select all duration columns, optionally filtering by time unit
#'
#' @inheritParams cs__datetime
#'
#' @inherit cs__all return seealso
#' @examplesIf requireNamespace("clock", quietly = TRUE)
#' df <- pl$DataFrame(
#'   dtm = as.POSIXct(c("2001-5-7 10:25", "2031-12-31 00:30")),
#'   dur_ms = clock::duration_milliseconds(1:2),
#'   dur_us = clock::duration_microseconds(1:2),
#'   dur_ns = clock::duration_nanoseconds(1:2),
#' )
#'
#' # Select duration columns:
#' df$select(cs$duration())
#'
#' # Select all duration columns that have "ms" precision:
#' df$select(cs$duration("ms"))
#'
#' # Select all duration columns that have "ms" OR "ns" precision:
#' df$select(cs$duration(c("ms", "ns")))
#'
#' # Select all columns except for those that are duration:
#' df$select(!cs$duration())
cs__duration <- function(time_unit = c("ms", "us", "ns")) {
  time_unit <- arg_match(time_unit, values = c("ms", "us", "ns"), multiple = TRUE)

  duration_dtypes <- time_unit |>
    lapply(pl$Duration)

  wrap_to_selector(
    pl$col(!!!duration_dtypes),
    name = "duration"
  )
}

#' Select columns that end with the given substring(s)
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Substring(s) that matching
#' column names should end with.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123, 456),
#'   baz = c(2.0, 5.5),
#'   zap = c(FALSE, TRUE)
#' )
#'
#' # Select columns that end with the substring "z":
#' df$select(cs$ends_with("z"))
#'
#' # Select columns that end with either the letter "z" or "r":
#' df$select(cs$ends_with("z", "r"))
#'
#' # Select all columns except for those that end with the substring "z":
#' df$select(!cs$ends_with("z"))
cs__ends_with <- function(...) {
  check_dots_unnamed()
  dots <- list2(...)
  check_list_of_string(dots, arg = "...")

  substrings <- as.character(dots) |>
    paste0(collapse = "|")
  raw_params <- paste0("^.*(", substrings, ")$")
  wrap_to_selector(pl$col(!!!raw_params), name = "ends_with")
}

#' Select all columns except those matching the given columns, datatypes, or
#' selectors
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Column names to exclude.
#'
#' @details
#' If excluding a single selector it is simpler to write as `!selector` instead.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   aa = 1:3,
#'   ba = c("a", "b", NA),
#'   cc = c(NA, 2.5, 1.5)
#' )
#'
#' # Exclude by column name(s):
#' df$select(cs$exclude("ba", "xx"))
#'
#' # Exclude using a column name, a selector, and a dtype:
#' df$select(cs$exclude("aa", cs$string(), pl$Int32))
cs__exclude <- function(...) {
  check_dots_unnamed()
  input <- list2(...)

  col_names <- Filter(
    \(x) is_string(x) && !(startsWith(x, "^") && !endsWith(x, "$")),
    input
  )
  regexes <- Filter(
    \(x) is_string(x) && startsWith(x, "^") && endsWith(x, "$"),
    input
  )
  dtypes <- Filter(is_polars_dtype, input)
  selectors <- Filter(is_polars_selector, input)
  unknown <- Filter(
    \(x) !is_character(x) && !is_polars_dtype(x) && !is_polars_selector(x),
    input
  )
  if (length(unknown) > 0) {
    abort("`...` can only contain column names, regexes, polars data types or polars selectors.")
  }

  selected <- list()
  if (length(col_names) > 0) {
    selected <- append(selected, cs$by_name(!!!col_names))
  }
  if (length(regexes) > 0) {
    selected <- append(selected, cs$matches(paste0(unlist(regexes), collapse = "|")))
  }
  if (length(dtypes) > 0) {
    selected <- append(selected, cs$by_dtype(!!!dtypes))
  }
  if (length(selectors) > 0) {
    selected <- append(selected, selectors)
  }
  all_selected <- Reduce(`|`, selected)

  !all_selected
}

#' Select the first column in the current scope
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123L, 456L),
#'   baz = c(2.0, 5.5),
#'   zap = c(FALSE, TRUE)
#' )
#'
#' # Select the first column:
#' df$select(cs$first())
#'
#' # Select everything except for the first column:
#' df$select(!cs$first())
cs__first <- function() {
  wrap_to_selector(pl$first(), name = "first")
}

#' Select all float columns.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123L, 456L),
#'   baz = c(2.0, 5.5),
#'   zap = c(FALSE, TRUE),
#'   .schema_overrides = list(baz = pl$Float32, zap = pl$Float64),
#' )
#'
#' # Select all float columns:
#' df$select(cs$float())
#'
#' # Select all columns except for those that are float:
#' df$select(!cs$float())
cs__float <- function() {
  list_dtypes <- list(pl$Float32, pl$Float64)
  wrap_to_selector(
    pl$col(!!!list_dtypes),
    name = "float",
    parameters = list_dtypes
  )
}

#' Select all integer columns.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123L, 456L),
#'   baz = c(2.0, 5.5),
#'   zap = 0:1
#' )
#'
#' # Select all integer columns:
#' df$select(cs$integer())
#'
#' # Select all columns except for those that are integer:
#' df$select(!cs$integer())
cs__integer <- function() {
  list_dtypes <- list(
    pl$Int8, pl$Int16, pl$Int32, pl$Int64,
    pl$UInt8, pl$UInt16, pl$UInt32, pl$UInt64
  )
  wrap_to_selector(
    pl$col(!!!list_dtypes),
    name = "integer",
    parameters = list_dtypes
  )
}

#' Select the last column in the current scope
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123L, 456L),
#'   baz = c(2.0, 5.5),
#'   zap = c(FALSE, TRUE)
#' )
#'
#' # Select the last column:
#' df$select(cs$last())
#'
#' # Select everything except for the last column:
#' df$select(!cs$last())
cs__last <- function() {
  wrap_to_selector(pl$last(), name = "last")
}

#' Select all columns that match the given regex pattern
#'
#' @param pattern A valid regular expression pattern, compatible with the
#' `regex crate <https://docs.rs/regex/latest/regex/>`_.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123, 456),
#'   baz = c(2.0, 5.5),
#'   zap = c(0, 1)
#' )
#'
#' # Match column names containing an "a", preceded by a character that is not
#' # "z":
#' df$select(cs$matches("[^z]a"))
#'
#' # Do not match column names ending in "R" or "z" (case-insensitively):
#' df$select(!cs$matches(r"((?i)R|z$)"))
cs__matches <- function(pattern) {
  check_character(pattern)
  if (pattern == ".*") {
    cs$all()
  }

  if (startsWith(pattern, ".*")) {
    pattern <- substr(pattern, 2, nchar(pattern))
  } else if (endsWith(pattern, ".*")) {
    pattern <- substr(pattern, 1, nchar(pattern) - 2)
  }

  if (!startsWith(pattern, ".*")) {
    pfx <- "^.*"
  } else {
    pfx <- ""
  }

  if (!endsWith(pattern, ".*")) {
    sfx <- ".*$"
  } else {
    sfx <- ""
  }
  raw_params <- paste0(pfx, pattern, sfx)
  wrap_to_selector(pl$col(!!!raw_params), name = "matches")
}

#' Select all numeric columns.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123L, 456L),
#'   baz = c(2.0, 5.5),
#'   zap = 0:1,
#'   .schema_overrides = list(bar = pl$Int16, baz = pl$Float32, zap = pl$UInt8),
#' )
#'
#' # Select all numeric columns:
#' df$select(cs$numeric())
#'
#' # Select all columns except for those that are numeric:
#' df$select(!cs$numeric())
cs__numeric <- function() {
  list_dtypes <- list(
    pl$Float32, pl$Float64,
    pl$Int8, pl$Int16, pl$Int32, pl$Int64,
    pl$UInt8, pl$UInt16, pl$UInt32, pl$UInt64
  )
  wrap_to_selector(
    pl$col(!!!list_dtypes),
    name = "numeric",
    parameters = list_dtypes
  )
}

#' Select all signed integer columns
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c(-123L, -456L),
#'   bar = c(3456L, 6789L),
#'   baz = c(7654L, 4321L),
#'   zap = c("ab", "cd"),
#'   .schema_overrides = list(bar = pl$UInt32, baz = pl$UInt64),
#' )
#'
#' # Select signed integer columns:
#' df$select(cs$signed_integer())
#'
#' # Select all columns except for those that are signed integer:
#' df$select(!cs$signed_integer())
#'
#' # Select all integer columns (both signed and unsigned):
#' df$select(cs$integer())
cs__signed_integer <- function() {
  list_dtypes <- list(pl$Int8, pl$Int16, pl$Int32, pl$Int64)
  wrap_to_selector(
    pl$col(!!!list_dtypes),
    name = "signed_integer",
    parameters = list_dtypes
  )
}

#' Select columns that start with the given substring(s)
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Substring(s) that matching
#' column names should end with.
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c("x", "y"),
#'   bar = c(123, 456),
#'   baz = c(2.0, 5.5),
#'   zap = c(FALSE, TRUE)
#' )
#'
#' # Select columns that start with the substring "b":
#' df$select(cs$starts_with("b"))
#'
#' # Select columns that start with either the letter "b" or "z":
#' df$select(cs$starts_with("b", "z"))
#'
#' # Select all columns except for those that start with the substring "b":
#' df$select(!cs$starts_with("b"))
cs__starts_with <- function(...) {
  check_dots_unnamed()
  dots <- list2(...)
  check_list_of_string(dots, arg = "...")

  substrings <- as.character(dots) |>
    paste0(collapse = "|")
  raw_params <- paste0("^(", substrings, ").*$")
  wrap_to_selector(pl$col(!!!raw_params), name = "starts_with")
}

#' Select all String (and, optionally, Categorical) string columns.
#'
#' @inheritParams rlang::args_dots_empty
#' @param include_categorical If `TRUE`, also select categorical columns.
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   w = c("xx", "yy", "xx", "yy", "xx"),
#'   x = c(1, 2, 1, 4, -2),
#'   y = c(3.0, 4.5, 1.0, 2.5, -2.0),
#'   z = c("a", "b", "a", "b", "b")
#' )$with_columns(
#'   z = pl$col("z")$cast(pl$Categorical())
#' )
#'
#' # Group by all string columns, sum the numeric columns, then sort by the
#' # string cols:
#' df$group_by(cs$string())$agg(cs$numeric()$sum())$sort(cs$string())
#'
#' # Group by all string and categorical columns:
#' df$
#'   group_by(cs$string(include_categorical = TRUE))$
#'   agg(cs$numeric()$sum())$
#'   sort(cs$string(include_categorical = TRUE))
cs__string <- function(..., include_categorical = FALSE) {
  check_dots_empty0(...)
  if (isTRUE(include_categorical)) {
    list_dtypes <- list(pl$String, pl$Categorical())
  } else {
    list_dtypes <- list(pl$String)
  }
  wrap_to_selector(pl$col(!!!list_dtypes), name = "string")
}

#' Select all temporal columns
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   dtm = as.POSIXct(c("2001-5-7 10:25", "2031-12-31 00:30")),
#'   dt = as.Date(c("1999-12-31", "2024-8-9")),
#'   value = 1:2
#' )
#'
#' # Match all temporal columns:
#' df$select(cs$temporal())
#'
#' # Match all temporal columns except for time columns:
#' df$select(cs$temporal() - cs$datetime())
#'
#' # Match all columns except for temporal columns:
#' df$select(!cs$temporal())
cs__temporal <- function() {
  list_dtypes <- list(pl$Date, pl$Time)
  wrap_to_selector(
    pl$col(!!!list_dtypes),
    name = "temporal",
    parameters = list_dtypes
  ) | cs$datetime() | cs$duration()
}

#' Select all time columns
#'
#' @inherit cs__all return seealso
#' @examplesIf requireNamespace("hms", quietly = TRUE)
#' df <- pl$DataFrame(
#'   dtm = as.POSIXct(c("2001-5-7 10:25", "2031-12-31 00:30")),
#'   dt = as.Date(c("1999-12-31", "2024-8-9")),
#'   tm = hms::parse_hms(c("0:0:0", "23:59:59"))
#' )
#'
#' # Select time columns:
#' df$select(cs$time())
#'
#' # Select all columns except for those that are time:
#' df$select(!cs$time())
cs__time <- function() {
  wrap_to_selector(pl$col(pl$Time), name = "time")
}

#' Select all unsigned integer columns
#'
#' @inherit cs__all return seealso
#' @examples
#' df <- pl$DataFrame(
#'   foo = c(-123L, -456L),
#'   bar = c(3456L, 6789L),
#'   baz = c(7654L, 4321L),
#'   zap = c("ab", "cd"),
#'   .schema_overrides = list(bar = pl$UInt32, baz = pl$UInt64),
#' )
#'
#' # Select unsigned integer columns:
#' df$select(cs$unsigned_integer())
#'
#' # Select all columns except for those that are unsigned integer:
#' df$select(!cs$unsigned_integer())
#'
#' # Select all integer columns (both unsigned and unsigned):
#' df$select(cs$integer())
cs__unsigned_integer <- function() {
  list_dtypes <- list(pl$UInt8, pl$UInt16, pl$UInt32, pl$UInt64)
  wrap_to_selector(
    pl$col(!!!list_dtypes),
    name = "integer",
    parameters = list_dtypes
  )
}
