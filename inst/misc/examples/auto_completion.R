library(polars)


"[.pl_f" = function(x, ...) x(...)

# when using [ ] instead of ( ) the whole query allows static analyis and methods are auto completed
pl$LazyFrame[iris]$
  select[
    pl$col["Species"]$unique_counts[]
  ]$
  collect[]

