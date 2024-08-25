#' Parse dynamic dots into a list of datatypes
#' @noRd
parse_into_list_of_datatypes <- function(...) {
  list2(...) |>
    lapply(\(x) {
      if (!isTRUE(is_polars_data_type(x))) {
        abort(
          sprintf("Dynamic dots `...` must be polars data types, got %s", toString(class(x))),
          call = parent.frame(3L)
        )
      }
      x$`_dt`
    })
}
