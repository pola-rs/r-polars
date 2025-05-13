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
  if (missing(uint8)) {
    uint8 <- missing_arg()
  }
  if (missing(int64)) {
    int64 <- missing_arg()
  }
  if (missing(date)) {
    date <- missing_arg()
  }
  if (missing(time)) {
    time <- missing_arg()
  }
  if (missing(struct)) {
    struct <- missing_arg()
  }
  if (missing(decimal)) {
    decimal <- missing_arg()
  }
  if (missing(as_clock_class)) {
    as_clock_class <- missing_arg()
  }
  if (missing(ambiguous)) {
    ambiguous <- missing_arg()
  }
  if (missing(non_existent)) {
    non_existent <- missing_arg()
  }

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
  if (missing(uint8)) {
    uint8 <- missing_arg()
  }
  if (missing(int64)) {
    int64 <- missing_arg()
  }
  if (missing(date)) {
    date <- missing_arg()
  }
  if (missing(time)) {
    time <- missing_arg()
  }
  if (missing(decimal)) {
    decimal <- missing_arg()
  }
  if (missing(as_clock_class)) {
    as_clock_class <- missing_arg()
  }
  if (missing(ambiguous)) {
    ambiguous <- missing_arg()
  }
  if (missing(non_existent)) {
    non_existent <- missing_arg()
  }

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

  length_i <- length(i)
  x <- if (is_logical(i) && !anyNA(i) && length_i %in% c(1L, n_rows)) {
    # If non-NA logical vector, just passing it to $filter() is enough
    x$filter(i)
  } else {
    # Else, we need to use `select_rows_by_index()` and calculate the indices in R.
    # For LazyFrame (n_rows is NA), this branch is unreachable.
    # So this `seq_len()` should be safe.
    seq_n_rows <- seq_len(n_rows)
    idx <- if (is_logical(i)) {
      # If logical, `i` must be of length 1 or number of rows
      if (!length_i %in% c(1L, n_rows)) {
        abort(
          c(
            `!` = sprintf("Can't subset rows with `%s`.", deparse(i_arg)),
            i = sprintf(
              "Logical subscript `%s` must be size 1 or %s, not %s",
              deparse(i_arg),
              n_rows,
              length_i
            )
          ),
          call = error_env
        )
      } else {
        seq_n_rows[i]
      }
    } else {
      idx <- if (is_character(i)) {
        # Character case
        i
      } else {
        # Integer-ish case
        # Negative indices -> drop those rows
        # - Do not accept NA values in negative indices
        # - Do not accept mixing negative and positive indices
        if (length_i == 0L || suppressWarnings(min(i, na.rm = TRUE) >= 0)) {
          # Empty index or positive integer-ish
          # `0` is ignored
          i[i > 0L]
        } else if (suppressWarnings(max(i, na.rm = TRUE) <= 0)) {
          n_na <- sum(is.na(i))
          if (n_na > 0) {
            if (n_na < length_i) {
              # Negative indices containing NAs (Not allowed)
              abort(
                c(
                  sprintf("Can't subset rows with `%s`.", deparse(i_arg)),
                  x = "Negative locations can't have missing values.",
                  i = sprintf(
                    "Subscript `%s` has %s missing values at location %s.",
                    deparse(i_arg),
                    n_na,
                    oxford_comma(which(is.na(i)), final = "and")
                  )
                ),
                call = error_env
              )
            } else {
              # If all values are NA, i will be used as the index
              i
            }
          } else {
            # Negative indices without NAs
            setdiff(seq_n_rows, abs(i))
          }
        } else {
          # Mixing negative and positive indices (Not allowed)
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

      # Need to replace invalid indices with NA
      idx[!idx %in% seq_n_rows] <- NA
      # Ensure idx is numeric for further processing
      if (is_character(idx)) mode(idx) <- "numeric"
      idx
    }
    # Similar to Python Polars' _convert_series_to_indices,
    # but we already check idx values above, so just need to
    # convert to UInt32
    indices <- as_polars_series(idx - 1L)$cast(pl$UInt32, strict = TRUE)
    select_rows_by_index(x, indices)
  }

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
  to_select <- if (is_integerish(j)) {
    max_j <- suppressWarnings(max(j))
    min_j <- suppressWarnings(min(j))
    if (min_j >= 0) {
      # Empty index or positive integer-ish
      if (max_j > n_cols) {
        wrong_locs <- j[j > n_cols]
        abort(
          c(
            "Can't subset columns past the end.",
            i = sprintf("Location(s) %s don't exist.", oxford_comma(wrong_locs, final = "and")),
            i = sprintf("There are only %s columns.", n_cols)
          ),
          call = error_env
        )
      } else {
        cols[j]
      }
    } else if (max_j <= 0) {
      # Negative indices
      abs_j <- abs(j)
      if (min_j < -n_cols) {
        wrong_locs <- abs_j[abs_j > n_cols]
        abort(
          c(
            "Can't negate columns past the end.",
            i = sprintf("Location(s) %s don't exist.", oxford_comma(wrong_locs, final = "and")),
            i = sprintf("There are only %s columns.", n_cols)
          ),
          call = error_env
        )
      } else {
        cols[setdiff(seq_len(n_cols), abs_j)]
      }
    } else {
      # Mixing negative and positive indices (Not allowed)
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
  } else if (is_character(j)) {
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
  } else if (is_logical(j)) {
    length_j <- length(j)
    if (length_j %in% c(1L, n_cols)) {
      cols[j]
    } else {
      abort(
        c(
          `!` = sprintf("Can't subset columns with `%s`.", deparse(j_arg)),
          i = sprintf(
            "Logical subscript `%s` must be size 1 or %s, not %s",
            deparse(j_arg),
            n_cols,
            length_j
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
