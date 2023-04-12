# TODO:
# implement attributes and methods instead of LazyFrame()$collect()
# uncomment and test max.DataFrame() et al. when the PR is merged.
# uncomment tail() when the PR is merged.
# require new methods/attributes:
#   - is.null
#   - na.omit
#   - colnames

#' @export
head.DataFrame = function(x, n = 6L, ...) x$limit(n = n)

#' @export
head.LazyFrame = head.DataFrame

# #' @export
# tail.DataFrame = function(x, n = 6L, ...) x$limit(n = n)
#
# #' @export
# tail.LazyFrame = tail.DataFrame

#' @export
dim.DataFrame = function(x, ...) x$shape

# TODO: inefficient to collect, but attribute is missing
#' @export
dim.LazyFrame = function(x, ...) x$collect()$shape

#' @export
length.DataFrame = function(x, ...) x$width

# TODO: inefficient to collect, but attribute is missing
#' @export
length.LazyFrame = function(x, ...) x$collect()$width

#' @export
nrow.DataFrame = function(x, ...) x$height

#' @export
NROW.DataFrame = nrow.DataFrame

# TODO: inefficient to collect, but attribute is missing
#' @export
nrow.LazyFrame = function(x, ...) x$collect()$height

#' @export
NROW.LazyFrame = nrow.LazyFrame

#' @export
ncol.DataFrame = function(x, ...) x$height

#' @export
NCOL.DataFrame = ncol.DataFrame

# TODO: inefficient to collect, but attribute is missing
#' @export
ncol.LazyFrame = function(x, ...) x$collect()$height

#' @export
NCOL.LazyFrame = ncol.LazyFrame

#' @export
names.DataFrame = function(x) x$columns

# TODO: inefficient to collect, but attribute is missing
#' @export
names.LazyFrame = function(x) x$collect()$columns

# TODO: inefficient to collect, but attribute is missing
#' @export
as.data.frame.LazyFrame = function(x, ...) x$collect()$as_data_frame(...)

#' @export
as.matrix.DataFrame = function(x, ...) as.matrix(x$as_data_frame(...))

# TODO: inefficient to collect, but attribute is missing
#' @export
as.matrix.LazyFrame = function(x, ...) as.matrix(x$collect()$as_data_frame(...))

# #' @export
# mean.DataFrame = function(x, ...) x$mean()
#
# #' @export
# mean.LazyFrame = function(x, ...) x$mean()
#
# #' @export
# median.DataFrame = function(x, ...) x$median()
#
# #' @export
# median.LazyFrame = function(x, ...) x$median()
#
# #' @export
# min.DataFrame = function(x, ...) x$min()
#
# #' @export
# min.LazyFrame = function(x, ...) x$min()
#
# #' @export
# max.DataFrame = function(x, ...) x$max()
#
# #' @export
# max.LazyFrame = function(x, ...) x$max()
#
# #' @export
# sum.DataFrame = function(x, ...) x$sum()
#
# #' @export
# sum.LazyFrame = function(x, ...) x$sum()
