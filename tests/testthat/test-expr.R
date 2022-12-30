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
    (pl$lit(2)<=1)$alias("2 lt_eq 1 not")$is_not(),

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

  #limit is an alias for head
  df = pl$DataFrame(list(a=1:11))$select(
    pl$col("a")$limit(2)$alias("limit2"),
    pl$col("a")$tail(2)$alias("tail2")
  )$as_data_frame()
  expect_equal(
    df,
    data.frame(limit2 = 1:2, tail2=10:11)
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


  #explicit vector to series to literal
  expect_identical(
    pl$DataFrame(list())$select(pl$lit(pl$Series(1:4)))$to_list()[[1L]],
   1:4
  )

  #implicit vector to literal
  expect_identical(
    pl$DataFrame(list())$select(pl$lit(24) / 4:1 + 2)$to_list()[[1L]],
    24 / 4:1 + 2
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
  expect_true( df$select(pl$lit(T)&T)$as_data_frame()[[1L]])
  expect_true(!df$select(pl$lit(T)&F)$as_data_frame()[[1L]])
  expect_true(!df$select(pl$lit(F)&T)$as_data_frame()[[1L]])
  expect_true(!df$select(pl$lit(F)&F)$as_data_frame()[[1L]])

  expect_true( df$select(pl$lit(T)|T)$as_data_frame()[[1L]])
  expect_true( df$select(pl$lit(T)|F)$as_data_frame()[[1L]])
  expect_true( df$select(pl$lit(F)|T)$as_data_frame()[[1L]])
  expect_true(!df$select(pl$lit(F)|F)$as_data_frame()[[1L]])

  expect_true(!df$select(pl$lit(T)$xor(pl$lit(T)))$as_data_frame()[[1L]])
  expect_true( df$select(pl$lit(T)$xor(pl$lit(F)))$as_data_frame()[[1L]])
  expect_true( df$select(pl$lit(F)$xor(pl$lit(T)))$as_data_frame()[[1L]])
  expect_true(!df$select(pl$lit(F)$xor(pl$lit(F)))$as_data_frame()[[1L]])

  df = pl$DataFrame(list(a=c(1:3,NA_integer_)))
  expect_true( df$select(pl$lit(1L)$is_in(pl$col("a")))$as_data_frame()[[1L]])
  expect_true(!df$select(pl$lit(4L)$is_in(pl$col("a")))$as_data_frame()[[1L]])


  #NA_int == NA_int
  expect_identical(
    pl$DataFrame(list(a=c(1:4,NA_integer_)))$select(pl$col("a")$is_in(pl$lit(NA_integer_)))$as_data_frame()[[1L]],
    c(1:4,NA_integer_) %in% NA_real_
  )

  #both R and polars aliases NA_int_ with NA_real_ in comparisons
  expect_identical(
    pl$DataFrame(list(a=c(1:4,NA_integer_)))$select(pl$col("a")$is_in(pl$lit(NA_real_)))$as_data_frame()[[1L]],
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


#TODO find alternative to thread panic test
test_that("map_alias" , {


  #skip map_alias thread-guard message
  pl$set_rpolars_options(no_messages = TRUE)

  df = pl$DataFrame(list(alice=1:3))$select(
    pl$col("alice")$alias("joe_is_not_root")$map_alias(\(x) paste0(x,"_and_bob"))
  )
  lf = df$lazy()
  expect_identical(lf$collect()$columns, "alice_and_bob")


  # expect_error(
  #   pl$DataFrame(list(alice=1:3))$select(
  #     pl$col("alice")$map_alias(\(x) 42) #wrong return
  #   ),
  #   "^select\\ panicked.$"
  # )

  # out_error = tryCatch(
  #   pl$DataFrame(list(alice=1:3))$select(
  #     pl$col("alice")$map_alias(\(x) stop("user fun error")) #wrong return
  #   ),
  #   error = function(e) as.character(e)
  # )
  # expect_identical(
  #   out_error,
  #   "Error in .pr$DataFrame$select(self, exprs): select panicked.\n",
  #
  # )


  # expect_error(
  #   pl$DataFrame(list(alice=1:3))$select(
  #     pl$col("alice")$map_alias(\() "bob") #missing param
  #   ),
  #   class = "not_one_arg"
  # )

  # expect_error(
  #   pl$DataFrame(list(alice=1:3))$select(
  #     pl$col("alice")$map_alias("not a function") #not a fun
  #   ),
  #   class = "not_fun"
  # )


  pl$reset_rpolars_options()
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

test_that("cumsum cumprod cummin cummax cumcount", {
  l_actual = pl$DataFrame(list(a=1:4))$select(
    pl$col("a")$cumsum()$alias("cumsum"),
    pl$col("a")$cumprod()$alias("cumprod")$cast(pl$dtypes$Float64),
    pl$col("a")$cummin()$alias("cummin"),
    pl$col("a")$cummax()$alias("cummax"),
    pl$col("a")$cumcount()$alias("cumcount")
  )$to_list()
  l_reference = list(
    cumsum = cumsum(1:4),
    cumprod = cumprod(1:4),
    cummin = cummin(1:4),
    cummax = cummax(1:4),
    cumcount = seq_along(1:4)-1
  )
  expect_identical(
    l_actual,l_reference
  )

  l_actual_rev = pl$DataFrame(list(a=1:4))$select(
    pl$col("a")$cumsum(reverse = TRUE)$alias("cumsum"),
    pl$col("a")$cumprod(reverse = TRUE)$alias("cumprod")$cast(pl$dtypes$Float64),
    pl$col("a")$cummin(reverse = TRUE)$alias("cummin"),
    pl$col("a")$cummax(reverse = TRUE)$alias("cummax"),
    pl$col("a")$cumcount(reverse = TRUE)$alias("cumcount")
  )$to_list()

  expect_identical(
    l_actual_rev,
    list(
      cumsum = rev(cumsum(4:1)),
      cumprod = rev(cumprod(4:1)),
      cummin = rev(cummin(4:1)),
      cummax = rev(cummax(4:1)),
      cumcount = rev(seq_along(4:1))-1
    )
  )


})


test_that("floor ceil round", {
  l_input = list(
    a = c(0.33, 1.02, 1.5, NaN , NA, Inf, -Inf)
  )

  l_actual = pl$DataFrame(l_input)$select(
    pl$col("a")$floor()$alias("floor"),
    pl$col("a")$ceil()$alias("ceil"),
    pl$col("a")$round(0)$alias("round")
  )$to_list()

  l_expected = list(
    floor = floor(l_input$a),
    ceil  = ceiling(l_input$a),
    round = round(l_input$a)
  )

  expect_identical(
    l_actual,
    l_expected
  )

  #NOTICE R uses ROUND to even on most OS according to help(round)
  round(0.5) == 0


})

test_that("mode", {

 df = pl$DataFrame(list(
   a=1:6,
   b = c(1L,1L,3L,3L,5L,6L),
   c = c(1L,1L,2L,2L,3L,3L),
   d = c(NA,NA,NA,"b","b","b"))
 )
 expect_identical( sort(df$select(pl$col("a")$mode())$to_list()$a),1:6)
 expect_identical( sort(df$select(pl$col("b")$mode())$to_list()$b),c(1L,3L))
 expect_identical( sort(df$select(pl$col("c")$mode())$to_list()$c),c(1L,2L,3L))
 expect_identical( sort(df$select(pl$col("d")$mode())$to_list()$d,na.last =TRUE),c("b",NA))

})

#TODO contribute rust, Null does not carry in dot products, NaN do.
#cumsum does not carry Null either. Maybe it is by design.
test_that("dot", {

  l = list(a=1:4,b=c(1,2,3,5),c=c(NA_real_,1:3),d=c(6:8,NaN))
  actual_list = pl$DataFrame(l)$select(
    pl$col("a")$dot(pl$col("b"))$alias("a dot b"),
    pl$col("a")$dot(pl$col("a"))$alias("a dot a"),
    pl$col("a")$dot(pl$col("c"))$alias("a dot c"),
    pl$col("a")$dot(pl$col("d"))$alias("a dot d")
  )$to_list()

  expected_list = list(
    `a dot b` = (l$a %*% l$b)[1L],
    `a dot a` = as.integer((l$a %*% l$a)[1L]),
    `a dot c` = 20, # polars do not carry NA ((l$a %*% l$c)[1L]),
    `a dot d` = ((l$a %*% l$d)[1L])
  )

  expect_identical(
    actual_list,
    expected_list
  )
})


test_that("Expr_sort", {

  l = list(a = c(6,1, 0, NA, Inf,-Inf, NaN))

  l_actual = pl$DataFrame(l)$select(
    pl$col("a")$sort()$alias("sort"),
    pl$col("a")$sort(nulls_last=TRUE)$alias("sort_nulls_last"),
    pl$col("a")$sort(reverse=TRUE)$alias("sort_reverse"),
    pl$col("a")$sort(reverse=TRUE,nulls_last=TRUE)$alias("sort_reverse_nulls_last"),
    pl$col("a")
      $set_sorted(reverse=FALSE)
      $sort(reverse=FALSE,nulls_last=TRUE)
      $alias("fake_sort_nulls_last"),
    (
    pl$col("a")
      $set_sorted(reverse=TRUE)
      $sort(reverse=TRUE,nulls_last=TRUE)
      $alias("fake_sort_reverse_nulls_last")
    )
  )$to_list()


  #TODO contribute polars in Expr_sort NaN is a value above Inf, but NaN > Inf is false.
  #more correct use of nan would be slower though
  expect_identical(
    l_actual,
    list(
      sort = c(NA, -Inf, 0, 1, 6, Inf, NaN),
      sort_nulls_last = c(-Inf,0, 1, 6, Inf, NaN, NA),
      sort_reverse = c(NA, NaN, Inf, 6, 1, 0, -Inf),
      sort_reverse_nulls_last = c(NaN, Inf, 6, 1, 0, -Inf, NA),
      #this is a bit surprising, have raised in discord
      fake_sort_nulls_last = c(-Inf, 0, 1, 6, Inf, NaN, NA),
      fake_sort_reverse_nulls_last = c(NaN, Inf, 6, 1, 0, -Inf, NA)
    )
  )

  #without NUlls set_sorted does prevent sorting
  l2 = list(a = c(1,3,2,4, Inf,-Inf, NaN))
  l_actual2 = pl$DataFrame(l2)$select(
    pl$col("a")$sort()$alias("sort"),
    pl$col("a")$sort(nulls_last=TRUE)$alias("sort_nulls_last"),
    pl$col("a")$sort(reverse=TRUE)$alias("sort_reverse"),
    pl$col("a")$sort(reverse=TRUE,nulls_last=TRUE)$alias("sort_reverse_nulls_last"),
    pl$col("a")
    $set_sorted(reverse=FALSE)
    $sort(reverse=FALSE,nulls_last=TRUE)
    $alias("fake_sort_nulls_last"),
    (
      pl$col("a")
      $set_sorted(reverse=TRUE)
      $sort(reverse=TRUE,nulls_last=TRUE)
      $alias("fake_sort_reverse_nulls_last")
    )
  )$to_list()
  expect_identical(
    l_actual2,
    list(
      sort = c( -Inf, 1, 2,3,4, Inf, NaN),
      sort_nulls_last = c(-Inf,1, 2, 3,4, Inf, NaN),
      sort_reverse = c( NaN, Inf, 4, 3, 2, 1, -Inf),
      sort_reverse_nulls_last = c(NaN, Inf, 4, 3, 2, 1, -Inf),
      fake_sort_nulls_last = l2$a,
      fake_sort_reverse_nulls_last = l2$a
    )
  )

})


test_that("Expr_k_top", {

  l = list(a = c(6, 1, 0, NA, Inf,-Inf, NaN))

  #TODO contribute polars k_top always places NaN first no matter reverse,
  # this behavour does not match Expr_sort
  l_actual = pl$DataFrame(l)$select(
    pl$col("a")$top_k(3)$alias("k_top"),
    pl$col("a")$top_k(3,reverse=TRUE)$alias("k_top_rev")
  )$to_list()

  expect_identical(
    l_actual,
    list(
      k_top = c(NaN, Inf,6),
      k_top_rev = c(NaN,-Inf,0) #NaN lower and higher than any value
    )
  )

})


#TODO contribute polars $arg_max() is not the same as arg_sort()$tail(1)
test_that("arg_min arg_max arg_sort", {

  #current arg_min arg_max and arg_sort are not internally concistent
  # so this testing is just tracking if the behavior it how it used to be

  l = list(a = c(6, 1, 0, Inf,-Inf, NaN,NA))


  get_arg_min_max = function(l) {pl$DataFrame(l)$select(
    pl$col("a")$arg_min()$alias("arg_min"),
    pl$col("a")$arg_max()$alias("arg_max"),
    pl$col("a")$arg_sort()$head(1)$alias("arg_sort_head_1"),
    pl$col("a")$argsort()$head(1)$alias("argsort_head_1"), #aliased function
    pl$col("a")$arg_sort()$tail(1)$alias("arg_sort_tail_1")
  )$to_list()
  }

  #it seems Null/NA is smallest value (arg_min)
  #it seems Inf is largest value to (arg_max)
  #however it seems NaN (arg_sort().tail(1))
  lapply(get_arg_min_max(l), function(idx) l$a[idx+1])

  expect_identical(
    get_arg_min_max(l),
    list(arg_min = 6, arg_max = 3, arg_sort_head_1 = 6,argsort_head_1 = 6, arg_sort_tail_1 = 5)
  )

  l_actual = pl$DataFrame(l)$select(
    pl$col("a")$arg_sort()$alias("arg_sort default"),
    pl$col("a")$arg_sort(reverse=TRUE)$alias("arg_sort rev"),
    pl$col("a")$arg_sort(reverse=TRUE, nulls_last = TRUE)$alias("arg_sort rev nulls_last")
  )$to_list()

  #it seems Null/NA is not sorted and just placed first or last given null_lasts
  #it seems NaN is a value larger than Inf
  lapply(l_actual, function(idx) l$a[idx+1])


  expect_identical(
    l_actual,
    list(
      `arg_sort default` = c(6, 4, 2, 1, 0, 3, 5),
      `arg_sort rev` = c(5, 3, 0, 1, 2, 4, 6),
      `arg_sort rev nulls_last` = c(5, 3, 0, 1, 2, 4, 6)
    )
  )



})

test_that("search_sorted", {
  expect_identical(
    pl$DataFrame(list(a=0:100))$select(pl$col("a")$search_sorted(pl$lit(42L)))$to_list()$a,
    42
  )
  #this test is minimal, if polars give better documentation on behaviour, expand the test.
})



test_that("sort_by", {
    l = list(
      ab = c(rep("a",6),rep("b",6)),
      v4 = rep(1:4, 3),
      v3 = rep(1:3, 4),
      v2 = rep(1:2,6),
      v1 = 1:12
    )
    df = pl$DataFrame(l)

    expect_identical(
      df$select(
        pl$col("ab")$sort_by("v4")$alias("ab4"),
        pl$col("ab")$sort_by("v3")$alias("ab3"),
        pl$col("ab")$sort_by("v2")$alias("ab2"),
        pl$col("ab")$sort_by("v1")$alias("ab1"),
        pl$col("ab")$sort_by(list("v3",pl$col("v1")),reverse=c(F,T))$alias("ab13FT"),
        pl$col("ab")$sort_by(list("v3",pl$col("v1")),reverse=T)$alias("ab13T")
      )$to_list(),
      list(
        ab4 = l$ab[order(l$v4)],
        ab3 = l$ab[order(l$v3)],
        ab2 = l$ab[order(l$v2)],
        ab1 = l$ab[order(l$v1)],
        ab13FT= l$ab[order(l$v3,rev(l$v1))],
        ab13T = l$ab[order(l$v3,l$v1,decreasing= T)]
      )
    )

  #this test is minimal, if polars give better documentation on behaviour, expand the test.
})

test_that("take that", {

  expect_identical(
    pl$select(pl$lit(0:10)$take(c(1,3,5,NA)))$to_list()[[1L]],
    c(1L,3L,5L,NA_integer_)
  )

  expect_error(
    pl$select(pl$lit(0:10)$take(11))$to_list()[[1L]]
  )


  expect_identical(
    pl$select(pl$lit(0:10)$take(-11))$to_list()[[1L]],
    NA_integer_
  )


})

test_that("shift", {


  R_shift = \(x, n){
    idx = seq_along(x) - n
    idx[idx<=0] = Inf
    x[idx]
  }

  expect_identical(
    pl$select(
      pl$lit(0:3)$shift(-2)$alias("sm2"),
      pl$lit(0:3)$shift(2)$alias("sp2")
    )$to_list(),
    list(
      sm2 = R_shift((0:3),-2),
      sp2 = R_shift((0:3),2)
    )
  )

  R_shift_and_fill = function(x, n, fill_value = NULL){
    idx = seq_along(x) - n
    idx[idx<=0] = Inf
    new_x = x[idx]
    if(is.null(fill_value)) return(new_x)
    new_x[is.na(new_x) & !is.na(x)] = fill_value
    new_x
  }

  expect_identical(
    pl$select(
      pl$lit(0:3)$shift_and_fill(-2, fill_value = 42)$alias("sm2"),
      pl$lit(0:3)$shift_and_fill(2, fill_value = pl$lit(42)/2)$alias("sp2")
    )$to_list(),
    list(
      sm2 = R_shift_and_fill(0:3,-2,42),
      sp2 = R_shift_and_fill(0:3, 2,21)
    )
  )


})


test_that("fill_null  + forward backward _fill + fill_nan", {

  l = list(a=c(1L,rep(NA_integer_,3L),10))

  #fiil value
  expect_identical(
    pl$DataFrame(l)$select(pl$col("a")$fill_null(42L))$to_list()$a,
    l$a |> (\(x){x[is.na(x)]<-42L;x})()
  )

  #forwarnd

  R_fill_fwd = \(x,lim=Inf) {
    last_seen = NA
    lim_ct=0L
    sapply(x, \(this_val) {
      if(is.na(this_val)) {
        lim_ct <<- lim_ct + 1L
        if(lim_ct>lim) {
          return(this_val) #lim_ct exceed lim since last_seen, return NA
        } else {
          return(last_seen) #return last_seen
        }
      } else {
        lim_ct <<- 0L #reset counter
        last_seen<<-this_val #reset last_seen
        this_val
      }
    })
  }
  R_fill_bwd = \(x,lim=Inf)  rev(R_fill_fwd(rev(x),lim=lim))
  R_replace_na = \(x, y) {x[is.na( x)] <-y;x}

  #TODO let select and other ... functions accept trailing ','
  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$fill_null(strategy="forward")$alias("forward"),
      pl$col("a")$fill_null(strategy="backward")$alias("backward"),
      pl$col("a")$fill_null(strategy="forward",  limit=1)$alias("forward_lim1"),
      pl$col("a")$fill_null(strategy="backward", limit=1)$alias("backward_lim1"),
      pl$col("a")$fill_null(strategy="forward",  limit=0)$alias("forward_lim0"),
      pl$col("a")$fill_null(strategy="backward", limit=0)$alias("backward_lim0"),
      pl$col("a")$fill_null(strategy="forward", limit=10)$alias("forward_lim10"),
      pl$col("a")$fill_null(strategy="backward",limit=10)$alias("backward_lim10")

    )$to_list(),
   list(
     forward  = l$a |> R_fill_fwd(),
     backward = l$a |> R_fill_bwd(),
     forward_lim1  = l$a |> R_fill_fwd(lim=1),
     backward_lim1 = l$a |> R_fill_bwd(lim=1),
     forward_lim0  = l$a |> R_fill_fwd(lim=0),
     backward_lim0 = l$a |> R_fill_bwd(lim=0),
     forward_lim10  = l$a |> R_fill_fwd(lim=10),
     backward_lim10 = l$a |> R_fill_bwd(lim=10)
  )
)

  expect_identical(
    pl$DataFrame(l)$select(

      pl$col("a")$fill_null(strategy="min")$alias("min"),
      pl$col("a")$fill_null(strategy="max")$alias("max"),
      pl$col("a")$fill_null(strategy="mean")$alias("mean"),
      pl$col("a")$fill_null(strategy="zero")$alias("zero"),
      pl$col("a")$fill_null(strategy="one")$alias("one")
    )$to_list(),
    list(
      min = l$a |> R_replace_na(min(l$a,na.rm = TRUE)),
      max = l$a |> R_replace_na(max(l$a,na.rm = TRUE)),
      mean = l$a |> R_replace_na(mean(l$a,na.rm = TRUE)),
      zero = l$a |> R_replace_na(0),
      one = l$a |> R_replace_na(1)
    )
  )


  #forward_fill + backward_fill
  l = list(a = c(1:2,NA_integer_,NA_integer_,3L))
  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$forward_fill(1 )$alias("a_ffill_1"),
      pl$col("a")$forward_fill(  )$alias("a_ffill_NULL"),
      pl$col("a")$backward_fill(1)$alias("a_bfill_1"),
      pl$col("a")$backward_fill( )$alias("a_bfill_NULL")
    )$to_list(),
    list(
      a_ffill_1    = R_fill_fwd(l$a,1),
      a_ffill_NULL = R_fill_fwd(l$a  ),
      a_bfill_1    = R_fill_bwd(l$a,1),
      a_bfill_NULL = R_fill_bwd(l$a  )
    )
  )

  #Fill NaN
  R_replace_nan= \(x, y) {x[is.nan(x)] <-y;x}
  l = list(a = c(1,NaN,NA,NaN,3))
  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$fill_nan()$alias("fnan_NULL"),
      pl$col("a")$fill_nan(42L)$alias("fnan_int"),
      pl$col("a")$fill_nan(NA)$alias("fnan_NA"),
      pl$col("a")$fill_nan("hej")$alias("fnan_str"),
      pl$col("a")$fill_nan(TRUE)$alias("fnan_bool"),
      pl$col("a")$fill_nan(pl$lit(10)/2)$alias("fnan_expr"),
      pl$col("a")$fill_nan(pl$Series(10))$alias("fnan_series")
    )$to_list(),
    list(
      fnan_NULL  = R_replace_nan(l$a,NA_real_),
      fnan_int   = R_replace_nan(l$a,42L),
      fnan_NA    = R_replace_nan(l$a,NA),
      fnan_str   = c("1.0", "hej", "NA", "hej", "3.0"),
      fnan_bool  = R_replace_nan(l$a,TRUE),
      fnan_expr  = R_replace_nan(l$a,pl$select(pl$lit(10)/2)$to_list()[[1L]]),
      fnan_series= R_replace_nan(l$a, pl$Series(10)$to_r())
    )
  )
  #series with length not allowed
  expect_error(
    pl$DataFrame(l)$select(pl$col("a")$fill_nan(pl$Series(10:11))$alias("fnan_series2"))
  )

})

