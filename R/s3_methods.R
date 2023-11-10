#' Take a subset of rows and columns
#'
#' @param x A Polars DataFrame or LazyFrame
#' @param i Rows to select
#' @param j Columns to select, either by index or by name.
#' @param ... Not used.
#' @param drop Convert to a Polars Series if only one column is selected.
#'
#' @export
#' @rdname S3_subset
`[.DataFrame` = function(x, i, j, ..., drop = TRUE) {
  # selecting `j` is usually faster, so we start here.
  if (!missing(j)) {
    if (is.atomic(j) && is.vector(j)) {
      if (is.logical(j)) {
        if (length(j) != ncol(x)) {
          stop(sprintf("`j` must be of length %s.", ncol(x)), call. = FALSE)
        }
        cols = x$columns[j]
      } else if (is.character(j)) {
        if (!all(j %in% x$columns)) {
          stop("Column(s) not found: ", paste(j[!j %in% x$columns], collapse = ", "), call. = FALSE)
        }
        cols = j
      } else if (is.integer(j) || (is.numeric(j) && all(j %% 1 == 0))) {
        if (max(abs(j)) > ncol(x)) {
          stop("Elements of `j` must be less than or equal to the number of columns.", call. = FALSE)
        }
        negative = any(j < 0)
        if (isTRUE(negative)) {
          if (any(j > 0)) {
            stop("Elements of `j` must be all postive or all negative.", call. = FALSE)
          }
          cols = x$columns[!seq_along(x$columns) %in% abs(j)]
        } else {
          cols = x$columns[j]
        }
      }
      x = do.call(x$select, lapply(cols, pl$col))
    } else {
      stop("`j` must be an atomic vector of class logical, character, or integer.", call. = FALSE)
    }
  }

  if (!missing(i)) {
    if (inherits(x, "LazyFrame")) {
      stop("Row selection using brackets is not supported for LazyFrames.", call. = FALSE)
    }
    if (is.atomic(i) && is.vector(i)) {
      if (is.logical(i)) {
        # nrow() not available for LazyFrame
        if (inherits(x, "DataFrame") && length(i) != nrow(x)) {
          stop(sprintf("`i` must be of length %s.", nrow(x)), call. = FALSE)
        }
        idx = i
      } else if (is.integer(i) || (is.numeric(i) && all(i %% 1 == 0))) {
        negative = any(i < 0)
        if (isTRUE(negative)) {
          if (any(i > 0)) {
            stop("Elements of `j` must be all postive or all negative.", call. = FALSE)
          }
          idx = !seq_len(x$height) %in% abs(i)
        } else {
          if (any(diff(i) < 0)) {
            stop("Elements of `i` must be in increasing order.", call. = FALSE)
          }
          idx = seq_len(x$height) %in% i
        }
      }
      x = x$filter(pl$lit(idx))
    } else {
      stop("`i` must be an atomic vector of class logical or integer.", call. = FALSE)
    }
  }

  if (drop && x$width == 1L) {
    if (inherits(x, "LazyFrame")) {
      stop(
        "Single column conversion to a Series using brackets is not supported for LazyFrames.\n",
        "Please set `drop = FALSE` to prevent conversion or use $collect() before using brackets.",
        call. = FALSE
      )
    }
    x = x$to_series()
  }

  x
}

#' @export
#' @rdname S3_subset
`[.LazyFrame` = `[.DataFrame`

#' Take the first n rows
#'
#' @param x A Polars DataFrame or LazyFrame
#' @param n Number of rows
#' @param ... Not used
#'
#' @export
#' @rdname S3_head
head.DataFrame = function(x, n = 6L, ...) x$limit(n = n)

#' @export
#' @rdname S3_head
head.LazyFrame = head.DataFrame

#' Take the last n rows
#'
#' @param x A Polars DataFrame or LazyFrame
#' @param n Number of rows
#' @param ... Not used
#'
#' @export
#' @rdname S3_tail
tail.DataFrame = function(x, n = 6L, ...) x$tail(n = n)

#' @export
#' @rdname S3_tail
tail.LazyFrame = tail.DataFrame

