#' check if schema
#' @param x object to test if schema
#' @return bool
#' @keywords functions
#' @examples
#' pl$is_schema(pl$DataFrame(iris)$schema)
#' pl$is_schema(list("alice", "bob"))
pl_is_schema = \(x) {
  is.list(x) && !is.null(names(x)) && !anyNA(names(x)) &&
    do.call(all, lapply(x, inherits, "RPolarsDataType"))
}


#' wrap proto schema
#' @noRd
#' @name wrap_proto_schema
#' @param x either schema, or incomplete schema where dataType can be NULL
#' or schema is just char vec, implicitly the same as if all DataType are NULL,
#' mean undefined.
#' @return bool
#' @examples
#' .pr$env$wrap_proto_schema(c("alice", "bob"))
#' .pr$env$wrap_proto_schema(list("alice" = pl$Int64, "bob" = NULL))
wrap_proto_schema = function(x) {
  pcase(
    is.list(x) && !is.null(names(x)),
    x,
    is.character(x) && !anyNA(x),
    {
      names(x) = x
      lapply(x, \(x) NULL)
    },
    or_else = stop(
      "arg schema must be a list of named DataType/RPolarsDataType or char vec of no NAs"
    )
  )
}



#' @title DataTypes (RPolarsDataType)
#'
#' @name pl_dtypes
#' @aliases RPolarsDataType
#' @description `DataType` any polars type (ported so far)
#' @return not applicable
#' @examples
#' print(ls(pl$dtypes))
#' pl$dtypes$Float64
#' pl$dtypes$String
#'
#' pl$List(pl$List(pl$UInt64))
#'
#' pl$Struct(pl$Field("CityNames", pl$String))
#'
#' # The function changes type from Int32 to String
#' # Specifying the output DataType: String solves the problem
#' as_polars_series(1:4)$map_elements(\(x) letters[x], datatype = pl$dtypes$String)
#'
NULL



#' print a polars datatype
#'
#' @param x DataType
#' @param ... not used
#'
#' @return self
#' @export
#'
#' @noRd
#' @examples
#' pl$dtypes$Boolean # implicit print
print.RPolarsDataType = function(x, ...) {
  cat("DataType: ")
  x$print()
  invisible(x)
}


#' @export
"==.RPolarsDataType" = function(e1, e2) e1$eq(e2)
#' @export
"!=.RPolarsDataType" = function(e1, e2) e1$ne(e2)


#' check if x is a valid RPolarsDataType
#' @name same_outer_datatype
#' @param lhs an RPolarsDataType
#' @param rhs an RPolarsDataType
#' @noRd
#' @return bool TRUE if outer datatype is the same.
#' @examples
#' # TRUE
#' pl$same_outer_dt(pl$Datetime("us"), pl$Datetime("ms"))
#' pl$same_outer_dt(pl$List(pl$Int64), pl$List(pl$Float32))
#'
#' # FALSE
#' pl$same_outer_dt(pl$Int64, pl$Float64)
pl_same_outer_dt = function(lhs, rhs) {
  .pr$DataType$same_outer_datatype(lhs, rhs)
}


#' DataType_new (simple DataType's)
#' @noRd
#' @description Create a new flag like DataType
#' @param str name of DataType to create
#' @details
#' This function is mainly used in `zzz.R` `.onLoad` to instantiate singletons of all
#' flag-like DataType.
#'
#' Non-flag like DataType called composite DataTypes also carries extra information
#' e.g. Datetime a timeunit and a TimeZone, or List which recursively carries another DataType
#' inside. Composite DataTypes use DataType constructors.
#'
#' Any DataType can be found in pl$dtypes
#'
#' @return DataType
#' @examples
#' .pr$env$DataType_new("Int64")
DataType_new = function(str) {
  .pr$DataType$new(str)
}

#' DataType_constructors (composite DataType's)
#' @description List of all composite DataType constructors
#' @noRd
#' @details
#' This list is mainly used in `zzz.R` `.onLoad` to instantiate singletons of all
#' flag-like DataTypes.
#'
#' Non-flag like DataType called composite DataTypes also carries extra information
#' e.g. Datetime a timeunit and a TimeZone, or List which recursively carries another DataType
#' inside. Composite DataTypes use DataType constructors.
#'
#' Any DataType can be found in pl$dtypes
#'
#' @return DataType
#' @examples
#' # constructors are finally available via pl$... or pl$dtypes$...
#' pl$List(pl$List(pl$Int64))
DataType_constructors = function() {
  list(
    Array = DataType_Array,
    Categorical = DataType_Categorical,
    Enum = DataType_Enum,
    Datetime = DataType_Datetime,
    Duration = DataType_Duration,
    List = DataType_List,
    Struct = DataType_Struct
  )
}