test_that("std var", {

  expect_identical(
    pl$select(
      pl$lit(1:5)$std()$alias("std"),
      pl$lit(c(NA,1:5))$std()$alias("std_missing")
    )$to_list(),
    list(
      std = sd(1:5),
      std_missing = sd(c(NA,1:5),na.rm=TRUE)
    )
  )
  expect_true(pl$select(pl$lit(1:5)$std(3))$to_list()[[1L]] != sd(1:5))


  expect_identical(
    pl$select(
      pl$lit(1:5)$var()$alias("var"),
      pl$lit(c(NA,1:5))$var()$alias("var_missing")
    )$to_list(),
    list(
      var = var(1:5),
      var_missing = var(c(NA,1:5),na.rm=TRUE)
    )
  )
  expect_true(pl$select(pl$lit(1:5)$var(3))$to_list()[[1L]] != var(1:5))


})


test_that("is_unique is_first is_duplicated", {
  v = c(1,1,2,2,3,NA,NaN,Inf)
  expect_identical(
    pl$select(
      pl$lit(v)$is_unique()$alias("is_unique"),
      pl$lit(v)$is_first()$alias("is_first"),
      pl$lit(v)$is_duplicated()$alias("is_duplicated"),
      pl$lit(v)$is_first()$is_not()$alias("R_duplicated")
    )$to_list(),
    list(
      is_unique = !v %in% v[duplicated(v)],
      is_first  = !duplicated(v),
      is_duplicated = v %in% v[duplicated(v)],
      R_duplicated = duplicated(v)
    )
  )
})

