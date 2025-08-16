patrick::with_parameters_test_that(
  "pl$linear_space()",
  .cases = {
    tibble::tribble(
      ~closed, ~expected_output,
      "both", c(0, 0.5, 1),
      "left", c(0, 0.333333, 0.66667),
      "right", c(0.333333, 0.66667, 1),
      "none", c(0.25, 0.5, 0.75)
    )
  },
  code = {
    expect_equal(
      pl$select(
        pl$linear_space(start = 0, end = 1, num_samples = 3, closed = closed)
      ),
      pl$DataFrame(literal = expected_output),
      tolerance = 1e-4
    )
  }
)

test_that("pl$linear_space()", {
  expect_equal(
    pl$select(
      pl$linear_space(
        start = as.Date("2025-01-01"),
        end = as.Date("2025-02-01"),
        num_samples = 3,
        closed = "right"
      )
    ),
    pl$DataFrame(
      literal = as.POSIXct(c("2025-01-11 08:00:00", "2025-01-21 16:00:00", "2025-02-01 00:00:00"))
    )$with_columns(pl$col("literal")$cast(pl$Datetime("us")))
  )

  df <- pl$DataFrame(a = c(1, 2, 3, 4, 5))
  expect_equal(
    df$select(ls = pl$linear_space(0, 1, pl$len())),
    pl$DataFrame(ls = c(0, 0.25, 0.5, 0.75, 1))
  )
})

test_that("pl$linear_spaces()", {
  df <- pl$DataFrame(start = c(1, -1), end = c(3, 2), num_samples = c(4, 5))
  expect_equal(
    df$select(ls = pl$linear_spaces("start", "end", "num_samples")),
    pl$DataFrame(ls = list(c(1, 1.666, 2.333, 3), c(-1, -0.25, 0.5, 1.25, 2))),
    tolerance = 1e-3
  )
  expect_equal(
    df$select(ls = pl$linear_spaces("start", "end", 3, as_array = TRUE)),
    pl$DataFrame(ls = list(c(1, 2, 3), c(-1, 0.5, 2)))$cast(pl$Array(pl$Float64, 3))
  )
})
