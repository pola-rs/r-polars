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
    (pl$lit(1)<1)$alias("1 lt 1 not")$is_not(),

    (pl$lit(2)>1)$alias("2 gt 1"),
    (pl$lit(1)>1)$alias("1 gt 1 not")$is_not(),

    (pl$lit(1)==1)$alias("1 eq 1"),
    (pl$lit(1)==2)$alias("1 eq 2 not")$is_not(),

    (pl$lit(1)<=1)$alias("1 lt_eq 1"),
    (pl$lit(2)<=1)$alias("2 lt_eq 1 not")$is_not()$is_not(), #TODO extra not when polars rust > 24.3

    (pl$lit(2)>=2)$alias("2 gt_eq 2"),
    (pl$lit(1)>=2)$alias("1 gt_eq 2 not")$is_not(),

    (pl$lit(2)!=1)$alias("2 not eq 1"),
    (pl$lit(2)!=2)$alias("2 not eq 1 not")$is_not(),

    pl$lit(TRUE)$is_not() == pl$lit(FALSE)$alias("not true == false"),
    pl$lit(TRUE) != pl$lit(FALSE)$alias("true != false"),

    (pl$lit(TRUE)$is_not() == FALSE)$alias("not true == false wrap"),
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
    unlist(pl$DataFrame(iris)$select(pl$all()$unique()$len())$as_data_frame()),
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
    df$with_columns(pl$all()$is_null()$is_not()$suffix("_isnull"))$as_data_frame()
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

test_that("col DataType + col(s) + col regex", {

  #one Datatype
  expect_equal(
    pl$DataFrame(iris)$select(pl$col(pl$dtypes$Float64))$as_data_frame(),
    iris[,sapply(iris,is.numeric)]
  )

  #multiple
  expect_equal(
    pl$DataFrame(iris)$select(pl$col(list(pl$Float64,pl$Categorical)))$as_data_frame(),
    iris
  )

  #multiple cols
  Names = c("Sepal.Length","Sepal.Width")
  expect_equal(
    pl$DataFrame(iris)$select(pl$col(Names))$as_data_frame(),
    iris[,Names]
  )

  #regex
  expect_equal(
    pl$DataFrame(iris)$select(pl$col("^Sepal.*$"))$as_data_frame(),
    iris[,Names]
  )

  #warn no multiple regex

  expect_warning(
    pl$col(c("^Sepal.*$","Species"))
  )

})



