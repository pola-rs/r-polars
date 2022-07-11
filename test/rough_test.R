minipolars::import_polars_as_("pl")


#chain expression
pl::col("blop")$sum()$over(c("hej","du","der"))


#build series
values = list (
  a = pl::series(1:5),
  b = pl::series((1:5) * 5),
  c = pl::series(letters[1:5])
)
#clone into dataframe
pl::df(values)



#build dataframe directly from inheriting data.frame
pl::df(iris)

