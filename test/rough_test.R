minipolars::import_polars_as_("pl")


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
pl::df(iris)

