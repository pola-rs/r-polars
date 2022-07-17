library(magrittr)
minipolars::import_polars_as_("pl")
pf = pl::pf(iris)


#build an expression
pl::col("Sepal.Width")$sum()$over("Species")$alias("miah")
pl::col("Sepal.Width")$sum()$over(c("Species", "Petal.Width"))$alias("miah")

#make selection with expressions or strings, convert back to data.frame
pf$select(
  pl::col("Sepal.Width")$sum()$over("Species")$alias("sw_sum_over_species"),
  pl::col("Sepal.Length")$sum()$over("Species")$alias("sl_sum_over_species"),
  "Petal.Width"
)$as_data_frame() %>% head


#datatypes
pl::datatype("logical")
pl::datatype("Boolean")
pl::datatype("double")
pl::datatype("character")


##read a csv file
minipolars:::new_csv_r(
  path = "a path",
  sep = ",",
  has_header = TRUE,
  ignore_errors = FALSE,
  skip_rows = 0,
  n_rows = NULL,
  cache = FALSE,
  minipolars:::Rdatatype_vector$new()
)









