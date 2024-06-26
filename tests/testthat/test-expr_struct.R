test_that("expr struct$field", {
  df = pl$DataFrame(
    aaa = c(1, 2),
    bbb = c("ab", "cd"),
    ccc = c(TRUE, NA),
    ddd = list(c(1, 2), 3)
  )$select(
    pl$struct(pl$all())$alias("struct_col")
  )
  # struct field into a new Series
  act = df$select(
    pl$col("struct_col")$struct$field("bbb"),
    pl$col("struct_col")$struct$field("ddd")
  )
  expect_identical(
    act$to_list(),
    df$unnest()$select(pl$col(c("bbb", "ddd")))$to_list()
  )

  err_state = result(df$select(pl$col("struct_col")$struct$field(42)))
  expect_grepl_error(unwrap(err_state), "str")
  expect_grepl_error(unwrap(err_state), "\\[name\\]")
  expect_grepl_error(unwrap(err_state), "str")
  expect_grepl_error(unwrap(err_state), "42.0")
})


test_that("expr struct$rename_fields", {
  df = pl$DataFrame(
    aaa = 1:2,
    bbb = c("ab", "cd"),
    ccc = c(TRUE, NA),
    ddd = list(1:2, 3L)
  )$select(
    pl$struct(pl$all())$alias("struct_col")
  )

  df_act = df$select(
    pl$col("struct_col")$struct$rename_fields(c("www", "xxx", "yyy", "zzz"))
  )
  expect_identical(df_act$unnest()$columns, c("www", "xxx", "yyy", "zzz"))

  # odd edge cases
  df_too_many = df$select(pl$col("struct_col")$struct$rename_fields(
    c("www", "xxx", "yyy", "zzz", "invalid", "joe")
  ))
  expect_identical(df_act$to_list(), df_too_many$to_list())

  df_too_few = df$select(pl$col("struct_col")$struct$rename_fields(
    c("www", "xxx")
  ))
  expect_identical(
    df_act$unnest()$select(pl$col(c("www", "xxx")))$to_list(),
    df_too_few$unnest()$to_list()
  )

  err_state = result(pl$col("")$struct$rename_fields(42))
  expect_grepl_error(unwrap(err_state), "str")
  expect_grepl_error(unwrap(err_state), "\\[names\\]")
  expect_grepl_error(unwrap(err_state), "in \\$struct\\$rename_fields:")
  expect_grepl_error(unwrap(err_state), "42.0")
})

test_that("$struct$with_fields", {
  df = pl$DataFrame(x = c(1, 4, 9), y = c(4, 9, 16), multiply = c(10, 2, 3))$
    with_columns(coords = pl$struct(c("x", "y")))$
    select("coords", "multiply")

  out = df$select(
    pl$col("coords")$struct$with_fields(
      pl$col("coords")$struct$field("x")$sqrt(),
      y_mul = pl$col("coords")$struct$field("y") * pl$col("multiply")
    )
  )$unnest("coords")

  # same thing but with pl$field()
  out2 = df$select(
    pl$col("coords")$struct$with_fields(
      pl$field("x")$sqrt(),
      y_mul = pl$field("y") * pl$col("multiply")
    )
  )$unnest("coords")

  expect_identical(
    out$to_data_frame(),
    data.frame(x = c(1, 2, 3), y = c(4, 9, 16), y_mul = c(40, 18, 48))
  )

  expect_identical(
    out2$to_data_frame(),
    data.frame(x = c(1, 2, 3), y = c(4, 9, 16), y_mul = c(40, 18, 48))
  )
})

test_that("pl$field() errors if field doesn't exist", {
  expect_grepl_error(
    pl$DataFrame(x = c(1, 4, 9))$
      select(coords = pl$struct("x"))$
      select(
      pl$col("coords")$struct$with_fields(
        pl$field("foobar")
      )
    ),
    "field not found"
  )
})
