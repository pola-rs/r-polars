minipolars::import_polars_as_("pl")
pf = pl::pf(iris)

print(pl::col("Sepal.Width")$sum()$over("Species")$alias("miah"))

df = pf$select(
  pl::col("Sepal.Width")$sum()$over("Species")$alias("miah"),
  pl::col("Sepal.Length")$sum()$over("Species")$alias("miah2"),
  "Petal.Length"
)$as_data_frame()
df




pf$select("Sepal.Width","Sepal.Length")$as_data_frame()
df
df$.__enclos_env__$private$pf$as_rlist_of_vectors()

pf$select("Sepal.Width","Sepal.Length")$.__enclos_env__$private$pf$as_rlist_of_vectors()

pf2 = pf$clone(deep = TRUE)
library(xptr)
xptr::xptr_address(pf$.__enclos_env__$private$pf)
xptr::xptr_address(pf2$.__enclos_env__$private$pf)


pf$.__enclos_env__$private$pf



#chain expression
pl::col("blop")$sum()$over(c("hej","du","der"))


#build df from mixed Rseries and vectors
values = list (
  newname = pl::series(c(1,2,3,4,5),name = "b"), #overwrite name b with newname
  pl::series((1:5) * 5,"a"),
  pl::series(letters[1:5],"b"),
  c(5,4,3,2,1), #unnamed vector
  named_vector = c(15,14,13,12,11) #named provide
)
#clone into dataframe and change one name
df = pl::df(values)
df

pra = minipolars:::ProtoRexprArray$new()
pra$push_back_str("a")


df$select(pra)

#build dataframe directly from inheriting data.frame
pf = pl::pf(iris)


#polar_frame from iris



