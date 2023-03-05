test_that("when", {
  expect_true(inherits(pl$when("columnname"),"When"))
  expect_true(inherits(pl$when(TRUE),"When"))
  expect_true(inherits(pl$when(1:4),"When"))

  #string "a" is not interpreted as column
  e_actual = pl$when("a")$then("b")$otherwise("c")
  e_expected = pl$when(pl$col("a"))$then("b")$otherwise("c")
  expect_false(e_actual$meta$eq(e_expected))

  #printing works
  expect_true(grepl("polars When",capture.output(print(pl$when("a")))))
})


test_that("whenthen", {
  expect_true(inherits(pl$when("a")$then("b"),"WhenThen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE),"WhenThen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE)$when(NA),"WhenThenThen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE)$otherwise(NA),"Expr"))
})


test_that("whenthenthen", {
  expect_true(inherits(pl$when("a")$then("b")$when("c"),"WhenThenThen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE)$when(TRUE),"WhenThenThen"))
  wtt = pl$when("a")$then("b")$when("c")
  expect_true(inherits(wtt$then("a"),"WhenThenThen"))
  expect_true(inherits(wtt$then("d")$otherwise("e"), "Expr"))

  #TODO contribute polars, no panic on bad when then otherwise syntax like this
  #wtt$otherwise("e")
})


test_that("when-then-otherwise", {

  df = pl$DataFrame(mtcars)
  e = pl$when(pl$col("cyl")>4)$
    then(">4cyl")$
    otherwise("<=4cyl")


  expect_identical(
    df$select(e)$to_list(),
    list(literal = ifelse(df$to_list()$cyl>4, ">4cyl", "<=4cyl"))
  )

   wtt = pl$when(pl$col("cyl")<=4)$
    then("<=4cyl")$
      when(pl$col("cyl")<=6)$
      then("<=6cyl")$
    otherwise(">6cyl")
    df$with_columns(wtt)


})
