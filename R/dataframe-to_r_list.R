#' Export the polars DataFrame as an R list of R vectors
#'
#' This method is a combination of [`<DataFrame>$get_columns()`][dataframe__get_columns] and
#' [`<Series>$to_r_vector()`][series__to_r_vector].
#' First, it gets the columns of the DataFrame as a list of [Series], then it converts each [Series]
#' to an R [vector].
#' @inheritParams series__to_r_vector
#' @return A [list] of [vectors][vector]
#' @examples
#' df <- pl$DataFrame(foo = c(1, 2, 3), bar = c(4, 5, 6))
#' df$to_r_list()
#'
#' df <- pl$DataFrame(
#'   a = 1:4,
#'   b = c(0.5, 4, 10, 13),
#'   c = c(TRUE, TRUE, FALSE, TRUE)
#' )
#' df$to_r_list()
dataframe__to_r_list <- function(
    ...,
    int64 = "double",
    as_clock_class = FALSE,
    ambiguous = "raise",
    non_existent = "raise") {
  wrap({
    check_dots_empty0(...)

    self$get_columns() |>
      lapply(
        \(col) col$to_r_vector(
          int64 = int64,
          as_clock_class = as_clock_class,
          ambiguous = ambiguous,
          non_existent = non_existent
        )
      )
  })
}
