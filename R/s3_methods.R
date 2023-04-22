#' @export
#' @noRd
`[.DataFrame` <- function(x, i, j, ..., drop = TRUE) {
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
                if (max(j) > ncol(x)) {
                    stop("Elements of `j` must be less than or equal to the number of columns.", call. = FALSE)
                }
                if (min(j) < 1) {
                    stop("Elements of `j` must be greater than or equal to 1.", call. = FALSE)
                }
                cols = x$columns[j]
            }
            x = do.call(x$select, lapply(cols, pl$col))
        } else {
            stop("`j` must be an atomic vector of class logical, character, or integer.", call. = FALSE)
        }
    }

    if (!missing(i)) {
        if (is.atomic(i) && is.vector(i)) {
            if (is.logical(i)) {
                if (length(i) != nrow(x)) {
                    stop(sprintf("`i` must be of length %s.", nrow(x)), call. = FALSE)
                }
                idx = i
            } else if (is.integer(i) || (is.numeric(i) && all(i %% 1 == 0))) {
                if (any(diff(i) < 0)) {
                    stop("Elements of `i` must be in increasing order.", call. = FALSE)
                }
                idx = seq_len(x$height) %in% i
            }
            x = x$filter(pl$lit(idx))
        } else {
            stop("`i` must be an atomic vector of class logical or integer.", call. = FALSE)
        }
    }

    if (drop && x$width == 1L) {
        x = x$to_series()
    }

    x
}

# TODO: un-comment when the `LazyFrame.columns` attribute is implemented
# #' @export
# #' @noRd
# `[.LazyFrame` <- `[.DataFrame`

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
dim.DataFrame = function(x, ...) x$shape

#' @export
#' @noRd
length.DataFrame = function(x, ...) x$width

#' @export
#' @noRd
length.Series = function(x, ...) x$len()

#' The Number of Rows of a DataFrame 
#' @param x DataFrame
#' @return Integer
#' @export
nrow.DataFrame = function(x) x$height

#' The Number of Columns of a DataFrame 
#' @param x DataFrame
#' @return Integer
#' @export
ncol.DataFrame = function(x) x$height

#' @export
#' @noRd
names.DataFrame = function(x) x$columns

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

#' @param x Series
#' @param format a logical. If `TRUE`, the Series will be formatted.
#' @param str_length an integer. If `format = TRUE`,
#' utf8 or categorical type Series will be formatted to a string of this length.
#' @examples
#' s = pl$Series(c("foo", "barbaz"))
#' as.character(s)
#' as.character(s, format = TRUE)
#' as.character(s, format = TRUE, str_length = 3)
#' @export
as.character.Series = function(x, ..., format = FALSE, str_length = 15) {
    if (isTRUE(format)) {
        .pr$Series$to_fmt_char(x, str_length = str_length)
    } else {
        x$to_vector() |>
            as.character()
    }
}

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
#'     x = as.numeric(c(1, 1:5)),
#'     y = as.numeric(c(1, 1:5)),
#'     z = as.numeric(c(1, 1, 1:4)))
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
#'     x = as.numeric(c(1, 1:5)),
#'     y = as.numeric(c(1, 1:5)),
#'     z = as.numeric(c(1, 1, 1:4)))$lazy()
#' unique(df)$collect()
unique.LazyFrame = function(x, incomparables = FALSE, subset = NULL, keep = "first", ...) {
    if (!is.null(subset) && !is.atomic(subset) && !is.character(subset)) {
        stop("subset must be NULL, a string, or a character vector")
    }
    x$unique(subset = subset, keep = keep)
}
