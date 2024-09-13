#' Export the polars DataFrame as an R list of R vectors
#'
#' This method is a shortcut of `<DataFrame>$to_struct()$to_r_vector(ensure_vector = TRUE)`.
#' Different from [`<DataFrame>$get_columns()`][dataframe__get_columns], all columns are exported as R objects.
#' @seealso
#' - [`<DataFrame>$get_columns()`][dataframe__get_columns]: Export the polars [DataFrame] as a [list] of [Series].
#' - [`<Series>$to_r_vector()`][series__to_r_vector]: Export the polars [Series] as an R vector.
#' @inheritParams series__to_r_vector
#' @return A [list] containing [vector]s and [R dataframe][data.frame]s
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
    struct = "dataframe",
    decimal = "double",
    ambiguous = "raise",
    non_existent = "raise") {
  wrap({
    check_dots_empty0(...)

    self$to_struct()$to_r_vector(
      ensure_vector = TRUE,
      int64 = int64,
      struct = struct,
      decimal = decimal,
      as_clock_class = as_clock_class,
      ambiguous = ambiguous,
      non_existent = non_existent
    )
  })
}
