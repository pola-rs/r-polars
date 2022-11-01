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


  #explicit vector to series to literal
  expect_identical(
    pl$DataFrame(list())$select(pl$lit(pl$Series(1:4)))$to_list()[[1]],
   1:4
  )

  #implicit vector to literal
  expect_identical(
    pl$DataFrame(list())$select(pl$lit(24) / 4:1 + 2)$to_list()[[1]],
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


  #skip map_alias thread-guard message
  pl$set_minipolars_options(no_messages = TRUE)

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


  pl$reset_minipolars_options()
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
    pl$col("a")$cumprod()$alias("cumprod"),
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
    pl$col("a")$cumprod(reverse = TRUE)$alias("cumprod"),
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
    `a dot b` = (l$a %*% l$b)[1],
    `a dot a` = as.integer((l$a %*% l$a)[1]),
    `a dot c` = 20, # polars do not carry NA ((l$a %*% l$c)[1]),
    `a dot d` = ((l$a %*% l$d)[1])
  )

  expect_identical(
    actual_list,
    expected_list
  )
})


test_that("Expr_sort", {

  l = list(a = c(6, 1, 0, NA, Inf,-Inf, NaN))

  l_actual = pl$DataFrame(l)$select(
    pl$col("a")$sort()$alias("sort"),
    pl$col("a")$sort(nulls_last=TRUE)$alias("sort_nulls_last"),
    pl$col("a")$sort(reverse=TRUE)$alias("sort_reverse"),
    pl$col("a")$sort(reverse=TRUE,nulls_last=TRUE)$alias("sort_reverse_nulls_last")
  )$to_list()


  #TODO contribute polars in Expr_sort NaN is a value above Inf, but NaN > Inf is false.
  #more correct use of nan would be slower though
  expect_identical(
    l_actual,
    list(
      sort = c(NA, -Inf, 0, 1, 6, Inf, NaN),
      sort_nulls_last = c(-Inf,0, 1, 6, Inf, NaN, NA),
      sort_reverse = c(NA, NaN, Inf, 6, 1, 0, -Inf),
      sort_reverse_nulls_last = c(NaN, Inf, 6, 1, 0, -Inf, NA)
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
    pl$col("a")$arg_sort()$tail(1)$alias("arg_sort_tail_1")
  )$to_list()
  }

  #it seems Null/NA is smallest value (arg_min)
  #it seems Inf is largest value to (arg_max)
  #however it seems NaN (arg_sort().tail(1))
  lapply(get_arg_min_max(l), function(idx) l$a[idx+1])

  expect_identical(
    get_arg_min_max(l),
    list(arg_min = 6, arg_max = 3, arg_sort_head_1 = 6, arg_sort_tail_1 = 5)
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
    pl$empty_select(pl$lit(0:10)$take(c(1,3,5,NA)))$to_list()[[1]],
    c(1L,3L,5L,NA_integer_)
  )

  expect_error(
    pl$empty_select(pl$lit(0:10)$take(11))$to_list()[[1]]
  )


  expect_identical(
    pl$empty_select(pl$lit(0:10)$take(-11))$to_list()[[1]],
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
    pl$empty_select(
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
    pl$empty_select(
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
      fnan_expr  = R_replace_nan(l$a,pl$empty_select(pl$lit(10)/2)$to_list()[[1]]),
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
    pl$empty_select(
      pl$lit(1:5)$std()$alias("std"),
      pl$lit(c(NA,1:5))$std()$alias("std_missing"),
    )$to_list(),
    list(
      std = sd(1:5),
      std_missing = sd(c(NA,1:5),na.rm=TRUE)
    )
  )
  expect_true(pl$empty_select(pl$lit(1:5)$std(3))$to_list()[[1]] != sd(1:5))


  expect_identical(
    pl$empty_select(
      pl$lit(1:5)$var()$alias("var"),
      pl$lit(c(NA,1:5))$var()$alias("var_missing"),
    )$to_list(),
    list(
      var = var(1:5),
      var_missing = var(c(NA,1:5),na.rm=TRUE)
    )
  )
  expect_true(pl$empty_select(pl$lit(1:5)$var(3))$to_list()[[1]] != var(1:5))


})


test_that("is_unique is_first is_duplicated", {
  v = c(1,1,2,2,3,NA,NaN,Inf)
  expect_identical(
    pl$empty_select(
      pl$lit(v)$is_unique()$alias("is_unique"),
      pl$lit(v)$is_first()$alias("is_first"),
      pl$lit(v)$is_duplicated()$alias("is_duplicated"),
      pl$lit(v)$is_first()$is_not()$alias("R_duplicated"),
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
      pl$col("b")$nan_max()$suffix("_nan_max"),
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
      pl$col("c")$product(),
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
      pl$col("c")$null_count(),
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
      pl$col("c")$arg_unique()$list(),
    )$to_list() |> lapply(unlist),
    list(
      a = which(!duplicated(l$a))-1.0,
      b = which(!duplicated(l$b))-1.0,
      c = which(!duplicated(l$c))-1.0
    )
  )

})

test_that("quantile", {

  v = sample(0:100)
  expect_identical(
    sapply(seq(0,1,le=101),\(x) pl$empty_select(pl$lit(v)$quantile(x,"nearest"))$to_list()[[1]]),
    as.double(sort(v))
  )

  v2 = seq(0,1,le=42)
  expect_equal( #tiny rounding errors
    sapply(v2,\(x) pl$empty_select(pl$lit(v)$quantile(x,"linear"))$to_list()[[1]]),
    unname(quantile(v,v2))
  )

  expect_error(
    pl$lit(1)$quantile(1,"some_unknwon_interpolation_method")
  )


  expect_identical(
    pl$empty_select(
      pl$lit(0:1)$quantile(.5,"nearest")$alias("nearest"),
      pl$lit(0:1)$quantile(.5,"linear")$alias("linear"),
      pl$lit(0:1)$quantile(.5,"higher")$alias("higher"),
      pl$lit(0:1)$quantile(.5,"lower")$alias("lower"),
      pl$lit(0:1)$quantile(.5,"midpoint")$alias("midpoint"),

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
    pl$empty_select(
      pl$lit(c(0:1,NA_integer_))$quantile(0.5,"midpoint")$alias("midpoint_na"),
      pl$lit(c(0:1,NaN))$quantile(0.5,"midpoint")$alias("midpoint_nan"),
      pl$lit(c(0:1,NA_integer_))$quantile(0,"nearest")$alias("nearest_na"),
      pl$lit(c(0:1,NaN))$quantile(.7,"nearest")$alias("nearest_nan"),
      pl$lit(c(0:1,NA_integer_))$quantile(0,"linear")$alias("linear_na"),
      pl$lit(c(0:1,NaN))$quantile(.51,"linear")$alias("linear_nan"),
      pl$lit(c(0:1,NaN))$quantile(.7,"linear")$alias("linear_nan_0.7"),
      pl$lit(c(0, Inf,NaN))$quantile(.51,"linear")$alias("linear_nan_inf"),
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




test_that("Expr filter", {

  pdf = pl$DataFrame(list(
    group_col =  c("g1", "g1", "g2"),
    b = c(1, 2, 3)
  ))

  df = pdf$groupby("group_col")$agg(
    pl$col("b")$filter(pl$col("b") < 2)$sum()$alias("lt"),
    pl$col("b")$filter(pl$col("b") >= 2)$sum()$alias("gte"),
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



test_that("Expr xplode/flatten", {

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
