map_nanoarrow_array <- function() {
  schema <- nanoarrow::na_map(
    key_type = nanoarrow::na_string(nullable = FALSE),
    item_type = nanoarrow::na_int32()
  )
  nanoarrow::as_nanoarrow_array(
    list(
      data.frame(key = c("a", "b"), value = c(1L, 2L)),
      NULL,
      data.frame(key = character(), value = integer())
    ),
    schema = schema
  )
}

# TODO: Create this test input with Polars directly once R can construct Map Series.
map_nanoarrow_series <- function() {
  nanoarrow::as_nanoarrow_array_stream(map_nanoarrow_array()) |>
    as_polars_series()
}
