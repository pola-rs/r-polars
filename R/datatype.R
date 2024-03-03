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
#' pl$Series(1:4)$map_elements(\(x) letters[x], datatype = pl$dtypes$String)
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
#' @name is_polars_dtype
#' @noRd
#' @param x a candidate
#' @return a list DataType with an inner DataType
#' @examples .pr$env$is_polars_dtype(pl$Int64)
is_polars_dtype = function(x, include_unknown = FALSE) {
  inherits(x, "RPolarsDataType") && (x != pl$Unknown || include_unknown)
}

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
    Datetime = DataType_Datetime,
    List = DataType_List,
    Struct = DataType_Struct
  )
}


#' Data type representing a calendar date and time of day.
#'
#' The underlying representation of this type is a 64-bit signed integer.
#' The integer indicates the number of time units since the Unix epoch (1970-01-01 00:00:00).
#' The number can be negative to indicate datetimes before the epoch.
#' @param time_unit Unit of time. One of `"ms"`, `"us"` (default) or `"ns"`.
#' @param time_zone Time zone string, as defined in [OlsonNames()].
#' When using to match dtypes, can use `"*"` to check for Datetime columns that
#' have any timezone.
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

#' Create Struct DataType
#'
#' Struct DataType Constructor
#' @param ... RPolarsDataType objects
#' @return a list DataType with an inner DataType
#' @examples
#' # create a Struct-DataType
#' pl$Struct(pl$Boolean)
#' pl$Struct(foo = pl$Int32, bar = pl$Float64)
#'
#' # Find any DataType via pl$dtypes
#' print(pl$dtypes)
#'
#' # check if an element is any kind of Struct()
#' test = pl$Struct(pl$UInt64)
#' pl$same_outer_dt(test, pl$Struct())
#'
#' # `test` is a type of Struct, but it doesn't mean it is equal to an empty Struct
#' test == pl$Struct()
DataType_Struct = function(...) {
  result({
    largs = list2(...)
    if (length(largs) >= 1 && is.list(largs[[1]])) {
      largs = largs[[1]]
      element_name = "list element"
    } else {
      element_name = "positional argument"
    }
    mapply(
      names(largs) %||% character(length(largs)),
      largs,
      seq_along(largs),
      FUN = \(name, arg, i) {
        if (inherits(arg, "RPolarsDataType")) {
          return(pl$Field(name, arg))
        }
        if (inherits(arg, "RPolarsRField")) {
          return(arg)
        }
        stop(sprintf(
          "%s [%s] {name:'%s', value:%s} must either be a Field (pl$Field) or a named DataType",
          element_name, i, name, arg
        ))
      }, SIMPLIFY = FALSE
    )
  }) |>
    and_then(DataType$new_struct) |>
    unwrap("in pl$Struct:")
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
