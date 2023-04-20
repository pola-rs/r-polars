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

#' @export
#' @noRd
row.names.DataFrame = function(x) as.character(seq_len(nrow(x)))

#' @export
#' @noRd
dimnames.DataFrame = function(x) list(row.names(x), names(x))

# TODO: inefficient to collect, but attribute is missing
#' @export
#' @noRd
as.data.frame.LazyFrame = function(x, ...) x$collect()$to_data_frame(...)

#' @export
#' @noRd
as.matrix.DataFrame = function(x, ...) as.matrix(x$to_data_frame(...))

# TODO: inefficient to collect, but attribute is missing
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
