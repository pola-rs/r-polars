# The env for storing Schema methods
polars_schema__methods <- new.env(parent = emptyenv())

#' Polars Schema class (`polars_schema`)
#'
#' An ordered mapping of column names to their [data type][polars_dtype].
#' It is a named [list] of polars data types with the class `polars_schema`,
#' so base R functions such as [names()], [length()], `[[` or [lapply()] work as usual.
#' [`<DataFrame>$schema`][DataFrame] and
#' [`<LazyFrame>$collect_schema()`][lazyframe__collect_schema] return this class.
#'
#' Elements of the schema can be extracted with `$` (e.g. `schema$foo`),
#' except for column names that conflict with a method name
#' (`dtypes`, `to_frame`, `contains_dtype`), which must be extracted with `[[`.
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]>
#' Name-value pairs of polars data types. Each name is a column name.
#' @return A polars Schema.
#' @aliases polars_schema Schema
#' @examples
#' schema <- pl$Schema(
#'   foo = pl$String,
#'   bar = pl$Duration("us"),
#'   baz = pl$Array(pl$Int8, 4)
#' )
#' schema
#'
#' # Access the data type associated with a specific column name
#' schema$baz
#' schema[["baz"]]
#'
#' # Names and number of columns
#' names(schema)
#' length(schema)
#'
#' # Compare schemas
#' schema == pl$Schema(foo = pl$String, bar = pl$Duration("us"), baz = pl$Array(pl$Int8, 4))
#' schema == pl$Schema(foo = pl$String)
#'
#' # Schemas of frames
#' pl$DataFrame(a = 1:2, b = c("x", "y"))$schema
pl__Schema <- function(...) {
  wrap(new_polars_schema(list2(...)))
}

new_polars_schema <- function(x) {
  if (length(x) > 0L && is.null(names(x))) {
    abort("All elements of a Schema must be named.")
  }
  if (!is_list_of_polars_dtype(x)) {
    abort("All elements of a Schema must be polars data types.")
  }
  dup <- anyDuplicated(names(x))
  if (dup > 0L) {
    abort(sprintf("Schema contains duplicate name '%s'.", names(x)[[dup]]))
  }
  if (is.null(names(x))) {
    names(x) <- character()
  }
  class(x) <- c("polars_schema", "list")
  x
}

#' Get the data types of a Schema
#'
#' @return A list of polars data types.
#' @examples
#' schema <- pl$Schema(x = pl$UInt8, y = pl$List(pl$UInt8))
#' schema$dtypes()
schema__dtypes <- function() {
  unname(unclass(self))
}

#' Create an empty DataFrame or LazyFrame from a Schema
#'
#' @inheritParams rlang::args_dots_empty
#' @param eager If `TRUE` (default), create a [DataFrame]; otherwise, create
#' a [LazyFrame].
#' @return A polars [DataFrame] or [LazyFrame].
#' @examples
#' schema <- pl$Schema(x = pl$Int32, y = pl$String)
#' schema$to_frame()
#' schema$to_frame(eager = FALSE)
schema__to_frame <- function(..., eager = TRUE) {
  wrap({
    check_dots_empty0(...)
    check_bool(eager)
    df <- lapply(self, \(dtype) as_polars_series(NULL)$cast(dtype)) |>
      as_polars_df()
    if (eager) df else df$lazy()
  })
}

#' Check if a Schema contains the given data type
#'
#' @inheritParams rlang::args_dots_empty
#' @param dtype A polars data type to search for.
#' @param recursive If `FALSE`, only check top-level column data types.
#' If `TRUE`, search the data types inside nested types (List, Array, Map, Struct)
#' instead, in which case the nested types themselves are not matched.
#' @return A logical value.
#' @examples
#' schema <- pl$Schema(x = pl$Int64, y = pl$List(pl$Float64))
#' schema$contains_dtype(pl$Int64, recursive = FALSE)
#' schema$contains_dtype(pl$Float64, recursive = FALSE)
#' schema$contains_dtype(pl$Float64, recursive = TRUE)
schema__contains_dtype <- function(dtype, ..., recursive) {
  wrap({
    check_dots_empty0(...)
    check_polars_dtype(dtype)
    check_bool(recursive)

    unpack <- function(dt) {
      if (inherits(dt, c("polars_dtype_list", "polars_dtype_array"))) {
        unpack(dt$inner)
      } else if (inherits(dt, "polars_dtype_map")) {
        c(unpack(dt$key), unpack(dt$value))
      } else if (inherits(dt, "polars_dtype_struct")) {
        unlist(lapply(unname(dt$fields), unpack), recursive = FALSE)
      } else {
        list(dt)
      }
    }

    dtypes <- self$dtypes()
    if (recursive) {
      dtypes <- unlist(lapply(dtypes, unpack), recursive = FALSE)
    }
    any(vapply(dtypes, \(dt) dt$eq(dtype), logical(1)))
  })
}

#' @export
`$.polars_schema` <- function(x, name) {
  if (name %in% names(polars_schema__methods)) {
    fn <- polars_schema__methods[[name]]
    self <- x # nolint: object_usage_linter
    environment(fn) <- environment()
    fn
  } else {
    .subset2(x, name)
  }
}

#' @exportS3Method utils::.DollarNames
`.DollarNames.polars_schema` <- function(x, pattern = "") {
  all_names <- union(names(polars_schema__methods), names(x))
  findMatches(pattern, all_names)
}

#' @export
`[.polars_schema` <- function(x, i) {
  new_polars_schema(NextMethod())
}

#' @export
`[[<-.polars_schema` <- function(x, i, value) {
  new_polars_schema(NextMethod())
}

#' @export
`$<-.polars_schema` <- function(x, name, value) {
  new_polars_schema(NextMethod())
}

#' @export
`[<-.polars_schema` <- function(x, i, value) {
  new_polars_schema(NextMethod())
}

#' @export
as.list.polars_schema <- function(x, ...) {
  unclass(x)
}

#' @export
Ops.polars_schema <- function(e1, e2) {
  if (!.Generic %in% c("==", "!=")) {
    abort(sprintf("`%s` is not supported for polars Schema.", .Generic))
  }
  equal <- is_list_of_polars_dtype(e1) &&
    is_list_of_polars_dtype(e2) &&
    identical(names(e1), names(e2)) &&
    all(vapply(seq_along(e1), \(i) e1[[i]]$eq(e2[[i]]), logical(1)))

  if (.Generic == "==") equal else !equal
}

#' @export
format.polars_schema <- function(x, ...) {
  c(
    sprintf("Schema with %d column%s:", length(x), if (length(x) == 1L) "" else "s"),
    sprintf("  %s: %s", names(x), vapply(x, format, character(1)))
  )
}

#' @export
print.polars_schema <- function(x, ...) {
  writeLines(format(x, ...))
  invisible(x)
}