test_that("nan_min nan_max", {

  l = list(
    a=c(1,NaN,-Inf,3),
    b=c(NA,1:3)
  )

  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$nan_min()$suffix("_nan_min"),
      pl$col("b")$nan_min()$suffix("_nan_min"),
      pl$col("a")$nan_max()$suffix("_nan_max"),
      pl$col("b")$nan_max()$suffix("_nan_max")
    )$to_list(),
    list(
      a_nan_min = min(l$a),
      b_nan_min = min(l$b,na.rm=TRUE),
      a_nan_max = max(l$a),
      b_nan_max = max(l$b,na.rm=TRUE)
    )
  )

})


test_that("product", {

  l = list(
    a=c(1,NaN,-Inf,3),
    b=c(NA,1:3)*1, #integer32 currently not supported
    c=c(1:4)*1 #integer32 currently not supported
  )

  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$product(),
      pl$col("b")$product(),
      pl$col("c")$product()
    )$to_list(),
    list(
     a = prod(l$a),
     b = prod(l$b,na_rm=TRUE),
     c = prod(l$c)
    )
  )

})

test_that("null count", {

  l = list(
    a=c(NA,NaN,NA),
    b=c(NA,2,NA), #integer32 currently not supported
    c=c(NaN,NaN,NaN) #integer32 currently not supported
  )

  is.na_only = \(x) is.na(x) & !is.nan(x)
  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$null_count(),
      pl$col("b")$null_count(),
      pl$col("c")$null_count()
    )$to_list(),
    list(
      a = sum(is.na_only(l$a)) * 1.0,
      b = sum(is.na_only(l$b)) * 1.0,
      c = sum(is.na_only(l$c)) * 1.0
    )
  )

})

