lf = pl$LazyFrame(data.frame(x = 1:10, y = 11:20))

test_that("Test collecting LazyFrame in background", {
  compute = lf$select(pl$col("x") * pl$col("y"))
  res_bg = compute$collect_in_background()$join()
  expect_equal(res_bg$to_data_frame(), compute$collect()$to_data_frame())
})

test_that("Test using $map() in background", {

  #change capacity
  pl$set_global_rpool_cap(0)
  expect_equal(pl$get_global_rpool_cap(), list(available = 0, capacity = 0))
  pl$set_global_rpool_cap(1)
  expect_equal(pl$get_global_rpool_cap(), list(available = 0, capacity = 1))



  compute = lf$select(pl$col("y")$map(\(x) x * x, in_background = FALSE))
  compute_bg = lf$select(pl$col("y")$map(\(x) x * x, in_background = TRUE))
  res_ref = compute$collect()$to_data_frame()

  # no process spawned yet
  expect_equal(pl$get_global_rpool_cap(), list(available = 0, capacity = 1))

  # process was spawned
  res_fg_map_bg = compute_bg$collect()$to_data_frame()
  expect_equal(pl$get_global_rpool_cap(), list(available = 1, capacity = 1))

  # same result
  expect_identical(res_ref, res_fg_map_bg)

  #cannot collect in background without a cap
  pl$set_global_rpool_cap(0)
  handle = compute_bg$collect_in_background()
  res = result(handle$join())
  expect_rpolarserr(unwrap(res),c("When", "Hint", "PlainErrorMessage"))
  expect_identical(
    res$err$contexts() |> tail(1) |> unlist(use.names = FALSE),
    "cannot run background R process with zero capacity"
  )


  #can print handle after exhausted
  handle |> as.character() |> invisible()

  #can ask if joined after exhausted
  expect_equal(handle$is_finished(), NULL)

  #gives correct err message
  expect_rpolarserr(handle$join(), "Handled")

})
