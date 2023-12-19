

## supports autocomplete methods and arguments


## missing autocomplete, docs
source("~/Documents/projs/r-polars/R/rstudio_completion.R")
.dev$activate_polars_rstudio_completion()

library(polars)
pl$col("a")$list$diff(n = 4)


pl$
  DataFrame(iris)$
  with_columns(pl$col('Sepal.Width')$
  alias("mycol"))$group_by(
