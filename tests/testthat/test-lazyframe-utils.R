test_that("forward_old_opt_flags", {
  flags <- pl$QueryOptFlags()
  test_fn <- function(...) {
    forward_old_opt_flags(
      flags,
      ...
    ) |>
      print() |>
      validate()
  }

  expect_snapshot(test_fn(type_coercion = FALSE))
  expect_snapshot(test_fn(predicate_pushdown = FALSE))
  expect_snapshot(test_fn(projection_pushdown = FALSE))
  expect_snapshot(test_fn(simplify_expression = FALSE))
  expect_snapshot(test_fn(slice_pushdown = FALSE))
  expect_snapshot(test_fn(comm_subplan_elim = FALSE))
  expect_snapshot(test_fn(comm_subexpr_elim = FALSE))
  expect_snapshot(test_fn(cluster_with_columns = FALSE))
  expect_snapshot(test_fn(collapse_joins = FALSE))
  expect_snapshot(test_fn(no_optimization = TRUE))
})
