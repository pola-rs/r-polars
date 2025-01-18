test_that("pl$concat_list()", {
  df <- pl$DataFrame(a = list(1:2, 3, 4:5), b = list(4, integer(0), NULL))

  expect_equal(
    df$select(x = pl$concat_list("a", "b")),
    pl$DataFrame(x = list(c(1, 2, 4), 3, NULL))
  )
  expect_equal(
    df$select(x = pl$concat_list("a", pl$lit("x"))),
    pl$DataFrame(x = list(
      c("1.0", "2.0", "x"),
      c("3.0", "x"),
      c("4.0", "5.0", "x")
    ))
  )
  expect_snapshot(
    df$select(x = pl$concat_list("a", factor("a"))),
    error = TRUE
  )
})

test_that("concat_str", {
  df <- pl$DataFrame(
    a = 1:3,
    b = c("dogs", "cats", NA),
    c = c("play", "swim", "walk")
  )
  expect_equal(
    df$select(
      x = pl$concat_str(
        pl$col("a") * 2L, "b", pl$col("c"),
        separator = " "
      )
    ),
    pl$DataFrame(x = c("2 dogs play", "4 cats swim", NA))
  )

  # literal numeric
  expect_equal(
    df$select(
      x = pl$concat_str(
        1L, "b", pl$col("c"),
        separator = " "
      )
    ),
    pl$DataFrame(x = c("1 dogs play", "1 cats swim", NA))
  )

  # ignore_nulls
  expect_equal(
    df$select(
      x = pl$concat_str(
        pl$col("a") * 2L, "b", pl$col("c"),
        separator = " ",
        ignore_nulls = TRUE
      )
    ),
    pl$DataFrame(x = c("2 dogs play", "4 cats swim", "6 walk"))
  )

  expect_snapshot(
    df$select(x = pl$concat_str(pl$col("a"), complex(1))),
    error = TRUE
  )
  expect_snapshot(
    df$select(x = pl$concat_str(a = "foo")),
    error = TRUE
  )
})
