make_cases <- function() {
  tibble::tribble(
    ~ .test_name, ~ pola,   ~ base,
    "mean",       "mean",   mean,
    "median",     "median", stats::median,
    "min",        "min",    min,
    "max",        "max",    max,
    "sum",        "sum",    sum,
  )
}
patrick::with_parameters_test_that("aggregations",
    {
        d = pl$DataFrame(mtcars)
        w = d[[pola]]()$to_data_frame()
        x = base(d)$to_data_frame()
        y = base(d$lazy())$collect()$to_data_frame()
        z = data.frame(t(sapply(mtcars, base)))
        expect_equal(w, x, ignore_attr = TRUE)
        expect_equal(w, y, ignore_attr = TRUE)
        expect_equal(w, z, ignore_attr = TRUE)
    },
    .cases = make_cases()
)


make_cases <- function() {
  tibble::tribble(
    ~ .test_name, ~ FUN,
    "head",       head,
    "tail",       tail,
    "nrow",       nrow,
    "ncol",       ncol,
    "length",     length,
    "as.matrix",  as.matrix,
    "names",      names,
  )
}
patrick::with_parameters_test_that("inspection",
    {
        d = pl$DataFrame(mtcars)
        x = FUN(mtcars)
        y = FUN(d)
        if (inherits(y, "DataFrame")) y = y$to_data_frame()
        expect_equal(x, y, ignore_attr = TRUE)
        if (.test_name == "as.matrix") {
          z = FUN(d$lazy())
          expect_equal(x, z, ignore_attr = TRUE)
        } else if (!.test_name %in% c("length", "nrow", "ncol", "names")) {
          z = FUN(d$lazy())$collect()$to_data_frame()
          expect_equal(x, z, ignore_attr = TRUE)
        }
    },
    .cases = make_cases()
)


make_cases <- function() {
  tibble::tribble(
    ~ .test_name, ~ pola,   ~ base,
    "length",     "len",    length,
    "min",        "min",    min,
    "max",        "max",    max,
    "sum",        "sum",    sum,
  )
}
patrick::with_parameters_test_that("Series",
    {
        d = pl$Series(mtcars$mpg)
        x = base(mtcars$mpg)
        y = base(d)
        z = d[[pola]]()
        if (inherits(y, "Series")) y = y$to_vector()
        if (inherits(z, "Series")) z = z$to_vector()
        expect_equal(x, y, ignore_attr = TRUE)
        expect_equal(x, z, ignore_attr = TRUE)
    },
    .cases = make_cases()
)

vecs_to_test = list(
  letters,
  1:10,
  c("foo" = "bar"),
  c(TRUE, FALSE),
  as.factor(letters),
  c("foooo", "barrrrr")
)

patrick::with_parameters_test_that("Series as.vector",
  {
    expect_equal(as.vector(pl$Series(v)), v, ignore_attr = TRUE)
  },
  v = vecs_to_test
)

patrick::with_parameters_test_that("Series as.character",
  {
    expect_snapshot(as.character(pl$Series(v)), cran = TRUE)
    expect_snapshot(as.character(pl$Series(v), format = TRUE), cran = TRUE)
    expect_snapshot(as.character(pl$Series(v), format = TRUE, str_length = 2), cran = TRUE)
  },
  v = vecs_to_test
)

test_that("drop_nulls", {
  tmp = mtcars
  tmp[1:3, "mpg"] = NA
  tmp[4, "hp"] = NA
  d = pl$DataFrame(tmp)
  dl = pl$DataFrame(tmp)$lazy()
  expect_equal(nrow(na.omit(d)), 28)
  expect_equal(nrow(na.omit(d, subset = "hp")), 31)
  expect_equal(nrow(na.omit(d, subset = c("mpg", "hp"))), 28)
  expect_error(na.omit(d, "bad"),"ColumnNotFound")
  expect_equal(nrow(na.omit(dl)$collect()), 28)
  expect_equal(nrow(na.omit(dl, subset = "hp")$collect()), 31)
  expect_equal(nrow(na.omit(dl, subset = c("mpg", "hp"))$collect()), 28)
  expect_error(na.omit(dl, "bad")$collect(),"ColumnNotFound")
})


