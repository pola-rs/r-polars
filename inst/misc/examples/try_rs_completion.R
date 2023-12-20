

## supports autocomplete methods and arguments


## missing autocomplete, docs


source("~/Documents/projs/r-polars/R/rstudio_completion.R")
.dev$deactivate_polars_rstudio_completion()
.dev$activate_polars_rstudio_completion()
library(polars)



#
#
# pl$
#   DataFrame(iris)$
#   lazy()$
#   with_columns(pl$col('Sepal.Width')$
#   alias("mycol"))$group_by(pl$col('Sepal.Length'))$
#



pl$DataFrame(iris)$group_by(pl$col('Sepal.Length'))$agg(
