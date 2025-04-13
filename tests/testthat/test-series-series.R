patrick::with_parameters_test_that(
  "roundtrip around serialization",
  .cases = {
    # fmt: skip
    tibble::tribble(
      ~.test_name, ~x,
      "null", as_polars_series(NULL),
      "int32", as_polars_series(1:1000),
      "int128", as_polars_series(1:3)$cast(pl$Int128),
      "struct", as_polars_series(data.frame(a = 1:3, b = letters[1:3])),
    )
  },
  code = {
    serialized <- x$serialize()
    expect_type(serialized, "raw")

    expect_equal(pl$deserialize_series(serialized), x)
  }
)

test_that("deserialize series' error", {
  expect_snapshot(
    pl$deserialize_series(0L),
    error = TRUE
  )
  expect_snapshot(
    pl$deserialize_series(raw(0)),
    error = TRUE
  )
  expect_snapshot(
    pl$deserialize_series(as.raw(1:100)),
    error = TRUE
  )
})

test_that("flags work", {
  s <- as_polars_series(c(2, 1, 3))
  expect_identical(
    s$flags,
    c(SORTED_ASC = FALSE, SORTED_DESC = FALSE)
  )
  expect_identical(
    s$flags,
    c(SORTED_ASC = FALSE, SORTED_DESC = FALSE)
  )

  s <- as_polars_series(list(1, 2, 3))
  expect_identical(
    s$flags,
    c(SORTED_ASC = FALSE, SORTED_DESC = FALSE, FAST_EXPLODE = TRUE)
  )
})

test_that("alias/rename works", {
  series <- pl$Series("a", 1:3)
  expect_equal(
    series$alias("b"),
    pl$Series("b", 1:3)
  )
  expect_equal(
    series$rename("b"),
    pl$Series("b", 1:3)
  )
})

test_that("rechunk() and n_chunks() work", {
  s <- as_polars_series(1:3)
  expect_identical(s$n_chunks(), 1L)

  s2 <- as_polars_series(4:6)
  s3 <- pl$concat(s, s2, rechunk = FALSE)
  expect_identical(s3$n_chunks(), 2L)

  expect_identical(s3$rechunk()$n_chunks(), 1L)
  # The original chunk size is not changed yet
  expect_identical(s3$n_chunks(), 2L)
  expect_identical(s3$rechunk(in_place = TRUE)$n_chunks(), 1L)
  # The operation above changes the original chunk size
  expect_identical(s3$n_chunks(), 1L)
})

test_that("rechunk() and chunk_lengths() work", {
  s <- as_polars_series(1:3)
  expect_identical(s$chunk_lengths(), 3L)

  s2 <- as_polars_series(4:6)
  s3 <- pl$concat(s, s2, rechunk = FALSE)
  expect_identical(s3$chunk_lengths(), c(3L, 3L))

  expect_identical(s3$rechunk()$chunk_lengths(), 6L)
})
