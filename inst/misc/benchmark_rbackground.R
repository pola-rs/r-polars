library(polars)

regular_lf <- pl$LazyFrame(data.frame(val = 1:1e5))
long_map_fg <- pl$col("val")
long_map_bg <- pl$col("val")
for (i in 1:1e3) {
  long_map_fg <- long_map_fg$map(\(x) x + 1 / x, in_background = FALSE)
  long_map_bg <- long_map_bg$map(\(x) x + 1 / x, in_background = TRUE)
}
long_compute_fg <- regular_lf$with_columns(long_map_fg$alias("res"))
long_compute_bg <- regular_lf$with_columns(long_map_bg$alias("res"))
# Initialize a backgrounnd process
long_compute_bg$collect_in_background()$join() |> invisible()
# Long foreground map in foreground
long_compute_fg$collect() |> system.time()
# Long background map in foreground
long_compute_bg$collect() |> system.time()
# Long background map in background
long_compute_bg$collect_in_background()$join() |> system.time()


large_compute_fn <- function(x) {
  vals <- x$to_r()
  path <- 0
  while (any(vals > 1)) {
    mask <- vals != 1
    path <- path + mask
    odd <- mask * (vals %% 2)
    even <- mask * (1 - vals %% 2)
    vals <- (1 - mask) * vals + odd * (3 * vals + 1) + even * vals %/% 2
  }
  path
}
map_fg <- pl$col("val")$map(large_compute_fn, in_background = FALSE)
map_bg <- pl$col("val")$map(large_compute_fn, in_background = TRUE)
large_compute_fg <- regular_lf$with_columns(map_fg$alias("res"))
large_compute_bg <- regular_lf$with_columns(map_bg$alias("res"))
# Large foreground map in foreground
large_compute_fg$collect() |> system.time()
# Large background map in foreground
large_compute_bg$collect() |> system.time()
# Large background map in background
large_compute_bg$collect_in_background()$join() |> system.time()
