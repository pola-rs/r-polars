# Unlike Python Polars, the DataType object is defined on the Rust side,
# so this file provide wrappers

# TODO: link to data type mapping vignette
# TODO: floating point numbers section
# TODO: lists bindings of each class
# source: https://docs.pola.rs/user-guide/concepts/data-types-and-structures/
#' Polars DataType class (`polars_dtype`)
#'
#' @description
#' Polars supports a variety of data types that fall broadly under the following categories:
#'
#' - Numeric data types: signed integers, unsigned integers, floating point numbers, and decimals.
#' - Nested data types: lists, structs, and arrays.
#' - Temporal: dates, datetimes, times, and time deltas.
#' - Miscellaneous: strings, binary data, Booleans, categoricals, and enums.
#'
#' All types support missing values represented by the special value `null`.
#' This is not to be conflated with the special value `NaN` in floating number data types;
#' see the section about floating point numbers for more information.
#'
#' @details
#' ## Full data types table
#'
# nolint start: line_length_linter
#' | Type(s)                                        | Details                                                                         |
#' | ---------------------------------------------- | ------------------------------------------------------------------------------- |
#' | `Boolean`                                      | Boolean type that is bit packed efficiently.                                    |
#' | `Int8`, `Int16`, `Int32`, `Int64`              | Varying-precision signed integer types.                                         |
#' | `UInt8`, `UInt16`, `UInt32`, `UInt64`          | Varying-precision unsigned integer types.                                       |
#' | `Float32`, `Float64`                           | Varying-precision signed floating point numbers.                                |
#' | `Decimal` `r lifecycle::badge("experimental")` | Decimal 128-bit type with optional precision and non-negative scale.            |
#' | `String`                                       | Variable length UTF-8 encoded string data, typically Human-readable.            |
#' | `Binary`                                       | Stores arbitrary, varying length raw binary data.                               |
#' | `Date`                                         | Represents a calendar date.                                                     |
#' | `Time`                                         | Represents a time of day.                                                       |
#' | `Datetime`                                     | Represents a calendar date and time of day.                                     |
#' | `Duration`                                     | Represents a time duration.                                                     |
#' | `Array`                                        | Arrays with a known, fixed shape per series; akin to numpy arrays.              |
#' | `List`                                         | Homogeneous 1D container with variable length.                                  |
#' | `Categorical`                                  | Efficient encoding of string data where the categories are inferred at runtime. |
#' | `Enum` `r lifecycle::badge("experimental")`    | Efficient ordered encoding of a set of predetermined string categories.         |
#' | `Struct`                                       | Composite product type that can store multiple fields.                          |
#' | `Null`                                         | Represents null values.                                                         |
# nolint end
#' @name polars_dtype
#' @aliases DataType
#' @examples
#' pl$Int8
#' pl$Int16
#' pl$Int32
#' pl$Int64
#' pl$UInt8
#' pl$UInt16
#' pl$UInt32
#' pl$UInt64
#' pl$Float32
#' pl$Float64
#' pl$Decimal(scale = 2)
#' pl$String
#' pl$Binary
#' pl$Date
#' pl$Time
#' pl$Datetime()
#' pl$Duration()
#' pl$Array(pl$Int32, c(2, 3))
#' pl$List(pl$Int32)
#' pl$Categorical()
#' pl$Enum(c("a", "b", "c"))
#' pl$Struct(a = pl$Int32, b = pl$String)
#' pl$Null
#' pl$Unknown
NULL

