time_print = \(expr, name) {
    expr |> system.time() |> round(5) |> (get("*"))(1000) |>  formatC(width=5, format = "d") |>
    paste0("ms") |> (\(time) paste(c("usr", "sys", "elp"),time[1:3],sep=":"))() |>
    cat()
    cat(" || ",name,"\n")
}



### 1 ------- Compare long chain of sequantial maps(no parallel proc use)
# many io's - low bitrate - low cpu
print("test 1a - sequential")
library(polars)
pl$set_global_rpool_cap(1)
regular_lf <- pl$LazyFrame(data.frame(val = 1:1e1))
long_map_fg <- pl$col("val")
long_map_bg <- pl$col("val")
for (i in 1:1000) {
  long_map_fg <- long_map_fg$map(\(x) x + 1 / x, in_background = FALSE)
  long_map_bg <- long_map_bg$map(\(x) x + 1 / x, in_background = TRUE)
}
long_compute_fg <- regular_lf$with_columns(long_map_fg$alias("res"))
long_compute_bg <- regular_lf$with_columns(long_map_bg$alias("res"))

# Initialize a backgrounnd process
long_compute_bg$collect_in_background()$join() |> invisible()
# Long foreground map in foreground
long_compute_fg$collect() |> time_print("- 1a +io %bitrate %cpu foreground")
# Long background map in background
long_compute_bg$collect() |> time_print("- 1a +io %bitrate %cpu background1")
# Long background map in background
long_compute_bg$collect_in_background()$join() |> time_print("- 1a +io %bitrate %cpu background2")


### 1b ------- Compare long chain of sequantial maps(no parallel proc use)
# many io's - high bitrate - low cpu
print("test 1b - sequential")
library(polars)
pl$set_global_rpool_cap(1)
regular_lf <- pl$LazyFrame(data.frame(val = 1:2e6))
long_map_fg <- pl$col("val")
long_map_bg <- pl$col("val")
for (i in 1:16) {
  long_map_fg <- long_map_fg$map(\(x) x + 1 / x, in_background = FALSE)
  long_map_bg <- long_map_bg$map(\(x) x + 1 / x, in_background = TRUE)
}
long_compute_fg <- regular_lf$with_columns(long_map_fg$alias("res"))
long_compute_bg <- regular_lf$with_columns(long_map_bg$alias("res"))

# Long foreground map in foreground
long_compute_fg$collect() |> time_print("- 1b -io +bitrate %cpu foreground")
# Long background map in background
long_compute_bg$collect() |> time_print("- 1b -io +bitrate %cpu background1")
# Long background map in background
long_compute_bg$collect_in_background()$join()  |> time_print("- 1b -io +bitrate %cpu background2")



### 2a ---------- Compare large computation
# low io - med bitrate - high cpu
print("test 2a - sequential")
library(polars)
pl$set_global_rpool_cap(1)
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
large_compute_fg$collect() |> time_print("- 2a %io ~bitrate +cpu foreground")
# Large background map in foreground
large_compute_bg$collect() |> time_print("- 2a %io ~bitrate +cpu background")
# Large background map in background
large_compute_bg$collect_in_background()$join() |> time_print("- 2a %io ~bitrate +cpu background2")


### 3a -----------  Use R processes in parallel
# high io, low bitrate, low cpu
print("test 3a - parallel")
library(polars)
lf <- pl$LazyFrame(lapply(1:1000,\(i) rep(i,5)))
f_sum_all_cols <-  \(lf,...) lf$select(pl$all()$map(\(x) {x$to_r() |> sum()},...))

f_sum_all_cols(lf)$collect() |> time_print("- 3a +io %bitrate %cpu foreground")

pl$set_global_rpool_cap(8)
f_sum_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3a +io %bitrate %cpu pool=8 background burn-in ")  #burn-in start processes
f_sum_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3a +io %bitrate %cpu pool=8 background")

pl$set_global_rpool_cap(4)
f_sum_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3a +io %bitrate %cpu pool=4 background")

pl$set_global_rpool_cap(2)
f_sum_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3a +io %bitrate %cpu pool=2 background")

pl$set_global_rpool_cap(1)
f_sum_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3a +io %bitrate %cpu pool=1 background")




### 3b -----------  Use R processes in parallel
# low io, low bitrate, high cpu
print("test 3b - parallel")
lf <- pl$LazyFrame(lapply(1:16,\(i) rep(i,5)))
f_all_cols <-  \(lf,...) lf$select(pl$all()$map(\(x) {
  for(i in 1:10000) y = sum(rnorm(1000))
  sum(x)
},...))

f_all_cols(lf, in_background = FALSE)$collect() |> time_print("- 3b %io %bitrate +cpu foreground")

pl$set_global_rpool_cap(8)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3b %io %bitrate +cpu pool=8 background burn-in ")
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3b %io %bitrate +cpu pool=8 background")


pl$set_global_rpool_cap(6)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3b %io %bitrate +cpu pool=6 background")

pl$set_global_rpool_cap(4)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3b %io %bitrate +cpu pool=4 background")

pl$set_global_rpool_cap(2)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3b %io %bitrate +cpu pool=2 background")

pl$set_global_rpool_cap(1)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3b %io %bitrate +cpu pool=1 background")


### 3c -----------  Use R processes in parallel,
# low io, high bitrate, high cpu
print("test 3c - parallel")
library(polars)
lf <- pl$LazyFrame(lapply(1:16,\(i) rep(i,1e6)*1.1))
f_all_cols <-  \(lf,...) lf$select(pl$all()$map(\(x) {
  for(i in 1:10000) y = sum(rnorm(1000))
  sum(x)
},...))

f_all_cols(lf, in_background = FALSE)$collect()  |> time_print("- 3c %io +bitrate +cpu foreground ")

pl$set_global_rpool_cap(8)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3c %io +bitrate +cpu pool=8 background burn-in ")
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3c %io +bitrate +cpu pool=8 background")


pl$set_global_rpool_cap(6)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3c %io +bitrate +cpu pool=6 background")

pl$set_global_rpool_cap(4)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3c %io +bitrate +cpu pool=4 background")

pl$set_global_rpool_cap(2)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3c %io +bitrate +cpu pool=2 background")

pl$set_global_rpool_cap(1)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3c %io +bitrate +cpu pool=1 background")


### 3d -----------  Use R processes in parallel,
# low io, high bitrate, low cpu (R conversion)
print("test 3d - parallel + r-polars conversion")
library(polars)
lf <- pl$LazyFrame(lapply(1:32,\(i) rep(i,1e6)*1.1))
f_all_cols <-  \(lf,...) lf$select(pl$all()$map(\(x) {
 x$to_r()
},...))

f_all_cols(lf, in_background = FALSE)$collect()  |> time_print("- 3d %io +bitrate +cpu foreground ")

pl$set_global_rpool_cap(8)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3d %io +bitrate +cpu pool=8 background burn-in ")
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3d %io +bitrate +cpu pool=8 background")


pl$set_global_rpool_cap(6)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3d %io +bitrate +cpu pool=6 background")

pl$set_global_rpool_cap(4)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3d %io +bitrate +cpu pool=4 background")

pl$set_global_rpool_cap(2)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3d %io +bitrate +cpu pool=2 background")

pl$set_global_rpool_cap(1)
f_all_cols(lf, in_background = TRUE)$collect() |> time_print("- 3d %io +bitrate +cpu pool=1 background")
