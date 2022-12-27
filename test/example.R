library(magrittr)
rpolars::import_polars_as_("pl")
pf = pl$DataFrame(iris)


#check cloning
pf2 = pl$DataFrame(pf) # constructor is also identity function
pf3 = pf$clone(deep=TRUE)
pf4 = pf$clone(deep=FALSE)


isTRUE(all.equal(pf,pf2))
isTRUE(all.equal(pf,pf3))
isTRUE(all.equal(pf,pf4))
isFALSE(identical(pf3,pf4))

pl$mem_address(pf$.__enclos_env__$private$pf) ==
  pl$mem_address(pf2$.__enclos_env__$private$pf)

pl$mem_address(pf$.__enclos_env__$private$pf) !=
  pl$mem_address(pf3$.__enclos_env__$private$pf)

pl$mem_address(pf$.__enclos_env__$private$pf) ==
  pl$mem_address(pf4$.__enclos_env__$private$pf)



values = list (
  newname = pl$Series(c(1,2,3,4,5),name = "b"), #overwrite name b with newname
  pl$Series((1:5) * 5,"a"),
  pl$Series(letters[1:5],"b"),
  c(5,4,3,2,1), #unnamed vector
  named_vector = c(15,14,13,12,11) ,#named provide
  c(5,4,3,2,0)
)

pl$DataFrame(values)





#build an expression
pl$col("Sepal.Width")$sum()$over("Species")$alias("miah")
pl$col("Sepal.Width")$sum()$over(c("Species", "Petal.Width"))$alias("miah")

#make selection with expressions or strings, convert back to data.frame
pf$select(
  pl$col("Sepal.Width")$sum()$over("Species")$alias("sw_sum_over_species"),
  pl$col("Sepal.Length")$sum()$over("Species")$alias("sl_sum_over_species"),
  "Petal.Width"
)$as_data_frame() %>% head


#datatypes
pl$dtypes


##read a csv file
rpolars:::new_csv_r(
  path = "a path",
  sep = ",",
  has_header = TRUE,
  ignore_errors = FALSE,
  skip_rows = 0,
  n_rows = NULL,
  cache = FALSE,
  rpolars:::DataType_vector$new()
)









