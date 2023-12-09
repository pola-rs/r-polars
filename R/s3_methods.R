#' Extract Parts of a Polars Object
#'
#' Mimics the behavior of [`x[i, j, drop = TRUE]`][Extract] for [data.frame] or R vector.
#'
#' `<Series>[i]` is equivalent to `pl$select(<Series>)[i, , drop = TRUE]`.
#' @rdname S3_extract
#' @param x A [DataFrame][DataFrame_class], [LazyFrame][LazyFrame_class], or [Series][Series_class]
#' @param i Rows to select. Integer vector, logical vector, or an [Expression][Expr_class].
#' @param j Columns to select. Integer vector, logical vector, character vector, or an [Expression][Expr_class].
#' For LazyFrames, only an Expression can be used.
#' @param drop Convert to a Polars Series if only one column is selected.
#' For LazyFrames, if the result has one column and `drop = TRUE`, an error will occur.
#' @seealso
#' [`<DataFrame>$select()`][DataFrame_select],
#' [`<LazyFrame>$select()`][LazyFrame_select],
#' [`<DataFrame>$filter()`][DataFrame_filter],
#' [`<LazyFrame>$filter()`][LazyFrame_filter]
#' @examples
#' df = pl$DataFrame(data.frame(a = 1:3, b = letters[1:3]))
#' lf = df$lazy()
#'
#' # Select a row
#' df[1, ]
#'
#' # If only `i` is specified, it is treated as `j`
#' # Select a column
#' df[1]
#'
#' # Select a column by name (and convert to a Series)
#' df[, "b"]
#'
#' # Can use Expression for filtering and column selection
#' lf[pl$col("a") >= 2, pl$col("b")$alias("new"), drop = FALSE] |>
#'   as.data.frame()
#' @export
`[.RPolarsDataFrame` = function(x, i, j, drop = TRUE) {
  uw = \(res) unwrap(res, "in `[` (Extract):")

  # Special case for only `i` being specified
  only_i = ((nargs() - !missing(drop)) == 2)
  if (only_i) {
    j = i
    i = NULL
    drop = !missing(drop) && drop
  }

  if (!missing(i) && !isTRUE(only_i)) {
    # `i == NULL` means return 0 rows
    i = i %||% 0

    if (is.atomic(i) && is.vector(i)) {
      if (inherits(x, "RPolarsLazyFrame")) {
        Err_plain("Row selection using vector is not supported for LazyFrames.") |> uw()
      }

      if (is.logical(i)) {
        # nrow() not available for LazyFrame
        if (inherits(x, "RPolarsDataFrame") && length(i) != nrow(x)) {
          stop(sprintf("`i` must be of length %s.", nrow(x)), call. = FALSE)
        }
        idx = i
      } else if (is.integer(i) || (is.numeric(i) && all(i %% 1 == 0))) {
        negative = any(i < 0)
        if (isTRUE(negative)) {
          if (any(i > 0)) {
            Err_plain("Elements of `i` must be all postive or all negative.") |> uw()
          }
          idx = !seq_len(x$height) %in% abs(i)
        } else {
          if (any(diff(i) < 0)) {
            Err_plain("Elements of `i` must be in increasing order.") |> uw()
          }
          idx = seq_len(x$height) %in% i
        }
      }
      x = x$filter(pl$lit(idx))
    } else if (identical(class(i), "RPolarsExpr")) {
      x = x$filter(i)
    } else {
      Err_plain("`i` must be an Expr or an atomic vector of class logical or integer.") |> uw()
    }
  }

  if (!missing(j)) {
    if (is.atomic(j) && is.vector(j)) {
      if (is.logical(j)) {
        if (length(j) != ncol(x)) {
          Err_plain(sprintf("`j` must be of length %s.", ncol(x))) |> uw()
        }
        cols = x$columns[j]
      } else if (is.character(j)) {
        if (!all(j %in% x$columns)) {
          Err_plain("Column(s) not found: ", paste(j[!j %in% x$columns], collapse = ", ")) |> uw()
        }
        cols = j
      } else if (is.integer(j) || (is.numeric(j) && all(j %% 1 == 0))) {
        if (max(abs(j)) > ncol(x)) {
          Err_plain("Elements of `j` must be less than or equal to the number of columns.") |> uw()
        }
        negative = any(j < 0)
        if (isTRUE(negative)) {
          if (any(j > 0)) {
            Err_plain("Elements of `j` must be all postive or all negative.") |> uw()
          }
          cols = x$columns[!seq_along(x$columns) %in% abs(j)]
        } else {
          cols = x$columns[j]
        }
      }
      x = do.call(x$select, lapply(cols, pl$col))
    } else if (identical(class(j), "RPolarsExpr")) {
      x = x$select(j)
    } else {
      Err_plain("`j` must be an Expr or an atomic vector of class logical, character, or integer.") |> uw()
    }
  }

  if (drop && x$width == 1L) {
    if (inherits(x, "RPolarsLazyFrame")) {
      Err_plain(
        "Single column conversion to a Series using brackets is not supported for LazyFrames.\n",
        "Please set `drop = FALSE` to prevent conversion or use $collect() before using brackets."
      ) |> uw()
    }
    x = x$to_series()
  }

  x
}

