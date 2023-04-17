# `Expr_apply`

Expr_apply


## Description

Apply a custom/user-defined function (UDF) in a GroupBy or Projection context.
 Depending on the context it has the following behavior:
 -Selection


## Usage

```r
Expr_apply(
  f,
  return_type = NULL,
  strict_return_type = TRUE,
  allow_fail_eval = FALSE
)
```


## Arguments

Argument      |Description
------------- |----------------
`f`     |     r function see details depending on context
`return_type`     |     NULL or one of pl$dtypes, the output datatype, NULL is the same as input.
`strict_return_type`     |     bool (default TRUE), error if not correct datatype returned from R, if FALSE will convert to a Polars Null and carry on.
`allow_fail_eval`     |     bool (default FALSE), if TRUE will not raise user function error but convert result to a polars Null and carry on.


## Details

Apply a user function in a groupby or projection(select) context
 
 Depending on context the following behaviour:
  

*  Projection/Selection: Expects an `f` to operate on R scalar values. Polars will convert each element into an R value and pass it to the function The output of the user function will be converted back into a polars type. Return type must match. See param return type. Apply in selection context should be avoided as a `lapply()` has half the overhead. 

*  Groupby Expects a user function `f` to take a `Series` and return a `Series` or Robj convertable to `Series` , eg. R vector. GroupBy context much faster if number groups are quite fewer than number of rows, as the iteration is only across the groups. The r user function could e.g. do vectorized operations and stay quite performant. use `s$to_r()` to convert input Series to an r vector or list. use `s$to_r_vector` and `s$to_r_list()` to force conversion to vector or list. 
 
 Implementing logic using an R function is almost always significantly 
 slower and more memory intensive than implementing the same logic using
 the native expression API because:
 - The native expression engine runs in Rust; functions run in R.
 - Use of R functions forces the DataFrame to be materialized in memory.
 - Polars-native expressions can be parallelised (R functions cannot*).
 - Polars-native expressions can be logically optimised (R functions cannot).
 Wherever possible you should strongly prefer the native expression API
 to achieve the best performance.


## Value

Expr


## Examples

```r
#apply over groups - normal usage
# s is a series of all values for one column within group, here Species
e_all =pl$all() #perform groupby agg on all columns otherwise e.g. pl$col("Sepal.Length")
e_sum  = e_all$apply(\(s)  sum(s$to_r()))$suffix("_sum")
e_head = e_all$apply(\(s) head(s$to_r(),2))$suffix("_head")
pl$DataFrame(iris)$groupby("Species")$agg(e_sum,e_head)


# apply over single values (should be avoided as it takes ~2.5us overhead + R function exec time
# on a 2015 MacBook Pro) x is an R scalar

#perform on all Float64 columns, using pl$all requires user function can handle any input type
e_all =pl$col(pl$dtypes$Float64)
e_add10  = e_all$apply(\(x)  {x+10})$suffix("_sum")
#quite silly index into alphabet(letters) by ceil of float value
#must set return_type as not the same as input
e_letter = e_all$apply(\(x) letters[ceiling(x)], return_type = pl$dtypes$Utf8)$suffix("_letter")
pl$DataFrame(iris)$select(e_add10,e_letter)


##timing "slow" apply in select /with_columns context, this makes apply
n = 1000000L
set.seed(1)
df = pl$DataFrame(list(
a = 1:n,
b = sample(letters,n,replace=TRUE)
))

print("apply over 1 million values takes ~2.5 sec on 2015 MacBook Pro")
system.time({
rdf = df$with_columns(
pl$col("a")$apply(\(x) {
x*2L
})$alias("bob")
)
})

print("R lapply 1 million values take ~1sec on 2015 MacBook Pro")
system.time({
lapply(df$get_column("a")$to_r(),\(x) x*2L )
})
print("using polars syntax takes ~1ms")
system.time({
(df$get_column("a") * 2L)
})


print("using R vector syntax takes ~4ms")
r_vec = df$get_column("a")$to_r()
system.time({
r_vec * 2L
})
```


