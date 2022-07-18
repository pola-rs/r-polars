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
pl::datatype("logical") #r lingo
pl::datatype("Boolean") #polars lingo for same type
pl::datatype("double")
pl::datatype("character")



#creating polar_frame from mixed columns
values = list (
  newname = pl::series(c(1,2,3,4,5),name = "b"), #overwrite name b with newname
  pl::series((1:5) * 5,"a"),
  pl::series(letters[1:5],"b"),
  c(5,4,3,2,1), #unnamed vector
  named_vector = c(15,14,13,12,11) ,#named provide
  c(5,4,3,2,0)
)

pl::pf(values)

##read a csv file, not finished
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