test_that("unique", {
  df = pl$DataFrame(
    x = as.numeric(c(1, 1:5)),
    y = as.numeric(c(1, 1:5)),
    z = as.numeric(c(1, 1, 1:4)))
  expect_equal(unique(df)$height, 5)
  expect_equal(unique(df, subset = "z")$height, 4)
  df = pl$DataFrame(
    x = as.numeric(c(1, 1:5)),
    y = as.numeric(c(1, 1:5)),
    z = as.numeric(c(1, 1, 1:4)))$lazy()
  expect_equal(unique(df)$collect()$height, 5)
  expect_equal(unique(df, subset = "z")$collect()$height, 4)
})

test_that("brackets", {
  # informative errors
  df = pl$DataFrame(mtcars)

  expect_error(df[, "bad"], regexp = "not found")
  expect_error(df[c(1, 4, 3), ], regexp = "increasing order")
  expect_error(df[, rep(TRUE, 50)], regexp = "length 11")
  expect_error(df[, 1:32], regexp = "less than")
  expect_error(df[, mtcars], regexp = "atomic vector")

  # eager
  df = pl$DataFrame(mtcars)
  a = df[, c("mpg", "hp")]$to_data_frame()
  b = mtcars[, c("mpg", "hp")]
  expect_equal(a, b, ignore_attr = TRUE)

  a = df[, c("hp", "mpg")]$to_data_frame()
  b = mtcars[, c("hp", "mpg")]
  expect_equal(a, b, ignore_attr = TRUE)

  idx = rep(FALSE, ncol(mtcars))
  idx[c(1, 3, 6, 9)] = TRUE
  a = df[, idx]$to_data_frame()
  b = mtcars[, idx]
  expect_equal(a, b, ignore_attr = TRUE)

  a = df[, c(1, 4, 2)]$to_data_frame()
  b = mtcars[, c(1, 4, 2)]
  expect_equal(a, b, ignore_attr = TRUE)

  idx = rep(FALSE, nrow(mtcars))
  idx[c(1, 3, 6, 9)] = TRUE
  a = df[idx, 1:3]$to_data_frame()
  b = mtcars[idx, 1:3]
  expect_equal(a, b, ignore_attr = TRUE)

  a = df[3:7, 1:3]$to_data_frame()
  b = mtcars[3:7, 1:3]
  expect_equal(a, b, ignore_attr = TRUE)

  # un-comment when the `LazyFrame.columns` attribute is implemented

  # # lazy
  # df = pl$DataFrame(mtcars)$lazy()
  # a = df[, c("mpg", "hp")]$collect()$to_data_frame()
  # b = mtcars[, c("mpg", "hp")]
  # expect_equal(a, b, ignore_attr = TRUE)
  #
  # a = df[, c("hp", "mpg")]$collect()$to_data_frame()
  # b = mtcars[, c("hp", "mpg")]
  # expect_equal(a, b, ignore_attr = TRUE)
  #
  # idx = rep(FALSE, ncol(mtcars))
  # idx[c(1, 3, 6, 9)] = TRUE
  # a = df[, idx]$collect()$to_data_frame()
  # b = mtcars[, idx]
  # expect_equal(a, b, ignore_attr = TRUE)
  #
  # a = df[, c(1, 4, 2)]$collect()$to_data_frame()
  # b = mtcars[, c(1, 4, 2)]
  # expect_equal(a, b, ignore_attr = TRUE)
  #
  # idx = rep(FALSE, nrow(mtcars))
  # idx[c(1, 3, 6, 9)] = TRUE
  # a = df[idx, 1:3]$collect()$to_data_frame()
  # b = mtcars[idx, 1:3]
  # expect_equal(a, b, ignore_attr = TRUE)
  #
  # a = df[3:7, 1:3]$collect()$to_data_frame()
  # b = mtcars[3:7, 1:3]
  # expect_equal(a, b, ignore_attr = TRUE)
})

