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
#' `<LazyFrame>$collect_in_background()` will execute a polars query detached from the R session
#' and return a `RThreadHandle` immediately. The RThreadHandle has the methods `is_finished()` and
#' `$join()`.
#'
#' The background thread may access the pool of extra R sessions to process R code
#' embedded in polars query via `$map(...,background = TRUE)` or `$apply(background=TRUE)`. Use
#' `pl$set_global_rpool_cap()` to limit number of parallel R sessions. Extra R sessions are spawned
#' and used if `background` arg is set to TRUE.
#'
#' Starting polars `<LazyFrame>$collect_in_background()` with e.g. some
#' `$map(...,background = FALSE)` will raise an Error as the main R session is not available to
#' process the query.
#' @return see methods
#' @keywords RThreadHandle
#' @seealso \link{LazyFrame_collect_in_background} \link{Expr_map} \link{Expr_apply}
#' @examples
#' prexpr <- pl$col("mpg")$map(\(x) {Sys.sleep(1.5);x * 0.43}, in_background = TRUE)$alias("kml")
#' handle = pl$LazyFrame(mtcars)$with_column(prexpr)$collect_in_background()
#' if(!handle$is_finished()) print("not done yet")
#' df = handle$join() #get result
#' df
#'
RThreadHandle

#' Join a RThreadHandle
#' @keywords RThreadHandle
#' @details method `<RThreadHandle>$join()`: will block until job is done and then return some value
#'  or raise an error from the thread.
#' Calling `<RThreadHandle>$join()` a second time will raise an error because handle is already
#' exhausted.
#' @export
RThreadHandle_join = function() {
  .pr$RThreadHandle$join(self) |> unwrap()
}


#' Ask if RThreadHandle is finished?
#' @keywords RThreadHandle
#' @details method `<RThreadHandle>$is_finished()`: Calling `<RThreadHandle>$is_finished()` returns
#' trinary value: `TRUE` if finished, `FALSE` if not, and `NULL` if the handle was exhausted
#' (already joined).
#' @export
RThreadHandle_is_finished = function() {
  .pr$RThreadHandle$is_finished(self) |> unwrap_or(NULL)
}




#' get/set global R session pool cap
#' @name global_rpool_cap
#' @param n integer, the capacity limit R sessions to process R code.
#' @return for `pl$get_global_rpool_cap()` a list(available = ? , capacity = ?)
#' where available is how many R session already spawned in pool. Capacity is the limit of
#' how many new R sessions to spawn. Anytime a polars thread worker needs a background R session
#' specifically to run R code embedded in a query via `$map(..., in_background = TRUE)` or
#' `$apply(..., in_background = TRUE)` it will obtain any R session idling in rpool, otherwise spawn
#' a new R session (process) and add it to pool if not `capacity` has been reached. If capacity has
#' been reached already the thread worker will sleep until an R session is idling.
#'
#' Background R sessions communicate via polars arrow IPC (series/vectors) or R serialize +
#' shared memory buffers via the rust crate `ipc-channel`. Multi-process communication has overhead
#' because all data must be serialized/de-serialized and sent via buffers. Using multiple R sessions
#' will likely only give a speed-up in a `low io - high cpu` scenario. Native polars query syntax
#' runs in threads and have no overhead.
#'
#' @examples
#' default = pl$get_global_rpool_cap()
#' print(default)
#' pl$set_global_rpool_cap(8)
#' pl$get_global_rpool_cap()
#' pl$set_global_rpool_cap(default$capacity)
pl$get_global_rpool_cap = function() {
  get_global_rpool_cap() |> unwrap()
}

#' @rdname global_rpool_cap
#' @name set_global_rpool_cap
pl$set_global_rpool_cap = function(n) {
  set_global_rpool_cap(n) |> unwrap() |> invisible()
}


