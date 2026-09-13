test_that("pl$all()", {
  df <- pl$DataFrame(
    a = c(TRUE, FALSE, TRUE),
    b = c(FALSE, FALSE, FALSE)
  )
  expect_equal(
    df$select(pl$all()),
    df
  )
  expect_equal(
    df$select(pl$all(names = c("a", "b"))),
    pl$DataFrame(a = FALSE, b = FALSE)
  )
})

test_that("pl$any()", {
  df <- pl$DataFrame(
    a = c(TRUE, FALSE, TRUE),
    b = c(FALSE, FALSE, FALSE)
  )
  expect_equal(
    df$select(pl$any(names = c("a", "b"))),
    pl$DataFrame(a = TRUE, b = FALSE)
  )
})

test_that("pl$max()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$max(names = c("a", "b"))),
    pl$DataFrame(a = 8, b = 5)
  )
})

test_that("pl$min()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$min(names = c("a", "b"))),
    pl$DataFrame(a = 1, b = 2)
  )
})

test_that("pl$sum()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$sum(names = c("a", "b"))),
    pl$DataFrame(a = 12, b = 11)
  )
})

test_that("pl$cum_sum()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$cum_sum(names = c("a", "b"))),
    pl$DataFrame(a = c(1, 9, 12), b = c(4, 9, 11))
  )
})

test_that("vertical aggregation helpers accept single values", {
  local_lifecycle_warnings()
  df <- pl$DataFrame(
    a = c(TRUE, FALSE, TRUE),
    b = c(FALSE, FALSE, FALSE)
  )
  names <- c("a", "b")

  expect_no_warning(df$select(pl$all(names)))
  expect_no_warning(df$select(pl$any(!!!list(names))))
  expect_no_warning(df$select(pl$max(names)))
  expect_no_warning(df$select(pl$min(names = names)))
  expect_no_warning(df$select(pl$sum(names)))
  expect_no_warning(df$select(pl$cum_sum(!!!list(names))))

  dtypes <- list(pl$Int64, pl$Float64)
  df_dtypes <- pl$DataFrame(
    int = as.integer(c(1, 2, 3)),
    dbl = c(1, 2, 3)
  )
  expect_no_warning({
    expect_equal(
      df_dtypes$select(pl$sum(pl$Int64)),
      df_dtypes$select(pl$sum(names = pl$Int64))
    )
    expect_equal(
      df_dtypes$select(pl$sum(dtypes)),
      df_dtypes$select(pl$sum(names = dtypes))
    )
  })
})

test_that("vertical aggregation helper dynamic dots are deprecated", {
  local_lifecycle_warnings()
  df <- pl$DataFrame(
    a = c(TRUE, FALSE, TRUE),
    b = c(FALSE, FALSE, FALSE)
  )
  names <- c("a", "b")
  dtypes <- list(pl$Int64, pl$Float64)

  expect_snapshot(invisible(pl$all(!!!names)), cnd_class = TRUE)
  expect_snapshot(invisible(pl$all(!!!character())), cnd_class = TRUE)
  expect_snapshot(invisible(pl$any("a", "b")), cnd_class = TRUE)
  expect_snapshot(invisible(pl$max(!!!names)), cnd_class = TRUE)
  expect_snapshot(invisible(pl$min("a", "b")), cnd_class = TRUE)
  expect_snapshot(invisible(pl$sum(!!!names)), cnd_class = TRUE)
  expect_snapshot(invisible(pl$cum_sum("a", "b")), cnd_class = TRUE)
  expect_snapshot(invisible(pl$sum(!!!dtypes)), cnd_class = TRUE)

  local_lifecycle_silence()
  expect_equal(
    df$select(pl$all("a", "b")),
    df$select(pl$all(names = names))
  )
  expect_equal(
    df$select(pl$any(!!!names)),
    df$select(pl$any(names = names))
  )
})

test_that("vertical aggregation helper empty selection is deprecated", {
  local_lifecycle_warnings()
  expect_no_warning(pl$all())
  expect_snapshot(invisible(pl$any()), cnd_class = TRUE)
  expect_snapshot(invisible(pl$max()), cnd_class = TRUE)
  expect_snapshot(invisible(pl$min()), cnd_class = TRUE)
  expect_snapshot(invisible(pl$sum()), cnd_class = TRUE)
  expect_snapshot(invisible(pl$cum_sum()), cnd_class = TRUE)

  local_lifecycle_silence()
  expect_snapshot(pl$any(names = character()))
  expect_snapshot(pl$max(names = character()))
})

test_that("vertical aggregation helper inputs are validated", {
  local_lifecycle_warnings()
  expect_no_warning(pl$all())
  expect_snapshot(pl$all(a = "a"), error = TRUE, cnd_class = TRUE)
  expect_snapshot(pl$all(names = NULL), error = TRUE, cnd_class = TRUE)
  expect_snapshot(pl$sum("a", names = "b"), error = TRUE, cnd_class = TRUE)
  expect_snapshot(pl$sum("a", 1), error = TRUE, cnd_class = TRUE)
  expect_snapshot(pl$sum(pl$Int64, "a"), error = TRUE, cnd_class = TRUE)
})
