#' @export
print.polars_data_frame <- function(x, ...) {
  x$`_df`$as_str() |>
    writeLines()
  invisible(x)
}

#' @export
dim.polars_data_frame <- function(x) x$shape

#' @export
length.polars_data_frame <- function(x) x$width

#' @export
names.polars_data_frame <- function(x) x$columns

#' Export the polars object as an R list
#'
#' These S3 methods call [`as_polars_df(x, ...)$get_columns()`][dataframe__get_columns] with
#' [rlang::set_names()], or, `as_polars_df(x, ...)$to_struct()$to_r_vector(ensure_vector = TRUE)`
#' depending on the `as_series` argument.
#'
#' Arguments other than `x` and `as_series` are passed to
#' [`<Series>$to_r_vector()`][series__to_r_vector],
#' so they are ignored when `as_series=TRUE`.
#' @inheritParams series__to_r_vector
#' @param x A polars object
#' @param ... Passed to [as_polars_df()].
#' @param as_series Whether to convert each column to an [R vector][vector] or a [Series].
#' If `TRUE` (default), return a list of [Series], otherwise a list of [vectors][vector].
#' @return A [list]
#' @seealso
#' - [`<DataFrame>$get_columns()`][dataframe__get_columns]
#' @examples
#' df <- as_polars_df(list(a = 1:3, b = 4:6))
#'
#' as.list(df, as_series = TRUE)
#' as.list(df, as_series = FALSE)
#'
#' as.list(df$lazy(), as_series = TRUE)
#' as.list(df$lazy(), as_series = FALSE)
#' @export
#' @rdname s3-as.list
as.list.polars_data_frame <- function(
  x,
  ...,
  as_series = TRUE,
  uint8 = c("integer", "raw"),
  int64 = c("double", "character", "integer", "integer64"),
  date = c("Date", "IDate"),
  time = c("hms", "ITime"),
  struct = c("dataframe", "tibble"),
  decimal = c("double", "character"),
  as_clock_class = FALSE,
  ambiguous = c("raise", "earliest", "latest", "null"),
  non_existent = c("raise", "null")
) {
  if (isTRUE(as_series)) {
    # Ensure collect data because x may be a lazy frame
    x <- as_polars_df(x, ...)
    x$get_columns() |>
      set_names(x$columns)
  } else {
    as_polars_df(x, ...)$to_struct()$to_r_vector(
      ensure_vector = TRUE,
      uint8 = uint8,
      int64 = int64,
      date = date,
      time = time,
      struct = struct,
      decimal = decimal,
      as_clock_class = as_clock_class,
      ambiguous = ambiguous,
      non_existent = non_existent
    )
  }
}

#' Export the polars object as an R DataFrame
#'
#' This S3 method is a shortcut for
#' [`as_polars_df(x, ...)$to_struct()$to_r_vector(ensure_vector = FALSE, struct = "dataframe")`]
#' [series__to_r_vector].
#' @inheritParams as.list.polars_data_frame
#' @return An [R data frame][data.frame]
#' @examples
#' df <- as_polars_df(list(a = 1:3, b = 4:6))
#'
#' as.data.frame(df)
#' as.data.frame(df$lazy())
#' @export
#' @rdname s3-as.data.frame
as.data.frame.polars_data_frame <- function(
  x,
  ...,
  uint8 = c("integer", "raw"),
  int64 = c("double", "character", "integer", "integer64"),
  date = c("Date", "IDate"),
  time = c("hms", "ITime"),
  decimal = c("double", "character"),
  as_clock_class = FALSE,
  ambiguous = c("raise", "earliest", "latest", "null"),
  non_existent = c("raise", "null")
) {
  as_polars_df(x, ...)$to_struct()$to_r_vector(
    ensure_vector = FALSE,
    uint8 = uint8,
    int64 = int64,
    date = date,
    time = time,
    struct = "dataframe",
    decimal = decimal,
    as_clock_class = as_clock_class,
    ambiguous = ambiguous,
    non_existent = non_existent
  )
}

