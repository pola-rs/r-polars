test_that("lazy prints", {

  getprint = function(x) capture_output(print(x))

  df = pl$DataFrame(list(a=1:3,b=c(T,T,F)))
  ldf = df$lazy()$filter(pl$col("a")==2L)

  #generic and internal 'print'-methods return self (invisibly likely)
  print_generic =  capture_output_lines({ret_val = print(ldf)  })
  expect_identical(getprint(ret_val),getprint(ldf))
  print_internal_method = capture_output({ret_val2 = ldf$print()})
  expect_equal(getprint(ret_val2),getprint(ldf))


  #described plan is not equal to optimized plan
  expect_true(
    capture_output(ldf$describe_optimized_plan()) != capture_output(ldf$describe_plan())
  )

})


test_that("lazy filter", {

  ##preparation

  test_df = iris
  test_df$is_long = apply(test_df[,c("Sepal.Length","Petal.Length")],1,mean) |> (\(x) x> (max(x)+mean(x))/2)()
  test_df$Species = as.character(test_df$Species)
  pdf = pl$DataFrame(test_df)
  ldf = pdf$lazy()
  df_enumerate_rows = function(df) {
    stopifnot(inherits(df,"data.frame"))
    attr(df,"row.names") = seq_along(attr(df,"row.names"))
    df
  }
  expect_not_equal = function(object,expected,...) {
    expect_failure(expect_equal(object,expected,...))
  }


  #filter ==
  expect_identical(
    pdf$lazy()$filter(pl$col("Species")=="setosa")$collect()$as_data_frame(),
    test_df[test_df$Species=="setosa",] |> df_enumerate_rows()
  )
  expect_identical(
    pdf$lazy()$filter(pl$col("Sepal.Length")==5.0)$collect()$as_data_frame(),
    test_df[test_df$Sepal.Length == 5.0,,] |> df_enumerate_rows()
  )
  expect_identical(
    pdf$lazy()$filter(pl$col("is_long"))$collect()$as_data_frame(),
    test_df[test_df$is_long,] |> df_enumerate_rows()
  )


  #filter >=
  expect_identical(pdf$lazy()$filter(pl$col("Species")>="versicolor")$collect()$as_data_frame(), test_df[test_df$Species>="versicolor",] |> df_enumerate_rows())
  expect_identical(pdf$lazy()$filter(pl$col("Sepal.Length")>=5.0)$collect()$as_data_frame(), test_df[test_df$Sepal.Length >= 5.0,,] |> df_enumerate_rows())
  expect_identical(pdf$lazy()$filter(pl$col("is_long")>=TRUE)$collect()$as_data_frame(),test_df[test_df$is_long >= TRUE,,] |> df_enumerate_rows())

  #no trues                                       #flip signs here
  expect_not_equal(pdf$lazy()$filter(pl$col("Species")<"versicolor")$collect()$as_data_frame(), test_df[test_df$Species>="versicolor",] |> df_enumerate_rows())
  expect_not_equal(pdf$lazy()$filter(pl$col("Species")<="versicolor")$collect()$as_data_frame(), test_df[test_df$Species>="versicolor",] |> df_enumerate_rows())
  expect_not_equal(pdf$lazy()$filter(pl$col("Sepal.Length")< 5.0)$collect()$as_data_frame(), test_df[test_df$Sepal.Length >= 5.0,,] |> df_enumerate_rows())
  expect_not_equal(pdf$lazy()$filter(pl$col("Sepal.Length")<=5.0)$collect()$as_data_frame(), test_df[test_df$Sepal.Length >= 5.0,,] |> df_enumerate_rows())
  expect_not_equal(pdf$lazy()$filter(pl$col("is_long")<TRUE)$collect()$as_data_frame(),test_df[test_df$is_long >= TRUE,,] |> df_enumerate_rows())


  #bool specific
  expect_identical(pdf$lazy()$filter(pl$col("is_long")!=TRUE )$collect()$as_data_frame(),test_df[test_df$is_long != TRUE ,,] |> df_enumerate_rows())
  expect_identical(pdf$lazy()$filter(pl$col("is_long")!=FALSE)$collect()$as_data_frame(),test_df[test_df$is_long != FALSE,,] |> df_enumerate_rows())


  #and
  expect_identical(
    pdf$lazy()$filter(
      pl$col("is_long") & (pl$col("Sepal.Length")> 5.0)
    )$collect()$as_data_frame(),
    test_df[test_df$is_long & test_df$Sepal.Length>5 ,,] |> df_enumerate_rows()
  )

  #or
  expect_identical(
    pdf$lazy()$filter(
      pl$col("is_long") | (pl$col("Sepal.Length")> 5.0)
    )$collect()$as_data_frame(),
    test_df[test_df$is_long | test_df$Sepal.Length>5 ,,] |> df_enumerate_rows()
  )

  #xor
  expect_identical(
    pdf$lazy()$filter(
      pl$col("is_long")$xor(pl$col("Sepal.Length")> 5.0)
    )$collect()$as_data_frame(),
    test_df[xor(test_df$is_long,test_df$Sepal.Length>5),] |> df_enumerate_rows()
  )


})


test_that("methods without arguments", {
  a = pl$DataFrame(mtcars)$lazy()$first()$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, head, 1))
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$last()$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, tail, 1))
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$max()$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, max))
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$mean()$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, mean))
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$median()$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, median))
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$min()$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, min))
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$sum()$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, sum))
  expect_equal(a, b, ignore_attr = TRUE)
  
  a = pl$DataFrame(mtcars)$lazy()$reverse()$collect()$as_data_frame()
  b = mtcars[32:1,]
  expect_equal(a, b, ignore_attr = TRUE)
  
  a = pl$DataFrame(mtcars)$lazy()$slice(2, 4)$collect()$as_data_frame()
  b = mtcars[3:6,]
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$slice(30)$collect()$as_data_frame()
  b = tail(mtcars, 2)
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$var()$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, var))
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$var(10)$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, var))
  expect_true(all(a != b))

  a = pl$DataFrame(mtcars)$lazy()$std()$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, sd))
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$std(10)$collect()$as_data_frame()
  b = data.frame(lapply(mtcars, sd))
  expect_true(all(a != b))

  a = pl$DataFrame(mtcars)$lazy()$tail(6)$collect()$as_data_frame()
  b = tail(mtcars)
  expect_equal(a, b, ignore_attr = TRUE)
})


#TODO complete tests for lazy