test_that("arg_unique", {

  l = list(
    a=c(1:2,1:3),
    b=c("a","A","a",NA,"B"), #integer32 currently not supported
    c=c(NaN,Inf,-Inf,1,NA) #integer32 currently not supported
  )

  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$arg_unique()$list(),
      pl$col("b")$arg_unique()$list(),
      pl$col("c")$arg_unique()$list()
    )$to_list() |> lapply(unlist),
    list(
      a = which(!duplicated(l$a))-1.0,
      b = which(!duplicated(l$b))-1.0,
      c = which(!duplicated(l$c))-1.0
    )
  )

})

test_that("Expr_quantile", {

  v = sample(0:100)
  expect_identical(
    sapply(seq(0,1,le=101),\(x) pl$select(pl$lit(v)$quantile(x,"nearest"))$to_list()[[1L]]),
    as.double(sort(v))
  )

  v2 = seq(0,1,le=42)
  expect_equal( #tiny rounding errors
    sapply(v2,\(x) pl$select(pl$lit(v)$quantile(x,"linear"))$to_list()[[1L]]),
    unname(quantile(v,v2))
  )

  expect_error(
    pl$lit(1)$quantile(1,"some_unknwon_interpolation_method")
  )


  expect_identical(
    pl$select(
      pl$lit(0:1)$quantile(.5,"nearest")$alias("nearest"),
      pl$lit(0:1)$quantile(.5,"linear")$alias("linear"),
      pl$lit(0:1)$quantile(.5,"higher")$alias("higher"),
      pl$lit(0:1)$quantile(.5,"lower")$alias("lower"),
      pl$lit(0:1)$quantile(.5,"midpoint")$alias("midpoint")

    )$to_list(),
    list(
      nearest = 1.0,
      linear = 0.5,
      higher = 1,
      lower = 0,
      midpoint = .5

    )
  )

  #midpoint/linear NaN poisons, NA_integer_ always omitted
  expect_identical(
    pl$select(
      pl$lit(c(0:1,NA_integer_))$quantile(0.5,"midpoint")$alias("midpoint_na"),
      pl$lit(c(0:1,NaN))$quantile(0.5,"midpoint")$alias("midpoint_nan"),
      pl$lit(c(0:1,NA_integer_))$quantile(0,"nearest")$alias("nearest_na"),
      pl$lit(c(0:1,NaN))$quantile(.7,"nearest")$alias("nearest_nan"),
      pl$lit(c(0:1,NA_integer_))$quantile(0,"linear")$alias("linear_na"),
      pl$lit(c(0:1,NaN))$quantile(.51,"linear")$alias("linear_nan"),
      pl$lit(c(0:1,NaN))$quantile(.7,"linear")$alias("linear_nan_0.7"),
      pl$lit(c(0, Inf,NaN))$quantile(.51,"linear")$alias("linear_nan_inf")
    )$to_list(),
    list(
      midpoint_na = .5,
      midpoint_nan = 1,
      nearest_na = 0,
      nearest_nan = NaN,
      linear_na = 0,
      linear_nan = NaN,
      linear_nan_0.7 = NaN,
      linear_nan_inf = NaN
    )
  )



})




test_that("Expr_filter", {

  pdf = pl$DataFrame(list(
    group_col =  c("g1", "g1", "g2"),
    b = c(1, 2, 3)
  ))

  df = pdf$groupby("group_col")$agg(
    pl$col("b")$filter(pl$col("b") < 2)$sum()$alias("lt"),
    pl$col("b")$filter(pl$col("b") >= 2)$sum()$alias("gte")
  )$as_data_frame() |> (\(x) x[order(x$group_col),])()
  row.names(df) = NULL

  expect_identical(
    df,
    data.frame(
      group_col = c("g1", "g2"),
      lt = c(1, NA_real_),
      gte = c(2,3)
    )
  )
})



test_that("Expr explode/flatten", {

  df = pl$DataFrame(list(a=letters))$select(pl$col("a")$explode()$take(0:5))

  expect_identical(
    df$as_data_frame()$a,
    letters[1:6]
  )

  little_iris = iris[c(1:3,51:53),]
  listed_group_df =  pl$DataFrame(little_iris)$groupby("Species",maintain_order=TRUE)$agg(pl$all())
  vectors_df = listed_group_df$select(
    pl$col(c("Sepal.Width","Sepal.Length"))$explode()
  )

  df = listed_group_df$as_data_frame()


  # yikes kinda like by(), but all details are different
  x = by(little_iris,as.character(little_iris$Species),FUN = list)
  df_ref = as.data.frame(do.call(rbind,unname(lapply(x,lapply,I))))
  df_ref[] = lapply(df_ref,lapply,unAsIs)
  df_ref$Species = factor(sapply(df_ref$Species,function(x) head((x),1)))
  row.names(df_ref) = NULL


  expect_identical(
    df,
    df_ref[,names(df)]
  )


})


test_that("take_every", {
  df = pl$DataFrame(list(a=0:24))$select(pl$col("a")$take_every(6))
  expect_identical(
    df$to_list()[[1L]],
    seq(0L,24L,6L)
  )
})

#TODO contribute polars, panics if start or stop expression has len > 1 or len!= col.len()
test_that("is_between", {
  l = list(a = (1:5)*1.0)
  df = pl$DataFrame(l)

  expect_identical(df$select(pl$col("a")$is_between(2,4))$to_list()[[1L]],       c(F,F,T,F,F))
  expect_identical(df$select(pl$col("a")$is_between(2,4,T))$to_list()[[1L]],     c(F,T,T,T,F))
  expect_identical(df$select(pl$col("a")$is_between(2,4,c(T,F)))$to_list()[[1L]],c(F,T,T,F,F))
  expect_identical(df$select(pl$col("a")$is_between(2,4,c(F,T)))$to_list()[[1L]],c(F,F,T,T,F))
  expect_identical(df$select(pl$col("a")$is_between(1.9,4.1,F))$to_list()[[1L]], c(F,T,T,T,F))

  expect_error(pl$col("a")$is_between(1,2,logical()))
  expect_error(pl$col("a")$is_between(1,2,logical(3)))
  expect_error(pl$col("a")$is_between(1,2,NA))
})


