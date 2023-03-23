library(polars)
library(arrow)
library(nycflights13)


# nyx = nycflights13::flights
# for(i in names(which(sapply(nyx,is.character)))) {
#   nyx[[i]] = NULL
# }
big_arrow_table = do.call(rbind,lapply(1:25, \(x) arrow::arrow_table(nycflights13::flights)))
(dim(big_arrow_table)/c(1E6,1)) |> paste(c("million rows", "cols"))
cat("total n chunks:", ncol(big_arrow_table)* big_arrow_table$column(1)$num_chunks)

library(nanoarrow)
library(bench)

# via arrow API
system.time({
   rbr = as_record_batch_reader(big_arrow_table)
      df = polars:::rb_list_to_df(rbr$batches(),rbr$schema$names)
})

system.time({
   rbr = as_record_batch_reader(big_arrow_table)
   df = pl$from_arrow(rbr)
})

# via r-polars conversion full copy
big_df = as.data.frame(big_arrow_table)
system.time({df_simple = pl$DataFrame(big_df)})
#about 40 times speed up


x = bench::mark(
  # much faster because strings are never materialized to R
  to_arrow = {
      rbr = as_record_batch_reader(big_arrow_table)
      df = polars:::rb_list_to_df(rbr$batches(),rbr$schema$names)
  },
  from_arrow = {
      pl$from_arrow(big_arrow_table)
  },
  from_arrow_no_rechunk = {
      pl$from_arrow(big_arrow_table,rechunk = FALSE)
  },
  from_arrow_all_series ={
    lapply(big_arrow_table$columns, pl$from_arrow, rechunk=FALSE)
  },

  # ,
  # DataFrame = {
  #     df = pl$DataFrame(big_df)
  # },
  check = FALSE,
  min_iterations = 10L
)

x

#a not very smooth to way to do rechunk in arrow
bat = arrow::Table$create(
  do.call(data.frame,lapply(big_arrow_table$columns, \(x) as.vector(as_arrow_array(x))) )
)


y = bench::mark(
  # much faster because strings are never materialized to R
  to_arrow = {
      rbr = as_record_batch_reader(bat)
      df = polars:::rb_list_to_df(rbr$batches(),rbr$schema$names)
  },
  from_arrow = {
      pl$from_arrow(bat)
  },
  from_arrow_all_series ={
    lapply(big_arrow_table$columns, pl$from_arrow, rechunk=FALSE)
  },
  to_arrow2 = {
      rbr = as_record_batch_reader(bat)
      df = polars:::rb_list_to_df(rbr$batches(),rbr$schema$names)
  },
  # ,
  # DataFrame = {
  #     df = pl$DataFrame(big_df)
  # },
  check = FALSE,
  min_iterations = 10L
)

print(x)
print(y)

arrow:::as_arrow_array.ChunkedArray(big_arrow_table$column(1))








