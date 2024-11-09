test_that("struct$field", {
  df <- pl$DataFrame(
    aaa = c(1, 2),
    bbb = c("ab", "cd"),
    ccc = c(TRUE, NA),
    ddd = list(1:2, 3)
  )$select(struct_col = pl$struct("aaa", "bbb", "ccc", "ddd"))

  expect_equal(
    df$select(pl$col("struct_col")$struct$field("bbb")),
    pl$DataFrame(bbb = c("ab", "cd"))
  )
  expect_equal(
    df$select(
      pl$col("struct_col")$struct$field("bbb"),
      pl$col("struct_col")$struct$field("ddd")
    ),
    pl$DataFrame(bbb = c("ab", "cd"), ddd = list(1:2, 3))
  )
  expect_equal(
    df$select(pl$col("struct_col")$struct$field("*")),
    pl$DataFrame(
      aaa = c(1, 2),
      bbb = c("ab", "cd"),
      ccc = c(TRUE, NA),
      ddd = list(1:2, 3)
    )
  )
  expect_equal(
    df$select(pl$col("struct_col")$struct$field("aaa", "bbb")),
    pl$DataFrame(aaa = c(1, 2), bbb = c("ab", "cd"))
  )
  expect_equal(
    df$select(pl$col("struct_col")$struct$field("^a.*|b.*$")),
    pl$DataFrame(aaa = c(1, 2), bbb = c("ab", "cd"))
  )
})

test_that("struct$rename_fields", {
  df <- pl$DataFrame(
    aaa = c(1, 2),
    bbb = c("ab", "cd"),
    ccc = c(TRUE, NA),
    ddd = list(1:2, 3)
  )$
    select(struct_col = pl$struct("aaa", "bbb", "ccc", "ddd"))$
    select(
    pl$col("struct_col")$struct$rename_fields(c("www", "xxx", "yyy", "zzz"))
  )
  expect_named(
    df$select(pl$col("struct_col")$struct$field("*")),
    c("www", "xxx", "yyy", "zzz")
  )

  expect_snapshot(
    df$select(pl$col("struct_col")$struct$field("aaa")),
    error = TRUE
  )
})

test_that("struct$json_encode", {
  df <- pl$DataFrame(
    a = list(1:2, c(9, 1, 3)),
    b = list(45, NA)
  )$select(a = pl$struct("a", "b"))

  expect_snapshot(
    df$with_columns(encoded = pl$col("a")$struct$json_encode())
  )
})

test_that("struct$with_fields", {
  df <- pl$DataFrame(
    x = c(1, 4, 9),
    y = c(4, 9, 16),
    multiply = c(10, 2, 3)
  )$
    select(coords = pl$struct("x", "y"), "multiply")$
    with_columns(
    pl$col("coords")$struct$with_fields(
      y_mul = pl$field("y") * pl$col("multiply")
    )
  )

  expect_equal(
    df$select(pl$col("coords")$struct$field("y_mul")),
    pl$DataFrame(y_mul = c(40, 18, 48))
  )
})

test_that("struct$unnest", {
  df <- pl$DataFrame(
    aaa = c(1, 2),
    bbb = c("ab", "cd"),
    ccc = c(TRUE, NA),
    ddd = list(1:2, 3)
  )$select(struct_col = pl$struct("aaa", "bbb", "ccc", "ddd"))

  expect_equal(
    df$select(pl$col("struct_col")$struct$unnest()),
    pl$DataFrame(
      aaa = c(1, 2),
      bbb = c("ab", "cd"),
      ccc = c(TRUE, NA),
      ddd = list(1:2, 3)
    )
  )
})
