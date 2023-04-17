make_cases <- function() {
  tibble::tribble(
    ~.test_name, ~pola,   ~base,
    "mean",       "mean",   mean,
    "median",     "median", stats::median,
    "min",        "min",    min,
    "max",        "max",    max,
    "sum",        "sum",    sum,
  )
}
patrick::with_parameters_test_that("aggregations",
  {
    d <- pl$DataFrame(mtcars)
    w <- d[[pola]]()$as_data_frame()
    x <- base(d)$as_data_frame()
    y <- base(d$lazy())$collect()$as_data_frame()
    z <- data.frame(t(sapply(mtcars, base)))
    expect_equal(w, x, ignore_attr = TRUE)
    expect_equal(w, y, ignore_attr = TRUE)
    expect_equal(w, z, ignore_attr = TRUE)
  },
  .cases = make_cases()
)


make_cases <- function() {
  tibble::tribble(
    ~.test_name, ~FUN,
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
    d <- pl$DataFrame(mtcars)
    x <- FUN(mtcars)
    y <- FUN(d)
    z <- FUN(d$lazy())
    if (inherits(y, "DataFrame")) y <- y$as_data_frame()
    if (inherits(z, "LazyFrame")) z <- z$collect()$as_data_frame()
    expect_equal(x, y, ignore_attr = TRUE)
    expect_equal(x, z, ignore_attr = TRUE)
  },
  .cases = make_cases()
)


make_cases <- function() {
  tibble::tribble(
    ~.test_name, ~pola,   ~base,
    "length",     "len",    length,
    "min",        "min",    min,
    "max",        "max",    max,
    "sum",        "sum",    sum,
  )
}
patrick::with_parameters_test_that("Series",
  {
    d <- pl$Series(mtcars$mpg)
    x <- base(mtcars$mpg)
    y <- base(d)
    z <- d[[pola]]()
    if (inherits(y, "Series")) y <- y$to_r_vector()
    if (inherits(z, "Series")) z <- z$to_r_vector()
    expect_equal(x, y, ignore_attr = TRUE)
    expect_equal(x, z, ignore_attr = TRUE)
  },
  .cases = make_cases()
)
