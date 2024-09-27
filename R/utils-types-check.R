# standalone-types-check.R like type checking functions

check_polars_dtype <- function(
    x,
    ...,
    allow_null = FALSE,
    arg = caller_arg(x),
    call = caller_env()) {
  if (!missing(x)) {
    if (is_polars_data_type(x)) {
      return(invisible(NULL))
    }
    if (allow_null && is_null(x)) {
      return(invisible(NULL))
    }
  }

  stop_input_type(
    x,
    "a polars data type",
    ...,
    allow_na = FALSE,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
}

check_polars_series <- function(
    x,
    ...,
    allow_null = FALSE,
    arg = caller_arg(x),
    call = caller_env()) {
  if (!missing(x)) {
    if (is_polars_series(x)) {
      return(invisible(NULL))
    }
    if (allow_null && is_null(x)) {
      return(invisible(NULL))
    }
  }

  stop_input_type(
    x,
    "a polars series",
    ...,
    allow_na = FALSE,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
}

check_polars_df <- function(
    x,
    ...,
    allow_null = FALSE,
    arg = caller_arg(x),
    call = caller_env()) {
  if (!missing(x)) {
    if (is_polars_df(x)) {
      return(invisible(NULL))
    }
    if (allow_null && is_null(x)) {
      return(invisible(NULL))
    }
  }

  stop_input_type(
    x,
    "a polars data frame",
    ...,
    allow_na = FALSE,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
}
