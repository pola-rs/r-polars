test_that("as.list() returns a named list of series", {
  expect_equal(
    pl$DataFrame(a = 1L, "foo") |>
      as.list(),
    list(a = pl$Series("a", 1L), pl$Series("", "foo"))
  )
})

test_that("head() works", {
  dat <- data.frame(x = 1:10, y = 11:20)
  dat_pl <- as_polars_df(dat)
  expect_identical(
    as.data.frame(head(dat_pl, 5)),
    head(dat, 5),
    ignore_attr = TRUE
  )
})

test_that("tail() works", {
  dat <- data.frame(x = 1:10, y = 11:20)
  dat_pl <- as_polars_df(dat)
  expect_identical(
    as.data.frame(tail(dat_pl, 5)),
    tail(dat, 5),
    ignore_attr = TRUE
  )
})

patrick::with_parameters_test_that(
  "Row subsetting with `[` returns the same rows as tibble",
  .cases = {
    # fmt: skip
    tibble::tribble(
      ~.test_name, ~first_arg,
      "NULL", NULL,
      "positive scalar", 1,
      "positive slice", 1:2,
      "positive reverse slice", 2:1,
      "scalar 0", 0,
      "positive includes 0", 0:2,
      "positive includes oob", c(1, 10),
      "positive includes the same row twice", c(2, 1, 1),
      "positive includes 0 twice", c(2, 0, 1, 0),
      "positive includes NA", c(2, NA),
      "negative scalar", -1,
      "negative slice", -2:-1,
      "negative includes 0", -2:0,
      "negative includes oob", c(-1, -10),
      "negative includes the same row twice", c(-2, -1, -1),
      "scalar int NA", NA_integer_,
      "numeric length 0", double(),
      "character scalar 1", "1",
      "character scalar 1.0", "1.0",
      "character slice", c("1", "2"),
      "character reverse slice", c("2", "1"),
      "character scalar non-numeric", "foo",
      "character includes NA", c("2", NA),
      "character includes non-numeric", c("foo", "1"),
      "character includes the same row twice", c("2", "1", "1"),
      "scalar character NA", NA_character_,
      "character length 0", character(),
      "logical scalar TRUE", TRUE,
      "logical scalar FALSE", FALSE,
      "logical scalar NA", NA,
      "logical with the same length to the height", c(TRUE, TRUE, FALSE),
      "logical includes NA with the same length to the height", c(FALSE, NA, TRUE),
    )
  },
  code = {
    tbl <- tibble::tibble(a = 1:3, b = 4:6, c = 7:9)
    pl_df <- as_polars_df(tbl)

    # If row index is not one of TRUE, FALSE, or NULL,
    # query for LazyFrame raises an error
    if (is.null(first_arg) || isTRUE(first_arg) || isFALSE(first_arg)) {
      # Only specify the first argument
      expect_query_equal(
        .input[first_arg, ],
        pl_df,
        as_polars_df(tbl[first_arg, ])
      )
      # Returns single column
      expect_query_equal(
        .input[first_arg, "b"],
        pl_df,
        as_polars_df(tbl[first_arg, "b"])
      )
    } else {
      error_regexp <- "Cannot subset rows of a LazyFrame"
      # Only specify the first argument
      expect_eager_equal_lazy_error(
        .input[first_arg, ],
        pl_df,
        as_polars_df(tbl[first_arg, ]),
        regexp = error_regexp
      )
      # Returns single column
      expect_eager_equal_lazy_error(
        .input[first_arg, "b"],
        pl_df,
        as_polars_df(tbl[first_arg, "b"]),
        regexp = error_regexp
      )
    }

    # Check the behavior if `drop = TRUE`.
    # Since tbl[first_arg, , drop = TRUE] may return a vector,
    # we need to convert it to a Series to ensure the same class.
    expect_equal(
      as_polars_series(pl_df[first_arg, , drop = TRUE]),
      as_polars_series(tbl[first_arg, , drop = TRUE])
    )
  }
)

patrick::with_parameters_test_that(
  "Row subsetting with `[` raise error for {.test_name}: {rlang::quo_text(first_arg)}",
  .cases = {
    # fmt: skip
    tibble::tribble(
      ~.test_name, ~first_arg,
      "positive not integer-ish", 1.005,
      "mixed positive and negative (positive first)", c(1, 0, -2),
      "mixed positive and negative (negative first)", c(-2, 0, 1),
      "negative not integer-ish", -1.005,
      "negative includes NA", c(NA, -2, NA),
      "logical with not the same length to the height", c(TRUE, FALSE),
      "logical includes NA with not the same length to the height", c(NA, TRUE),
      "not supported object (function)", mean,
      "not supported object (Date)", .Date(1:2),
      "not supported object (list)", list(1),
    )
  },
  code = {
    pl_df <- pl$DataFrame(a = 1:3, b = 4:6, c = 7:9)

    expect_snapshot(pl_df[first_arg, ], error = TRUE)
    expect_snapshot(pl_df$lazy()[first_arg, ], error = TRUE)
  }
)

