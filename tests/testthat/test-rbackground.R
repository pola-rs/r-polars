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

  #can collect in background this process is spawned independently
  pl$set_global_rpool_cap(0)
  handle = compute_bg$collect_in_background()
  res_bg_map_bg = handle$join()

  expect_equal(pl$get_global_rpool_cap(), list(available = 0, capacity = 0))
  expect_identical(res_ref, res_bg_map_bg$to_data_frame())
  pl$set_global_rpool_cap(1)

  #can print handle after exhausted
  print(handle)

  #can ask if joined after exhausted
  handle$is_finished()

  #gives correct err message
  expect_error(handle$join())

})
