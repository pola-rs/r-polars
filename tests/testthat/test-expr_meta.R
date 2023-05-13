test_that("meta$eq meta$neq", {
  # three naive expression literals
  e1 = pl$lit(40) + 2
  e2 = pl$lit(42)
  e3 = pl$lit(40) + 2

  # e1 and e3 are identical expressions
  expect_true(e1$meta$eq(e3))
  expect_false(e1$meta$eq(e2))
  expect_true(e1$meta$neq(e2))
  expect_false(e1$meta$neq(e3))

  # other is wrapped in Expr
  expect_true(e2$meta$eq(42))

  # error if not wrappable
  expect_grepl_error(e2$meta$eq(complex(1)), c(
    "in \\$meta\\$eq", "not convertable into Expr because"
  ))
  expect_grepl_error(e2$meta$neq(complex(1)), "in \\$meta\\$neq")
})


test_that("meta$pop", {
  e1 = pl$lit(40) + 2
  e2 = pl$lit(42)$sum()

  pop1 = e1$meta$pop()
  expect_true(length(pop1) == 2L)
  expect_true(pop1[[1]]$meta$eq(2))
  expect_true(pop1[[2]]$meta$eq(40))

  pop2 = e2$meta$pop()
  expect_true(length(pop2) == 1L)
  expect_true(pop2[[1]]$meta$eq(42))
})


test_that("meta$root_names", {
  e = pl$col("alice")$alias("bob")
  expect_true(e$meta$root_names() == "alice")
  expect_false(e$meta$root_names() == "bob")
  expect_identical(
    (pl$col("a") + pl$col("b"))$meta$root_names(),
    c("a", "b")
  )
})

test_that("meta$output_name", {
  e = pl$col("alice")$alias("bob")
  expect_false(e$meta$output_name() == "alice")
  expect_true(e$meta$output_name() == "bob")
  expect_identical(
    (pl$col("a") + pl$col("b"))$meta$output_name(),
    "a"
  )
  expect_grepl_error(
    pl$all()$meta$output_name(),
    c("\\$meta\\$output_name", "Cannot determine.*output column")
  )
})

test_that("meta$undo_aliases", {
  e = pl$col("alice")$alias("bob")
  expect_true(e$meta$undo_aliases()$meta$output_name() == "alice")
  expect_false(e$meta$undo_aliases()$meta$output_name() == "bob")
})

test_that("meta$undo_aliases", {
  e1 = pl$col("alice")
  e2 = pl$col(c("alice", "bob"))
  expect_true(e2$meta$has_multiple_outputs())
  expect_false(e1$meta$has_multiple_outputs())
})

test_that("meta$is_regex_projection", {
  e1 = pl$col("^Sepal.*$")
  e2 = pl$col("Sepal.Length")
  expect_true(e1$meta$is_regex_projection())
  expect_false(e2$meta$is_regex_projection())
})