#' @exportS3Method utils::head
head.polars_data_frame <- function(x, n = 6L, ...) x$head(n = n)

#' @exportS3Method utils::tail
tail.polars_data_frame <- function(x, n = 6L, ...) x$tail(n = n)

# Try to match `tibble` behavior as much as possible, following
# https://tibble.tidyverse.org/articles/invariants.html#column-subsetting
# TODO: add document
#' @export
`[.polars_data_frame` <- function(x, i, j, ..., drop = FALSE) {
  # taken from tibble:::`[.tbl_df`
  cols <- names(x)

  # useful for error messages below
  called_from_lazy_s3_method <- identical(caller_fn(), `[.polars_lazy_frame`)
  if (isTRUE(called_from_lazy_s3_method)) {
    # Necessary so that e.g. `test[mean]` prints "Can't subset columns with
    # `mean`." and not "Can't subset columns with `j`."
    j_arg <- env_get(caller_env(), "j_arg", default = NULL)
    error_env <- caller_env()
  } else {
    j_arg <- substitute(j)
    error_env <- current_env()
  }
  i_arg <- substitute(i)

  if (missing(i)) {
    i <- TRUE
    i_arg <- NULL
  }
  if (missing(j)) {
    j <- cols
    j_arg <- NULL
  }

  n_real_args <- nargs() - !missing(drop)
  if (n_real_args <= 2L) {
    if (!missing(drop)) {
      warn(
        c(
          `!` = "`drop` argument ignored for subsetting a DataFrame with `x[j]`.",
          i = "It has an effect only for `x[i, j]`."
        )
      )
      drop <- FALSE
    }
    j <- if (!missing(i)) {
      i
    } else {
      cols
    }
    i <- TRUE
    j_arg <- i_arg
    i_arg <- NULL
  }

  i <- i %||% FALSE
  j <- j %||% character()

  # Same as `nrow(x)`, but `nrow()` calls `$collect_schema()` internally
  # which is expensive for LazyFrame, so we should avoid it.
  n_rows <- if (called_from_lazy_s3_method) {
    NA_integer_
  } else {
    x$height
  }
  n_cols <- length(cols)

  #### Rows -----------------------------------------------------

  # check accepted types for subsetting rows
  if (!is_bare_character(i) && !is_bare_numeric(i) && !is_bare_logical(i)) {
    abort(
      c(
        sprintf("Can't subset rows with `%s`.", deparse(i_arg)),
        i = sprintf(
          "`%s` must be logical, numeric, or character, not %s.",
          deparse(i_arg),
          obj_type_friendly(i)
        )
      ),
      call = error_env
    )
  }

  if (is_bare_numeric(i) && !is_integerish(i)) {
    abort(
      c(
        sprintf("Can't subset rows with `%s`.", deparse(i_arg)),
        x = "Can't convert from `i` <double> to <integer> due to loss of precision."
      ),
      call = error_env
    )
  }

  # If logical, `i` must be of length 1 or number of rows
  if (is_bare_logical(i)) {
    if (length(i) %in% c(1L, n_rows)) {
      idx <- i
    } else {
      abort(
        c(
          `!` = sprintf("Can't subset rows with `%s`.", deparse(i_arg)),
          i = sprintf(
            "Logical subscript `%s` must be size 1 or %s, not %s",
            deparse(i_arg),
            n_rows,
            length(i)
          )
        )
      )
    }
  } else {
    seq_n_rows <- seq_len(n_rows)
    # Negative indices -> drop those rows
    # Do not accept mixing negative and positive indices
    if (is_bare_numeric(i)) {
      # TODO: NA indices are ignored for now
      i <- i[!is.na(i)]
      if (all(i < 0)) {
        i <- setdiff(seq_n_rows, abs(i))
      } else if (any(i < 0) && any(i > 0)) {
        sign_start <- sign(i[i != 0])[1]
        loc <- if (sign_start == -1) {
          which(sign(i) == 1)[1]
        } else if (sign_start == 1) {
          which(sign(i) == -1)[1]
        }
        abort(
          c(
            `!` = sprintf("Can't subset rows with `%s`.", deparse(i_arg)),
            x = "Negative and positive locations can't be mixed.",
            i = sprintf(
              "Subscript `%s` has a %s value at location %s.",
              deparse(i_arg),
              if (sign_start == 1) "negative" else "positive",
              loc
            )
          ),
          call = error_env
        )
      }
    }

    idx <- seq_n_rows %in% i
  }

  x <- x$filter(pl$lit(idx))

  #### Columns -----------------------------------------------------

  # check accepted types for subsetting columns
  if (!is_bare_character(j) && !is_bare_numeric(j) && !is_bare_logical(j)) {
    abort(
      c(
        sprintf("Can't subset columns with `%s`.", deparse(j_arg)),
        i = sprintf(
          "`%s` must be logical, numeric, or character, not %s.",
          deparse(j_arg),
          obj_type_friendly(j)
        )
      ),
      call = error_env
    )
  }

  if (is_bare_numeric(j) && !is_integerish(j)) {
    abort(
      c(
        sprintf("Can't subset columns with `%s`.", deparse(j_arg)),
        x = "Can't convert from `j` <double> to <integer> due to loss of precision."
      ),
      call = error_env
    )
  }

  # NA values are accepted for rows but not columns.
  if (anyNA(j)) {
    na_val <- which(is.na(j))
    abort(
      c(
        sprintf("Can't subset columns with `%s`.", deparse(j_arg)),
        x = sprintf("Subscript `%s` can't contain missing values.", deparse(j_arg)),
        x = sprintf(
          "It has missing value(s) at location %s.",
          oxford_comma(na_val, final = "and")
        )
      ),
      call = error_env
    )
  }

  # Can be:
  # - numeric but cannot beyond the number of columns, and cannot mix positive
  #   and negative indices
  # - logical but must be of length 1 or number of columns
  # - character, should not contain non-existing column names
  to_select <- if (is_bare_numeric(j)) {
    wrong_locs <- j[j > n_cols]
    if (length(wrong_locs) > 0) {
      abort(
        c(
          "Can't subset columns past the end.",
          i = sprintf("Location(s) %s don't exist.", oxford_comma(wrong_locs, final = "and")),
          i = sprintf("There are only %s columns.", n_cols)
        ),
        call = error_env
      )
    }
    if (all(j < 0)) {
      j <- setdiff(seq_len(n_cols), abs(j))
    } else if (any(j < 0) && any(j > 0)) {
      sign_start <- sign(j[j != 0])[1]
      loc <- if (sign_start == -1) {
        which(sign(j) == 1)[1]
      } else if (sign_start == 1) {
        which(sign(j) == -1)[1]
      }
      abort(
        c(
          `!` = sprintf("Can't subset columns with `%s`.", deparse(j_arg)),
          x = "Negative and positive locations can't be mixed.",
          i = sprintf(
            "Subscript `%s` has a %s value at location %s.",
            deparse(j_arg),
            if (sign_start == 1) "negative" else "positive",
            loc
          )
        ),
        call = error_env
      )
    }
    cols[j]
  } else if (is_bare_character(j)) {
    non_existent_cols <- setdiff(j, cols)
    if (length(non_existent_cols) > 0L) {
      abort(
        c(
          "Can't subset columns that don't exist.",
          x = sprintf(
            "Columns %s don't exist.",
            oxford_comma(sprintf("`%s`", non_existent_cols), final = "and")
          )
        ),
        call = error_env
      )
    } else {
      j
    }
  } else if (is_bare_logical(j)) {
    if (length(j) %in% c(1L, n_cols)) {
      cols[j]
    } else {
      abort(
        c(
          `!` = sprintf("Can't subset columns with `%s`.", deparse(j_arg)),
          i = sprintf(
            "Logical subscript `%s` must be size 1 or %s, not %s",
            deparse(j_arg),
            n_cols,
            length(j)
          )
        ),
        call = error_env
      )
    }
  }

  x <- x$select(to_select)

  if (isTRUE(drop) && ncol(x) == 1L) {
    x$get_columns()[[1]]
  } else {
    x
  }
}
