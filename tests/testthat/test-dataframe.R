

input_vectors_and_series = list (
    newname = pl$Series(c(1,2,3,4,5),name = "b"), #overwrite name b with newname
    pl$Series((1:5) * 5,"a"),
    pl$Series(letters[1:5],"b"),
    c(5,4,3,2,1), #unnamed vector
    named_vector = c(15,14,13,12,11) ,#named provide
    c(5,4,3,2,0)
  )

expected_mixed_print =
c("polars DataFrame: shape: (5, 6)", "┌─────────┬──────┬─────┬─────────────┬──────────────┬─────────────┐",
  "│ newname ┆ a    ┆ b   ┆ newcolumn_1 ┆ named_vector ┆ newcolumn_2 │",
  "│ ---     ┆ ---  ┆ --- ┆ ---         ┆ ---          ┆ ---         │",
  "│ f64     ┆ f64  ┆ str ┆ f64         ┆ f64          ┆ f64         │",
  "╞═════════╪══════╪═════╪═════════════╪══════════════╪═════════════╡",
  "│ 1.0     ┆ 5.0  ┆ a   ┆ 5.0         ┆ 15.0         ┆ 5.0         │",
  "├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┤",
  "│ 2.0     ┆ 10.0 ┆ b   ┆ 4.0         ┆ 14.0         ┆ 4.0         │",
  "├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┤",
  "│ 3.0     ┆ 15.0 ┆ c   ┆ 3.0         ┆ 13.0         ┆ 3.0         │",
  "├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┤",
  "│ 4.0     ┆ 20.0 ┆ d   ┆ 2.0         ┆ 12.0         ┆ 2.0         │",
  "├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌┤",
  "│ 5.0     ┆ 25.0 ┆ e   ┆ 1.0         ┆ 11.0         ┆ 0.0         │",
  "└─────────┴──────┴─────┴─────────────┴──────────────┴─────────────┘"
)

expected_iris_select_df = structure(list(miah = c(171.4, 171.4, 171.4, 171.4, 171.4, 171.4,
171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4,
171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4,
171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4,
171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4,
171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 171.4, 138.5,
138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5,
138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5,
138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5,
138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5,
138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5, 138.5,
138.5, 138.5, 138.5, 138.5, 148.7, 148.7, 148.7, 148.7, 148.7,
148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7,
148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7,
148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7,
148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7,
148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7, 148.7
), miah2 = c(250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3,
250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3,
250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3,
250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3,
250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3,
250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 250.3, 296.8, 296.8,
296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8,
296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8,
296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8,
296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8,
296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8, 296.8,
296.8, 296.8, 296.8, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4,
329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4,
329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4,
329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4,
329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4,
329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4, 329.4), Petal.Length = c(1.4,
1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.6, 1.4, 1.1,
1.2, 1.5, 1.3, 1.4, 1.7, 1.5, 1.7, 1.5, 1, 1.7, 1.9, 1.6, 1.6,
1.5, 1.4, 1.6, 1.6, 1.5, 1.5, 1.4, 1.5, 1.2, 1.3, 1.4, 1.3, 1.5,
1.3, 1.3, 1.3, 1.6, 1.9, 1.4, 1.6, 1.4, 1.5, 1.4, 4.7, 4.5, 4.9,
4, 4.6, 4.5, 4.7, 3.3, 4.6, 3.9, 3.5, 4.2, 4, 4.7, 3.6, 4.4,
4.5, 4.1, 4.5, 3.9, 4.8, 4, 4.9, 4.7, 4.3, 4.4, 4.8, 5, 4.5,
3.5, 3.8, 3.7, 3.9, 5.1, 4.5, 4.5, 4.7, 4.4, 4.1, 4, 4.4, 4.6,
4, 3.3, 4.2, 4.2, 4.2, 4.3, 3, 4.1, 6, 5.1, 5.9, 5.6, 5.8, 6.6,
4.5, 6.3, 5.8, 6.1, 5.1, 5.3, 5.5, 5, 5.1, 5.3, 5.5, 6.7, 6.9,
5, 5.7, 4.9, 6.7, 4.9, 5.7, 6, 4.8, 4.9, 5.6, 5.8, 6.1, 6.4,
5.6, 5.1, 5.6, 6.1, 5.6, 5.5, 4.8, 5.4, 5.6, 5.1, 5.1, 5.9, 5.7,
5.2, 5, 5.2, 5.4, 5.1)), class = "data.frame", row.names = c(NA,
-150L))






test_that("DataFrame, mixed input, create and print", {
  #clone into DataFrame and change one name
  df = pl$DataFrame(input_vectors_and_series)
  testthat::expect_identical(
    capture.output(print(df)),
    expected_mixed_print
  )
})


test_that("polar_frame, mixed input, create and print", {
  #clone into DataFrame and change one name
  df = pl$DataFrame(input_vectors_and_series)
  testthat::expect_identical(
    capture.output(print(df)),
    expected_mixed_print
  )
})

test_that("polar_frame, select sum over", {
  df = pl$DataFrame(iris)$select(
    pl$col("Sepal.Width")$sum()$over("Species")$alias("miah"),
    pl$col("Sepal.Length")$sum()$over("Species")$alias("miah2"),
    "Petal.Length"
  )$as_data_frame()

  testthat::expect_equal(
    df,
    expected_iris_select_df
  )

})



test_that("map unity", {

  ## float is preserved
  expect_identical(
    pl$DataFrame(iris)$select(pl$col("Sepal.Length")$map(\(s) s))$as_data_frame()[,1,drop=FALSE],
    iris[,1,drop=FALSE]
  )

  ##int is preseved
  int_iris = iris
  int_iris[] = lapply(iris,as.integer)
  expect_identical(
    pl$DataFrame(int_iris)$select(pl$col("Sepal.Length")$map(\(s) s))$as_data_frame()[,1,drop=FALSE],
    int_iris[,1,drop=FALSE]
  )

  ## factor is not preserved in polars
  expect_failure(expect_identical(
    pl$DataFrame(iris)$select(pl$col("Species")$map(\(s) s))$as_data_frame()[,1],
    iris[,1,drop=FALSE]
  ))

  ## factor is not preserved in polars
  str_iris = iris
  str_iris$Species = as.character(iris$Species)
  expect_identical(
    pl$DataFrame(iris)$select(pl$col("Species")$map(\(s) s))$as_data_frame(),
    str_iris[,5,drop=FALSE]
  )


})

test_that("map type", {

  int_iris = iris
  int_iris[] = lapply(iris,as.integer)

  ## auto new type allowed if return is R vector
  expect_identical(
    pl$DataFrame(iris)$select(pl$col("Sepal.Length")$map(\(s) {as.integer(s$to_r())}))$as_data_frame()[,1,drop=FALSE],
    int_iris[,1,drop=FALSE]
  )

})




test_that("cloning", {

  pf = pl$DataFrame(iris)

  #shallow copy, same external pointer
  pf2 = pl$DataFrame(pf)
  testthat::expect_true(all.equal(pf,pf2))
  testthat::expect_true(xptr::xptr_address(pf) == xptr::xptr_address(pf2))

  #deep copy clone rust side object, hence not same mem address
  pf3 = pf$clone_extendr()
  testthat::expect_true(all.equal(pf,pf3))
  testthat::expect_true(xptr::xptr_address(pf) != xptr::xptr_address(pf3))


})