#' Data type representing a calendar date and time of day.
#'
#' The underlying representation of this type is a 64-bit signed integer.
#' The integer indicates the number of time units since the Unix epoch (1970-01-01 00:00:00).
#' The number can be negative to indicate datetimes before the epoch.
#' @aliases pl_Datetime
#' @param time_unit Unit of time. One of `"ms"`, `"us"` (default) or `"ns"`.
#' @param time_zone Time zone string, as defined in [OlsonNames()].
#' Setting `timezone = "*"` will match any timezone, which can be useful to
#' select all Datetime columns containing a timezone.
#' @return Datetime DataType
#' @examples
#' pl$Datetime("ns", "Pacific/Samoa")
#'
#' df = pl$DataFrame(
#'   naive_time = as.POSIXct("1900-01-01"),
#'   zoned_time = as.POSIXct("1900-01-01", "UTC")
#' )
#' df
#'
#' df$select(pl$col(pl$Datetime("us", "*")))
DataType_Datetime = function(time_unit = "us", time_zone = NULL) {
  if (!is.null(time_zone) && !isTRUE(time_zone %in% c(base::OlsonNames(), "*"))) {
    sprintf(
      "The time zone '%s' is not supported in polars. See `base::OlsonNames()` for supported time zones.",
      time_zone
    ) |>
      Err_plain() |>
      unwrap("in $Datetime():")
  }
  unwrap(.pr$DataType$new_datetime(time_unit, time_zone))
}

#' Data type representing a time duration
#'
#' @inheritParams DataType_Datetime
#'
#' @return Duration DataType
#'
#' @examples
#' test = pl$DataFrame(
#'   a = 1:2,
#'   b = c("a", "b"),
#'   c = pl$duration(weeks = c(1, 2), days = c(0, 2))
#' )
#'
#' # select all columns of type "duration"
#' test$select(pl$col(pl$Duration()))
DataType_Duration = function(time_unit = "us") {
  unwrap(.pr$DataType$new_duration(time_unit))
}

#' Create Struct DataType
#'
#' One can create a `Struct` data type with `pl$Struct()`. There are also
#' multiple ways to create columns of data type `Struct` in a `DataFrame` or
#' a `Series`, see the examples.
#'
#' @param ... Either named inputs of the form `field_name = datatype` or objects
#' of class `RPolarsField` created by [`pl$Field()`][pl_Field].
#' @return A Struct DataType containing a list of Fields
#' @examples
#' # create a Struct-DataType
#' pl$Struct(foo = pl$Int32, pl$Field("bar", pl$Boolean))
#'
#' # check if an element is any kind of Struct()
#' test = pl$Struct(a = pl$UInt64)
#' pl$same_outer_dt(test, pl$Struct())
#'
#' # `test` is a type of Struct, but it doesn't mean it is equal to an empty Struct
#' test == pl$Struct()
#'
#' # The way to create a `Series` of type `Struct` is a bit convoluted as it involves
#' # `data.frame()`, `list()`, and `I()`:
#' as_polars_series(
#'   data.frame(a = 1:2, b = I(list(c("x", "y"), "z")))
#' )
#'
#' # A slightly simpler way would be via `tibble::tibble()` or
#' # `data.table::data.table()`:
#' if (requireNamespace("tibble", quietly = TRUE)) {
#'   as_polars_series(
#'     tibble::tibble(a = 1:2, b = list(c("x", "y"), "z"))
#'   )
#' }
#'
#' # Finally, one can use `pl$struct()` to convert existing columns or `Series`
#' # to a `Struct`:
#' x = pl$DataFrame(
#'   a = 1:2,
#'   b = list(c("x", "y"), "z")
#' )
#'
#' out = x$select(pl$struct(c("a", "b")))
#' out
#'
#' out$schema
DataType_Struct = function(...) {
  uw = \(res) unwrap(res, "in pl$Struct():")
  err_message = Err_plain("`pl$Struct()` only accepts named inputs or input of class RPolarsField.")
  result({
    largs = list2(...)
    if (length(largs) >= 1 && is.list(largs[[1]])) {
      largs = largs[[1]]
    }
    lapply(seq_along(largs), function(x) {
      name = names(largs)[x]
      dtype = largs[[x]]
      if (inherits(dtype, "RPolarsRField")) {
        return(dtype)
      }
      if (is.null(name)) {
        err_message |> uw()
      }
      if (inherits(dtype, "RPolarsDataType")) {
        return(pl$Field(name, dtype))
      }
      err_message |> uw()
    })
  }) |>
    and_then(DataType$new_struct) |>
    uw()
}

