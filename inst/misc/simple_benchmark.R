library(arrow, warn.conflicts = FALSE)
library(polars)
library(nanoarrow)
library(bench)

df <- pl$DataFrame(nycflights13::flights)
nyf = nycflights13::flights
for(i in  names(nyf)[sapply(nyf,is.character)]) nyf[[i]]<-NULL
df_no_char <- pl$DataFrame(nyf)

n <- df$shape[1]

x = bench::mark(
  nanoarrow = {
    nanoarrow::as_nanoarrow_array_stream(df)
  },
  nanoarrow_df = {
    as.data.frame(nanoarrow::as_nanoarrow_array_stream(df))
  },
  # much faster because strings are never materialized to R
  arrow_table = {
    as.data.frame(as.data.frame(arrow::as_arrow_table(df)))
  },
  df2 <- pl$DataFrame(nycflights13::flights),
  df3 <- pl$DataFrame(nyf),

  rpolars_df = df$as_data_frame(),
  rpolars_list = df$to_list(),
  rpolars_list_no_char = df_no_char$to_list(),
  rpolars_uwind = .pr$DataFrame$to_list_unwind(df),
  check = FALSE,
  min_iterations = 15L
)

print(x)
