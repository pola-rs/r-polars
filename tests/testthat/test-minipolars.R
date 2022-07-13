test_that("create expression and print", {
  expr = pl::col("sweetnes")$sum()$over(c("color","country"))
  testthat::expect_identical(
    capture.output(expr$print()),
    "col(\"sweetnes\").sum().over([col(\"color\"), col(\"country\")])"
  )
})


test_that("create series and print", {
  series = pl::series(c(1,2,3,4,5),"sweetnes")
  testthat::expect_identical(
    capture.output(series$print()),
    c("shape: (5,)", "Series: 'sweetnes' [f64]", "[", "\t1.0", "\t2.0",
      "\t3.0", "\t4.0", "\t5.0", "]")
  )
})


