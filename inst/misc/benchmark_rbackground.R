library(polars)

### 1 ------- Compare long chain of sequantial maps
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



### 2 ---------- Compare large computation
regular_lf <- pl$LazyFrame(data.frame(val = 1:1e5))
long_map_fg <- pl$col("val")
long_map_bg <- pl$col("val")
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


### 3a -----------  Use R processes in parallel, low io, low cpu
lf <- pl$LazyFrame(lapply(1:100,\(i) rep(i,5)))
f_sum_all_cols <-  \(lf,...) lf$select(pl$all()$map(\(x) {x$to_r() |> sum()},...))

f_sum_all_cols(lf)$collect() |> system.time()

pl$set_global_rpool_cap(1)
f_sum_all_cols(lf, in_background = TRUE)$collect() |> system.time() #burn-in start processes
f_sum_all_cols(lf, in_background = TRUE)$collect() |> system.time()

pl$set_global_rpool_cap(4)
f_sum_all_cols(lf, in_background = TRUE)$collect() |> system.time() #burn-in start processes
f_sum_all_cols(lf, in_background = TRUE)$collect() |> system.time()



### 3a -----------  Use R processes in parallel, low io, high cpu
lf <- pl$LazyFrame(lapply(1:12,\(i) rep(i,5)))
f_all_cols <-  \(lf,...) lf$select(pl$all()$map(\(x) {
  for(i in 1:10000) y = sum(rnorm(1000))
  sum(x)
},...))



pl$set_global_rpool_cap(1)
f_all_cols(lf, in_background = TRUE)$collect() |> system.time() #burn-in start processes
f_all_cols(lf, in_background = TRUE)$collect() |> system.time()
f_all_cols(lf, in_background = FALSE)$collect() |> system.time()

##Appears to be a factor overhead when comparing single process
pl$set_global_rpool_cap(0)
f_all_cols(lf, in_background = TRUE)$collect() |> system.time() #burn-in start processes
f_all_cols(lf, in_background = TRUE)$collect() |> system.time()
f_all_cols(lf, in_background = FALSE)$collect() |> system.time()

pl$set_global_rpool_cap(2)
f_all_cols(lf, in_background = TRUE)$collect() |> system.time() #burn-in start processes
f_all_cols(lf, in_background = TRUE)$collect() |> system.time()
f_all_cols(lf, in_background = FALSE)$collect() |> system.time()

pl$set_global_rpool_cap(8)
f_all_cols(lf, in_background = TRUE)$collect() |> system.time() #burn-in start processes
f_all_cols(lf, in_background = TRUE)$collect() |> system.time()
f_all_cols(lf, in_background = FALSE)$collect() |> system.time()
pl$get_global_rpool_cap() #only 2 processes appears to be spawned
