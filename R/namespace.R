#' @importFrom utils globalVariables head tail download.file capture.output str
NULL

utils::globalVariables(c("pl", "self", "runtime_state","build_debug_print"))




#' python None is NA
#' @return an R NA value
#' @export
#' @details
#' py-polars use python None to encode polars Null, where r-polars uses NA.
#' When copy pasting py-polars code, forgetting to change None to NA
#' should not be a show-stopper.
#'
#' None should not be used casually.
#' @examples
#' None
None = NA
