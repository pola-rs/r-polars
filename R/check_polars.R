# TODO: link to dtype docs
#' Check if the object is a polars object
#'
#' Functions to check if the object is a polars object.
#' `is_*` functions return `TRUE` of `FALSE` depending on the class of the object.
#' `check_*` functions throw an informative error if the object is not the correct class.
#' Suffixes are corresponding to the polars object classes:
#' - `*_dtype`: For polars data types.
#' - `*_df`: For [polars data frames][DataFrame].
#' - `*_expr`: For [polars expressions][Expr].
#' - `*_lf`: For [polars lazy frames][LazyFrame].
#' - `*_partitioning_scheme`: For [polars partitioning schemes][polars_partitioning_scheme].
#' - `*_selector`: For [polars selectors][cs].
#' - `*_series`: For [polars series][Series].
#'
#' `check_polars_*` functions are derived from the `standalone-types-check` functions
#' from the [rlang][rlang::rlang-package] package
#' (Can be installed with `usethis::use_standalone("r-lib/rlang", file = "types-check")`).
#'
#' @name check_polars
#' @aliases is_polars
#' @inheritParams rlang::args_error_context
#' @inheritParams rlang::is_list
#' @param x An object to check.
#' @param ... Arguments passed to [rlang::abort()].
#' @param allow_null If `TRUE`, `NULL` is allowed as a valid input.
#' @return
#' - `is_polars_*` functions return `TRUE` or `FALSE`.
#' - `check_polars_*` functions return `NULL` invisibly if the input is valid.
#' @seealso
#' - [infer_polars_dtype()]: Check if the object can be converted to a [Series].
#' @examples
#' is_polars_df(as_polars_df(mtcars))
#' is_polars_df(mtcars)
#'
#' # Use `check_polars_*` functions in a function
#' # to ensure the input is a polars object
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
is_polars_dtype <- function(x) {
  inherits(x, "polars_dtype")
}

#' @rdname check_polars
#' @export
is_polars_df <- function(x) {
  inherits(x, "polars_data_frame")
}

#' @rdname check_polars
#' @export
is_polars_expr <- function(x, ...) {
  inherits(x, "polars_expr")
}

#' @rdname check_polars
#' @export
is_polars_lf <- function(x) {
  inherits(x, "polars_lazy_frame")
}

#' @rdname check_polars
#' @export
is_polars_selector <- function(x, ...) {
  inherits(x, "polars_selector")
}

#' @rdname check_polars
#' @export
is_polars_series <- function(x) {
  inherits(x, "polars_series")
}

#' @rdname check_polars
#' @export
is_polars_partitioning_scheme <- function(x) {
  inherits(x, "polars_partitioning_scheme")
}

#' @rdname check_polars
#' @export
is_list_of_polars_dtype <- function(x, n = NULL) {
  is_list_of_polars_dtype_impl <- function(x) {
    for (i in seq_along(x)) {
      if (!is_polars_dtype(x[[i]])) {
        return(FALSE)
      }
    }
    TRUE
  }

  is_list(x, n = n) && is_list_of_polars_dtype_impl(x)
}

#' @rdname check_polars
#' @export
check_polars_dtype <- function(
  x,
  ...,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (!missing(x)) {
    if (is_polars_dtype(x)) {
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
check_polars_df <- function(
  x,
  ...,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
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

#' @rdname check_polars
#' @export
check_polars_expr <- function(
  x,
  ...,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (!missing(x)) {
    if (is_polars_expr(x)) {
      return(invisible(NULL))
    }
    if (allow_null && is_null(x)) {
      return(invisible(NULL))
    }
  }

  stop_input_type(
    x,
    "a polars expression",
    ...,
    allow_na = FALSE,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
}

#' @rdname check_polars
#' @export
check_polars_lf <- function(
  x,
  ...,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (!missing(x)) {
    if (is_polars_lf(x)) {
      return(invisible(NULL))
    }
    if (allow_null && is_null(x)) {
      return(invisible(NULL))
    }
  }

  stop_input_type(
    x,
    "a polars lazy frame",
    ...,
    allow_na = FALSE,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
}

#' @rdname check_polars
#' @export
check_polars_selector <- function(
  x,
  ...,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (!missing(x)) {
    if (is_polars_selector(x)) {
      return(invisible(NULL))
    }
    if (allow_null && is_null(x)) {
      return(invisible(NULL))
    }
  }

  stop_input_type(
    x,
    "a polars selector",
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
  call = caller_env()
) {
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
# nolint start: object_name_linter
check_polars_partitioning_scheme <- function(
  # nolint end: object_name_linter
  x,
  ...,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (!missing(x)) {
    if (is_polars_partitioning_scheme(x)) {
      return(invisible(NULL))
    }
    if (allow_null && is_null(x)) {
      return(invisible(NULL))
    }
  }

  stop_input_type(
    x,
    "a polars partitioning scheme",
    ...,
    allow_na = FALSE,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
}

# TODO: improve the error when x is a list of other objects
#' @rdname check_polars
#' @export
check_list_of_polars_dtype <- function(
  x,
  ...,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (!missing(x)) {
    if (is_list_of_polars_dtype(x)) {
      return(invisible(NULL))
    }
    if (allow_null && is_null(x)) {
      return(invisible(NULL))
    }
  }

  stop_input_type(
    x,
    "a list of polars data types",
    ...,
    allow_na = FALSE,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
}