test_that("hash + reinterpret", {
  df = pl$DataFrame(iris)

  hash_values1 = unname(unlist(df$select(pl$col(c("Sepal.Width","Species"))$unique()$hash()$list())$to_list()))
  hash_values2 = unname(unlist(df$select(pl$col(c("Sepal.Width","Species"))$unique()$hash(1,2,3,4)$list())$to_list()))
  expect_true(!any(duplicated(hash_values1)))
  expect_true(!any(duplicated(hash_values2)))
  expect_true(!identical(hash_values1,hash_values2))

  df_hash = df$select(pl$col(c("Sepal.Width","Species"))$unique()$hash(1,2,3,4)$list())
  df_hash_same = df_hash$select(pl$all()$flatten()$reinterpret(FALSE)$list())
  df_hash_rein = df_hash$select(pl$all()$flatten()$reinterpret(TRUE)$list())


  expect_identical(df_hash$to_list(),df_hash_same$to_list())
  expect_false(identical(df_hash$to_list(),df_hash_rein$to_list()))


  df_actual = pl$select(pl$lit(-2:2)$cast(pl$dtypes$Int64)$alias("i64"))$with_columns(
    pl$col("i64")$reinterpret(FALSE)$alias("u64")
  )
  df_ref = pl$select(
    pl$lit(-2:2)$cast(pl$dtypes$Int64)$alias("i64"),
    pl$lit(c("18446744073709551614","18446744073709551615","0","1","2"))$cast(pl$dtypes$UInt64)$alias("u64")
  )
  expect_identical(df_actual$to_list(),df_ref$to_list())

})



test_that("inspect", {

  actual_txt = capture_output(
    pl$select(
      pl$lit(1:5)
      $inspect(
        "before dropping half the column it was:{}and not it is dropped"
      )
      $head(2)
    )
  )
  ref_fun = \(s) {
    cat("before dropping half the column it was:")
    pl$Series(1:5)$print()
    cat("and not it is dropped","\n",sep="")
  }
  ref_text = capture_output(ref_fun())

  expect_identical(actual_txt, ref_text)

  pl$lit(1)$inspect("{}") # no error
  pl$lit(1)$inspect("ssdds{}sdsfsd") #no error
  expect_error(pl$lit(1)$inspect(""))
  expect_error(pl$lit(1)$inspect("{}{}"))
  expect_error(pl$lit(1)$inspect("sd{}sdfsf{}sdsdf"))
  expect_error(pl$lit(1)$inspect("ssdds{sdds}sdsfsd"))

})

test_that("interpolate", {
  expect_identical(
    pl$select(pl$lit(c(1,NA,4,NA,100))$interpolate(method = "linear"))$to_list()[[1L]],
    approx(c(1,NA,4,NA,100),xout = c(1:5))$y
  )

  expect_identical(
    pl$select(pl$lit(c(1,NA,4,NA,100,90,NA,60))$interpolate(method = "nearest"))$to_list()[[1L]],
    approx(c(1,NA,4,NA,100,90,NA,60),xout = c(1:8), method = "constant", f = 1)$y
  )
})



test_that("Expr_rolling_", {

  library(data.table)
  #check all examples
  df = pl$DataFrame(list(a=1:6))
  dt = data.table(a=1:6)

  df_expected = dt[,
     .(
       min      = as.integer(frollapply(a,2,min)),
       max      = as.integer(frollapply(a,2,max)),
       mean     = frollmean(a,2),
       sum      = as.integer(frollsum(a,2)),
       std      = frollapply(a,2,sd),
       var      = frollapply(a,2,var),
       median   = frollapply(a,2,median),
       quantile_linear = frollapply(a,2,quantile,probs=.33)
     )
  ] |> as.data.frame()

  expect_identical(
    df$select(
      pl$col("a")$rolling_min(window_size = 2)$alias("min"),
      pl$col("a")$rolling_max(window_size = 2)$alias("max"),
      pl$col("a")$rolling_mean(window_size = 2)$alias("mean"),
      pl$col("a")$rolling_sum(window_size = 2)$alias("sum"),
      pl$col("a")$rolling_std(window_size = 2)$alias("std"),
      pl$col("a")$rolling_var(window_size = 2)$alias("var"),
      pl$col("a")$rolling_median(window_size = 2)$alias("median"),
      pl$col("a")$rolling_quantile(
        quantile=.33,window_size = 2,interpolation = "linear"
      )$alias("quantile_linear")

    )$as_data_frame(),
    df_expected
  )

  #check skewness
  df_actual_skew = pl$DataFrame(list(a=iris$Sepal.Length))$select(pl$col("a")$rolling_skew(window_size = 4 )$head(10))
  expect_equal(
                   df_actual_skew$to_list()[[1L]],
    c(NA, NA, NA, 0.27803055565397, -1.5030755787344e-14, 0.513023958460299,
      0.493382200218155, 0, 0.278030555653967, -0.186617740163675)
  )

})


test_that("Expr_rank", {
  l = list(a = c(3, 6, 1, 1, 6))
  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$rank()$alias("avg"),
      pl$col("a")$rank(reverse = TRUE)$alias("avg_rev"),
      pl$col("a")$rank(method = "ordinal")$alias("ord_rev")
    )$to_list(),
    list(
      avg = rank(l$a),
      avg_rev = rank(-l$a),
      ord_rev = as.double(rank(l$a, ties.method = "first"))
    )
  )
})


test_that("Expr_diff", {

  l = list( a=c(20L,10L,30L,40L))

  #polars similar fun
  diff_r = \(x, n , ignore=TRUE) {
    x_na = x[length(x)+1]
    c(if(ignore) rep(x_na,n),diff(x,lag=n))
  }

  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$diff()$alias("diff_default"),
      pl$col("a")$diff(2,"ignore")$alias("diff_2_ignore")
    )$to_list(),
    list(
      diff_default  = diff_r(l$a,n=1,TRUE),
      diff_2_ignore = diff_r(l$a,n=2,TRUE)
    )
  )

  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$diff(2, "drop")$alias("diff_2_drop")
    )$to_list(),
    list(
      diff_2_drop = diff_r(l$a,n=2,FALSE)
    )
  )

  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$diff(1, "drop")$alias("diff_1_drop")
    )$to_list(),
    list(
      diff_1_drop = diff_r(l$a,n=1,FALSE)
    )
  )


  pl$select(pl$lit(1:5)$diff(0)) #no error
  expect_error(pl$lit(1:5)$diff(-1))
  expect_error(pl$lit(1:5)$diff(99^99))
  expect_error(pl$lit(1:5)$diff(5,"not a null behavior"))

})



test_that("Expr_pct_change", {
  l = list( a=c(10L, 11L, 12L, NA_integer_,NA_integer_, 12L))

  R_shift = \(x, n){
    idx = seq_along(x) - n
    idx[idx<=0] = Inf
    x[idx]
  }

  R_fill_fwd = \(x,lim=Inf) {
    last_seen = NA
    lim_ct=0L
    sapply(x, \(this_val) {
      if(is.na(this_val)) {
        lim_ct <<- lim_ct + 1L
        if(lim_ct>lim) {
          return(this_val) #lim_ct exceed lim since last_seen, return NA
        } else {
          return(last_seen) #return last_seen
        }
      } else {
        lim_ct <<- 0L #reset counter
        last_seen<<-this_val #reset last_seen
        this_val
      }
    })
  }

  r_pct_chg = function(x,n=1) {
    xf = R_fill_fwd(x)
    xs  = R_shift(xf,n)
    (xf - xs) / xs
  }

  expect_identical(
    pl$DataFrame(l)$select(
      pl$col("a")$pct_change()$alias("n1"),
      pl$col("a")$pct_change(2)$alias("n2"),
      pl$col("a")$pct_change(0)$alias("n0")
    )$to_list(),
    list(
      n1 = r_pct_chg(l$a),
      n2 = r_pct_chg(l$a,n=2),
      n0 = r_pct_chg(l$a,n=0)
    )
  )
})



