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
dim.LazyFrame = function(x, ...) x$collect()$shape

#' @export
#' @noRd
length.DataFrame = function(x, ...) x$width

#' @export
#' @noRd
length.Series = function(x, ...) x$len()

#' @export
#' @noRd
length.LazyFrame = function(x, ...) x$collect()$width

#' The Number of Rows of a DataFrame 
#' @param x DataFrame
#' @return Integer
#' @export
nrow.DataFrame = function(x) x$height

#' The Number of Rows of a LazyFrame 
#' @param x LazyFrame
#' @return Integer
#' @export
nrow.LazyFrame = function(x) x$collect()$height

#' The Number of Columns of a DataFrame 
#' @param x DataFrame
#' @return Integer
#' @export
ncol.DataFrame = function(x) x$height

#' The Number of Columns of a LazyFrame 
#' @param x LazyFrame
#' @return Integer
#' @export
ncol.LazyFrame = function(x) x$collect()$height

#' @export
#' @noRd
names.DataFrame = function(x) x$columns

# TODO: inefficient to collect, but attribute is missing
#' @export
#' @noRd
names.LazyFrame = function(x) x$collect()$columns

# TODO: inefficient to collect, but attribute is missing
#' @export
#' @noRd
as.data.frame.LazyFrame = function(x, ...) x$collect()$as_data_frame(...)

#' @export
#' @noRd
as.matrix.DataFrame = function(x, ...) as.matrix(x$as_data_frame(...))

# TODO: inefficient to collect, but attribute is missing
#' @export
#' @noRd
as.matrix.LazyFrame = function(x, ...) as.matrix(x$collect()$as_data_frame(...))

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

# Drop nulls from a DataFrame
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
