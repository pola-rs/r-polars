library(rpolars)
library(arrow)
library(nycflights13)


rbr = as_record_batch_reader(nycflights13::flights)
big_arrow_table = do.call(rbind,lapply(1:2, \(x) arrow::arrow_table(nycflights13::flights)))
rbr = as_record_batch_reader(big_arrow_table)

dim(big_arrow_table)

# via arrow API
system.time({df = rpolars:::rb_list_to_df(rbr$batches(),rbr$schema$names)})

big_df = as.data.frame(big_arrow_table)

# via r-polars conversion full copy
system.time({df_simple = pl$DataFrame(big_df)})