test_that("skew", {

  R_skewness = function (x, bias = TRUE,na.rm = FALSE) {
    if (na.rm) x <- x[!is.na(x)]
    n <- length(x)
    m2 = sum((x - mean(x))^2) / n
    m3 = sum((x - mean(x))^3) / n
    biased_skewness = m3 / m2^(3 / 2)
    if (bias) {
      biased_skewness
    } else {
      correction = sqrt(n * (n - 1L)) / (n - 2)
      biased_skewness * correction
    }
  }

  l = list(a = c(1:3,2:1),b=c(1:3,NA_integer_,1L))
  expect_equal(
    pl$DataFrame(l)$select(
      pl$col("a")$skew()$alias("a_skew"),
      pl$col("a")$skew(bias=FALSE)$alias("a_skew_bias_F"),
      pl$col("b")$skew()$alias("b_skew"),
      pl$col("b")$skew(bias=FALSE)$alias("b_skew_bias_F")
    )$to_list(),
    list(
      a_skew = R_skewness(l$a),
      a_skew_bias_F = R_skewness(l$a,bias=F),
      b_skew = R_skewness(l$b,na.rm=TRUE),
      #TODO update when fixed to R_skewness(l$b,bias=F,na.rm=TRUE)
      b_skew_bias_F = 0.73549076 # error in polars
    )
  )

})



test_that("kurtosis", {

  R_kurtosis = function (x, fisher= TRUE, bias = TRUE,na.rm = TRUE) {
    if (na.rm) x <- x[!is.na(x)]
    n <- length(x)
    m2 = sum((x - mean(x))^2) / n
    m4 = sum((x - mean(x))^4) / n
    fisher_correction = if(fisher) 3 else 0
    biased_kurtosis = m4 / m2^2
    if (bias) {
      biased_kurtosis - fisher_correction
    } else {
      correction = 1.0/(n-2)/(n-3) * ((n**2-1.0)*m4/m2**2.0 - 3*(n-1)**2.0)
      correction + 3 - fisher_correction
    }
  }


  l = list(a=c(1:3,NA_integer_,1:3))
  l2 = list(a=c(1:3,1:3))


  #TODO this test should pass when polars is updated
  ##missing values should not change outcome
  # expect_equal(
  #   pl$DataFrame(l)$select(
  #     pl$col("a")$kurtosis()$alias("kurt"),
  #     pl$col("a")$kurtosis(fisher = TRUE, bias=FALSE)$alias("_TF"),
  #     pl$col("a")$kurtosis(fisher = FALSE, bias=TRUE)$alias("kurt_FT"),
  #     pl$col("a")$kurtosis(fisher = FALSE, bias=FALSE)$alias("kurt_FF")
  #   )$to_list(),
  #   pl$DataFrame(l2)$select(
  #     pl$col("a")$kurtosis()$alias("kurt"),
  #     pl$col("a")$kurtosis(fisher = TRUE, bias=FALSE)$alias("_TF")+3,
  #     pl$col("a")$kurtosis(fisher = FALSE, bias=TRUE)$alias("kurt_FT"),
  #     pl$col("a")$kurtosis(fisher = FALSE, bias=FALSE)$alias("kurt_FF")+3
  #   )$to_list()
  # )

  #

  #TODO test for bias correction when polars is updated
  expect_equal(
    pl$DataFrame(l2)$select(
      pl$col("a")$kurtosis()$alias("kurt_TT"),
      #pl$col("a")$kurtosis(fisher = TRUE, bias=FALSE)$alias("kurt_TF"),
      pl$col("a")$kurtosis(fisher = FALSE, bias=TRUE)$alias("kurt_FT")
      #pl$col("a")$kurtosis(fisher = FALSE, bias=FALSE)$alias("kurt_FF")
    )$to_list(),
    list2(
      kurt_TT =  R_kurtosis(l2$a,T,T),
      #kurt_TF =  R_kurtosis(l2$a,T,F),
      kurt_FT =  R_kurtosis(l2$a,F,T)
      #kurt_FF =  R_kurtosis(l2$a,F,F)
    )
  )
})



test_that("clip clip_min clip_max", {


  r_clip <- \(x, a, b) ifelse(x<=a,a,x) |> (\(x) ifelse(x>=b,b,x))()
  r_clip_min <- \(x, a) ifelse(x<=a,a,x)
  r_clip_max <- \(x, b) ifelse(x>=b,b,x)


  l = list(
    int   = c(NA_integer_,-.Machine$integer.max,-4:4 ,.Machine$integer.max),
    float = c(NA_real_, -Inf,.Machine$double.xmin, -3:2,.Machine$double.xmax,Inf,NaN)

  )


##TODO contribute polars mention in documentation that clipping with NaN takes no effect.
#clip min
expect_identical(
  pl$DataFrame(l)$select(
    pl$col("int")$clip_min(-.Machine$integer.max)$alias("int_mini32"),
    pl$col("int")$clip_min(-2L)$alias("int_m2i32"),
    pl$col("int")$clip_min(2L)$alias("int_p2i32"),
    pl$col("float")$clip_min(-Inf)$alias("float_minf64"),
    pl$col("float")$clip_min(NaN)$alias("float_NaN2f64"), #in Polars NaN is the highest values
    pl$col("float")$clip_min(2)$alias("float_p2f64")

  )$to_list(),
  list(
    int_mini32 = r_clip_min(l$int,-.Machine$integer.max),
    int_m2i32 = r_clip_min(l$int,-2L),
    int_p2i32 = r_clip_min(l$int, 2L),
    float_minf64 = r_clip_min(l$float,-Inf),
    float_NaN2f64 = l$float, #float_NaN2f64 = r_clip_min(l$float,NaN), #in R NaN is more like NA,
    float_p2f64 = r_clip_min(l$float,2)
  )
)

#clip max
expect_identical(
  pl$DataFrame(l)$select(
    pl$col("int")$clip_max(-.Machine$integer.max)$alias("int_mini32"),
    pl$col("int")$clip_max(-2L)$alias("int_m2i32"),
    pl$col("int")$clip_max(2L)$alias("int_p2i32"),
    pl$col("float")$clip_max(-Inf)$alias("float_minf64"),
    pl$col("float")$clip_max(NaN)$alias("float_NaN2f64"), #in Polars NaN is the highest values
    pl$col("float")$clip_max(2)$alias("float_p2f64")

  )$to_list(),
  list(
    int_mini32 = r_clip_max(l$int,-.Machine$integer.max),
    int_m2i32 = r_clip_max(l$int,-2L),
    int_p2i32 = r_clip_max(l$int, 2L),
    float_minf64 = r_clip_max(l$float,-Inf),
    float_NaN2f64 = l$float, #float_NaN2f64 = r_clip_max(l$float,NaN), #in R NaN is more like NA,
    float_p2f64 = r_clip_max(l$float,2)
  )
)

##TODO contribute polars any NaN value will crash internal clip assertion
expect_identical(
  pl$DataFrame(l)$select(
    pl$col("int")$clip(-.Machine$integer.max,-.Machine$integer.max+1L)$alias("a"),
    pl$col("int")$clip(-2L,-2L+1L)$alias("b"),
    pl$col("int")$clip(2L,2L+1L)$alias("c"),
    pl$col("float")$clip(-Inf,1)$alias("d"),
    pl$col("float")$clip(2,2+1)$alias("e")

  )$to_list(),
  list(
    a = r_clip(l$int,-.Machine$integer.max,-.Machine$integer.max+1L),
    b = r_clip(l$int,-2L,-2L+1L),
    c = r_clip(l$int,2L,2L+1L),
    d = r_clip(l$float,-Inf,1),
    e = r_clip(l$float,2,2+1)
  )
)



})

