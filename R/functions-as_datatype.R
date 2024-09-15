# TODO: support `schema` argument
pl__struct <- function(...) {
  parse_into_list_of_expressions(...) |>
    as_struct() |>
    wrap()
}
