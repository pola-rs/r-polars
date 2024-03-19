test_that("lazyframe join examples", {
  df = pl$LazyFrame(
    foo = 1:3,
    bar = c(6, 7, 8),
    ham = c("a", "b", "c")
  )

  other_df = pl$LazyFrame(
    apple = c("x", "y", "z"),
    ham = c("a", "b", "d")
  )

  # inner default join
  df_inner = df$join(other_df, on = "ham")$collect()
  expect_identical(
    df_inner$to_data_frame(),
    data.frame(foo = 1:2, bar = c(6, 7), ham = c("a", "b"), apple = c("x", "y"))
  )

  # outer
  df_outer = df$join(other_df, on = "ham", how = "outer")$collect()
  expect_identical(
    df_outer$to_data_frame(),
    data.frame(
      foo = c(1L, 2L, NA, 3L),
      bar = c(6, 7, NA, 8),
      ham = c("a", "b", NA, "c"),
      apple = c("x", "y", "z", NA),
      ham_right = c("a", "b", "d", NA)
    )
  )

  # error on unknown how choice
  expect_error(
    df$join(other_df, on = "ham", how = "foobar"),
    "should be one of"
  )

  # error on invalid choice
  expect_error(
    df$join(other_df, on = "ham", how = 42),
    "Not a valid R choice"
  )
})


test_that("test_semi_anti_join", {
  # 1
  df_a = pl$DataFrame(list(key = 1:3, payload = c("f", "i", NA)))
  df_b = pl$DataFrame(list(key = c(3L, 4L, 5L, NA)))

  # eager1
  expect_identical(
    df_a$join(df_b, on = "key", how = "anti")$to_data_frame(),
    data.frame(key = 1:2, payload = c("f", "i"))
  )
  expect_identical(
    df_a$join(df_b, on = "key", how = "semi")$to_data_frame(),
    data.frame(key = 3L, payload = NA_character_)
  )

  # lazy1
  expect_identical(
    df_a$lazy()$join(df_b$lazy(), on = "key", how = "anti")$collect()$to_data_frame(),
    data.frame(key = 1:2, payload = c("f", "i"))
  )
  expect_identical(
    df_a$lazy()$join(df_b$lazy(), on = "key", how = "semi")$collect()$to_data_frame(),
    data.frame(key = 3L, payload = NA_character_)
  )

  # 2
  df_a = pl$DataFrame(list(a = c(1:3, 1L), b = c("a", "b", "c", "a"), payload = c(10L, 20L, 30L, 40L)))
  df_b = pl$DataFrame(list(a = c(3L, 3L, 4L, 5L), b = c("c", "c", "d", "e")))

  # eager2
  expect_identical(
    df_a$join(df_b, on = c("a", "b"), how = "anti")$to_data_frame(),
    data.frame(a = c(1:2, 1L), b = c("a", "b", "a"), payload = c(10L, 20L, 40L))
  )
  expect_identical(
    df_a$join(df_b, on = c("a", "b"), how = "semi")$to_data_frame(),
    data.frame(a = 3L, b = "c", payload = 30L)
  )

  # lazy2
  expect_identical(
    df_a$lazy()$join(df_b$lazy(), on = c("a", "b"), how = "anti")$collect()$to_data_frame(),
    data.frame(a = c(1:2, 1L), b = c("a", "b", "a"), payload = c(10L, 20L, 40L))
  )
  expect_identical(
    df_a$lazy()$join(df_b$lazy(), on = c("a", "b"), how = "semi")$collect()$to_data_frame(),
    data.frame(a = 3L, b = "c", payload = 30L)
  )
})


test_that("cross join, DataFrame", {
  dat = pl$DataFrame(
    x = letters[1:3]
  )
  dat2 = pl$DataFrame(
    y = 1:4
  )

  expect_identical(
    dat$join(dat2, how = "cross")$to_data_frame(),
    data.frame(
      x = rep(letters[1:3], each = 4),
      y = rep(1:4, 3)
    )
  )

  # one empty dataframe
  dat_empty = pl$DataFrame(y = character())
  expect_identical(
    dat$join(dat_empty, how = "cross")$to_data_frame(),
    data.frame(x = character(), y = character())
  )
  expect_identical(
    dat_empty$join(dat, how = "cross")$to_data_frame(),
    data.frame(y = character(), x = character())
  )

  # suffix works
  expect_identical(
    dat$join(dat, how = "cross")$to_data_frame(),
    data.frame(
      x = rep(letters[1:3], each = 3),
      x_right = rep(letters[1:3], 3)
    )
  )
})

test_that("'other' must be a LazyFrame", {
  expect_error(
    pl$LazyFrame(x = letters[1:5], y = 1:5)$join(mtcars, on = "x"),
    "`other` must be a LazyFrame"
  )
})

test_that("argument 'validate' works", {
  df1 = pl$LazyFrame(x = letters[1:5], y = 1:5)
  df2 = pl$LazyFrame(x = c("a", letters[1:4]), y2 = 6:10)

  # 1:1
  expect_error(
    df1$join(df2, on = "x", validate = "1:1")$collect(),
    "join keys did not fulfil 1:1 validation"
  )

  # m:1
  expect_error(
    df1$join(df2, on = "x", validate = "m:1")$collect(),
    "join keys did not fulfil m:1 validation"
  )

  # 1:m
  expect_error(
    df2$join(df1, on = "x", validate = "1:m")$collect(),
    "join keys did not fulfil 1:m validation"
  )

  expect_error(
    df2$join(df1, on = "x", validate = "foobar")$collect(),
    "should be one of"
  )
})

test_that("argument 'join_nulls' works", {
  df1 = pl$DataFrame(x = c(NA, letters[1:2]), y = 1:3)
  df2 = pl$DataFrame(x = c(NA, letters[2:3]), y2 = 4:6)

  # 1 discard nulls by default

  # eager1
  expect_identical(
    df1$join(df2, on = "x")$to_data_frame(),
    data.frame(x = "b", y = 3L, y2 = 5L)
  )

  # lazy1
  expect_identical(
    df1$lazy()$join(df2$lazy(), on = "x")$collect()$to_data_frame(),
    data.frame(x = "b", y = 3L, y2 = 5L)
  )

  # 2 consider nulls as a valid key

  # eager2
  expect_identical(
    df1$join(df2, on = "x", join_nulls = TRUE)$to_data_frame(),
    data.frame(x = c(NA, "b"), y = c(1L, 3L), y2 = c(4L, 5L))
  )

  # lazy2
  expect_identical(
    df1$lazy()$join(df2$lazy(), on = "x", join_nulls = TRUE)$collect()$
      to_data_frame(),
    data.frame(x = c(NA, "b"), y = c(1L, 3L), y2 = c(4L, 5L))
  )

  # 3 several nulls
  df3 = pl$DataFrame(x = c(NA, letters[2:3], NA), y2 = 4:7)

  # eager3
  expect_identical(
    df1$join(df3, on = "x", join_nulls = TRUE)$to_data_frame(),
    data.frame(x = c(NA, "b", NA), y = c(1L, 3L, 1L), y2 = c(4L, 5L, 7L))
  )

  # lazy3
  expect_identical(
    df1$lazy()$join(df3$lazy(), on = "x", join_nulls = TRUE)$collect()$
      to_data_frame(),
    data.frame(x = c(NA, "b", NA), y = c(1L, 3L, 1L), y2 = c(4L, 5L, 7L))
  )
})