#TODO check value exported from polars are not lower bound which will become NA in R
test_that("upper lower bound", {

  expect_identical(
    pl$DataFrame(
      i32 = 1L,
      f64 = 5
    )$select(
      pl$all()$upper_bound()$suffix("_ub"),
      pl$all()$lower_bound()$suffix("_lb")
    )$to_list(),
    list(
      i32_ub = .Machine$integer.max,
      f64_ub = Inf,
      i32_lb = NA_integer_, #R encodes lower bound as NA
      f64_lb = -Inf
    )
  )

})


test_that("expr trignonometry", {

  a = seq(-2*pi,2*pi,le=50)

  expect_equal(
    pl$DataFrame(a=a)$select(
      pl$col("a")$sin()$alias("sin"),
      pl$col("a")$cos()$alias("cos"),
      pl$col("a")$tan()$alias("tan"),
      pl$col("a")$arcsin()$alias("arcsin"),
      pl$col("a")$arccos()$alias("arccos"),
      pl$col("a")$arctan()$alias("arctan"),
      pl$col("a")$sinh()$alias("sinh"),
      pl$col("a")$cosh()$alias("cosh"),
      pl$col("a")$tanh()$alias("tanh"),
      pl$col("a")$arcsinh()$alias("arcsinh"),
      pl$col("a")$arccosh()$alias("arccosh"),
      pl$col("a")$arctanh()$alias("arctanh")
    )$to_list(),
    suppressWarnings(
      list(
        sin = sin(a),
        cos = cos(a),
        tan = tan(a),
        arcsin = asin(a),
        arccos = acos(a),
        arctan = atan(a),
        sinh = sinh(a),
        cosh = cosh(a),
        tanh = tanh(a),
        arcsinh = asinh(a),
        arccosh = acosh(a),
        arctanh = atanh(a)
      )
    )
  )

})


test_that("reshape", {

  r_reshape = function(x,dims) {
    unname(as.list(as.data.frame(array(x,dims))))
  }

  expect_identical(
    pl$select(
      pl$lit(1:12)$reshape(c(3,4))$alias("rs_3_4")$list(),
      pl$lit(1:12)$reshape(c(4,3))$alias("rs_4_3")$list()
    )$to_list(),
    list(
      rs_3_4 = list(r_reshape(1:12,c(4,3))),
      rs_4_3 = list(r_reshape(1:12,c(3,4)))
    )
  )

  expect_error(pl$lit(1:12)$reshape("hej"))
  expect_error(pl$lit(1:12)$reshape(c(3,4,3)))
  expect_error(pl$lit(1:12)$reshape(NaN))
  expect_error(pl$lit(1:12)$reshape(NA_real_))

})


test_that("shuffle", {

  r_reshape = function(x,dims) {
    unname(as.list(as.data.frame(array(x,dims))))
  }

  expect_identical(
    pl$DataFrame(a = 1:1000)$select(pl$col("a")$shuffle(seed=1))$to_list(),
    pl$DataFrame(a = 1:1000)$select(pl$col("a")$shuffle(seed=1))$to_list()
  )

  expect_false(
    isTRUE(all.equal(
      pl$DataFrame(a = 1:1000)$select(pl$col("a")$shuffle(seed=1))$to_list(),
      pl$DataFrame(a = 1:1000)$select(pl$col("a")$shuffle(seed=42))$to_list()
    ))
  )

  expect_identical(
      pl$DataFrame(a = letters)$select(pl$col("a")$shuffle(seed=1))$to_list(),
      pl$DataFrame(a = letters)$select(pl$col("a")$shuffle(seed=1))$to_list()
  )

  expect_error(pl$lit(1:12)$shuffle("hej"))
  expect_error(pl$lit(1:12)$shuffle(-2))
  expect_error(pl$lit(1:12)$shuffle(NaN))
  expect_error(pl$lit(1:12)$shuffle(10^73))

})


test_that("sample", {
  df = pl$DataFrame(a=1:10)
  res = df$select(
    pl$col("a")$sample(seed=1)$alias("default")$list(),
    pl$col("a")$sample(n=3,seed=1)$alias("n3")$list(),
    pl$col("a")$sample(frac=.4,seed=1)$alias("frac.4")$list(),
    pl$col("a")$sample(frac=1,seed=1)$alias("frac2")$list(),
    pl$col("a")$sample(frac=1,with_replacement=FALSE,seed=1)$alias("frac1norep")$list(),
    pl$col("a")$sample(n = 10,with_replacement=FALSE,seed=1)$alias("n10norep")$list(),
    pl$col("a")$sample(frac=1,with_replacement=FALSE,shuffle= TRUE,seed=1)$alias("frac1norepshuffle")$list(),
    pl$col("a")$sample(n = 10,with_replacement=FALSE,shuffle= TRUE,seed=1)$alias("n10norep_shuffle")$list()
  )$to_list() |> lapply(unlist)

  expect_identical(
    res,
    list(
      default = c(8L, 1L, 2L, 4L, 5L, 10L, 2L, 5L, 3L, 8L),
      n3 = c(8L,  1L, 2L),
      frac.4 = c(8L, 1L, 2L, 4L),
      frac2 = c(8L, 1L, 2L, 4L,  5L, 10L, 2L, 5L, 3L, 8L),
      frac1norep = 1:10,
      n10norep = 1:10,
      frac1norepshuffle = c(6L, 4L, 5L, 10L, 7L, 9L, 3L, 2L, 1L,8L),
      n10norep_shuffle = c(6L, 4L, 5L, 10L, 7L, 9L, 3L, 2L,1L, 8L)
    )
  )
})


test_that("ewm_", {



  ewm_mean_res = pl$DataFrame(a = c(1,rep(0,10)))$select(
    pl$col("a")$ewm_mean(com=1)$alias("com1"),
    pl$col("a")$ewm_mean(span = 2)$alias("span2"),
    pl$col("a")$ewm_mean(half_life = 2)$alias("hl2"),
    pl$col("a")$ewm_mean(alpha = .5)$alias("a.5"),
    pl$col("a")$ewm_mean(com=1, adjust=FALSE)$alias("com1_noadjust"),
    pl$col("a")$ewm_mean(alpha = .5, adjust=FALSE)$alias("a.5_noadjust"),
    pl$col("a")$ewm_mean(half_life = 3,adjust=FALSE)$alias("hl2_noadjust"),
    pl$col("a")$ewm_mean(com=1,min_periods = 4)$alias("com1_min_periods")
  )

  expect_equal(
    ewm_mean_res$to_list(),
    list(
      com1 = c(1, 0.333333333333333, 0.142857142857143, 0.0666666666666667, 0.032258064516129, 0.0158730158730159, 0.0078740157480315, 0.00392156862745098, 0.00195694716242661, 0.000977517106549365, 0.000488519785051295),
      span2 = c(1, 0.25, 0.076923076923077, 0.025, 0.00826446280991736, 0.00274725274725275, 0.000914913083257092, 0.000304878048780488, 0.000101615689462453, 3.38707492209728e-05, 1.12901222720242e-05),
      hl2 = c(1, 0.414213562373095, 0.226540919660986, 0.138071187457698, 0.0889470746090553, 0.0591733660532993, 0.0401614571920342, 0.0276142374915397, 0.0191522437659561, 0.0133617278184869, 0.00935973598751054),
      a.5 = c(1, 0.333333333333333, 0.142857142857143, 0.0666666666666667,     0.032258064516129, 0.0158730158730159, 0.0078740157480315,     0.00392156862745098, 0.00195694716242661, 0.000977517106549365,     0.000488519785051295),
      com1_noadjust = c(1, 0.5, 0.25, 0.125,     0.0625, 0.03125, 0.015625, 0.0078125, 0.00390625, 0.001953125,     0.0009765625),
      a.5_noadjust = c(1, 0.5, 0.25, 0.125, 0.0625,     0.03125, 0.015625, 0.0078125, 0.00390625, 0.001953125, 0.0009765625    ),
      hl2_noadjust = c(1, 0.7937005259841, 0.629960524947437,     0.5, 0.39685026299205, 0.314980262473718, 0.25, 0.198425131496025,     0.157490131236859, 0.125, 0.0992125657480125),
      com1_min_periods = c(NA,     NA, NA, 0.0666666666666667, 0.032258064516129, 0.0158730158730159,     0.0078740157480315, 0.00392156862745098, 0.00195694716242661,     0.000977517106549365, 0.000488519785051295)
    )
  )

  ##TODO test ewm_std + ewm_var


})


