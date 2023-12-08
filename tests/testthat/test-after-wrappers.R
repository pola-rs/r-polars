test_that("public and private functions in pl and .pr", {
  expect_snapshot(ls(pl))
  expect_snapshot(ls(.pr))
})


make_class_cases = function() {
  tibble::tribble(
    ~.test_name, ~class_name, ~private_key,
    "DataFrame", "RPolarsDataFrame", "DataFrame",
    "GroupBy", "GroupBy", NULL,
    "LazyFrame", "RPolarsLazyFrame", "LazyFrame",
    "Expr", "RPolarsExpr", "Expr",
    "When", "RPolarsWhen", "When",
    "Then", "RPolarsThen", "Then",
    "ChainedWhen", "RPolarsChainedWhen", "ChainedWhen",
    "ChainedThen", "RPolarsChainedThen", "ChainedThen",
    "RField", "RPolarsRField", "RField",
    "RPolarsSeries", "RPolarsSeries", "Series",
    "RThreadHandle", "RPolarsRThreadHandle", "RThreadHandle",
    "RPolarsSQLContext", "RPolarsSQLContext", "RPolarsSQLContext", # TODO: Update private key to `SQLContext`
  )
}


patrick::with_parameters_test_that("public and private methods of each class",
  {
    expect_snapshot(ls(.pr$env[[class_name]]))
    if (!is.null(private_key)) {
      expect_snapshot(ls(.pr[[private_key]]))
    }
  },
  .cases = make_class_cases()
)
