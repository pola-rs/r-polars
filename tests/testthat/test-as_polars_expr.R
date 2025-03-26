test_that("x argument can't be missing", {
  expect_error(as_polars_expr(), r"(The `x` argument of `as_polars_expr\(\)` can't be missing)")
})

test_that("as_polars_expr for polars_expr `structify=TRUE`", {
  as_func <- function(x) {
    as_polars_expr(x, structify = TRUE)
  }
  expect_equal(as_func(pl$col("a")), pl$col("a"))
  expect_equal(as_func(pl$col("a", "b")), pl$struct(pl$col("a", "b")))
  expect_equal(as_func(pl$col("*")), pl$struct(pl$col("*")))
})

test_that("as_polars_expr for character `as_lit=FALSE`", {
  invalid_error_message <- r"(Invalid input for `pl\$col\(\)`)"

  expect_equal(as_polars_expr(character()), pl$col())
  expect_equal(as_polars_expr(c("foo")), pl$col("foo"))
  expect_equal(as_polars_expr(c("foo", "bar")), pl$col("foo", "bar"))
  expect_error(as_polars_expr(NA_character_), invalid_error_message)
  expect_error(as_polars_expr(c("foo", NA_character_)), invalid_error_message)
})

test_that("as_polars_expr for raw `raw_as_binary=FALSE`", {
  expect_equal(
    as_polars_expr(as.raw(1:8), raw_as_binary = FALSE) |>
      pl$select(),
    as_polars_series(1:8, "literal")$cast(pl$UInt8) |>
      pl$select()
  )
})

patrick::with_parameters_test_that(
  "as_polars_expr works for classes",
  .cases = {
    lit_from_single_via_series <- function(x) {
      wrap(lit_from_series_first(as_polars_series(x)$`_s`))
    }

    # fmt: skip
    tibble::tribble(
      ~.test_name, ~x, ~expected_expr, ~expected_length,
      "chr (0)", character(), as_polars_expr(as_polars_series(character(), "literal")), 0,
      "chr (1)", "foo", lit_from_single_via_series("foo"), 1,
      "chr (2)", c("foo", "bar"), as_polars_expr(as_polars_series(c("foo", "bar"), "literal")), 2,
      "chr NA", NA_character_, lit_from_single_via_series(NA_character_), 1,
      "lgl (0)", logical(), as_polars_expr(as_polars_series(logical(), "literal")), 0,
      "lgl (1)", TRUE, lit_from_single_via_series(TRUE), 1,
      "lgl (2)", c(TRUE, FALSE), as_polars_expr(as_polars_series(c(TRUE, FALSE), "literal")), 2,
      "lgl NA", NA, lit_from_single_via_series(NA), 1,
      "int (0)", integer(), as_polars_expr(as_polars_series(integer(), "literal")), 0,
      "int (1)", 1L, lit_from_single_via_series(1L), 1,
      "int (2)", 1:2, as_polars_expr(as_polars_series(1:2, "literal")), 2,
      "int NA", NA_integer_, lit_from_single_via_series(NA_integer_), 1,
      "dbl (0)", numeric(), as_polars_expr(as_polars_series(numeric(), "literal")), 0,
      "dbl (1)", 1, lit_from_single_via_series(1), 1,
      "dbl (2)", c(1, 2), as_polars_expr(as_polars_series(c(1, 2), "literal")), 2,
      "dbl NaN", NaN, lit_from_single_via_series(NaN), 1,
      "dbl NA", NA_real_, lit_from_single_via_series(NA_real_), 1,
      "raw (0)", raw(), as_polars_expr(charToRaw("")), 1,
      "raw (1)", charToRaw("a"), wrap(lit_bin_from_raw(charToRaw("a"))), 1,
      "raw (2)", charToRaw("ab"), wrap(lit_bin_from_raw(charToRaw("ab"))), 1,
      "NULL", NULL, wrap(lit_null()), 1,
      "list (0)", list(), as_polars_expr(as_polars_series(list(), "literal")), 0,
      "list (1)", list(TRUE), as_polars_expr(list(TRUE)), 1,
      "list (2)", list(TRUE, FALSE), as_polars_expr(as_polars_series(list(TRUE, FALSE), "literal")), 2,
      "Date (0)", as.Date(integer()), as_polars_expr(as_polars_series(as.Date(integer()), "literal")), 0,
      "Date (1)", as.Date(0), as_polars_expr(as.Date(0)), 1,
      "Date (2)", as.Date(0:1), as_polars_expr(as_polars_series(as.Date(0:1), "literal")), 2,
      "POSIXct (UTC) (0)", as.POSIXct(integer(), "UTC"), as_polars_expr(as_polars_series(as.POSIXct(integer(), "UTC"), "literal")), 0,
      "POSIXct (UTC) (1)", as.POSIXct(0, "UTC"), as_polars_expr(as.POSIXct(0, "UTC")), 1,
      "POSIXct (UTC) (2)", as.POSIXct(0:1, "UTC"), as_polars_expr(as_polars_series(as.POSIXct(0:1, "UTC"), "literal")), 2,
      "series (0)", as_polars_series(logical()), as_polars_expr(as_polars_series(logical())), 0,
      "series (1)", as_polars_series(TRUE), as_polars_expr(as_polars_series(TRUE)), 1,
      "series (2)", as_polars_series(c(TRUE, FALSE)), as_polars_expr(as_polars_series(c(TRUE, FALSE))), 2
    )
  },
  code = {
    out <- as_polars_expr(x, as_lit = TRUE)
    selected_out <- pl$select(out)

    expect_equal(out, expected_expr)
    expect_snapshot(out)

    expect_equal(selected_out$height, expected_length)
    if (is_polars_series(x)) {
      # For Series, the column name is came from the Series' name
      expect_equal(selected_out$columns[1], x$name)
    } else {
      expect_equal(selected_out$columns[1], "literal")
    }
    expect_snapshot(selected_out)

    # Ensure broadcasting works if the length is 1 (except for Series)
    lf <- pl$LazyFrame(a = 1:10)$with_columns(b = out)

    if (expected_length == 1) {
      if (is_polars_series(x)) {
        # For Series with length 1, a special error message is thrown
        expect_error(
          lf$collect(),
          r"(length 1 doesn't match the DataFrame height of 10.*for instance by adding '\.first\(\)')"
        )
      } else {
        expect_no_error(lf$collect())
      }
    } else {
      expect_error(
        lf$collect(),
        r"(unable to add a column of length \d+ to a DataFrame of height 10)"
      )
    }
  }
)
