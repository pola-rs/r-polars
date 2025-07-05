is_list_of_string <- function(
  x,
  ...,
  allow_empty = TRUE,
  allow_na = FALSE,
  allow_null = FALSE
) {
  is_list_of_string_impl <- function(
    x,
    ...,
    allow_empty = TRUE,
    allow_na = FALSE,
    allow_null = FALSE
  ) {
    for (i in seq_along(x)) {
      if (
        !.rlang_check_is_string(
          x[[i]],
          allow_empty = allow_empty,
          allow_na = allow_na,
          allow_null = allow_null
        )
      ) {
        return(FALSE)
      }
    }
    TRUE
  }

  is_list(x, n = NULL) &&
    is_list_of_string_impl(
      x,
      allow_empty = allow_empty,
      allow_na = allow_na,
      allow_null = allow_null
    )
}

check_list_of_string <- function(
  x,
  ...,
  allow_empty = TRUE,
  allow_na = FALSE,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (!missing(x)) {
    if (
      is_list_of_string(
        x,
        allow_empty = allow_empty,
        allow_na = allow_na,
        allow_null = allow_null
      )
    ) {
      return(invisible(NULL))
    }
  }

  stop_input_type(
    x,
    "a list of single strings",
    ...,
    allow_na = allow_na,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
}

# TODO: rename and rewrite to allow more types
check_date_or_datetime <- function(
  x,
  ...,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (!missing(x)) {
    if (is_polars_expr(x) || is_string(x)) {
      return(invisible(NULL))
    }
    if (allow_null && is_null(x)) {
      return(invisible(NULL))
    }
    maybe_dtype <- tryCatch(
      infer_polars_dtype(x),
      error = function(e) NULL
    )
    if (inherits(maybe_dtype, c("polars_dtype_date", "polars_dtype_datetime"))) {
      return(invisible(NULL))
    }
  }

  stop_input_type(
    x,
    "a single string, Polars expression, or something convertible to date/datetime type Series",
    ...,
    allow_na = FALSE,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
}


check_arg_is_1byte <- function(arg_name, arg, ..., can_be_empty = FALSE) {
  if (!is_string(arg)) {
    abort(paste0("`", arg_name, "` should be a single byte character."))
  }
  arg_byte_length <- nchar(arg, type = "bytes")
  if (isTRUE(can_be_empty)) {
    if (arg_byte_length > 1) {
      abort(paste0(
        "`",
        arg_name,
        "` = '",
        arg,
        "' should be a single byte character or empty, but is ",
        arg_byte_length,
        " bytes long."
      ))
    }
  } else if (arg_byte_length != 1) {
    abort(paste0(
      "`",
      arg_name,
      "` = '",
      arg,
      "' should be a single byte character, but is ",
      arg_byte_length,
      " bytes long."
    ))
  }
}

# Less strict than rlang::check_exclusive() since we allow arguments to be NULL
check_exclusive_or_null <- function(x, y) {
  x_name <- quo_name(enquo(x))
  y_name <- quo_name(enquo(y))
  if (!missing(x) && !missing(y) && !is.null(x) && !is.null(y)) {
    abort(
      paste0("Exactly one of `", x_name, "` or `", y_name, "` must be supplied."),
      call = caller_env()
    )
  }
}

# similar to arg_match0() but also allows for integerish values
arg_match_compat_level <- function(arg, arg_nm = caller_arg(arg), error_call = caller_env()) {
  if (is_character(arg)) {
    arg_match0(arg, c("newest", "oldest"), arg_nm = arg_nm, error_call = error_call)
  } else if (is_scalar_integerish(arg, finite = TRUE)) {
    arg
  } else {
    abort(
      sprintf(
        "`%s` must be a string or an integerish scalar value, got: %s",
        arg_nm,
        obj_type_friendly(arg)
      ),
      call = error_call
    )
  }
}

# Same as Python Polars' `_to_sink_target`
arg_to_sink_target <- function(arg, arg_nm = caller_arg(arg), error_call = caller_env()) {
  if (is_string(arg)) {
    arg
  } else if (is_polars_partitioning_scheme(arg)) {
    arg$`_r_partitioning`
  } else {
    abort(
      sprintf(
        "`%s` must be a string or a polars_partitioning_scheme, got: %s",
        arg_nm,
        obj_type_friendly(arg)
      ),
      call = error_call
    )
  }
}
