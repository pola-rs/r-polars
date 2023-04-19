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
        z = FUN(d$lazy())
        if (inherits(y, "DataFrame")) y = y$to_data_frame()
        if (inherits(z, "LazyFrame")) z = z$collect()$to_data_frame()
        expect_equal(x, y, ignore_attr = TRUE)
        expect_equal(x, z, ignore_attr = TRUE)
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
  expect_equal(nrow(na.omit(dl)), 28)
  expect_equal(nrow(na.omit(dl, subset = "hp")), 31)
  expect_equal(nrow(na.omit(dl, subset = c("mpg", "hp"))), 28)
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