#' @export
#' @rdname S3_extract
`[.RPolarsLazyFrame` = `[.RPolarsDataFrame`

#' @export
#' @rdname S3_extract
`[.RPolarsSeries` = function(x, i) {
  pl$select(x)[i, , drop = TRUE]
}

#' Take the first n rows
#'
#' @param x A [DataFrame][DataFrame_class] or [LazyFrame][LazyFrame_class]
#' @param n Number of rows
#' @param ... Not used
#'
#' @export
#' @rdname S3_head
head.RPolarsDataFrame = function(x, n = 6L, ...) x$limit(n = n)

#' @export
#' @rdname S3_head
head.RPolarsLazyFrame = head.RPolarsDataFrame

#' Take the last n rows
#'
#' @param x A [DataFrame][DataFrame_class] or [LazyFrame][LazyFrame_class]
#' @param n Number of rows
#' @param ... Not used
#'
#' @export
#' @rdname S3_tail
tail.RPolarsDataFrame = function(x, n = 6L, ...) x$tail(n = n)

#' @export
#' @rdname S3_tail
tail.RPolarsLazyFrame = tail.RPolarsDataFrame

#' Get the dimensions
#'
#' @param x A [DataFrame][DataFrame_class] or [LazyFrame][LazyFrame_class]
#'
#' @export
#' @rdname S3_dim
dim.RPolarsDataFrame = function(x) as.integer(x$shape)

#' @export
#' @rdname S3_dim
dim.RPolarsLazyFrame = function(x) c(NA, x$width)

#' Get the length
#'
#' @param x A [DataFrame][DataFrame_class], [LazyFrame][LazyFrame_class], or
#' [Series][Series_class]
#'
#' @export
#' @rdname S3_length
length.RPolarsDataFrame = function(x) x$width

#' @export
#' @rdname S3_length
length.RPolarsLazyFrame = length.RPolarsDataFrame

#' @export
#' @rdname S3_length
length.RPolarsSeries = function(x) x$len()

#' Get the column names
#'
#' @param x A [DataFrame][DataFrame_class] or [LazyFrame][LazyFrame_class]
#'
#' @export
#' @rdname S3_names
names.RPolarsDataFrame = function(x) x$columns

#' @export
#' @rdname S3_names
names.RPolarsLazyFrame = function(x) x$columns

#' Get the row names
#'
#' @param x A Polars DataFrame
#'
#' @export
#' @rdname S3_rownames
row.names.RPolarsDataFrame = function(x) as.character(seq_len(nrow(x)))

#' Get the row and column names
#'
#' @param x A [DataFrame][DataFrame_class] or [LazyFrame][LazyFrame_class]
#'
#' @export
#' @rdname S3_dimnames
dimnames.RPolarsDataFrame = function(x) list(row.names(x), names(x))

#' @export
#' @rdname S3_dimnames
dimnames.RPolarsLazyFrame = function(x) list(NULL, names(x))

#' Convert to a data.frame
#'
#' @param x A [DataFrame][DataFrame_class] or [LazyFrame][LazyFrame_class]
#' @param ... Any arguments passed to [data.frame()].
#'
#' @export
#' @rdname S3_as.data.frame
as.data.frame.RPolarsDataFrame = function(x, ...) x$to_data_frame(...)


#' @export
#' @rdname S3_as.data.frame
as.data.frame.RPolarsLazyFrame = function(x, ...) x$collect()$to_data_frame(...)

#' Convert to a matrix
#'
#' @inheritParams as.data.frame.RPolarsDataFrame
#'
#' @export
#' @rdname S3_as.matrix
as.matrix.RPolarsDataFrame = function(x, ...) as.matrix(as.data.frame(x, ...))

#' @export
#' @rdname S3_as.matrix
as.matrix.RPolarsLazyFrame = as.matrix.RPolarsDataFrame

#' Compute the mean
#'
#' @param x A [DataFrame][DataFrame_class], [LazyFrame][LazyFrame_class], or
#' [Series][Series_class]
#' @param ... Not used.
#'
#' @export
#' @rdname S3_mean
mean.RPolarsDataFrame = function(x, ...) x$mean()