test_that("extend_constant", {


  expect_identical(
      pl$lit(c("5","Bob_is_not_a_number"))
        $cast(pl$dtypes$Utf8, strict = FALSE)
        $extend_constant("chuchu", 2)$to_r()
    ,
    c("5","Bob_is_not_a_number","chuchu","chuchu")
  )

  expect_identical(
    (pl$lit(c("5","Bob_is_not_a_number"))
       $cast(pl$dtypes$Int32, strict = FALSE)
       $extend_constant(5, 2)
       $to_r()
    ),
    c(5L, NA_integer_, 5L, 5L)
  )

  expect_identical(
    (
      pl$lit(c("5","Bob_is_not_a_number"))
      $cast(pl$dtypes$Int32, strict = FALSE)
      $extend_constant(5, 0)
      $to_r()
    ),
    c(5L, NA_integer_)
  )
  expect_error(pl$lit(1)$extend_constant(5,-1))
  expect_error(pl$lit(1)$extend_constant(5,Inf))

})


test_that("extend_expr", {

  expect_identical(
    (
      pl$lit(c("5","Bob_is_not_a_number"))
      $cast(pl$dtypes$Utf8, strict = FALSE)
      $extend_expr("chuchu", 2)
    )$to_r(),
    c("5","Bob_is_not_a_number","chuchu","chuchu")
  )

  expect_identical(
    (
        pl$lit(c("5","Bob_is_not_a_number"))
        $cast(pl$dtypes$Int32, strict = FALSE)
        $extend_expr(5, 2)
        $to_r()
    ),
    c(5L, NA_integer_, 5L, 5L)
  )

  expect_identical(
   (
      pl$lit(c("5","Bob_is_not_a_number"))
      $cast(pl$dtypes$Int32, strict = FALSE)
      $extend_expr(5, 0)
      $to_r()
   ),
    c(5L, NA_integer_)
  )
  expect_error(pl$select(pl$lit(1)$extend_expr(5,-1)))
  expect_error(pl$select(pl$lit(1)$extend_expr(5,Inf)))

})

test_that("rep", {
  expect_identical(pl$lit(1:3)$rep(5)$to_r(), rep(1:3,5))
  expect_identical(pl$lit(c("a","b"))$rep(5)$to_r(), rep(c("a","b"),5))
  expect_identical(pl$lit((1:3)*1)$rep(5)$cast(pl$dtypes$Int64)$to_r(),rep((1:3)*1,5))
  expect_identical(pl$lit(c("a","b"))$rep(5)$to_r(), rep(c("a","b"),5))
  expect_identical(pl$lit(c(T,T,F))$rep(2)$to_r(), rep(c(T,T,F),2))
  expect_error(pl$lit(1:4)$rep(-1))
  expect_error(pl$lit(1:4)$rep(Inf))
})

test_that("rep_extend", {
  expect_identical(pl$lit(1:4)$rep_extend(2:1,2)$to_r(),c(1:4,2:1,2:1))
  expect_identical(
    pl$lit(1:4)$rep_extend(
      pl$lit(c(2,1))$cast(pl$dtypes$Int32),
      2
    )$to_r(),
    c(1:4,2:1,2:1)
  )
  expect_identical(
    pl$lit(1:4)$rep_extend(
      pl$lit(c(2,1)),
      2
    )$to_r(),
    c(1:4,2:1,2:1)*1.0
  )
  expect_identical(pl$lit(1)$rep_extend(numeric(),5)$to_r(), 1)
  expect_error(pl$lit(1)$rep_extend(1,-1))
  expect_error(pl$lit(1)$rep_extend(1,Inf))
})

test_that("to_r", {

  #objects with homomorphic translation between r and polars
  l = list(
    1,1:2,Inf,-Inf,NaN,"a",letters,
    numeric(),integer(),logical(), TRUE, FALSE,
    NA, NA_integer_, NA_character_, NA_real_
  )
  for(i in l) expect_identical(pl$lit(i)$to_r(), i)
  for(i in l) expect_identical(pl$expr_to_r(i), i)

  #object that has not, NULL signals a typeless polars Null, which reverses to NA
  expect_identical(pl$lit(NULL)$to_r(),NA)

})



test_that("unique_counts", {

  #test cases for value counts
  l = list(
    1,1:2,Inf,-Inf,NaN,"a",c(letters,LETTERS,letters),
    numeric(),integer(), NA_integer_, NA_character_, NA_real_,
    c(NA_real_,24,NaN),c(NA_real_,24,Inf,NaN,24), c("ejw",NA_character_),
    c(1,1,1,2,3,4,1,5,2,NA_real_,NA_real_)
  )

  #mimic value counts with R funcitons
  r_value_counts = function(x) {
    as.numeric(sapply(unique(x),\(y) sum(sapply(x,identical,y))))
  }

  for(i in l) {
    expect_identical(
      pl$lit(i)$unique_counts()$to_r(),
      r_value_counts(i)
    )
  }
})


test_that("entropy", {

  #https://stackoverflow.com/questions/27254550/calculating-entropy
  r_entropy = function(x, base = exp(1),  normalize= TRUE) {
    if(normalize) x = x/sum(x)
    -sum(x * log(x) / log(base))
  }

  expect_equal(pl$lit(1:3)$entropy(base=2)$to_r(),r_entropy(1:3,base=2))
  expect_equal(
    pl$lit(1:3)$entropy(base=2, normalize=FALSE)$to_r(),
    r_entropy(1:3,base=2,normalize = FALSE)
  )

  #TODO contribute polars calculating entropy on utf8 returns NULL, should either raise error
  pl$select(pl$lit(c("a","b","b","c","c","c"))$entropy(base=2))

  pl$lit(c("a","a","a"))$entropy(base=2, normalize=FALSE)$to_r()
})



test_that("cumulative_eval", {

  r_cumulative_eval = function(x,f,min_periods = 1L, ...) {
    g = function(x) if(length(x)<min_periods) x[length(x)+1L] else f(x)
    sapply(lapply(seq_along(x) ,\(i) x[1:i]),g)
  }

  expect_identical(
    pl$lit(1:5)$cumulative_eval(pl$element()$first()-pl$element()$last() ** 2)$to_r(),
    r_cumulative_eval(1:5, \(x) first(x)-last(x)**2)
  )

  expect_identical(
    pl$lit(1:5)$cumulative_eval(
      pl$element()$first()-pl$element()$last() ** 2,
      min_periods=4
    )$to_r(),
    r_cumulative_eval(1:5, \(x) first(x)-last(x)**2, min_periods = 4)
  )

  expect_identical(
    pl$lit(1:5)$cumulative_eval(
      pl$element()$first()-pl$element()$last() ** 2,
      min_periods=3,
      parallel = TRUE
    )$to_r(),
    r_cumulative_eval(1:5, \(x) first(x)-last(x)**2, min_periods = 3)
  )

})

test_that("shrink_dtype", {

  df = pl$DataFrame(
       a= c(1L, 2L, 3L),
       b= c(1L, 2L, bitwShiftL(2L,29)),
       c= c(-1L, 2L, bitwShiftL(1L,15)),
       d= c(-112L, 2L, 112L),
       e= c(-112L, 2L, 129L),
       f= c("a", "b", "c"),
       g= c(0.1, 1.32, 0.12),
       h= c(T, NA, F)
     )$with_column( pl$col("b")$cast(pl$Int64) *32L
     )$select(pl$all()$shrink_dtype())

  expect_true(all(mapply(
    df$dtypes,
    pl$dtypes[c("Int8","Int64","Int32","Int8","Int16","Utf8","Float32","Boolean")],
    FUN = function(actual, expected) actual == expected
  )))

})

