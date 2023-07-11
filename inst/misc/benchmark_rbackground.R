library(polars)
a = (1:5E7)*1.0
system.time({
  bigdf = pl$DataFrame(a = a)
})
system.time({
  out = polars:::test_serde_df(bigdf)
})
system.time({
  s = serialize(a,connection = NULL)
  out = unserialize(s)
})


lf <- pl$LazyFrame(val = a)
lf$with_column(pl$col("val")$map_in_background(\(x) 2 * x)$alias("res"))$collect() |> system.time()
