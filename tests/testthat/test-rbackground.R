lf = pl$LazyFrame(data.frame(x = 1:10, y = 11:20))

test_that("Test collecting LazyFrame in background", {
  compute = lf$select(pl$col("x") * pl$col("y"))
  res_bg = compute$collect_in_background()$join()
  expect_equal(res_bg$to_data_frame(), compute$collect()$to_data_frame())

  # via collect(collect_in_background = TRUE)
  res_bg = compute$collect(collect_in_background = TRUE)$join()
  expect_equal(res_bg$to_data_frame(), compute$collect()$to_data_frame())
})

test_that("Test using $map() in background", {
  # change capacity
  pl$set_options(rpool_cap = 0)
  expect_equal(pl$options$rpool_cap, 0)
  expect_equal(pl$options$rpool_avail, 0)
  pl$set_options(rpool_cap = 1)
  expect_equal(pl$options$rpool_cap, 1)
  expect_equal(pl$options$rpool_avail, 0)


  compute = lf$select(pl$col("y")$map(\(x) x * x, in_background = FALSE))
  compute_bg = lf$select(pl$col("y")$map(\(x) {
    Sys.sleep(2)
    x * x
  }, in_background = TRUE))
  res_ref = compute$collect()$to_data_frame()

  # no process spawned yet
  expect_equal(pl$options$rpool_cap, 1)
  expect_equal(pl$options$rpool_avail, 0)

  # process was spawned
  res_fg_map_bg = compute_bg$collect()$to_data_frame()
  expect_equal(pl$options$rpool_cap, 1)
  expect_equal(pl$options$rpool_avail, 1)

  # same result
  expect_identical(res_ref, res_fg_map_bg)

  # cannot collect in background without a cap
  pl$set_options(rpool_cap = 0)
  handle = compute_bg$collect_in_background()
  res = result(handle$join())
  expect_rpolarserr(unwrap(res), c("When", "Hint", "PlainErrorMessage"))
  expect_identical(
    res$err$contexts() |> tail(1) |> unlist(use.names = FALSE),
    "cannot run background R process with zero capacity"
  )

  # can print handle after exhausted
  handle |>
    as.character() |>
    invisible()

  # can ask if joined after exhausted
  expect_equal(handle$is_finished(), NULL)

  # gives correct err message
  expect_rpolarserr(handle$join(), "Handled")
})

test_that("rpool_cap_max always stays the same", {
  orig = pl$options$rpool_cap_max
  pl$set_options(rpool_cap = orig - 1)
  expect_identical(pl$options$rpool_cap_max, orig)
})

test_that("reset rpool_cap", {
  orig = pl$options$rpool_cap_max
  pl$set_options(rpool_cap = orig - 1)
  expect_different(pl$options$rpool_cap, orig)
  pl$reset_options()
  expect_identical(pl$options$rpool_cap, orig)
})


test_that("rpool errors", {
  rpool_cap_max = pl$options$rpool_cap_max
  expect_error(
    pl$set_options(rpool_cap = rpool_cap_max + 1),
    "must be smaller than the maximum capacity"
  )
  expect_error(
    pl$set_options(rpool_cap = c(1, 2)),
    "must be of length one"
  )
  expect_error(
    pl$set_options(rpool_cap = 2.5),
    "must be an integer"
  )
})
