

## supports autocomplete methods and arguments


## missing autocomplete, docs
source("~/Documents/projs/r-polars/R/rstudio_completion.R")
.dev$activate_polars_rstudio_completion()

library(polars)



pl$
  DataFrame(iris)$
  lazy()$
  silly()$
  this_method_does_exist()$
  with_columns(pl$col('Sepal.Width')$
  alias("mycol"))$group_by()





