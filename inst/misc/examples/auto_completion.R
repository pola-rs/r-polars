library(polars)


# when using [ ] instead of ( ) the whole query allows static analyis and methods are auto completed
pl$LazyFrame[iris]$
  select[
    pl$col["Species"]$unique_counts[]
  ]$
  collect[]$
  lazy[]