#' Create Array DataType
#'
#' The Array and List datatypes are very similar. The only difference is that
#' sub-arrays all have the same length while sublists can have different lengths.
#' Array methods can be accessed via the `$arr` subnamespace.
#'
#' @param datatype An inner DataType. The default is `"Unknown"` and is only a
#' placeholder for when inner DataType does not matter, e.g. as used in example.
#' @param width The length of the arrays.
#' @return An array DataType with an inner DataType
#' @examples
#' # basic Array
#' pl$Array(pl$Int32, 4)
#' # some nested Array
#' pl$Array(pl$Array(pl$Boolean, 3), 2)
DataType_Array = function(datatype = "unknown", width) {
  if (is.character(datatype) && length(datatype) == 1) {
    datatype = .pr$DataType$new(datatype)
  }
  if (!inherits(datatype, "RPolarsDataType")) {
    stop(paste(
      "input for generating a array DataType must be another DataType",
      "or an interpretable name thereof."
    ))
  }
  .pr$DataType$new_array(datatype, width) |>
    unwrap("in pl$Array():")
}

#' Create List DataType
#' @keywords pl
#' @param datatype an inner DataType, default is "Unknown" (placeholder for when inner DataType
#' does not matter, e.g. as used in example)
#' @return a list DataType with an inner DataType
#' @examples
#' # some nested List
#' pl$List(pl$List(pl$Boolean))
#'
#' # check if some maybe_list is a List DataType
#' maybe_List = pl$List(pl$UInt64)
#' pl$same_outer_dt(maybe_List, pl$List())
DataType_List = function(datatype = "unknown") {
  if (is.character(datatype) && length(datatype) == 1) {
    datatype = .pr$DataType$new(datatype)
  }
  if (!inherits(datatype, "RPolarsDataType")) {
    stop(paste(
      "input for generating a list DataType must be another DataType",
      "or an interpretable name thereof."
    ))
  }
  .pr$DataType$new_list(datatype)
}

#' Create Categorical DataType
#'
#' @param ordering Either `"physical"` (default) or `"lexical"`.
#'
#' @details
#' When a categorical variable is created, its string values (or "lexical"
#' values) are stored and encoded as integers ("physical" values) by
#' order of appearance. Therefore, sorting a categorical value can be done
#' either on the lexical or on the physical values. See Examples.
#'
#'
#' @return A Categorical DataType
#' @examples
#' # default is to order by physical values
#' df = pl$DataFrame(x = c("z", "z", "k", "a", "z"), schema = list(x = pl$Categorical()))
#' df$sort("x")
#'
#' # when setting ordering = "lexical", sorting will be based on the strings
#' df_lex = pl$DataFrame(
#'   x = c("z", "z", "k", "a", "z"),
#'   schema = list(x = pl$Categorical("lexical"))
#' )
#' df_lex$sort("x")
DataType_Categorical = function(ordering = "physical") {
  .pr$DataType$new_categorical(ordering) |> unwrap()
}

