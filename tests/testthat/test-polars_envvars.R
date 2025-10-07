test_that("default envvars", {
  # this should have no effect on the threadpool size because it's set after
  # package loading, but we only check that the number is correctly reported
  withr::with_envvar(
    list(POLARS_MAX_THREADS = 2),
    {
      expect_snapshot(polars_envvars())
    }
  )
})

patrick::with_parameters_test_that(
  "non-default envvars affect DataFrame printing",
  .cases = {
    tibble::tribble(
      ~envvar, ~value,
      "POLARS_FMT_MAX_COLS", "1",
      "POLARS_FMT_MAX_ROWS", "1",
      "POLARS_FMT_STR_LEN", "3",
      "POLARS_FMT_TABLE_CELL_ALIGNMENT", "CENTER",
      "POLARS_FMT_TABLE_CELL_LIST_LEN", "1",
      "POLARS_FMT_TABLE_CELL_NUMERIC_ALIGNMENT", "RIGHT",
      "POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW", "1",
      "POLARS_FMT_TABLE_FORMATTING", "ASCII_HORIZONTAL_ONLY",
      "POLARS_FMT_TABLE_HIDE_COLUMN_DATA_TYPES", "1",
      "POLARS_FMT_TABLE_HIDE_COLUMN_NAMES", "1",
      "POLARS_FMT_TABLE_HIDE_COLUMN_SEPARATOR", "1",
      "POLARS_FMT_TABLE_HIDE_DATAFRAME_SHAPE_INFORMATION", "1",
      "POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE", "1",
      "POLARS_FMT_TABLE_ROUNDED_CORNERS", "1",
    )
  },
  code = {
    df <- pl$DataFrame(
      string_var = c("some words", "more words", "even more words"),
      list_var = list(c(1, 2, 3), c(4, 5, 6), c(6, 7, 8)),
      num_var = c(1, 1.1, 1.1111)
    )
    new_envvar <- list(value) |>
      set_names(envvar)
    withr::with_envvar(
      new_envvar,
      {
        expect_snapshot(df)
      }
    )
  }
)
