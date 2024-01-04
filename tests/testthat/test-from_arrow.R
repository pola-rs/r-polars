test_that("from_arrow", {
  skip_if_not_installed("arrow")

  f_round_trip = \(df) {
    df |>
      arrow::as_arrow_table() |>
      pl$from_arrow() |>
      (\(x) x$to_data_frame())()
  }

  expect_identical(f_round_trip(iris), iris)

  # polars do not store row.names, add them as column
  mtcars$rnames = row.names(mtcars)
  row.names(mtcars) = NULL
  expect_identical(f_round_trip(mtcars), mtcars)

  # support plain chunked Table
  l = list(
    df1 = data.frame(val = c(1, 2, 3), blop = c("a", "b", "c")),
    df2 = data.frame(val = c(4, 5, 6), blop = c("a", "b", "c"))
  )
  at = lapply(l, arrow::as_arrow_table) |> do.call(what = rbind)

  # chunked conversion
  expect_identical(pl$from_arrow(at)$to_list(), as.list(at))
  expect_identical(lapply(at$columns, \(x) pl$from_arrow(x)$to_r()), unname(as.list(at)))

  # no rechunk
  expect_identical(
    lapply(at$columns, \(x) length(pl$from_arrow(x, rechunk = FALSE)$chunk_lengths())),
    lapply(at$columns, \(x) x$num_chunks)
  )
  expect_error(expect_identical(
    lapply(at$columns, \(x) length(pl$from_arrow(x, rechunk = TRUE)$chunk_lengths())),
    lapply(at$columns, \(x) x$num_chunks)
  ))
  expect_identical(
    pl$from_arrow(at, rechunk = FALSE)$select(pl$all()$map_batches(\(s) s$chunk_lengths()))$to_list() |>
      lapply(length) |> unname(),
    lapply(at$columns, \(x) x$num_chunks)
  )

  expect_error(expect_identical(
    pl$from_arrow(at, rechunk = TRUE)$select(pl$all()$map_batches(\(s) s$chunk_lengths()))$to_list() |>
      lapply(length) |> unname(),
    lapply(at$columns, \(x) x$num_chunks)
  ))


  # #not supported yet
  # #chunked data with factors
  l = list(
    df1 = data.frame(factor = factor(c("apple", "apple", "banana"))),
    df2 = data.frame(factor = factor(c("apple", "apple", "clementine")))
  )
  at = lapply(l, arrow::arrow_table) |> do.call(what = rbind)
  df = pl$from_arrow(at)
  expect_identical(as.data.frame(at), as.data.frame(df))

  # chunked data with factors and regular integer32
  at2 = lapply(l, \(df) {
    df$value = 1:3
    df
  }) |>
    lapply(arrow::arrow_table) |>
    do.call(what = rbind)
  df2 = pl$from_arrow(at2)
  expect_identical(as.data.frame(at2), as.data.frame(df2))


  # use schema override
  df = pl$from_arrow(
    arrow::arrow_table(iris),
    schema_overrides = list(Sepal.Length = pl$Float32, Species = pl$String)
  )
  iris_str = iris
  iris_str$Species = as.character(iris_str$Species)
  expect_error(expect_equal(df$to_list(), as.list(iris_str)))
  expect_equal(df$to_list(), as.list(iris_str), tolerance = 0.0001)

  # change column name via char schema
  char_schema = names(iris)
  char_schema[1] = "Alice"
  expect_identical(
    pl$from_arrow(
      data = arrow::arrow_table(iris),
      schema = char_schema
    )$columns,
    char_schema
  )
})