#' Get the dimensions
#'
#' @param x A Polars DataFrame or LazyFrame
#'
#' @export
#' @rdname S3_dim
dim.DataFrame = function(x) x$shape

#' @export
#' @rdname S3_dim
dim.LazyFrame = function(x) c(NA, x$width)

#' Get the length
#'
#' @param x A Polars DataFrame, LazyFrame, or Series
#'
#' @export
#' @rdname S3_length
length.DataFrame = function(x) x$width

#' @export
#' @rdname S3_length
length.LazyFrame = length.DataFrame

#' @export
#' @rdname S3_length
length.Series = function(x) x$len()

#' Get the column names
#'
#' @param x A Polars DataFrame or LazyFrame
#'
#' @export
#' @rdname S3_names
names.DataFrame = function(x) x$columns

#' @export
#' @rdname S3_names
names.LazyFrame = function(x) x$columns

#' Get the row names
#'
#' @param x A Polars DataFrame
#'
#' @export
#' @rdname S3_rownames
row.names.DataFrame = function(x) as.character(seq_len(nrow(x)))

#' Get the row and column names
#'
#' @param x A Polars DataFrame or LazyFrame
#'
#' @export
#' @rdname S3_dimnames
dimnames.DataFrame = function(x) list(row.names(x), names(x))

#' @export
#' @rdname S3_dimnames
dimnames.LazyFrame = function(x) list(NULL, names(x))

#' Convert to a data.frame
#'
#' @param x A Polars DataFrame or LazyFrame
#' @param ... Any arguments passed to `data.frame()`.
#'
#' @export
#' @rdname S3_as.data.frame
as.data.frame.DataFrame = function(x, ...) x$to_data_frame(...)


#' @export
#' @rdname S3_as.data.frame
as.data.frame.LazyFrame = function(x, ...) x$collect()$to_data_frame(...)

#' Convert to a matrix
#'
#' @param x A Polars DataFrame or LazyFrame
#' @param ... Not used.
#'
#' @export
#' @rdname S3_as.matrix
as.matrix.DataFrame = function(x, ...) as.matrix(x$to_data_frame(...))

#' @export
#' @rdname S3_as.matrix
as.matrix.LazyFrame = function(x, ...) as.matrix(x$collect()$to_data_frame(...))

#' Compute the mean
#'
#' @param x A Polars DataFrame, LazyFrame, or Series
#' @param ... Not used.
#'
#' @export
#' @rdname S3_mean
mean.DataFrame = function(x, ...) x$mean()

#' @export
#' @rdname S3_mean
mean.LazyFrame = function(x, ...) x$mean()

#' @export
#' @rdname S3_mean
mean.Series = function(x, ...) x$mean()

#' Compute the median
#'
#' @param x A Polars DataFrame, LazyFrame, or Series
#' @param ... Not used.
#'
#' @export
#' @rdname S3_median
#' @importFrom stats median
median.DataFrame = function(x, ...) x$median()

#' @export
#' @importFrom stats median
#' @rdname S3_median
median.LazyFrame = function(x, ...) x$median()

#' @export
#' @importFrom stats median
#' @rdname S3_median
median.Series = function(x, ...) x$median()

#' Compute the minimum value
#'
#' @param x A Polars DataFrame, LazyFrame, or Series
#' @param ... Not used.
#'
#' @export
#' @rdname S3_min
min.DataFrame = function(x, ...) x$min()

#' @export
#' @rdname S3_min
min.LazyFrame = function(x, ...) x$min()

#' @export
#' @rdname S3_min
min.Series = function(x, ...) x$min()

#' Compute the maximum value
#'
#' @param x A Polars DataFrame, LazyFrame, or Series
#' @param ... Not used.
#'
#' @export
#' @rdname S3_max
max.DataFrame = function(x, ...) x$max()

#' @export
#' @rdname S3_max
max.LazyFrame = function(x, ...) x$max()

#' @export
#' @rdname S3_max
max.Series = function(x, ...) x$max()