# The env for storing data type methods
polars_datatype__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRDataType <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_dt` <- x
  dtype_names <- x$`_get_dtype_names`()

  # Bindings mimic attributes of DataType classes of Python Polars
  env_bind(self, !!!x$`_get_datatype_fields`())

  ## _inner is a pointer now, so it should be wrapped
  if (exists("_inner", envir = self)) {
    makeActiveBinding(
      "inner",
      function() {
        .savvy_wrap_PlRDataType(self$`_inner`) |>
          wrap()
      },
      self
    )
  }

  ## _fields is a list of pointers now, so they should be wrapped
  if (exists("_fields", envir = self)) {
    makeActiveBinding(
      "fields",
      function() {
        lapply(self$`_fields`, function(x) {
          .savvy_wrap_PlRDataType(x) |>
            wrap()
        })
      },
      self
    )
  }

  class(self) <- c(dtype_names, "polars_dtype", "polars_object")
  self
}

# Register data types without arguments as active bindings
on_load({
  c(
    "Int8",
    "Int16",
    "Int32",
    "Int64",
    "Int128",
    "UInt8",
    "UInt16",
    "UInt32",
    "UInt64",
    "Float32",
    "Float64",
    "Boolean",
    "String",
    "Binary",
    "Date",
    "Time",
    "Null",
    "Unknown"
  ) |>
    lapply(function(name) {
      makeActiveBinding(name, function() PlRDataType$new_from_name(name) |> wrap(), pl)
    })
})

#' @rdname polars_dtype
#' @param precision Single integer or `NULL` (default), maximum number of digits in each number.
#' If `NULL`, the precision is inferred.
#' @param scale Single integer or `NULL`. Number of digits to the right of the decimal point
#' in each number. The default is `0`.
pl__Decimal <- function(precision = NULL, scale = 0L) {
  PlRDataType$new_decimal(scale = scale, precision = precision) |>
    wrap()
}

# TODO: more about timezone
#' @rdname polars_dtype
#' @param time_unit One of `"us"` (default, microseconds),
#' `"ns"` (nanoseconds) or `"ms"`(milliseconds). Representing the unit of time.
#' @param time_zone A string or `NULL` (default). Representing the timezone.
pl__Datetime <- function(time_unit = c("us", "ns", "ms"), time_zone = NULL) {
  wrap({
    time_unit <- arg_match0(time_unit, c("us", "ns", "ms"))
    PlRDataType$new_datetime(time_unit, time_zone)
  })
}

#' @rdname polars_dtype
pl__Duration <- function(time_unit = c("us", "ns", "ms")) {
  wrap({
    time_unit <- arg_match0(time_unit, c("us", "ns", "ms"))
    PlRDataType$new_duration(time_unit)
  })
}

#' @rdname polars_dtype
#' @param ordering One of `"physical"` (default) or `"lexical"`.
#' Ordering by order of appearance (`"physical"`) or string value (`"lexical"`).
pl__Categorical <- function(ordering = c("physical", "lexical")) {
  wrap({
    ordering <- arg_match0(ordering, c("physical", "lexical"))
    PlRDataType$new_categorical(ordering)
  })
}

#' @rdname polars_dtype
#' @param categories A character vector.
#' Should not contain `NA` values and all values should be unique.
pl__Enum <- function(categories) {
  # TODO: impliment `issue_unstable_warning`
  wrap({
    check_character(categories, allow_na = FALSE)

    if (anyDuplicated(categories)) {
      abort(sprintf(
        "Enum categories must be unique, found duplicated: %s",
        toString(categories[which(duplicated(categories))])
      ))
    }

    PlRDataType$new_enum(categories)
  })
}

# TODO: shape is...?
#' @rdname polars_dtype
#' @param inner A polars data type object.
#' @param shape A integer-ish vector, representing the shape of the Array.
pl__Array <- function(inner, shape) {
  wrap({
    check_polars_dtype(inner)
    PlRDataType$new_array(inner$`_dt`, shape)
  })
}

#' @rdname polars_dtype
pl__List <- function(inner) {
  wrap({
    check_polars_dtype(inner)
    PlRDataType$new_list(inner$`_dt`)
  })
}

#' @rdname polars_dtype
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]>
#' Name-value pairs of polars data type.
#' Each pair represents a field of the Struct.
pl__Struct <- function(...) {
  parse_into_list_of_datatypes(...) |>
    PlRDataType$new_struct() |>
    wrap()
}

datatype__eq <- function(other) {
  wrap({
    check_polars_dtype(other)
    self$`_dt`$eq(other$`_dt`)
  })
}

datatype__ne <- function(other) {
  wrap({
    check_polars_dtype(other)
    self$`_dt`$ne(other$`_dt`)
  })
}

datatype__is_numeric <- function() {
  inherits(self, "polars_dtype_numeric")
}

datatype__is_decimal <- function() {
  inherits(self, "polars_dtype_decimal")
}

datatype__is_integer <- function() {
  inherits(self, "polars_dtype_integer")
}

datatype__is_signed_integer <- function() {
  inherits(self, "polars_dtype_signed_integer")
}

datatype__is_unsigned_integer <- function() {
  inherits(self, "polars_dtype_unsigned_integer")
}

datatype__is_float <- function() {
  inherits(self, "polars_dtype_float")
}

datatype__is_temporal <- function() {
  inherits(self, "polars_dtype_temporal")
}

datatype__is_nested <- function() {
  inherits(self, "polars_dtype_nested")
}

datatype__max <- function() {
  self$`_dt`$max() |>
    wrap()
}

datatype__min <- function() {
  self$`_dt`$min() |>
    wrap()
}
