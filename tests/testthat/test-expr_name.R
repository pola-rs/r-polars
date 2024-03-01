test_that("name to_lowercase", {
  df = pl$DataFrame(Var1 = 1, vAR2 = 2)
  expect_equal(
    names(df$select(pl$all()$name$to_lowercase())),
    c("var1", "var2")
  )
})

test_that("name to_uppercase", {
  df = pl$DataFrame(Var1 = 1, vAR2 = 2)
  expect_equal(
    names(df$select(pl$all()$name$to_uppercase())),
    c("VAR1", "VAR2")
  )
})

test_that("name keep", {
  expect_identical(
    pl$DataFrame(list(alice = 1:3))$select(
      pl$col("alice")$alias("bob")$name$keep(),
      pl$col("alice")$alias("bob")
    )$columns,
    c("alice", "bob")
  )
})

test_that("name map", {
  skip_if_not_installed("withr")
  withr::with_options(
    list(polars.no_messages = TRUE),
    {
      df = pl$DataFrame(list(alice = 1:3))$select(
        pl$col("alice")$alias("joe_is_not_root")$name$map(\(x) paste0(x, "_and_bob"))
      )
      lf = df$lazy()
      expect_identical(lf$collect()$columns, "alice_and_bob")
      expect_error(
        pl$DataFrame(list(alice = 1:3))$select(
          pl$col("alice")$name$map(\(x) 42) # wrong return
        ),
        "was not a string"
      )

      # TODO: this works but always prints the error message of log("a"), how
      # can we silence it?
      # expect_error(
      #   pl$DataFrame(list(alice=1:3))$select(
      #     pl$col("alice")$name$map(\(x) log("a"))
      #   )
      # )
    }
  )
})

test_that("name prefix_fields", {
  df = pl$DataFrame(a = 1, b = 2)$select(
    pl$struct(pl$all())$alias("my_struct")
  )

  expect_identical(
    df$with_columns(pl$col("my_struct")$name$prefix_fields("col_"))$unnest()$to_list(),
    list(col_a = 1, col_b = 2)
  )

  expect_error(
    pl$DataFrame(a = 1, b = 2)$select(pl$col("a")$name$prefix_fields("col_"))
  )
})

test_that("name suffix_fields", {
  df = pl$DataFrame(a = 1, b = 2)$select(
    pl$struct(pl$all())$alias("my_struct")
  )

  expect_identical(
    df$with_columns(pl$col("my_struct")$name$suffix_fields("_post"))$unnest()$to_list(),
    list(a_post = 1, b_post = 2)
  )

  expect_error(
    pl$DataFrame(a = 1, b = 2)$select(pl$col("a")$name$suffix_fields("col_"))
  )
})
