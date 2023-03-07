library(rpolars)
library(arrow)
library(nycflights13)


# nyx = nycflights13::flights
# for(i in names(which(sapply(nyx,is.character)))) {
#   nyx[[i]] = NULL
# }
big_arrow_table = do.call(rbind,lapply(1:5, \(x) arrow::arrow_table(nycflights13::flights)))
rbr = as_record_batch_reader(big_arrow_table)

dim(big_arrow_table)

# via arrow API
system.time({
   rbr = as_record_batch_reader(big_arrow_table)
      df = rpolars:::rb_list_to_df(rbr$batches(),rbr$schema$names)
})

nb = rbr$read_next_batch()
nb$export_to_c()
big_df = as.data.frame(big_arrow_table)

# via r-polars conversion full copy
system.time({df_simple = pl$DataFrame(big_df)})

library(nanoarrow)
library(bench)

x = bench::mark(
  # much faster because strings are never materialized to R
  to_arrow = {
      rbr = as_record_batch_reader(big_arrow_table)
      df = rpolars:::rb_list_to_df(rbr$batches(),rbr$schema$names)
  },
  # ,
  # DataFrame = {
  #     df = pl$DataFrame(big_df)
  # },
  check = FALSE,
  min_iterations = 25L
)
print(x)
