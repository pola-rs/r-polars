expect_different = function(x, y) {
  expect_false(identical(x, y))
}


#' Expect grepl error: similar to `expect_error` and friends but adds some
#' polars options to avoid duplicating calls
#'
#' @param expr an R expression to test
#' @param expected_err one or several string patterns passed to grepl
#' @param do_not_repeat_call bool, prevent error-handler to add call to err msg
#' useful for grepping the same error message, without grep-patterns becomes
#' included in the error message. Latter leads to false positive outcomes.
#' @param ... args passed to expect_identical which will run if grepl fails
#'
#' @details expr must raise an error and expected_err pattern must match
#' against the error text with grepl()
#' @keywords internal
#' @return invisble NULL
#'
#' @examples
#' # passes as "carrot" is in "orange and carrot"
#' expect_grepl_error(stop("orange and carrot"), "carrot")
#' expect_grepl_error(stop("orange and carrot"), c("carrot", "orange"))
expect_grepl_error = function(expr, expected_err = NULL, do_not_repeat_call = TRUE, ...) {
  # turn of including call in err msg
  if (do_not_repeat_call) {
    pl$set_options(do_not_repeat_call = TRUE)
  }

  # capture err msg
  err = NULL
  err = tryCatch(expr, error = function(e) {
    as.character(e)
  })

  # restore previous options state
  if (do_not_repeat_call) {
    pl$set_options(do_not_repeat_call = FALSE)
  }

  # check if error message contains pattern
  founds = sapply(expected_err, \(x) isTRUE(grepl(x, err, ignore.case = TRUE)[1]))

  if (!all(founds)) {
    # ... if not use testthat to point out the difference
    expect_identical(expected_err[which(!founds)[1]], err, ...)
  }

  invisible(err)
}

make_print_cases = function() {
  tibble::tribble(
    ~.name, ~.value,
    "dummy", "dummy",
    "POLARS_FMT_TABLE_CELL_ALIGNMENT", "RIGHT",
    # "POLARS_FMT_TABLE_INLINE_COLUMN_DATA_TYPE", "1", # Skip because the test does not work well #133
    "POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW", "1",
    "POLARS_FMT_TABLE_FORMATTING", "ASCII_FULL",
    "POLARS_FMT_TABLE_FORMATTING", "ASCII_FULL_CONDENSED",
    "POLARS_FMT_TABLE_FORMATTING", "ASCII_NO_BORDERS",
    "POLARS_FMT_TABLE_FORMATTING", "ASCII_BORDERS_ONLY",
    "POLARS_FMT_TABLE_FORMATTING", "ASCII_BORDERS_ONLY_CONDENSED",
    "POLARS_FMT_TABLE_FORMATTING", "ASCII_HORIZONTAL_ONLY",
    "POLARS_FMT_TABLE_FORMATTING", "ASCII_MARKDOWN",
    "POLARS_FMT_TABLE_FORMATTING", "UTF8_FULL",
    "POLARS_FMT_TABLE_FORMATTING", "UTF8_FULL_CONDENSED",
    "POLARS_FMT_TABLE_FORMATTING", "UTF8_NO_BORDERS",
    "POLARS_FMT_TABLE_FORMATTING", "UTF8_BORDERS_ONLY",
    "POLARS_FMT_TABLE_FORMATTING", "UTF8_HORIZONTAL_ONLY",
    "POLARS_FMT_TABLE_FORMATTING", "NOTHING",
    "POLARS_FMT_TABLE_HIDE_COLUMN_DATA_TYPES", "1",
    "POLARS_FMT_TABLE_HIDE_COLUMN_NAMES", "1",
    "POLARS_FMT_TABLE_HIDE_COLUMN_SEPARATOR", "1",
    "POLARS_FMT_TABLE_HIDE_DATAFRAME_SHAPE_INFORMATION", "1",
    "POLARS_FMT_MAX_ROWS", "2",
  )
}

# Expect a RPolarsErr with given contexts
expect_rpolarserr = function(expr, ctxs) {
  res = result(expr)
  expect_identical(class(res$err), "RPolarsErr")
  expect_identical(names(res$err$contexts()), ctxs)
}

expect_snapshot_file = function(path, ...) {
  expect_snapshot(readLines(path, warn = FALSE) |> cat(sep = "\n"), ...)
}
