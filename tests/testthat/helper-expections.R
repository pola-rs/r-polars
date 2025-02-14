#' Compare the query result with LazyFrame and DataFrame
#'
#' Inspired by `compare_dplyr_binding` of the arrow package.
#' @param object A polars query, must be started with `.input`.
#' See the examples for details.
#' @param ... Dynamic dots taking the various inputs specified in `object`. The
#' last element MUST be the expected output.
#' @examples
#' expect_query_equal(
#'   .input$select("foo"),
#'   pl$DataFrame(foo = NULL, bar = NULL),
#'   pl$DataFrame(foo = NULL)
#' )
#'
#' a <- pl$DataFrame(x = 1:2, y = 3:4)
#' b <- pl$DataFrame(x = 2, z = 5)
#' expect_query_equal(
#'   .input$join(.input2, on = "x", how = "inner"),
#'   .input = a, .input2 = b,
#'   pl$DataFrame(a = 2, y = 4, z = 5)
#' )
#' @noRd
expect_query_equal <- function(object, ...) {
  query <- rlang::enquo(object)
  inputs <- list2(...)

  # Otherwise the expected output needs to be named in all expect_query_equal()
  expected <- inputs[[length(inputs)]]
  inputs[[length(inputs)]] <- NULL

  # Just a convenience to avoid naming `.input` when it's the only input in the
  # query
  inputs_lazy <- lapply(inputs, \(x) x$lazy())
  if (length(inputs) == 1 && is.null(names(inputs))) {
    names(inputs) <- ".input"
    names(inputs_lazy) <- ".input"
  }

  out_lazy <- rlang::eval_tidy(query, rlang::new_data_mask(rlang::env(!!!inputs_lazy)))$collect()
  expect_equal(out_lazy, expected)

  out_eager <- rlang::eval_tidy(query, rlang::new_data_mask(rlang::env(!!!inputs)))
  expect_equal(out_eager, expected)

  invisible(NULL)
}

#' Compare the query error with LazyFrame and DataFrame
#'
#' Same as `expect_query_equal()`, but for `expect_error()`.
#' @param object A polars query, must be started with `.input`.
#' See `expect_query_equal()` for details.
#' @param .input R object will be converted to a DataFrame or LazyFrame
#' by `as_polars_df()` or `as_polars_lf()`.
#' @param regexp passed to `expect_error()`.
#' @param class passed to `expect_error()`.
#' @param .input2 Same as `.input`. Used when query has two frames, e.g. in joins.
#' @param ... passed to `expect_error()`.
#' @noRd
expect_query_error <- function(object, .input, regexp = NULL, class = NULL, .input2 = NULL, ...) {
  query <- rlang::enquo(object)
  expect_error(
    rlang::eval_tidy(query, rlang::new_data_mask(rlang::env(.input = as_polars_lf(.input), .input2 = as_polars_lf(.input2))))$collect(),
    regexp = regexp,
    class = class,
    ...
  )
  expect_error(
    rlang::eval_tidy(query, rlang::new_data_mask(rlang::env(.input = as_polars_df(.input), .input2 = as_polars_df(.input2)))),
    regexp = regexp,
    class = class,
    ...
  )

  invisible(NULL)
}

#' Mix of `expect_query_equal()` and `expect_query_error()`
#'
#' The query only succeeds for DataFrame, but fails for LazyFrame.
expect_eager_equal_lazy_error <- function(object, input, expected, regexp = NULL, class = NULL, ...) {
  query <- rlang::enquo(object)
  out_eager <- rlang::eval_tidy(query, rlang::new_data_mask(rlang::env(.input = as_polars_df(input))))

  expect_equal(out_eager, expected)
  expect_error(
    rlang::eval_tidy(query, rlang::new_data_mask(rlang::env(.input = as_polars_lf(input))))$collect(),
    regexp = regexp,
    class = class,
    ...
  )

  invisible(NULL)
}
