lf = pl$LazyFrame(mtcars)$with_columns((pl$col("mpg") * 0.425)$alias("kpl"))
rdf = lf$collect()$to_data_frame()

test_that("Test sinking data to parquet file", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  expect_error(lf$sink_parquet(tmpf, compression = "rar"))
  lf$sink_parquet(tmpf)
  expect_equal(pl$scan_parquet(tmpf)$collect()$to_data_frame(), rdf)
})

test_that("Test sinking data to parquet file", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf$sink_ipc(tmpf)
  expect_error(lf$sink_ipc(tmpf, compression = "rar"))
  expect_identical(pl$scan_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame(), rdf)


  # update with new data
  lf$slice(5, 5)$sink_ipc(tmpf)
  expect_equal(
    pl$scan_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame(),
    lf$slice(5, 5)$collect()$to_data_frame()
  )
  lf$sink_ipc(tmpf)

  # from another process via rcall
  rdf_callr = callr::r(\(tmpf) {
    polars::pl$scan_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame()
  }, args = list(tmpf = tmpf))
  expect_identical(rdf_callr, rdf)


  # from another process via rpool
  f_ipc_to_s = \(s) {
    polars::pl$scan_ipc(s$to_r(), memmap = FALSE)$
      select(polars::pl$struct(polars::pl$all()))$
      collect()$
      to_series()
  }
  pl$set_options(rpool_cap = 4)
  rdf_in_bg = pl$LazyFrame()$
    select(pl$lit(tmpf)$map_batches(f_ipc_to_s, in_background = TRUE))$
    collect()$
    unnest()
  expect_identical(rdf_in_bg$to_data_frame(), rdf)
})




# test_that("chunks persists - NOT", {
#
#   tmpf = tempfile()
#   on.exit(unlink(tmpf))
#   df = pl$DataFrame(a=1:1000)
#   df$lazy()$sink_parquet(tmpf,row_group_size = 4)
#
#   #always n cpu chunks it seems, not reproducible across machines
#   df2 = pl$scan_parquet(tmpf)$collect()
#
#   expect_identical(
#     df2$to_series()$chunk_lengths(),
#     rep(125,8)
#   )
# })


# sink_csv ---------------------------------------------------------

dat = head(mtcars, n = 15)
dat[c(1, 3, 9, 12), c(3, 4, 5)] = NA
dat_pl = pl$LazyFrame(dat)
temp_out = tempfile(fileext = ".csv")

test_that("sink_csv works", {
  dat_pl$select(pl$col("drat", "mpg"))$sink_csv(temp_out)

  expect_identical(
    pl$read_csv(temp_out)$to_data_frame(),
    dat[, c("drat", "mpg")],
    ignore_attr = TRUE # ignore row names
  )
})

test_that("sink_csv: null_values works", {
  expect_error(
    dat_pl$sink_csv(temp_out, null_values = NULL)
  )
  dat_pl$sink_csv(temp_out, null_values = "hello")
  expect_snapshot_file(temp_out)
})


test_that("sink_csv: separator works", {
  dat_pl$sink_csv(temp_out, separator = "|")
  expect_snapshot_file(temp_out)
})

test_that("sink_csv: quote_style and quote works", {
  dat_pl2 = pl$LazyFrame(head(iris))

  # wrong quote_style
  ctx = dat_pl2$sink_csv(temp_out, quote_style = "foo") |> get_err_ctx()
  expect_identical(ctx$BadArgument, "quote_style")
  expect_identical(ctx$Plain, "`quote_style` should be one of 'always', 'necessary', 'non_numeric', or 'never'.")

  # wrong quote_style type
  ctx = dat_pl2$sink_csv(temp_out, quote_style = 42) |> get_err_ctx()
  expect_identical(ctx$TypeMismatch, "&str")

  # zero byte quote
  ctx = dat_pl2$sink_csv(temp_out, quote = "") |> get_err_ctx()
  expect_identical(ctx$Plain, "cannot extract single byte from empty string")

  # multi byte quote not allowed
  ctx = dat_pl2$sink_csv(temp_out, quote = "£") |> get_err_ctx()
  expect_identical(ctx$Plain, "multi byte-string not allowed")

  # multi string not allowed
  ctx = dat_pl2$sink_csv(temp_out, quote = c("a", "b")) |> get_err_ctx()
  expect_identical(ctx$TypeMismatch, "&str")
})

patrick::with_parameters_test_that(
  "sink_csv: quote_style",
  {
    df = pl$LazyFrame(
      a = c(r"("foo")", "bar"),
      b = 1:2,
      c = letters[1:2]
    )$sink_csv(temp_out, quote_style = quote_style)
    expect_snapshot_file(temp_out)
  },
  quote_style = c("necessary", "always", "non_numeric", "never")
)

test_that("sink_csv: date_format works", {
  dat = pl$LazyFrame(
    date = pl$date_range(
      as.Date("2020-01-01"),
      as.Date("2023-01-02"),
      interval = "1y",
      eager = TRUE
    )
  )
  dat$sink_csv(temp_out, date_format = "%Y")
  expect_snapshot_file(temp_out)
  dat$sink_csv(temp_out, date_format = "%d/%m/%Y")
  expect_snapshot_file(temp_out)
})

test_that("sink_csv: datetime_format works", {
  dat = pl$LazyFrame(
    date = pl$date_range(
      as.Date("2020-01-01"),
      as.Date("2020-01-02"),
      interval = "6h",
      eager = TRUE
    )
  )
  dat$sink_csv(temp_out, datetime_format = "%Hh%Mm - %d/%m/%Y")
  expect_snapshot_file(temp_out)
})

test_that("sink_csv: time_format works", {
  dat = pl$LazyFrame(
    date = pl$date_range(
      as.Date("2020-10-17"),
      as.Date("2020-10-18"),
      "8h",
      eager = TRUE
    )
  )$with_columns(pl$col("date")$dt$time())
  dat$sink_csv(temp_out, time_format = "%Hh%Mm%Ss")
  expect_snapshot_file(temp_out)
})


test_that("sink_csv: float_precision works", {
  dat = pl$LazyFrame(x = c(1.234, 5.6))
  dat$sink_csv(temp_out, float_precision = 1)
  expect_snapshot_file(temp_out)

  dat$sink_csv(temp_out, float_precision = 3)
  expect_snapshot_file(temp_out)
})
