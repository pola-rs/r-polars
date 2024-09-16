test_that("select works lazy/eager", {
  .data <- pl$DataFrame(
    int32 = 1:5,
    int64 = as_polars_series(1:5)$cast(pl$Int64),
    string = letters[1:5],
  )

  expect_query_equal(
    .input$select("int32"),
    .data,
    pl$DataFrame(int32 = 1:5)
  )
  expect_query_equal(
    .input$select(pl$lit("int32")),
    .data,
    pl$DataFrame(literal = "int32")
  )
  expect_query_equal(
    .input$select(foo = "int32"),
    .data,
    pl$DataFrame(foo = 1:5)
  )
})

test_that("POLARS_AUTO_STRUCTIFY works for select", {
  .data <- pl$DataFrame(
    foo = 1:3,
    bar = 6:8,
    ham = letters[1:3],
  )

  withr::with_envvar(
    c(POLARS_AUTO_STRUCTIFY = "foo"),
    {
      expect_query_error(
        .input$select(1),
        .data,
        r"(Environment variable `POLARS_AUTO_STRUCTIFY` must be one of \('0', '1'\), got 'foo')"
      )
    }
  )

  withr::with_envvar(
    c(POLARS_AUTO_STRUCTIFY = "0"),
    {
      expect_query_error(
        .input$select(is_odd = ((pl$col(pl$Int32) %% 2) == 1)$name$suffix("_is_odd")),
        .data,
        "`keep`, `suffix`, `prefix` should be last expression"
      )

      expect_query_equal(
        withr::with_envvar(c(POLARS_AUTO_STRUCTIFY = "1"), {
          .input$select(is_odd = ((pl$col(pl$Int32) %% 2) == 1)$name$suffix("_is_odd"))
        }),
        .data,
        as_polars_lf(.data)$select(
          is_odd = pl$struct(((pl$col(pl$Int32) %% 2) == 1)$name$suffix("_is_odd")),
        )$collect()
      )
    }
  )
})
