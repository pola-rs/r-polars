test_that("pl$concat_list()", {
  df <- pl$DataFrame(a = list(1:2, 3, 4:5), b = list(4, integer(0), NULL))

  expect_equal(
    df$select(x = pl$concat_list("a", "b")),
    pl$DataFrame(x = list(c(1, 2, 4), 3, NULL))
  )
  expect_equal(
    df$select(x = pl$concat_list("a", pl$lit("x"))),
    pl$DataFrame(
      x = list(
        c("1.0", "2.0", "x"),
        c("3.0", "x"),
        c("4.0", "5.0", "x")
      )
    )
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
        pl$col("a") * 2L,
        "b",
        pl$col("c"),
        separator = " "
      )
    ),
    pl$DataFrame(x = c("2 dogs play", "4 cats swim", NA))
  )

  # literal numeric
  expect_equal(
    df$select(
      x = pl$concat_str(
        1L,
        "b",
        pl$col("c"),
        separator = " "
      )
    ),
    pl$DataFrame(x = c("1 dogs play", "1 cats swim", NA))
  )

  # ignore_nulls
  expect_equal(
    df$select(
      x = pl$concat_str(
        pl$col("a") * 2L,
        "b",
        pl$col("c"),
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

test_that("pl$struct()", {
  df <- pl$DataFrame(
    int = 1:2,
    str = c("a", "b"),
    bool = c(TRUE, NA),
    list = list(1:2, 3L),
  )
  expect_equal(
    df$select(pl$struct(pl$all())$alias("my_struct"))$unnest("my_struct"),
    df
  )
  expect_equal(
    df$select(pl$struct("int", FALSE)$alias("my_struct"))$unnest("my_struct"),
    df$select("int", literal = FALSE)
  )
  expect_equal(
    df$select(pl$struct(p = "int", q = "bool")$alias("my_struct"))$unnest("my_struct"),
    df$select(p = "int", q = "bool")
  )
  struct_schema <- list(int = pl$UInt32, list = pl$List(pl$Float32))
  expect_equal(
    df$select(
      my_struct = pl$struct(pl$col("int", "list"), .schema = struct_schema)
    )$unnest("my_struct"),
    df$select("int", "list")$cast(int = pl$UInt32, list = pl$List(pl$Float32))
  )
  expect_equal(
    df$select(
      my_struct = pl$struct(.schema = struct_schema)
    )$unnest("my_struct"),
    df$select("int", "list")$cast(int = pl$UInt32, list = pl$List(pl$Float32))
  )
  expect_error(
    df$select(my_struct = pl$struct(.schema = list(a = 1))),
    "must be a list of polars data types"
  )
})

test_that("pl$date() works", {
  df <- pl$DataFrame(month = 1:3, day = 4:6)
  expect_equal(
    df$select(pl$date(2024, pl$col("month"), pl$col("day"))),
    pl$DataFrame(
      date = as.Date(c("2024-01-04", "2024-02-05", "2024-03-06"))
    )
  )
  expect_equal(
    df$select(pl$date(2024, NA, 1)),
    pl$DataFrame(date = as.Date(NA))
  )

  # Can use in filter() for instance
  df <- pl$DataFrame(
    start = rep(as.Date("2024-01-01"), 3),
    end = as.Date(c("2024-05-01", "2024-07-01", "2024-09-01"))
  )
  expect_equal(
    df$filter(pl$col("end") > pl$date(2024, 6, 1)),
    pl$DataFrame(
      start = rep(as.Date("2024-01-01"), 2),
      end = as.Date(c("2024-07-01", "2024-09-01"))
    )
  )
})
