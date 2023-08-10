#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x RThreadHandle
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.RThreadHandle = function(x, pattern = "") {
  paste0(ls(RThreadHandle, pattern = pattern), "()")
}


#' @title RThreadHandle to string
#' @description get description of RThreadHandle as string
#' @param x RThreadHandle
#' @param ... not used
#' @export
#' @keywords internal
as.character.RThreadHandle = function(x, ...) {
  .pr$RThreadHandle$thread_description(x) |>
    unwrap_or("An exhausted RThreadHandle")
}

#' s3 method print RThreadHandle
#'
#' @keywords internal
#' @param x RThreadHandle
#' @param ... not used
#'
#' @return self
#' @export
#'
#' @examples
#' handle = pl$LazyFrame()$select(pl$lit(2) + 2)$collect_in_background()
#' print(handle)
#' handle$join()
#' print(handle)
print.RThreadHandle = function(x, ...) as.character(x) |> cat("\n")


#' @title The RThreadHandle class
#' @name RThreadHandle_RThreadHandle_class
#' @description A handle to some polars query running in a background thread.
#' @details
#' [`<LazyFrame>$collect_in_background()`][LazyFrame_collect_in_background] will execute a polars
#' query detached from the R session and return an `RThreadHandle` immediately. This
#' `RThreadHandle`-class has the methods [`is_finished()`][RThreadHandle_is_finished] and
#' [`join()`][RThreadHandle_join].
#'
#' NOTICE:
#' The background thread cannot use the main R session, but can access the pool of extra R sessions
#' to process R code embedded in polars query via `$map(...,background = TRUE)` or
#' `$apply(background=TRUE)`. Use [`pl$set_global_rpool_cap()`][global_rpool_cap] to limit number of
#'  parallel R sessions.
#' Starting polars  [`<LazyFrame>$collect_in_background()`][LazyFrame_collect_in_background] with
#' e.g. some `$map(...,background = FALSE)` will raise an Error as the main R session is not
#' available to process the R part of the polars query. Native polars query does not need any R
#' session.
#' @return see methods:
#' [`is_finished()`][RThreadHandle_is_finished]
#' [`join()`][RThreadHandle_join]
#' @keywords RThreadHandle
#' @seealso
#' [`<LazyFrame>$collect_in_background()`][LazyFrame_collect_in_background]
#' [`<Expr>$map()`][Expr_map]
#' [`<Expr>$apply()`][Expr_apply]
#' @examples
#' prexpr = pl$col("mpg")$map(\(x) {
#'   Sys.sleep(1.5)
#'   x * 0.43
#' }, in_background = TRUE)$alias("kml")
#' handle = pl$LazyFrame(mtcars)$with_column(prexpr)$collect_in_background()
#' if (!handle$is_finished()) print("not done yet")
#' df = handle$join() # get result
#' df
#'
RThreadHandle

#' Join a RThreadHandle
#' @keywords RThreadHandle
#' @details method `<RThreadHandle>$join()`: will block until job is done and then return some value
#'  or raise an error from the thread.
#' Calling `<RThreadHandle>$join()` a second time will raise an error because handle is already
#' exhausted.
#' @return return value from background thread
#' @seealso [RThreadHandle_class][RThreadHandle_RThreadHandle_class]
RThreadHandle_join = function() {
  .pr$RThreadHandle$join(self) |> unwrap()
}


#' Ask if RThreadHandle is finished?
#' @keywords RThreadHandle
#' @return trinary value: `TRUE` if finished, `FALSE` if not, and `NULL` if the handle was exhausted
#' with [`<RThreadHandle>$join()`][RThreadHandle_join].
RThreadHandle_is_finished = function() {
  .pr$RThreadHandle$is_finished(self) |> unwrap_or(NULL)
}




