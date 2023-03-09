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
  expect_grepl_error(pl$when(complex(2)),c("in pl\\$when","predicate","not convertable into Expr"))

  #TODO contribute polars, suggest all When function has str_to_lit FALSE
  # a literal string expr does not result in a boolean mask so it has little use to assume lit
  # and not col

})


test_that("whenthen", {
  expect_true(inherits(pl$when("a")$then("b"),"WhenThen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE),"WhenThen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE)$when(NA),"WhenThenThen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE)$otherwise(NA),"Expr"))
  expect_grepl_error(
    pl$when("a")$then(complex(2)),
    c("in when\\$then","expr","not convertable into Expr")
  )
})


test_that("whenthenthen", {
  expect_true(inherits(pl$when("a")$then("b")$when("c"),"WhenThenThen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE)$when(TRUE),"WhenThenThen"))
  wtt = pl$when("a")$then("b")$when("c")
  expect_true(inherits(wtt$then("a"),"WhenThenThen"))
  expect_true(inherits(wtt$then("d")$otherwise("e"), "Expr"))
  wtt_peak_txt = paste(capture.output(wtt$then(42)$peak_inside()),collapse="\n")
  expect_true(grepl("WHEN Utf8", wtt_peak_txt))
  expect_true(grepl("this otherwise is not yet defined", wtt_peak_txt))



  #TODO contribute polars, no panic on bad when then otherwise syntax like this
  #wtt$otherwise("e")
  #wtt$peak_inside() # will fail




  expect_grepl_error(wtt$when(complex(1)), c("in WhenThenThen\\$when", "predicate", "into Expr"))
  expect_grepl_error(wtt$then(complex(1)), c("in WhenThenThen\\$then", "expr", "into Expr"))
  expect_grepl_error(
    wtt$otherwise(complex(1)), c("in WhenThenThen\\$otherwise", "expr", "into Expr")
  )
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

  wtt =
    pl$when(pl$col("cyl")<=4)$then("<=4cyl")$
    when(pl$col("cyl")<=6)$then("<=6cyl")$
    otherwise(">6cyl")
  df_act =  df$select(wtt)

  expect_identical(
    df_act$to_list()[[1]],
    sapply(
      df$to_list()$cyl, \(x){
        if(x<=4) return("<=4cyl")
        if(x<=6) return("<=6cyl")
        return(">6cyl")
      }
    )
  )

})



