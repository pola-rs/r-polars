test_that("expression boolean operators", {

  expect_equal(class( pl$col("foo") == pl$col("bar")), "Expr")
  expect_equal(class( pl$col("foo") <= pl$col("bar")), "Expr")
  expect_equal(class( pl$col("foo") >= pl$col("bar")), "Expr")
  expect_equal(class( pl$col("foo") != pl$col("bar")), "Expr")

  expect_equal(class( pl$col("foo") > pl$lit(5)), "Expr")
  expect_equal(class( pl$col("foo") < pl$lit(5)), "Expr")
  expect_equal(class( pl$col("foo") > 5), "Expr")
  expect_equal(class( pl$col("foo") < 5), "Expr")
  expect_equal(class( !pl$col("foobar")), "Expr")


  cmp_operators_df = pl$DataFrame(list())$with_columns(
    (pl$lit(1)<2)$alias("1 lt 2"),
    (pl$lit(1)<1)$alias("1 lt 1 not")$not(),

    (pl$lit(2)>1)$alias("2 gt 1"),
    (pl$lit(1)>1)$alias("1 gt 1 not")$not(),

    (pl$lit(1)==1)$alias("1 eq 1"),
    (pl$lit(1)==2)$alias("1 eq 2 not")$not(),

    (pl$lit(1)<=1)$alias("1 lt_eq 1"),
    (pl$lit(2)<=1)$alias("2 lt_eq 1 not")$not()$not(), #TODO extra not when polars rust > 24.3

    (pl$lit(2)>=2)$alias("2 gt_eq 2"),
    (pl$lit(1)>=2)$alias("1 gt_eq 2 not")$not(),

    (pl$lit(2)!=1)$alias("2 not eq 1"),
    (pl$lit(2)!=2)$alias("2 not eq 1 not")$not(),

    pl$lit(TRUE)$not() == pl$lit(FALSE)$alias("not true == false"),
    pl$lit(TRUE) != pl$lit(FALSE)$alias("true != false"),

    (pl$lit(TRUE)$not() == FALSE)$alias("not true == false wrap"),
    (pl$lit(TRUE) != FALSE)$alias("true != false wrap")
  )

  results  = unlist(  cmp_operators_df$to_list())
  fails = results[!unlist(results)]
  expect_equal(names(fails), character())

})

test_that("expression Arithmetics", {
  check_list = pl$DataFrame(list())$with_columns(
    (pl$lit(1) / 2 == (1/2))$alias("1 /2 == (1/2)"),
    (pl$lit(1) + 2 == (1+2))$alias("1 +2 == (1+2)"),
    (pl$lit(1) * 2 == (1*2))$alias("1 *2 == (1*2)"),
    (pl$lit(1) - 2 == (1-2))$alias("1 -2 == (1-2)"),

    (pl$lit(1)$div(pl$lit(2)) == (1/2))$alias("1$div(2) == (1/2)"),
    (pl$lit(1)$add(pl$lit(2)) == (1+2))$alias("1$add(2) == (1+2)"),
    (pl$lit(1)$mul(pl$lit(2)) == (1*2))$alias("1$mul(2) == (1*2)"),
    (pl$lit(1)$sub(pl$lit(2)) == (1-2))$alias("1$sub(2) == (1-2)")
  )$as_data_frame(check.names=FALSE)

  results  = unlist(check_list)
  fails = results[!unlist(results)]
  expect_equal(names(fails), character())
})


test_that("count + unique + n_unique", {
  expect_equal(
    unlist(pl$DataFrame(iris)$select(pl$all()$unique()$count())$as_data_frame()),
    sapply(iris, \(x) length(unique(x)))
  )

  expect_equal(
    unlist(pl$DataFrame(iris)$select(pl$all()$n_unique())$as_data_frame()),
    sapply(iris, \(x) length(unique(x)))
  )

  expect_equal(
    pl$DataFrame(list(a = 1:100))$select(pl$all()$unique(maintain_order = TRUE))$to_list(),
    list(a = 1:100)
  )

})


test_that("drop_nans drop_nulls", {

  x = c(1.0,2.0,NaN,NA)

  expect_equal(
    pl$DataFrame(list(x=x))$select(pl$col("x")$drop_nans()$drop_nulls())$get_column("x")$to_r(),
    c(1.0,2.0)
  )

  expect_equal(
    pl$DataFrame(list(x=x))$select(pl$col("x")$drop_nans()$drop_nulls()$count())$get_column("x")$to_r(),
    2L
  )

  expect_equal(
    pl$DataFrame(list(x=x))$select(pl$col("x")$drop_nulls())$get_column("x")$to_r(),
    c(1.0,2.0,NaN)
  )

  expect_equal(
    pl$DataFrame(list(x=x))$select(pl$col("x")$drop_nans())$get_column("x")$to_r(),
    c(1.0,2.0,NA)
  )


})

