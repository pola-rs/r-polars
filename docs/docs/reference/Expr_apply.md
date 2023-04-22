# Expr_apply

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

```r
Expr_apply(
  f,
  return_type = NULL,
  strict_return_type = TRUE,
  allow_fail_eval = FALSE
)
```

## Arguments

- `f`: r function see details depending on context
- `return_type`: NULL or one of pl$dtypes, the output datatype, NULL is the same as input.
- `strict_return_type`: bool (default TRUE), error if not correct datatype returned from R, if FALSE will convert to a Polars Null and carry on.
- `allow_fail_eval`: bool (default FALSE), if TRUE will not raise user function error but convert result to a polars Null and carry on.

## Returns

Expr

Apply a custom/user-defined function (UDF) in a GroupBy or Projection context. Depending on the context it has the following behavior: -Selection

## Details

Apply a user function in a groupby or projection(select) context

Depending on context the following behaviour:

 * Projection/Selection: Expects an `f` to operate on R scalar values. Polars will convert each element into an R value and pass it to the function The output of the user function will be converted back into a polars type. Return type must match. See param return type. Apply in selection context should be avoided as a `lapply()` has half the overhead.
 * Groupby Expects a user function `f` to take a `Series` and return a `Series` or Robj convertable to `Series`, eg. R vector. GroupBy context much faster if number groups are quite fewer than number of rows, as the iteration is only across the groups. The r user function could e.g. do vectorized operations and stay quite performant. use `s$to_r()` to convert input Series to an r vector or list. use `s$to_vector` and `s$to_r_list()` to force conversion to vector or list.

Implementing logic using an R function is almost always **significantly**

