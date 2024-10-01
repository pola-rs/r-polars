# standalone-types-check.R like type checking functions

#' Check if the argument is a polars object inside a function
#'
#' Functions to check if the argument is a polars object.
#' If the argument is not the correct class, an informative error is thrown.
#' 
#' These functions are derived from the `standalone-types-check` functions
#' from the [rlang][rlang::rlang-package] package
#' (Can be installed with `usethis::use_standalone("r-lib/rlang", file = "types-check")`).
#'
#' @name check_polars
#' @inheritParams rlang::args_error_context
#' @param x An object to check.
#' @param ... Arguments passed to [rlang::abort()].
#' @param allow_null If `TRUE`, `NULL` is allowed as a valid input.
#' @return `NULL` invisibly.
#' @examples
#' sample_func <- function(x) {
#'   check_polars_df(x)
#'   TRUE
#' }
#' 
#' sample_func(as_polars_df(mtcars))
#' try(sample_func(mtcars))
NULL

#' @rdname check_polars
#' @export
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

#' @rdname check_polars
#' @export
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

#' @rdname check_polars
#' @export
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