#' Compute the sum
#'
#' @param x A Polars DataFrame, LazyFrame, or Series
#' @param ... Not used.
#'
#' @export
#' @rdname S3_sum
sum.DataFrame = function(x, ...) x$sum()

#' @export
#' @rdname S3_sum
sum.LazyFrame = function(x, ...) x$sum()

#' @export
#' @rdname S3_sum
sum.Series = function(x, ...) x$sum()

#' Convert to a vector
#'
#' @param x A Polars Series
#'
#' @export
#' @rdname S3_as.vector
as.vector.Series = function(x) x$to_vector()


#' Convert to a character vector
#'
#' @param x A Polars Series
#' @param ... Not used.
#' @param str_length An integer. If specified, utf8 or categorical type Series
#' will be formatted to a string of this length.
#'
#' @export
#' @rdname S3_as.character
as.character.Series = function(x, ..., str_length = NULL) {
  if (is.numeric(str_length) && str_length > 0) {
    .pr$Series$to_fmt_char(x, str_length = str_length)
  } else {
    x$to_vector() |>
      as.character()
  }
}

#' Print values
#'
#' @param x A Polars Series
#' @param ... Not used
#'
#' @rdname S3_print
#' @export
print.Series = function(x, ...) {
  cat("polars Series: ")
  x$print()
  invisible(x)
}

#' Auto complete $-access into a polars object
#'
#' Called by the interactive R session internally.
#'
#' @param x Series
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @noRd
#' @inherit .DollarNames.DataFrame return
#' @keywords internal
.DollarNames.Series = function(x, pattern = "") {
  get_method_usages(Series, pattern = pattern)
}

#' Combine to a Series
#'
#' @param x A Polars Series
#' @param ... Series(s) or any object that can be converted to a Series.
#'
#' @return a combined Series
#' @details
#' All objects must have the same datatype. Combining does not rechunk. Read more
#' about R vectors, Series and chunks in \code{\link[polars]{docs_translations}}:
#' @examples
#' s = c(pl$Series(1:5), 3:1, NA_integer_)
#' s$chunk_lengths() # the series contain three unmerged chunks
#' @export
#' @rdname S3_c
c.Series = \(x, ...) {
  l = list2(...)
  x = x$clone() # clone to retain an immutable api, append_mut is not immutable
  for (i in seq_along(l)) { # append each element of i being either Series or Into<Series>
    unwrap(.pr$Series$append_mut(x, wrap_s(l[[i]])), "in $c:")
  }
  x
}

#' Drop missing values
#'
#' @param object A Polars DataFrame or LazyFrame
#' @param subset Character vector of column names to drop missing values from.
#' @param ... Not used.
#'
#' @importFrom stats na.omit
#' @export
#' @rdname S3_na.omit
#' @examples
#' df = pl$DataFrame(data.frame(a = c(NA, 2:10), b = c(1, NA, 3:10)))$lazy()
#' na.omit(df)
#' na.omit(df, subset = "a")
#' na.omit(df, subset = c("a", "b"))
na.omit.LazyFrame = function(object, subset = NULL, ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  object$drop_nulls(subset)
}

#' @export
#' @rdname S3_na.omit
na.omit.DataFrame = function(object, subset = NULL, ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  object$drop_nulls(subset)
}

#' Drop duplicated rows
#'
#' @param x A Polars DataFrame or LazyFrame
#' @param subset Character vector of column names to drop duplicated values from.
#' @param keep Either `"first"`, `"last"`, or `"none"`.
#' @param incomparables Not used.
#' @param ... Not used.
#'
#' @export
#' @rdname S3_unique
#' @examples
#' df = pl$DataFrame(
#'   x = as.numeric(c(1, 1:5)),
#'   y = as.numeric(c(1, 1:5)),
#'   z = as.numeric(c(1, 1, 1:4))
#' )
#' unique(df)
unique.DataFrame = function(x, incomparables = FALSE, subset = NULL, keep = "first", ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  x$unique(subset = subset, keep = keep)
}

#' @export
#' @rdname S3_unique
unique.LazyFrame = function(x, incomparables = FALSE, subset = NULL, keep = "first", ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  x$unique(subset = subset, keep = keep)
}
