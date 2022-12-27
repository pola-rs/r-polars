import polars as pl 
from functools import reduce

# Test columns for poisoning
# Define columns as diffrent mixes of (fin)finite, (inf)infinite, (nan)NaN, (nul)Null
# The prefix value should as thumbrule win the poison battle!
# There are reasonalbe exemptions for some functions.
tst_cols = pl.DataFrame({
  "fin" : [1.0]*7,
  "inf" : [float("-inf")] *4 + [float("inf")] *3,
  "nan" : [float("nan")] *7 ,
  "nul" : [None] *7 ,
  "inf_fin" : [float("-inf")] + [1.0]*5 + [float("inf")],
  "nan_fin" : [float("nan")] + [1.0]*5 + [float("nan")],
  "nul_fin" : [None] + [1.0]*5 + [None],
  "nan_inf_fin" : [float("nan")] +[float("-inf")] + [1.0]*3 + [float("inf")] + [float("nan")],
  "nul_nan_fin" : [None] +[float("nan")] + [1.0]*3 + [float("nan")] + [None],
  "nul_inf_fin" : [None] +[float("-inf")] + [1.0]*3 + [float("inf")] + [None],
  "nul_nan_inf_fin" : [None] +[float("nan")] +[float("-inf")] +
    [1.0]*1 + [float("inf")] +[float("nan")] + [None],
})

# Test columns for sorting
tst_cols3 = pl.DataFrame({
  "floats" : [None] +[float("nan")] +[float("-inf")]+ [float("inf")] + [1.0],
}).with_columns([
  pl.all().reverse().alias("REV") # add reverse, should produce same result
])

# Test poisoning behaviour on most relevant functions. rolling_x function could be included also
test_rank_poison = [  
  #scalar:  poison
  tst_cols.select([pl.lit("sum"),pl.all().sum(),]),
  tst_cols.select([pl.lit("mean"),pl.all().mean(),]),
  tst_cols.select([pl.lit("product"),pl.all().product(),]),
  tst_cols.select([pl.lit("std"),pl.all().std(),]),
  tst_cols.select([pl.lit("var"),pl.all().var(),]),

  #cumulative: poison
  tst_cols.select([pl.lit("cumsum"),pl.all().cumsum().tail(1),]),
  tst_cols.select([pl.lit("cumprod"),pl.all().cummax().tail(1),]),

  #scalar: ranking + poison
  tst_cols.select([pl.lit("min"),pl.all().min(),]),
  tst_cols.select([pl.lit("max"),pl.all().max(),]),
  tst_cols.select([pl.lit("arg_min_take"),pl.all().take(pl.all().arg_min()),]),
  tst_cols.select([pl.lit("arg_max_take"),pl.all().take(pl.all().arg_max()),]),

  #cumulative: ranking + poision
  tst_cols.select([pl.lit("cummin"),pl.all().cummin().tail(1),]),
  tst_cols.select([pl.lit("cummax"),pl.all().cummax().tail(1),]),
  
]

# Test sorting behaviour on relevant functions
test_sort = [  
  #scalar:  poison
  tst_cols3.select([pl.all().sort().suffix("_sort"),]),
  tst_cols3.select([pl.all().take(pl.all().arg_sort()).suffix("_take_arg_sort"),]),
  #tst_cols3.select([pl.all().sort_by(pl.all()).tail(4).suffix("_sort_by"),]),
  tst_cols3.select([pl.all().top_k(5,reverse=True).suffix("_top_k_rev"),]),
  #only works when all values are unique
  tst_cols3.select([pl.all().take(pl.all().rank("max")-1).suffix("_take_rank"),]), 
 
]

#support for stacking
def vstack_f(df1,df2) :
  return df1.vstack(df2)
def hstack_f(df1,df2) :
  return df1.hstack(df2)

#tweak pretty print
pl.Config.set_tbl_cols(tst_cols.width+1).set_tbl_rows(len(test_rank_poison)).set_fmt_str_lengths(15)

#print results
print(reduce(vstack_f,test_rank_poison))
pl.Config.set_fmt_str_lengths(50)
print(reduce(hstack_f,test_sort).with_row_count())

