pl__when <- function(...) {
  parse_predicates_constraints_into_expression(...) |>
    when() |>
    wrap()
}