#' @export
#' @rdname S3_mean
mean.RPolarsLazyFrame = function(x, ...) x$mean()

#' @export
#' @rdname S3_mean
mean.RPolarsSeries = function(x, ...) x$mean()

#' Compute the median
#'
#' @param x A [DataFrame][DataFrame_class], [LazyFrame][LazyFrame_class], or
#' [Series][Series_class]
#' @param ... Not used.
#'
#' @export
#' @rdname S3_median
#' @importFrom stats median
median.RPolarsDataFrame = function(x, ...) x$median()

#' @export
#' @importFrom stats median
#' @rdname S3_median
median.RPolarsLazyFrame = function(x, ...) x$median()

#' @export
#' @importFrom stats median
#' @rdname S3_median
median.RPolarsSeries = function(x, ...) x$median()

#' Compute the minimum value
#'
#' @param x A [DataFrame][DataFrame_class], [LazyFrame][LazyFrame_class], or
#' [Series][Series_class]
#' @param ... Not used.
#'
#' @export
#' @rdname S3_min
min.RPolarsDataFrame = function(x, ...) x$min()

#' @export
#' @rdname S3_min
min.RPolarsLazyFrame = function(x, ...) x$min()

#' @export
#' @rdname S3_min
min.RPolarsSeries = function(x, ...) x$min()

#' Compute the maximum value
#'
#' @param x A [DataFrame][DataFrame_class], [LazyFrame][LazyFrame_class], or
#' [Series][Series_class]
#' @param ... Not used.
#'
#' @export
#' @rdname S3_max
max.RPolarsDataFrame = function(x, ...) x$max()

#' @export
#' @rdname S3_max
max.RPolarsLazyFrame = function(x, ...) x$max()

#' @export
#' @rdname S3_max
max.RPolarsSeries = function(x, ...) x$max()

#' Compute the sum
#'
#' @param x A [DataFrame][DataFrame_class], [LazyFrame][LazyFrame_class], or
#' [Series][Series_class]
#' @param ... Not used.
#'
#' @export
#' @rdname S3_sum
sum.RPolarsDataFrame = function(x, ...) x$sum()

#' @export
#' @rdname S3_sum
sum.RPolarsLazyFrame = function(x, ...) x$sum()

#' @export
#' @rdname S3_sum
sum.RPolarsSeries = function(x, ...) x$sum()

#' Convert to a vector
#'
#' @param x A Polars Series
#' @param mode Not used.
#' @export
#' @rdname S3_as.vector
as.vector.RPolarsSeries = function(x, mode) x$to_vector()


#' Convert to a character vector
#'
#' @param x A Polars Series
#' @param ... Not used.
#' @param str_length An integer. If specified, utf8 or categorical type Series
#' will be formatted to a string of this length.
#'
#' @export
#' @rdname S3_as.character
#' @examples
#' s = pl$Series(c("foo", "barbaz"))
#' as.character(s)
#' as.character(s, str_length = 3)
as.character.RPolarsSeries = function(x, ..., str_length = NULL) {
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
print.RPolarsSeries = function(x, ...) {
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
#' @inherit .DollarNames.RPolarsDataFrame return
#' @keywords internal
.DollarNames.RPolarsSeries = function(x, pattern = "") {
  get_method_usages(RPolarsSeries, pattern = pattern)
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
c.RPolarsSeries = \(x, ...) {
  l = list2(...)
  x = x$clone() # clone to retain an immutable api, append_mut is not immutable
  for (i in seq_along(l)) { # append each element of i being either Series or Into<Series>
    unwrap(.pr$Series$append_mut(x, wrap_s(l[[i]])), "in $c:")
  }
  x
}

#' Drop missing values
#'
#' @param object A [DataFrame][DataFrame_class] or [LazyFrame][LazyFrame_class]
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
na.omit.RPolarsLazyFrame = function(object, subset = NULL, ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  object$drop_nulls(subset)
}

#' @export
#' @rdname S3_na.omit
na.omit.RPolarsDataFrame = function(object, subset = NULL, ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  object$drop_nulls(subset)
}

#' Drop duplicated rows
#'
#' @param x A [DataFrame][DataFrame_class] or [LazyFrame][LazyFrame_class]
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
unique.RPolarsDataFrame = function(x, incomparables = FALSE, subset = NULL, keep = "first", ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  x$unique(subset = subset, keep = keep)
}

#' @export
#' @rdname S3_unique
unique.RPolarsLazyFrame = function(x, incomparables = FALSE, subset = NULL, keep = "first", ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  x$unique(subset = subset, keep = keep)
}
