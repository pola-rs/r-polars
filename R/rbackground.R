#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x RThreadHandle
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.RThreadHandle = function(x, pattern = "") {
  paste0(ls(RThreadHandle, pattern = pattern), "()")
}


#' @export
#' @noRd
as.character.RThreadHandle = function(x, ...) x$thread_description() |> unwrap()


#' @export
#' @noRd
print.RThreadHandle = function(x, ...) x$thread_description() |> unwrap() |> cat()


#' @title Wait for the thread to complete its job
#' @keywords RThreadHandle
#' @param ... a RThreadHandle
#' @return the result of the job
#' @export
RThreadHandle_join = function(...) {
  .pr$RThreadHandle$join(self)
}


#' @title Check if the thread completes its job
#' @keywords RThreadHandle
#' @param ... a RThreadHandle
#' @return a boolean indicating the whether the job has been finished
#' @export
RThreadHandle_is_finished = function(...) {
  .pr$RThreadHandle$is_finished(self) |> unwrap()
}
