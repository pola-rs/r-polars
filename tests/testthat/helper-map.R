map_test_entries <- function() {
  list(
    data.frame(key = c("a", "b"), value = c(1L, 2L)),
    NULL,
    data.frame(key = character(), value = integer())
  )
}

map_test_series <- function() {
  as_polars_series(map_test_entries())$cast(pl$Map(pl$String, pl$Int32))
}
