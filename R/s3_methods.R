#' @export
#' @noRd
head.DataFrame = function(x, n = 6L, ...) x$limit(n = n)

#' @export
#' @noRd
head.LazyFrame = head.DataFrame

#' @export
#' @noRd
tail.DataFrame = function(x, n = 6L, ...) x$limit(n = n)

#' @export
#' @noRd
tail.LazyFrame = tail.DataFrame

#' @export
#' @noRd
dim.DataFrame = function(x, ...) x$shape

# TODO: inefficient to collect, but attribute is missing
#' @export
#' @noRd
dim.LazyFrame = function(x, ...) x$collect()$shape

#' @export
#' @noRd
length.DataFrame = function(x, ...) x$width

# TODO: inefficient to collect, but attribute is missing
#' @export
#' @noRd
length.LazyFrame = function(x, ...) x$collect()$width

#' @export
#' @noRd
nrow.DataFrame = function(x, ...) x$height

# TODO: inefficient to collect, but attribute is missing
#' @export
#' @noRd
nrow.LazyFrame = function(x, ...) x$collect()$height

#' @export
#' @noRd
ncol.DataFrame = function(x, ...) x$height

# TODO: inefficient to collect, but attribute is missing
#' @export
#' @noRd
ncol.LazyFrame = function(x, ...) x$collect()$height

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

# #' @export
# #' @noRd
# mean.DataFrame = function(x, ...) x$mean()
#
# #' @export
# #' @noRd
# mean.LazyFrame = function(x, ...) x$mean()
#
# #' @export
# #' @noRd
# median.DataFrame = function(x, ...) x$median()
#
# #' @export
# #' @noRd
# median.LazyFrame = function(x, ...) x$median()
#
# #' @export
# #' @noRd
# min.DataFrame = function(x, ...) x$min()
#
# #' @export
# #' @noRd
# min.LazyFrame = function(x, ...) x$min()
#
# #' @export
# #' @noRd
# max.DataFrame = function(x, ...) x$max()
#
# #' @export
# #' @noRd
# max.LazyFrame = function(x, ...) x$max()
#
# #' @export
# #' @noRd
# sum.DataFrame = function(x, ...) x$sum()
#
# #' @export
# #' @noRd
# sum.LazyFrame = function(x, ...) x$sum()