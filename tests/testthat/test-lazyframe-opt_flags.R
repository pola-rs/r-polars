test_that("QueryOptFlags", {
  # Class
  expect_snapshot(pl$QueryOptFlags)

  # Constructor
  expect_snapshot(eager_opt_flags(), transform = normalize_s7_str_spacing)
  expect_snapshot(
    pl$QueryOptFlags(TRUE),
    error = TRUE,
    cnd_class = TRUE
  )

  opt_flags <- pl$QueryOptFlags()

  expect_snapshot(opt_flags, transform = normalize_s7_str_spacing)
  expect_true(opt_flags@join_order)
  expect_true(opt_flags@row_estimate)
  expect_snapshot(eager_opt_flags(), transform = normalize_s7_str_spacing)

  # Validation
  expect_snapshot(
    opt_flags@type_coercion <- 1L,
    error = TRUE,
    cnd_class = TRUE
  )
  expect_snapshot(
    opt_flags@type_coercion <- NA,
    error = TRUE,
    cnd_class = TRUE
  )
  expect_snapshot(
    opt_flags@type_coercion <- c(TRUE, TRUE),
    error = TRUE,
    cnd_class = TRUE
  )

  # dollar method
  expect_snapshot(opt_flags$type_coercion)
  expect_snapshot(opt_flags$type, error = TRUE, cnd_class = TRUE)

  expect_snapshot(opt_flags$no_optimizations(), transform = normalize_s7_str_spacing)
  no_optimizations <- opt_flags$no_optimizations()
  expect_false(no_optimizations@join_order)
  expect_false(no_optimizations@row_estimate)

  # Pre-defined
  expect_snapshot(DEFAULT_EAGER_OPT_FLAGS, transform = normalize_s7_str_spacing)
})

test_that("Rust side validation", {
  opt_flags <- pl$QueryOptFlags()
  prop(opt_flags, "eager", check = FALSE) <- 1L

  expect_snapshot(
    validate(opt_flags),
    error = TRUE,
    cnd_class = TRUE
  )

  expect_snapshot(
    pl$collect_all(list(), optimizations = opt_flags),
    error = TRUE,
    cnd_class = TRUE
  )
})

test_that("QueryOptFlags are passed to the query optimizer", {
  lazy_query <- as_polars_lf(iris)$sort("Species")$filter(pl$col("Species") != "setosa")

  default_plan <- lazy_query$explain()
  expect_false(identical(
    default_plan,
    lazy_query$explain(optimizations = pl$QueryOptFlags(predicate_pushdown = FALSE))
  ))
  expect_false(identical(
    default_plan,
    lazy_query$explain(optimizations = pl$QueryOptFlags()$no_optimizations())
  ))

  # An object modified with `set_props()` is converted the same way as one built by the constructor
  expect_identical(
    lazy_query$explain(optimizations = pl$QueryOptFlags(predicate_pushdown = FALSE)),
    lazy_query$explain(
      optimizations = set_props(pl$QueryOptFlags(), predicate_pushdown = FALSE)
    )
  )
})
