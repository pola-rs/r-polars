# Polars Expr

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

```r
Expr_lit(x)

Expr_suffix(suffix)

Expr_prefix(prefix)

Expr_reverse()
```

## Arguments

- `x`: an R Scalar, or R vector/list (via Series) into Expr
- `suffix`: string suffix to be added to a name
- `prefix`: string suffix to be added to a name

## Returns

Expr, literal of that value

Expr

Expr

Expr

Polars pl$Expr

## Details

pl$lit(NULL) translates into a typeless polars Null

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='fl'>2</span><span class='op'>+</span><span class='fl'>2</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 4</span>
<span class='r-in'><span><span class='co'>#Expr has the following methods/constructors</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/Expr.html'>Expr</a></span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   [1] "abs"              "add"              "agg_groups"       "alias"            "all"              "and"              "any"             </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   [8] "append"           "apply"            "arccos"           "arccosh"          "arcsin"           "arcsinh"          "arctan"          </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [15] "arctanh"          "arg_max"          "arg_min"          "arg_sort"         "arg_unique"       "argsort"          "arr"             </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [22] "backward_fill"    "bin"              "cast"             "cat"              "ceil"             "clip"             "clip_max"        </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [29] "clip_min"         "cos"              "cosh"             "count"            "cumcount"         "cummax"           "cummin"          </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [36] "cumprod"          "cumsum"           "cumulative_eval"  "diff"             "div"              "dot"              "drop_nans"       </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [43] "drop_nulls"       "dt"               "entropy"          "eq"               "ewm_mean"         "ewm_std"          "ewm_var"         </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [50] "exclude"          "exp"              "explode"          "extend_constant"  "extend_expr"      "fill_nan"         "fill_null"       </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [57] "filter"           "first"            "flatten"          "floor"            "forward_fill"     "gt"               "gt_eq"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [64] "hash"             "head"             "inspect"          "interpolate"      "is_between"       "is_duplicated"    "is_finite"       </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [71] "is_first"         "is_in"            "is_infinite"      "is_nan"           "is_not"           "is_not_nan"       "is_not_null"     </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [78] "is_null"          "is_unique"        "keep_name"        "kurtosis"         "last"             "len"              "limit"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [85] "list"             "lit"              "lit_to_df"        "lit_to_s"         "log"              "log10"            "lower_bound"     </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [92] "lt"               "lt_eq"            "map"              "map_alias"        "max"              "mean"             "median"          </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [99] "meta"             "min"              "mode"             "mul"              "n_unique"         "nan_max"          "nan_min"         </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [106] "neq"              "null_count"       "or"               "over"             "pct_change"       "pow"              "prefix"          </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [113] "print"            "product"          "quantile"         "rank"             "rechunk"          "reinterpret"      "rep"             </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [120] "rep_extend"       "repeat_by"        "reshape"          "reverse"          "rolling_max"      "rolling_mean"     "rolling_median"  </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [127] "rolling_min"      "rolling_quantile" "rolling_skew"     "rolling_std"      "rolling_sum"      "rolling_var"      "round"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [134] "rpow"             "sample"           "search_sorted"    "set_sorted"       "shift"            "shift_and_fill"   "shrink_dtype"    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [141] "shuffle"          "sign"             "sin"              "sinh"             "skew"             "slice"            "sort"            </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [148] "sort_by"          "sqrt"             "std"              "str"              "struct"           "sub"              "suffix"          </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [155] "sum"              "tail"             "take"             "take_every"       "tan"              "tanh"             "to_physical"     </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [162] "to_r"             "to_struct"        "top_k"            "unique"           "unique_counts"    "upper_bound"      "value_counts"    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [169] "var"              "where"            "xor"             </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"this_column"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>over</span><span class='op'>(</span><span class='st'>"that_column"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: col("this_column").sum().over([col("that_column")])</span>
<span class='r-in'><span><span class='co'>#scalars to literal, explit `pl$lit(42)` implicit `+ 2`</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"some_column"</span><span class='op'>)</span> <span class='op'>/</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span> <span class='op'>+</span> <span class='fl'>2</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [([(col("some_column")) / (42f64)]) + (2f64)]</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#vector to literal explicitly via Series and back again</span></span></span>
<span class='r-in'><span><span class='co'>#R vector to expression and back again</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_list</span><span class='op'>(</span><span class='op'>)</span><span class='op'>[[</span><span class='fl'>1L</span><span class='op'>]</span><span class='op'>]</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1 2 3 4</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#r vecot to literal and back r vector</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1 2 3 4</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#r vector to literal to dataframe</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#r vector to literal to Series</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (4,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#vectors to literal implicitly</span></span></span>
<span class='r-in'><span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span> <span class='op'>+</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span> <span class='op'>)</span> <span class='op'>/</span> <span class='fl'>4</span><span class='op'>:</span><span class='fl'>1</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [([(2f64) + (Series)]) / (Series)]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"some"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>suffix</span><span class='op'>(</span><span class='st'>"_column"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: RENAME_ALIAS col("some")</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"some"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>suffix</span><span class='op'>(</span><span class='st'>"_column"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: RENAME_ALIAS col("some")</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>reverse</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>