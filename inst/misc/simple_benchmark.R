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
  df4 <- .pr$DataFrame$new_par_from_list(as.list(nycflights13::flights)),
  df5 <- .pr$DataFrame$new_par_from_list(as.list(nyf)),
  df_fa1 <- pl$from_arrow(arrow_table(nycflights13::flights)),
  df_fa2 <- pl$from_arrow(arrow_table(nyf)),
  df6 <- pl$DataFrame(nycflights13::flights,parallel = TRUE),
  df7 <- pl$DataFrame(nyf,parallel = TRUE),
  polars_df = df$as_data_frame(),
  polars_list = df$to_list(),
  polars_list_no_char = df_no_char$to_list(),
  polars_uwind = .pr$DataFrame$to_list_unwind(df),
  check = FALSE,
  min_iterations = 15L
)

print(x)
