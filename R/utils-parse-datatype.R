#' Parse dynamic dots into a list of datatypes
#' @noRd
parse_into_list_of_datatypes <- function(...) {
  list2(...) |>
    lapply(\(x) {
      if (!isTRUE(is_polars_dtype(x))) {
        abort(
          sprintf("Dynamic dots `...` must be polars data types, got %s", obj_type_friendly(x)),
          call = parent.frame(3L)
        )
      }
      x$`_dt`
    })
}
