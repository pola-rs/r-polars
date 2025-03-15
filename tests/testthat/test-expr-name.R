test_that("to_lowercase() works", {
  df <- pl$DataFrame(Var1 = 1, vAR2 = 2)
  expect_named(df$select(pl$all()$name$to_lowercase()), c("var1", "var2"))
})

test_that("to_uppercase() works", {
  df <- pl$DataFrame(Var1 = 1, vAR2 = 2)
  expect_named(df$select(pl$all()$name$to_uppercase()), c("VAR1", "VAR2"))
})

test_that("prefix() works", {
  expect_named(
    pl$DataFrame(alice = 1:3)$select(
      pl$col("alice")$name$prefix("a_"),
      pl$col("alice")$name$prefix("b_")
    ),
    c("a_alice", "b_alice")
  )
})

test_that("suffix() works", {
  expect_named(
    pl$DataFrame(alice = 1:3)$select(
      pl$col("alice")$name$suffix("_1"),
      pl$col("alice")$name$suffix("_2")
    ),
    c("alice_1", "alice_2")
  )
})

test_that("keep() works", {
  expect_named(
    pl$DataFrame(alice = 1:3)$select(
      pl$col("alice")$alias("bob")$name$keep(),
      pl$col("alice")$alias("bob")
    ),
    c("alice", "bob")
  )
})

test_that("prefix_fields() works", {
  df <- pl$DataFrame(a = 1, b = 2)$select(
    pl$struct(pl$all())$alias("my_struct")
  )

  expect_equal(
    df$with_columns(pl$col("my_struct")$name$prefix_fields("col_"))$unnest("my_struct"),
    pl$DataFrame(col_a = 1, col_b = 2)
  )

  expect_error(
    pl$DataFrame(a = 1, b = 2)$select(pl$col("a")$name$prefix_fields("col_")),
    "not supported for dtype `f64`"
  )
})

test_that("suffix_fields() works", {
  df <- pl$DataFrame(a = 1, b = 2)$select(
    pl$struct(pl$all())$alias("my_struct")
  )

  expect_equal(
    df$with_columns(pl$col("my_struct")$name$suffix_fields("_post"))$unnest("my_struct"),
    pl$DataFrame(a_post = 1, b_post = 2)
  )

  expect_error(
    pl$DataFrame(a = 1, b = 2)$select(pl$col("a")$name$suffix_fields("col_")),
    "not supported for dtype `f64`"
  )
})
