

# build polars as package
source("./inst/misc/develop_polars.R")
build_polars()


# activate completion
source("~/Documents/projs/r-polars/R/rstudio_completion.R")
.dev$deactivate_polars_rstudio_completion()
.dev$activate_polars_rstudio_completion()
library(polars)





pl$
  DataFrame(iris)$
  lazy()$
  with_columns(pl$col('Sepal.Width')$
  alias("mycol"))$group_by(pl$col('Sepal.Length'))$agg(pl$col('Species')$append())



pl$col()$alias(s = "hej")$


l = list(m = 42)
l$m



x = 42
class(x) ="bob"
.DollarNames.bob = function(x, pattern) {
  letters
}

e = pl$col()
e$


library(data.table)

dt = data.table(iris)



library(polars)
pl$DataFrame(iris)$select(pl$col('Sepal.Length')$add())


