test_that("meta$eq meta$ne", {
  # three naive expression literals
  e1 <- pl$lit(40) + 2
  e2 <- pl$lit(42)
  e3 <- pl$lit(40) + 2

  # e1 and e3 are identical expressions
  expect_true(e1$meta$eq(e3))
  expect_false(e1$meta$eq(e2))
  expect_true(e1$meta$ne(e2))
  expect_false(e1$meta$ne(e3))

  # other is wrapped in Expr
  expect_true(e2$meta$eq(42))

  # error if not wrappable
  expect_snapshot(
    e2$meta$eq(complex(1)),
    error = TRUE
  )
})

test_that("meta$pop", {
  e1 <- pl$lit(40) + 2
  e2 <- pl$lit(42)$sum()

  pop1 <- e1$meta$pop()
  expect_true(length(pop1) == 2L)
  expect_true(pop1[[1]]$meta$eq(2))
  expect_true(pop1[[2]]$meta$eq(40))

  pop2 <- e2$meta$pop()
  expect_true(length(pop2) == 1L)
})

test_that("meta$root_names", {
  e <- pl$col("alice")$alias("bob")
  expect_true(e$meta$root_names() == "alice")
  expect_false(e$meta$root_names() == "bob")
  expect_identical(
    (pl$col("a") + pl$col("b"))$meta$root_names(),
    c("a", "b")
  )
})

test_that("meta$output_name", {
  e <- pl$col("alice")$alias("bob")
  expect_false(e$meta$output_name() == "alice")
  expect_true(e$meta$output_name() == "bob")
  expect_identical(
    (pl$col("a") + pl$col("b"))$meta$output_name(),
    "a"
  )

  expect_snapshot(
    pl$all()$meta$output_name(),
    error = TRUE
  )
  expect_snapshot(
    pl$all()$name$suffix("_")$meta$output_name(),
    error = TRUE
  )
  expect_identical(
    pl$all()$meta$output_name(raise_if_undetermined = FALSE),
    NA_character_
  )
})

test_that("meta$undo_aliases", {
  e <- pl$col("alice")$alias("bob")
  expect_true(e$meta$undo_aliases()$meta$output_name() == "alice")
  expect_false(e$meta$undo_aliases()$meta$output_name() == "bob")
})

test_that("meta$has_multiple_outputs", {
  e1 <- pl$col("alice")
  e2 <- pl$col("alice", "bob")

  expect_false(e1$meta$has_multiple_outputs())
  expect_true(e2$meta$has_multiple_outputs())
})

test_that("meta$is_regex_projection", {
  e1 <- pl$col("^Sepal.*$")
  e2 <- pl$col("Sepal.Length")
  expect_true(e1$meta$is_regex_projection())
  expect_false(e2$meta$is_regex_projection())
})

test_that("meta$is_column_selection", {
  e <- pl$col("foo")
  expect_true(e$meta$is_column_selection())

  e <- pl$col("foo")$alias("bar")
  expect_false(e$meta$is_column_selection())
  expect_true(e$meta$is_column_selection(allow_aliasing = TRUE))

  e <- pl$col("foo") * pl$col("bar")
  expect_false(e$meta$is_column_selection())
})

test_that("meta$tree_format", {
  e <- (pl$col("foo") * pl$col("bar"))$sum()$over(pl$col("ham")) / 2
  expect_true(is.character(e$meta$tree_format()))
  expect_snapshot(cat(e$meta$tree_format()))
})

test_that("meta$serialize", {
  skip_if_not_installed("jsonlite")

  expr <- pl$col("foo")$sum()$over("bar")
  serialized <- expr$meta$serialize()
  deserialized <- pl$deserialize_expr(serialized)
  expect_true(deserialized$meta$eq(expr))

  expect_snapshot(
    expr$meta$serialize(format = "json") |>
      jsonlite::prettify()
  )
})