test_that("first last heaad tail", {

  check_list = pl$DataFrame(list(a=1:11))$select(
    (pl$col("a")$first() == 1L)$alias("1 is first"),
    (pl$col("a")$last() == 11L)$alias("11 is last")

  )$as_data_frame(check.names=FALSE)

  results  = unlist(check_list)
  fails = results[!unlist(results)]
  expect_equal(names(fails), character())

  df = pl$DataFrame(list(a=1:11))$select(
    pl$col("a")$head()$alias("head10"),
    pl$col("a")$tail()$alias("tail10")
  )$as_data_frame()

  expect_equal(
    df,
    data.frame(head10 = 1:10, tail10=2:11)
  )

  df = pl$DataFrame(list(a=1:11))$select(
    pl$col("a")$head(2)$alias("head2"),
    pl$col("a")$tail(2)$alias("tail2")
  )$as_data_frame()
  expect_equal(
    df,
    data.frame(head2 = 1:2, tail2=10:11)
  )

})

test_that("is_null", {

  df = pl$DataFrame(
    list(
      "a" =  c(1, 2, NA, 1, 5),
      "b" =  c(1.0, 2.0, NaN, 1.0, 5.0)
    )
  )

  expect_equal(
    df$with_columns(pl$all()$is_null()$suffix("_isnull"))$as_data_frame(),
    data.frame(
      a=c(1:2,NA_integer_,1L,5L),
      b=c(1,2,NaN,1,5),
      a_isnull=c(F,F,T,F,F),
      b_isnull=rep(F,5)
    )
  )

  expect_equal(
    df$with_columns(pl$all()$is_not_null()$suffix("_isnull"))$as_data_frame(),
    df$with_columns(pl$all()$is_null()$not()$suffix("_isnull"))$as_data_frame()
  )

})

test_that("min max", {

  check_list = pl$DataFrame(list(x=c(1,NA,3)))$select(
    (pl$col("x")$max() == 3L)$alias("3 is max"),
    (pl$col("x")$min() == 1L)$alias("1 not null is min")
  )$as_data_frame()

  results  = unlist(check_list)
  fails = results[!unlist(results)]
  expect_equal(names(fails), character())

})

test_that("over", {


  df = pl$DataFrame(list(
    val=1:5,
    a=c("+","+","-","-","+"),
    b=c("+","-","+","-","+"))
  )$select(
    pl$col("val")$count()$over("a",pl$col("b"))
  )

  expect_equal(
    df$get_column("val")$to_r(),
    c(2,1,1,1,2)
  )


})

test_that("col DataType", {

  expect_equal(
    pl$DataFrame(iris)$select(pl$col(pl$dtypes$Float64))$as_data_frame(),
    iris[,sapply(iris,is.numeric)]
  )

  iris_str = iris
  iris_str$Species = as.character(iris$Species)
  expect_equal(
    pl$DataFrame(iris)$select(pl$col(list(pl$dtypes$Float64,pl$dtypes$Utf8)))$as_data_frame(),
    iris_str
  )

})



test_that("lit expr", {
  expect_error(pl$lit(NA_character_))
  expect_error(pl$lit(NA))

  expect_identical(
    pl$DataFrame(list(a = 1:4))$filter(pl$col("a")>2L)$as_data_frame()$a,
    3:4
  )

  expect_identical(
    pl$DataFrame(list(a = letters))$filter(pl$col("a")>="x")$as_data_frame()$a,
    c("x","y","z")
  )

  expect_identical(
    pl$DataFrame(list(a = letters))$filter(pl$col("a")>=pl$lit(NULL))$as_data_frame(),
    data.frame(a=character())
  )

})

test_that("prefix suffix reverse", {
  df = pl$DataFrame(list(
    A = c(1, 2, 3, 4, 5),
    fruits = c("banana", "banana", "apple", "apple", "banana"),
    B = c(5, 4, 3, 2, 1),
    cars = c("beetle", "audi", "beetle", "beetle", "beetle")
  ))

  df2 = df$select(
    pl$all(),
    pl$all()$reverse()$suffix("_reverse")
  )
  expect_equal(
    df2$columns,
    c(df$columns,paste0(df$columns,"_reverse"))
  )

  df3 = df$select(
    pl$all(),
    pl$all()$reverse()$prefix("reverse_")
  )
  expect_equal(
    df3$columns,
    c(df$columns,paste0("reverse_",df$columns))
  )

  expect_equal(
    df2$get_column("A_reverse")$to_r(),
    rev(df2$get_column("A")$to_r())
  )



})