patrick::with_parameters_test_that(
  "Column subsetting with `[` returns the same rows as tibble",
  .cases = {
    # fmt: skip
    tibble::tribble(
      ~.test_name, ~second_arg,
      "NULL", NULL,
      "positive scalar", 1,
      "scalar 0", 0,
      "positive slice", 1:2,
      "positive reverse slice", 2:1,
      "positive includes 0", 0:2,
      "positive includes 0 twice", c(2, 0, 1, 0),
      "negative scalar", -1,
      "negative slice", -2:-1,
      "negative includes 0", -2:0,
      "negative includes the same column twice", c(-2, -1, -1),
      "numeric length 0", double(),
      "character scalar", "a",
      "character multiple", c("b", "a"),
      "character length 0", character(),
      "logical scalar TRUE", TRUE,
      "logical scalar FALSE", FALSE,
      "logical with the same length to the width", c(TRUE, FALSE, TRUE),
    )
  },
  code = {
    tbl <- tibble::tibble(a = 1:4, b = 4:7, c = 7:10)
    pl_df <- as_polars_df(tbl)

    # Only specify the second argument
    expect_query_equal(
      .input[, second_arg],
      pl_df,
      as_polars_df(tbl[, second_arg])
    )
    # Returns single row (not supported for LazyFrame)
    expect_eager_equal_lazy_error(
      .input[1, second_arg],
      pl_df,
      as_polars_df(tbl[1, second_arg]),
      regexp = "Cannot subset rows of a LazyFrame"
    )
    # Without commas, the first argument is treated as the second argument
    expect_query_equal(
      .input[second_arg],
      pl_df,
      as_polars_df(tbl[second_arg])
    )
  }
)

patrick::with_parameters_test_that(
  "Column subsetting with `[` raise error for {.test_name}: {rlang::quo_text(second_arg)}",
  .cases = {
    # fmt: skip
    tibble::tribble(
      ~.test_name, ~second_arg,
      "positive not integer-ish", 1.005,
      "positive out of bounds", c(1, 2, 10),
      "positive includes NA", c(1, NA, 2),
      "positive includes the same column twice", c(1, 2, 2),
      "mixed positive and negative (positive first)", c(1, 0, -2),
      "mixed positive and negative (negative first)", c(-2, 0, 1),
      "negative not integer-ish", -1.005,
      "negative includes NA", c(NA, -2, NA),
      "character includes NA", c("a", NA, "b"),
      "character includes non-existing", c("foo", "a", "bar", "b"),
      "character wildcard (valid for pl$col())", "*",
      "character includes the same column twice", c("a", "b", "b"),
      "logical includes NA", c(TRUE, NA, FALSE),
      "logical with not the same length to the width", c(TRUE, FALSE),
      "logical length 0", logical(),
      "not supported object (function)", mean,
      "not supported object (Date)", .Date(1:2),
      "not supported object (list)", list(1),
    )
  },
  code = {
    pl_df <- pl$DataFrame(a = 1:4, b = 4:7, c = 7:10)

    # Only specify the second argument
    expect_snapshot(pl_df[, second_arg], error = TRUE)
    ## Since `<lazyframe>$select()` does not raise an error if columns are duplicated,
    ## we need to collect the result to raise an error here.
    expect_snapshot(pl_df$lazy()[, second_arg]$collect(), error = TRUE)
    # Without commas, the first argument is treated as the second argument
    expect_snapshot(pl_df[second_arg], error = TRUE)
    expect_snapshot(pl_df$lazy()[second_arg]$collect(), error = TRUE)
  }
)

test_that("`[`'s drop argument works correctly", {
  pl_df <- pl$DataFrame(a = 1:3, b = 4:6, c = 7:9)

  expect_equal(
    pl_df[1, , drop = TRUE],
    pl$DataFrame(a = 1L, b = 4L, c = 7L)
  )
  expect_equal(
    pl_df[, 1, drop = TRUE],
    pl_df$to_series(0)
  )
  expect_equal(
    pl_df[1, NULL, drop = TRUE],
    as_polars_df(NULL)
  )

  # drop should be named
  expect_equal(
    pl_df[, "a", TRUE],
    pl$DataFrame(a = 1:3)
  )

  # Ignored if j is not specified
  expect_snapshot(pl_df[1, drop = TRUE])
  expect_snapshot(pl_df["a", drop = TRUE])
})


test_that("Special cases of `[` behavior", {
  pl_df <- pl$DataFrame(a = 1:3, b = 4:6, c = 7:9)

  # Empty args
  expect_query_equal(
    .input[],
    pl_df,
    pl_df
  )
  expect_query_equal(
    # fmt: skip
    # <https://github.com/posit-dev/air/issues/330>
    .input[, ],
    pl_df,
    pl_df
  )

  # Supports `"0"` row name
  # Tibble is buggy for `"0"` row name
  # <https://github.com/tidyverse/tibble/issues/1636>
  # TODO: move this to the parameterized test when the issue is fixed
  expect_eager_equal_lazy_error(
    .input["0", ],
    pl_df,
    pl$DataFrame(a = NA_integer_, b = NA_integer_, c = NA_integer_),
    regexp = "Cannot subset rows of a LazyFrame"
  )

  # polars drops rows if columns are dropped.
  # R dataframe or arrow::Table keeps the rows. (In this case, returns `c(3L, 0L)`)
  expect_query_equal(
    .input[, NULL],
    pl_df,
    as_polars_df(NULL)
  )

  # TODO: test behavior of x[i, , drop = TRUE] when it is clarified
  # https://github.com/tidyverse/tibble/issues/1570
})
