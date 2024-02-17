#' @inherit ExprStr_to_uppercase title description return details
#' @examples
#' pl$Series(c("a", "b", "c"))$str$to_uppercase()
SeriesStr_to_uppercase = function() {
  self$to_lit()$str$to_uppercase()$to_series()
}

#' @inherit ExprStr_to_lowercase title description return details
#' @examples
#' pl$Series(c("A", "B", "C"))$str$to_lowercase()
SeriesStr_to_lowercase = function() {
  self$to_lit()$str$to_lowercase()$to_series()
}