test_that("lit expr", {

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

test_that("and or is_in xor", {
  df = pl$DataFrame(list())
  expect_true( df$select(pl$lit(T)&T)$as_data_frame()[[1]])
  expect_true(!df$select(pl$lit(T)&F)$as_data_frame()[[1]])
  expect_true(!df$select(pl$lit(F)&T)$as_data_frame()[[1]])
  expect_true(!df$select(pl$lit(F)&F)$as_data_frame()[[1]])

  expect_true( df$select(pl$lit(T)|T)$as_data_frame()[[1]])
  expect_true( df$select(pl$lit(T)|F)$as_data_frame()[[1]])
  expect_true( df$select(pl$lit(F)|T)$as_data_frame()[[1]])
  expect_true(!df$select(pl$lit(F)|F)$as_data_frame()[[1]])

  expect_true(!df$select(pl$lit(T)$xor(pl$lit(T)))$as_data_frame()[[1]])
  expect_true( df$select(pl$lit(T)$xor(pl$lit(F)))$as_data_frame()[[1]])
  expect_true( df$select(pl$lit(F)$xor(pl$lit(T)))$as_data_frame()[[1]])
  expect_true(!df$select(pl$lit(F)$xor(pl$lit(F)))$as_data_frame()[[1]])

  df = pl$DataFrame(list(a=c(1:3,NA_integer_)))
  expect_true( df$select(pl$lit(1L)$is_in(pl$col("a")))$as_data_frame()[[1]])
  expect_true(!df$select(pl$lit(4L)$is_in(pl$col("a")))$as_data_frame()[[1]])


  #NA_int == NA_int
  expect_identical(
    pl$DataFrame(list(a=c(1:4,NA_integer_)))$select(pl$col("a")$is_in(pl$lit(NA_integer_)))$as_data_frame()[[1]],
    c(1:4,NA_integer_) %in% NA_real_
  )

  #both R and polars aliases NA_int_ with NA_real_ in comparisons
  expect_identical(
    pl$DataFrame(list(a=c(1:4,NA_integer_)))$select(pl$col("a")$is_in(pl$lit(NA_real_)))$as_data_frame()[[1]],
    c(1:4,NA_integer_) %in% NA_real_
  )



  #not sure if polars have a good consistant logical system, anyways here are some statements which were true when writing this
  #TODO discuss with polars team
  expect_true(
    pl$DataFrame(list())$select(
      #nothing is nothing
      pl$lit(NULL) == pl$lit(NULL)$alias("NULL is NULL"),

      #nothing is typed nothing
      pl$lit(NULL) == pl$lit(NA_real_)$alias("NULL is NULL_real"),

      #typed nothing is typed nothing
      pl$lit(NA_real_) == pl$lit(NA_real_)$alias("NULL_eral is NULL_real"),

      #type nothing is IN nothing
      pl$lit(NA_real_)$is_in(pl$lit(NA_real_))$alias("NULL typed is in  NULL typed"),

      #neither typed nor untyped NULL is IN NULL
      pl$lit(NA_real_)$is_in(pl$lit(NULL))$is_not()$alias("NULL typed is in NULL, NOT"),
      pl$lit(NULL)$is_in(pl$lit(NULL))$is_not()$alias("NULL is in NULL, NOY")
    )$as_data_frame() |> unlist() |> all()
  )



})


test_that("to_physical + cast", {

  #to_physical and some casting
  df  = pl$DataFrame(
    list(vals = c("a", "x", NA, "a"))
  )$with_columns(
    pl$col("vals")$cast(pl$Categorical),
    pl$col("vals")
      $cast(pl$Categorical)
      $to_physical()
      $alias("vals_physical")
  )

  expect_identical(
    df$as_data_frame(),
    data.frame(
      vals = factor(c("a","x",NA_character_,"a")),
      vals_physical = c(0:1,NA_real_,0) #u32 casted to real to preserve full range
    )
  )
  df


  #cast error raised for Utf8 to Boolean
  expect_error(
    pl$DataFrame(iris)$with_columns(
      pl$col("Species")$cast(pl$dtypes$Utf8)$cast(pl$dtypes$Boolean)
    )
  )


  #down cast big number
  df_big_n = pl$DataFrame(list(big = 2^50))$with_columns(pl$col("big")$cast(pl$Int64))


  #error overflow, strict TRUE
  expect_error(df_big_n$with_columns(pl$col("big")$cast(pl$Int32))  )

  #NA_int for strict_
  expect_identical(
    df_big_n$with_columns(pl$col("big")$cast(pl$Int32,strict=FALSE))$as_data_frame()$big,
    NA_integer_
  )

  #strict = FALSE yield NULL for overflow
  expect_identical(
    df_big_n$with_columns(pl$col("big")$cast(pl$Int32,strict=FALSE)$is_null())$as_data_frame()$big,
    TRUE
  )

  #no overflow to Int64
  expect_identical(
    df_big_n$with_columns(pl$col("big")$cast(pl$Int64)$is_null())$as_data_frame()$big,
    FALSE
  )



})


test_that("pow, rpow, sqrt, log10", {


  #pow
  expect_identical(pl$DataFrame(list(a = -1:3))$select(pl$lit(2)$pow(pl$col("a")))$get_column("literal")$to_r(), 2^(-1:3))
  expect_identical(pl$DataFrame(list(a = -1:3))$select(pl$lit(2) ^ pl$col("a") )$get_column("literal")$to_r(), 2^(-1:3))

  #rpow
  expect_identical( pl$DataFrame(list(a = -1:3))$select(pl$lit(2)$rpow(pl$col("a")))$get_column("a")$to_r(), (-1:3)^2)
  expect_identical( pl$DataFrame(list(a = -1:3))$select(pl$lit(2) %**% (pl$col("a")))$get_column("a")$to_r(), (-1:3)^2)


  #sqrt
  expect_identical(
    pl$DataFrame(list(a = -1:3))$select(pl$col("a")$sqrt())$get_column("a")$to_r(),
    suppressWarnings(sqrt(-1:3))
  )

  #log10
  expect_equal(
    pl$DataFrame(list(a = 10^(-1:3)))$select(pl$col("a")$log10())$as_data_frame()$a,
    -1:3
  )

  #log
  expect_equal(pl$DataFrame(list(a = exp(1)^(-1:3)))$select(pl$col("a")$log())$as_data_frame()$a,-1:3)
  expect_equal(pl$DataFrame(list(a = .42^(-1:3)))$select(pl$col("a")$log(0.42))$as_data_frame()$a,-1:3)

  #exp
  log10123 = suppressWarnings(log(-1:3))
  expect_equal(
    pl$DataFrame(list(a = log10123))$select(pl$col("a")$exp())$as_data_frame()$a,
    exp(1)^log10123
  )



})


test_that("exclude" , {

  #string column name
  df = pl$DataFrame(iris)
  expect_identical(
    df$select(pl$all()$exclude("Species"))$columns,
    c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")
  )

  #string regex
  expect_identical(
    df$select( pl$all()$exclude("^Sepal.*$"))$columns,
    c("Petal.Length", "Petal.Width", "Species")
  )

  #char vec
  expect_identical(
   df$select(pl$all()$exclude(c("Species","Petal.Width")))$columns,
   c("Sepal.Length", "Sepal.Width", "Petal.Length")
  )

  #char list
  expect_identical(
    df$select(pl$all()$exclude(list("Species","Petal.Width")))$columns,
    c("Sepal.Length", "Sepal.Width", "Petal.Length")
  )
  expect_error(
    df$select(pl$all()$exclude(list("Species",pl$Boolean)))$columns
  )


  #single DataType
  expect_identical(
    df$select(pl$all()$exclude(pl$Categorical))$columns,
    names(iris)[1:4]
  )
  expect_identical(
    df$select(pl$all()$exclude(pl$Float64))$columns,
    names(iris)[5]
  )

  #list DataType
  expect_identical(
    df$select(pl$all()$exclude(list(pl$Float64,pl$Categorical)))$columns,
    names(iris)[c()]
  )

  #wrong cast is not possible
  expect_error(
    unwrap(.pr$DataTypeVector$from_rlist(list(pl$Float64,pl$Categorical,"imNoYourType")))
  )
  expect_error(
    df$select(pl$all()$exclude(list(pl$Float64,pl$Categorical,"bob")))$columns
  )

})

test_that("keep_name" , {
  expect_identical(
    pl$DataFrame(list(alice=1:3))$select(
      pl$col("alice")$alias("bob")$keep_name(),
      pl$col("alice")$alias("bob")
    )$columns,
    c("alice","bob")

  )

})



test_that("map_alias" , {
  df = pl$DataFrame(list(alice=1:3))$select(
    pl$col("alice")$alias("joe_is_not_root")$map_alias(\(x) paste0(x,"_and_bob"))
  )
  lf = df$lazy()
  expect_identical(lf$collect()$columns, "alice_and_bob")

  expect_error(
    pl$DataFrame(list(alice=1:3))$select(
      pl$col("alice")$map_alias(\(x) 42) #wrong return
    ),
    "^select\\ panicked.$"
  )

  out_error = tryCatch(
    pl$DataFrame(list(alice=1:3))$select(
      pl$col("alice")$map_alias(\(x) stop("user fun error")) #wrong return
    ),
    error = function(e) as.character(e)
  )
  expect_identical(
    out_error,
    "Error in .pr$DataFrame$select(self, exprs): select panicked.\n",

  )


  expect_error(
    pl$DataFrame(list(alice=1:3))$select(
      pl$col("alice")$map_alias(\() "bob") #missing param
    ),
    class = "not_one_arg"
  )

  expect_error(
    pl$DataFrame(list(alice=1:3))$select(
      pl$col("alice")$map_alias("not a function") #not a fun
    ),
    class = "not_fun"
  )
})


test_that("finite infinte is_nan is_not_nan", {

  #TODO contribute polars NULL behavoir of is_nan and is_not_nan is not documented and not obvious
  expect_identical(
    pl$DataFrame(list(a=c(0,NaN,NA,Inf,-Inf)))$select(
      pl$col("a")$is_finite(  )$alias("is_finite"),
      pl$col("a")$is_infinite()$alias("is_infinite"),
      pl$col("a")$is_nan()$alias("is_nan"),
      pl$col("a")$is_not_nan()$alias("is_not_nan")
    )$to_list(),
    list(
      is_finite   = c(T,F,NA,F,F),
      is_infinite = c(F,F,NA,T,T),
      is_nan      = c(F,T,NA,F,F),
      is_not_nan  = c(T,F,T ,T,T)
    )
  )

})

test_that("slice", {

  l = list(a=0:100,b=100:0)

  #as head
  expect_identical(
    pl$DataFrame(l)$select(
      pl$all()$slice(0,6)
    )$to_list(),
    lapply(l,head)
  )

  #as tail
  expect_identical(
    pl$DataFrame(l)$select(
      pl$all()$slice(-6,6)
    )$to_list(),
    lapply(l,tail)
  )

  #use expression as input
  expect_identical(
    pl$DataFrame(l)$select(
      pl$all()$slice(0,pl$col("a")$len()/2)
    )$to_list(),
    lapply(l,head,length(l$a)/2)
  )

})

test_that("Expr_append", {
  #append bottom to to row
  df = pl$DataFrame(list(a = 1:3, b = c(NA_real_,4,5)))
  expect_identical(
    df$select(pl$all()$head(1)$append(pl$all()$tail(1)))$to_list(),
    list(a=c(1L,3L), b = c(NA_real_,5))
  )

  #implicit upcast, when default = TRUE
  expect_identical(
    pl$DataFrame(list())$select(pl$lit(42)$append(42L))$to_list(),
    list(literal = c(42,42))
  )

  expect_identical(
    pl$DataFrame(list())$select(pl$lit(42)$append(FALSE))$to_list(),
    list(literal = c(42,0))
  )

  expect_identical(
    pl$DataFrame(list())$select(pl$lit("Bob")$append(FALSE))$to_list(),
    list(literal = c("Bob","false"))
  )

  expect_error(
    pl$DataFrame(list())$select(pl$lit("Bob")$append(FALSE,upcast=FALSE)),
   "match"
  )

})


test_that("Expr_rechunk Series_chunk_lengths", {
  series_list = pl$DataFrame(list(a=1:3,b=4:6))$select(
    pl$col("a")$append(pl$col("b"))$alias("a_chunked"),
    pl$col("a")$append(pl$col("b"))$rechunk()$alias("a_rechunked")
  )$get_columns()
  expect_identical(
    lapply(series_list, \(x) x$chunk_lengths()),
    list(
      a_chunked = c(3,3),
      a_rechunked = 6
    )
  )
})
