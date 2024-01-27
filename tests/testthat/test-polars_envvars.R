test_that("default envvars", {
  default_envvars = polars_envvars()
  expect_snapshot(default_envvars)
})

skip_if_not_installed("withr")

# run snapshots with non-default values
make_class_cases = function() {
  tibble::tribble(
    ~envvar, ~value,
    # This doesn't work with Sys.setenv(POLARS_AUTO_STRUCTIFY = "1"), I don't
    # know why
    # "POLARS_AUTO_STRUCTIFY", "",

    # Exist in polars but can't be set (even in py-polars)
    # "POLARS_FMT_NUM_DECIMAL", "",
    # "POLARS_FMT_NUM_GROUP_SEPARATOR", "",
    # "POLARS_FMT_NUM_LEN", "",

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

    # Hard to test for in a consistent way
    # "POLARS_STREAMING_CHUNK_SIZE", "variable",
    # "POLARS_TABLE_WIDTH", "variable",
    # "POLARS_VERBOSE", "1",
    # "POLARS_WARN_UNSTABLE", "1"
  )
}

test_pl = pl$DataFrame(
  string_var = c("some words", "more words", "even more words"),
  list_var = list(c(1, 2, 3), c(4, 5, 6), c(6, 7, 8))
)

patrick::with_parameters_test_that(
  "non-default value for each envvar:",
  {
    new_envvar = list(value)
    names(new_envvar) = envvar
    withr::with_envvar(
      new_envvar,
      {
        expect_snapshot(test_pl)
      }
    )
  },
  .cases = make_class_cases()
)
