test_that("from_arrow", {
  skip_if_not_installed("arrow")

  f_round_trip = \(df) {
    df |>
    arrow::as_arrow_table() |>
    pl$from_arrow() |>
    (\(x) x$as_data_frame())()
  }

  expect_identical(f_round_trip(iris),iris)

  #polars do not store row.names, add them as column
  mtcars$rnames = row.names(mtcars)
  row.names(mtcars) = NULL
  expect_identical(f_round_trip(mtcars),mtcars)

  #support plain chunked Table
  l = list(
    df1 = data.frame(val = c(1,2,3), blop=c("a","b","c")),
    df2 = data.frame(val = c(4,5,6), blop=c("a","b","c"))
  )
  at = lapply(l, arrow::as_arrow_table) |> do.call(what=rbind)

  #chunked conversion
  expect_identical(pl$from_arrow(at)$to_list(), as.list(at))
  expect_identical(lapply(at$columns,\(x) pl$from_arrow(x)$to_r()), unname(as.list(at)))

  #no rechunk
  expect_identical(
    lapply(at$columns,\(x) length(pl$from_arrow(x,rechunk = FALSE)$chunk_lengths())),
    lapply(at$columns,\(x) x$num_chunks)
  )
  expect_error(expect_identical(
    lapply(at$columns,\(x) length(pl$from_arrow(x,rechunk = TRUE)$chunk_lengths())),
    lapply(at$columns,\(x) x$num_chunks)
  ))
  expect_identical(
    pl$from_arrow(at,rechunk = FALSE)$select(pl$all()$map(\(s) s$chunk_lengths()))$to_list()|>
    lapply(length) |> unname(),
    lapply(at$columns,\(x) x$num_chunks)
  )

  expect_error(expect_identical(
    pl$from_arrow(at,rechunk = TRUE)$select(pl$all()$map(\(s) s$chunk_lengths()))$to_list()|>
    lapply(length) |> unname(),
    lapply(at$columns,\(x) x$num_chunks)
  ))


 # #not supported yet
 # #chunked data with factors
 # l = list(
 #   df1 = data.frame(factor = factor(c("apple","apple","banana"))),
 #   df2 = data.frame(factor = factor(c("apple","apple","clementine")))
 # )


})