#' Create Enum DataType
#'
#' An `Enum` is a fixed set categorical encoding of a set of strings. It is
#' similar to the [`Categorical`][DataType_Categorical] data type, but the
#' categories are explicitly provided by the user and cannot be modified.
#'
#' This functionality is **unstable**. It is a work-in-progress feature and may
#' not always work as expected. It may be changed at any point without it being
#' considered a breaking change.
#'
#' @param categories A character vector specifying the categories of the variable.
#'
#' @return An Enum DataType
#' @examples
#' pl$DataFrame(
#'   x = c("Polar", "Panda", "Brown", "Brown", "Polar"),
#'   schema = list(x = pl$Enum(c("Polar", "Panda", "Brown")))
#' )
#'
#' # All values of the variable have to be in the categories
#' dtype = pl$Enum(c("Polar", "Panda", "Brown"))
#' tryCatch(
#'   pl$DataFrame(
#'     x = c("Polar", "Panda", "Brown", "Brown", "Polar", "Black"),
#'     schema = list(x = dtype)
#'   ),
#'   error = function(e) e
#' )
#'
#' # Comparing two Enum is only valid if they have the same categories
#' df = pl$DataFrame(
#'   x = c("Polar", "Panda", "Brown", "Brown", "Polar"),
#'   y = c("Polar", "Polar", "Polar", "Brown", "Brown"),
#'   z = c("Polar", "Polar", "Polar", "Brown", "Brown"),
#'   schema = list(
#'     x = pl$Enum(c("Polar", "Panda", "Brown")),
#'     y = pl$Enum(c("Polar", "Panda", "Brown")),
#'     z = pl$Enum(c("Polar", "Black", "Brown"))
#'   )
#' )
#'
#' # Same categories
#' df$with_columns(x_eq_y = pl$col("x") == pl$col("y"))
#'
#' # Different categories
#' tryCatch(
#'   df$with_columns(x_eq_z = pl$col("x") == pl$col("z")),
#'   error = function(e) e
#' )
DataType_Enum = function(categories) {
  .pr$DataType$new_enum(categories) |> unwrap()
}


#' Check whether the data type is a temporal type
#'
#' @return A logical value
#'
#' @examples
#' pl$Date$is_temporal()
#' pl$Float32$is_temporal()
DataType_is_temporal = use_extendr_wrapper

#' Check whether the data type is a logical type
#'
#' @return A logical value
DataType_is_logical = use_extendr_wrapper

#' Check whether the data type is a float type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$Float32$is_float()
#' pl$Int32$is_float()
DataType_is_float = use_extendr_wrapper

#' Check whether the data type is a numeric type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$Float32$is_numeric()
#' pl$Int32$is_numeric()
#' pl$String$is_numeric()
DataType_is_numeric = use_extendr_wrapper

#' Check whether the data type is an integer type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$Int32$is_integer()
#' pl$Float32$is_integer()
DataType_is_integer = use_extendr_wrapper

#' Check whether the data type is a signed integer type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$Int32$is_signed_integer()
#' pl$UInt32$is_signed_integer()
DataType_is_signed_integer = use_extendr_wrapper

#' Check whether the data type is an unsigned integer type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$UInt32$is_unsigned_integer()
#' pl$Int32$is_unsigned_integer()
DataType_is_unsigned_integer = use_extendr_wrapper

#' Check whether the data type is a null type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$Null$is_null()
#' pl$Float32$is_null()
DataType_is_null = use_extendr_wrapper

#' Check whether the data type is a binary type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$Binary$is_binary()
#' pl$Float32$is_binary()
DataType_is_binary = use_extendr_wrapper

#' Check whether the data type is a primitive type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$Float32$is_primitive()
#' pl$List()$is_primitive()
DataType_is_primitive = use_extendr_wrapper

#' Check whether the data type is a boolean type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$Boolean$is_bool()
#' pl$Float32$is_bool()
DataType_is_bool = use_extendr_wrapper

#' Check whether the data type is an array type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$Array(width = 2)$is_array()
#' pl$Float32$is_array()
DataType_is_array = use_extendr_wrapper

#' Check whether the data type is a list type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$List()$is_list()
#' pl$Float32$is_list()
DataType_is_list = use_extendr_wrapper

#' Check whether the data type is a nested type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$List()$is_nested()
#' pl$Array(width = 2)$is_nested()
#' pl$Float32$is_nested()
DataType_is_nested = use_extendr_wrapper

#' Check whether the data type is a temporal type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$Struct()$is_struct()
#' pl$Float32$is_struct()
DataType_is_struct = use_extendr_wrapper

#' Check whether the data type is an ordinal type
#'
#' @inherit DataType_is_temporal return
#'
#' @examples
#' pl$String$is_ord()
#' pl$Categorical()$is_ord()
DataType_is_ord = use_extendr_wrapper