slower and more memory intensive than implementing the same logic using the native expression API because: - The native expression engine runs in Rust; functions run in R. - Use of R functions forces the DataFrame to be materialized in memory. - Polars-native expressions can be parallelised (R functions cannot*). - Polars-native expressions can be logically optimised (R functions cannot). Wherever possible you should strongly prefer the native expression API to achieve the best performance.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#apply over groups - normal usage</span></span></span>
<span class='r-in'><span><span class='co'># s is a series of all values for one column within group, here Species</span></span></span>
<span class='r-in'><span><span class='va'>e_all</span> <span class='op'>=</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#perform groupby agg on all columns otherwise e.g. pl$col("Sepal.Length")</span></span></span>
<span class='r-in'><span><span class='va'>e_sum</span>  <span class='op'>=</span> <span class='va'>e_all</span><span class='op'>$</span><span class='fu'>apply</span><span class='op'>(</span>\<span class='op'>(</span><span class='va'>s</span><span class='op'>)</span>  <span class='fu'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='op'>(</span><span class='va'>s</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>suffix</span><span class='op'>(</span><span class='st'>"_sum"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>e_head</span> <span class='op'>=</span> <span class='va'>e_all</span><span class='op'>$</span><span class='fu'>apply</span><span class='op'>(</span>\<span class='op'>(</span><span class='va'>s</span><span class='op'>)</span> <span class='fu'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='op'>(</span><span class='va'>s</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span>,<span class='fl'>2</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>suffix</span><span class='op'>(</span><span class='st'>"_head"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>groupby</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>agg</span><span class='op'>(</span><span class='va'>e_sum</span>,<span class='va'>e_head</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 9)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───┬────────────┬────────────┬────────────┬─────┬────────────┬────────────┬────────────┬────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ S ┆ Sepal.Leng ┆ Sepal.Widt ┆ Petal.Leng ┆ ... ┆ Sepal.Leng ┆ Sepal.Widt ┆ Petal.Leng ┆ Petal.Widt │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ p ┆ th_sum     ┆ h_sum      ┆ th_sum     ┆     ┆ th_head    ┆ h_head     ┆ th_head    ┆ h_head     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ e ┆ ---        ┆ ---        ┆ ---        ┆     ┆ ---        ┆ ---        ┆ ---        ┆ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ c ┆ f64        ┆ f64        ┆ f64        ┆     ┆ list[f64]  ┆ list[f64]  ┆ list[f64]  ┆ list[f64]  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ e ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ - ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ - ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ - ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ c ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ t ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══╪════════════╪════════════╪════════════╪═════╪════════════╪════════════╪════════════╪════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ v ┆ 296.8      ┆ 138.5      ┆ 213.0      ┆ ... ┆ [7.0, 6.4] ┆ [3.2, 3.2] ┆ [4.7, 4.5] ┆ [1.4, 1.5] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ e ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ r ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ c ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ o ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ l ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ o ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ r ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s ┆ 250.3      ┆ 171.4      ┆ 73.1       ┆ ... ┆ [5.1, 4.9] ┆ [3.5, 3.0] ┆ [1.4, 1.4] ┆ [0.2, 0.2] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ e ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ t ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ o ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ v ┆ 329.4      ┆ 148.7      ┆ 277.6      ┆ ... ┆ [6.3, 5.8] ┆ [3.3, 2.7] ┆ [6.0, 5.1] ┆ [2.5, 1.9] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ r ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ g ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ n ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ c ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a ┆            ┆            ┆            ┆     ┆            ┆            ┆            ┆            │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───┴────────────┴────────────┴────────────┴─────┴────────────┴────────────┴────────────┴────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># apply over single values (should be avoided as it takes ~2.5us overhead + R function exec time</span></span></span>
<span class='r-in'><span><span class='co'># on a 2015 MacBook Pro) x is an R scalar</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#perform on all Float64 columns, using pl$all requires user function can handle any input type</span></span></span>
<span class='r-in'><span><span class='va'>e_all</span> <span class='op'>=</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Float64</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>e_add10</span>  <span class='op'>=</span> <span class='va'>e_all</span><span class='op'>$</span><span class='fu'>apply</span><span class='op'>(</span>\<span class='op'>(</span><span class='va'>x</span><span class='op'>)</span>  <span class='op'>{</span><span class='va'>x</span><span class='op'>+</span><span class='fl'>10</span><span class='op'>}</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>suffix</span><span class='op'>(</span><span class='st'>"_sum"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='co'>#quite silly index into alphabet(letters) by ceil of float value</span></span></span>
<span class='r-in'><span><span class='co'>#must set return_type as not the same as input</span></span></span>
<span class='r-in'><span><span class='va'>e_letter</span> <span class='op'>=</span> <span class='va'>e_all</span><span class='op'>$</span><span class='fu'>apply</span><span class='op'>(</span>\<span class='op'>(</span><span class='va'>x</span><span class='op'>)</span> <span class='va'>letters</span><span class='op'>[</span><span class='fu'><a href='https://rdrr.io/r/base/Round.html'>ceiling</a></span><span class='op'>(</span><span class='va'>x</span><span class='op'>)</span><span class='op'>]</span>, return_type <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>suffix</span><span class='op'>(</span><span class='st'>"_letter"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>e_add10</span>,<span class='va'>e_letter</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (150, 8)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Leng ┆ Sepal.Widt ┆ Petal.Leng ┆ Petal.Widt ┆ Sepal.Leng ┆ Sepal.Widt ┆ Petal.Leng ┆ Petal.Widt │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ th_sum     ┆ h_sum      ┆ th_sum     ┆ h_sum      ┆ th_letter  ┆ h_letter   ┆ th_letter  ┆ h_letter   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        ┆ ---        ┆ ---        ┆ ---        ┆ ---        ┆ ---        ┆ ---        ┆ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64        ┆ f64        ┆ f64        ┆ f64        ┆ str        ┆ str        ┆ str        ┆ str        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╪════════════╪════════════╪════════════╪════════════╪════════════╪════════════╪════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 15.1       ┆ 13.5       ┆ 11.4       ┆ 10.2       ┆ f          ┆ d          ┆ b          ┆ a          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 14.9       ┆ 13.0       ┆ 11.4       ┆ 10.2       ┆ e          ┆ c          ┆ b          ┆ a          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 14.7       ┆ 13.2       ┆ 11.3       ┆ 10.2       ┆ e          ┆ d          ┆ b          ┆ a          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 14.6       ┆ 13.1       ┆ 11.5       ┆ 10.2       ┆ e          ┆ d          ┆ b          ┆ a          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...        ┆ ...        ┆ ...        ┆ ...        ┆ ...        ┆ ...        ┆ ...        ┆ ...        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 16.3       ┆ 12.5       ┆ 15.0       ┆ 11.9       ┆ g          ┆ c          ┆ e          ┆ b          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 16.5       ┆ 13.0       ┆ 15.2       ┆ 12.0       ┆ g          ┆ c          ┆ f          ┆ b          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 16.2       ┆ 13.4       ┆ 15.4       ┆ 12.3       ┆ g          ┆ d          ┆ f          ┆ c          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 15.9       ┆ 13.0       ┆ 15.1       ┆ 11.8       ┆ f          ┆ c          ┆ f          ┆ b          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────────┴────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>##timing "slow" apply in select /with_columns context, this makes apply</span></span></span>
<span class='r-in'><span><span class='va'>n</span> <span class='op'>=</span> <span class='fl'>1000000L</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='va'>n</span>,</span></span>
<span class='r-in'><span>  b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/sample.html'>sample</a></span><span class='op'>(</span><span class='va'>letters</span>,<span class='va'>n</span>,replace<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span></span></span>
<span class='r-in'><span> <span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='st'>"apply over 1 million values takes ~2.5 sec on 2015 MacBook Pro"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "apply over 1 million values takes ~2.5 sec on 2015 MacBook Pro"</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='op'>(</span><span class='op'>{</span></span></span>
<span class='r-in'><span>  <span class='va'>rdf</span> <span class='op'>=</span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>apply</span><span class='op'>(</span>\<span class='op'>(</span><span class='va'>x</span><span class='op'>)</span> <span class='op'>{</span></span></span>
<span class='r-in'><span>     <span class='va'>x</span><span class='op'>*</span><span class='fl'>2L</span></span></span>
<span class='r-in'><span>   <span class='op'>}</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"bob"</span><span class='op'>)</span></span></span>
<span class='r-in'><span> <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>}</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>    user  system elapsed </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>    1.46    0.01    1.47 </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='st'>"R lapply 1 million values take ~1sec on 2015 MacBook Pro"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "R lapply 1 million values take ~1sec on 2015 MacBook Pro"</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='op'>(</span><span class='op'>{</span></span></span>
<span class='r-in'><span> <span class='fu'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='op'>(</span><span class='va'>df</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span>,\<span class='op'>(</span><span class='va'>x</span><span class='op'>)</span> <span class='va'>x</span><span class='op'>*</span><span class='fl'>2L</span> <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>}</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>    user  system elapsed </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>    0.64    0.00    0.64 </span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='st'>"using polars syntax takes ~1ms"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "using polars syntax takes ~1ms"</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='op'>(</span><span class='op'>{</span></span></span>
<span class='r-in'><span> <span class='op'>(</span><span class='va'>df</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span> <span class='op'>*</span> <span class='fl'>2L</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>}</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>    user  system elapsed </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       0       0       0 </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='st'>"using R vector syntax takes ~4ms"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "using R vector syntax takes ~4ms"</span>
<span class='r-in'><span><span class='va'>r_vec</span> <span class='op'>=</span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>get_column</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/system.time.html'>system.time</a></span><span class='op'>(</span><span class='op'>{</span></span></span>
<span class='r-in'><span> <span class='va'>r_vec</span> <span class='op'>*</span> <span class='fl'>2L</span></span></span>
<span class='r-in'><span><span class='op'>}</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>    user  system elapsed </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       0       0       0 </span>
 </code></pre>