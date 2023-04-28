#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x LazyFrame
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.PolarsBackgroundHandle = function(x, pattern = "") {
  paste0(ls(PolarsBackgroundHandle, pattern = pattern ),"()")
}

#' print LazyFrame s3 method
#' @keywords LazyFrame
#' @param x DataFrame
#' @param ... not used
#' @keywords internal
#'
#' @keywords internal
#' @return self
#' @export
#'
#' @examples
#' lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
#' handle = lazy_df$collect_background()
#' handle$is_exhausted()
#' df = handle$join()
#' handle$is_exhausted()
print.PolarsBackgroundHandle = function(x, ...) {
  cat(
    "PolarsBackgroundHandle\n",
    if(x$is_exhausted()) "this handle is exhausted \n" else  "use $join() to retrieve result\n"
  )
}

#' PolarsBackgroundHandle
#'
#' @return DataFrame
#' @keywords internal
#'
#' @examples
#' lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
#' handle = lazy_df$collect_background()
#' df = handle$join()
#'
PolarsBackgroundHandle_join = function() {
  unwrap(.pr$PolarsBackgroundHandle$join(self))
}


#' PolarsBackgroundHandle
#'
#' @return Bool
#'
#' @keywords internal
#' @examples
#' lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
#' handle = lazy_df$collect_background()
#' handle$is_exhausted()
#' df = handle$join()
#' handle$is_exhausted()
PolarsBackgroundHandle_is_exhausted = function() {
  .pr$PolarsBackgroundHandle$is_exhausted(self)
}
