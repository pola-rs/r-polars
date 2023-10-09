#' @export
#' @noRd
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
#' @noRd
`[.LazyFrame` = `[.DataFrame`

#' @export
#' @noRd
head.DataFrame = function(x, n = 6L, ...) x$limit(n = n)

#' @export
#' @noRd
head.LazyFrame = head.DataFrame

#' @export
#' @noRd
tail.DataFrame = function(x, n = 6L, ...) x$tail(n = n)

#' @export
#' @noRd
tail.LazyFrame = tail.DataFrame

#' @export
#' @noRd
dim.DataFrame = function(x) x$shape

#' @export
#' @noRd
dim.LazyFrame = function(x) c(NA, x$width)

#' @export
#' @noRd
length.DataFrame = function(x) x$width

#' @export
#' @noRd
length.LazyFrame = length.DataFrame

#' @export
#' @noRd
length.Series = function(x) x$len()

#' @export
#' @noRd
names.DataFrame = function(x) x$columns

#' @export
#' @noRd
names.LazyFrame = function(x) x$columns

#' @export
#' @noRd
row.names.DataFrame = function(x) as.character(seq_len(nrow(x)))

#' @export
#' @noRd
dimnames.DataFrame = function(x) list(row.names(x), names(x))

#' @export
#' @noRd
dimnames.LazyFrame = function(x) list(NULL, names(x))

#' @export
#' @noRd
as.data.frame.LazyFrame = function(x, ...) x$collect()$to_data_frame(...)

#' @export
#' @noRd
as.matrix.DataFrame = function(x, ...) as.matrix(x$to_data_frame(...))

#' @export
#' @noRd
as.matrix.LazyFrame = function(x, ...) as.matrix(x$collect()$to_data_frame(...))

#' @export
#' @noRd
mean.DataFrame = function(x, ...) x$mean()

#' @export
#' @noRd
mean.LazyFrame = function(x, ...) x$mean()

#' @export
#' @importFrom stats median
#' @noRd
median.DataFrame = function(x, ...) x$median()

#' @export
#' @importFrom stats median
#' @noRd
median.LazyFrame = function(x, ...) x$median()

#' @export
#' @noRd
min.DataFrame = function(x, ...) x$min()

#' @export
#' @noRd
min.LazyFrame = function(x, ...) x$min()

#' @export
#' @noRd
min.Series = function(x, ...) x$min()

#' @export
#' @noRd
max.DataFrame = function(x, ...) x$max()

#' @export
#' @noRd
max.LazyFrame = function(x, ...) x$max()

#' @export
#' @noRd
as.vector.Series = function(x, mode) x$to_vector()


#' as.character for polars Series
#' @param x Series
#' @param ... Additional arguments are ignored.
#' @param str_length an integer. If specified,
#' utf8 or categorical type Series will be formatted to a string of this length.
#' @return character vector
#' @examples
#' s = pl$Series(c("foo", "barbaz"))
#' as.character(s)
#' as.character(s, str_length = 3)
#' @export
as.character.Series = function(x, ..., str_length = NULL) {
  if (is.numeric(str_length) && str_length > 0) {
    .pr$Series$to_fmt_char(x, str_length = str_length)
  } else {
    x$to_vector() |>
      as.character()
  }
}


#' Print Series
#' @export
#' @param x Series
#' @param ... not used
#' @keywords internal
#' @name Series_print
#' @noRd
#'
#' @return invisible(self)
#' @examples print(pl$Series(1:3))
print.Series = function(x, ...) {
  cat("polars Series: ")
  x$print()
  invisible(x)
}


#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
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

#' Immutable combine series
#' @param x a Series
#' @param ... Series(s) or any object into Series meaning `pl$Series(object)` returns a series
#' @return a combined Series
#' @details append datatypes has to match. Combine does not rechunk.
#' Read more about R vectors, Series and chunks in \code{\link[polars]{docs_translations}}:
#' @examples
#' s = c(pl$Series(1:5), 3:1, NA_integer_)
#' s$chunk_lengths() # the series contain three unmerged chunks
#' @export
#' @noRd
c.Series = \(x, ...) {
  l = list2(...)
  x = x$clone() # clone to retain an immutable api, append_mut is not immutable
  for (i in seq_along(l)) { # append each element of i being either Series or Into<Series>
    unwrap(.pr$Series$append_mut(x, wrap_s(l[[i]])), "in $c:")
  }
  x
}

#' Length of series
#' @param x a Series
#' @return the length as a double
#' @export
#' @noRd
length.Series = \(x) x$len()



#' @export
#' @noRd
max.Series = function(x, ...) x$max()

#' @export
#' @noRd
sum.DataFrame = function(x, ...) x$sum()

#' @export
#' @noRd
sum.LazyFrame = function(x, ...) x$sum()

#' @export
#' @noRd
sum.Series = function(x, ...) x$sum()

# Drop nulls from a LazyFrame
#' @export
#' @noRd
#' @param object LazyFrame
#' @param subset Character vector of column names to drop nulls from
#' @param ... Additional arguments are ignored.
#' @importFrom stats na.omit
#' @examples
# 'df <- pl$DataFrame(data.frame(a = c(NA, 2:10), b = c(1, NA, 3:10)))$lazy()
#' na.omit(df)
#' na.omit(df, subset = "a")
#' na.omit(df, subset = c("a", "b"))
na.omit.LazyFrame = function(object, subset = NULL, ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  object$drop_nulls(subset)
}

#' Drop nulls from a DataFrame
#' @export
#' @noRd
#' @param object DataFrame
#' @param subset Character vector of column names to drop nulls from
#' @param ... Additional arguments are ignored.
#' @importFrom stats na.omit
#' @examples
# 'df <- pl$DataFrame(data.frame(a = c(NA, 2:10), b = c(1, NA, 3:10)))
#' na.omit(df)
#' na.omit(df, subset = "a")
#' na.omit(df, subset = c("a", "b"))
na.omit.DataFrame = function(object, subset = NULL, ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  object$drop_nulls(subset)
}


#' Drop duplicate rows from this dataframe.
#' @export
#' @noRd
#' @param x DataFrame
#' @param subset Character vector of column names to drop nulls from
#' @param keep string: "first", "last", or "none".
#' @param incomparables: Not used. Here for S3 method consistency.
#' @param ... Additional arguments are ignored.
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


#' Drop duplicate rows from this dataframe.
#' @export
#' @noRd
#' @param x LazyFrame
#' @param subset Character vector of column names to drop nulls from
#' @param keep string: "first", "last", or "none".
#' @param incomparables: Not used. Here for S3 method consistency.
#' @param ... Additional arguments are ignored.
#' @examples
#' df = pl$DataFrame(
#'   x = as.numeric(c(1, 1:5)),
#'   y = as.numeric(c(1, 1:5)),
#'   z = as.numeric(c(1, 1, 1:4))
#' )$lazy()
#' unique(df)$collect()
unique.LazyFrame = function(x, incomparables = FALSE, subset = NULL, keep = "first", ...) {
  if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
    stop("subset must be NULL, a string, or a character vector")
  }
  x$unique(subset = subset, keep = keep)
}
