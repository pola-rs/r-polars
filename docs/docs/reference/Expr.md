# Polars Expr

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

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='fl'>2</span><span class='op'>+</span><span class='fl'>2</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 4</span>
<span class='r-in'><span><span class='co'>#Expr has the following methods/constructors</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/Expr.html'>Expr</a></span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   [1] "abs"              "add"              "agg_groups"       "alias"            "all"              "and"             </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   [7] "any"              "append"           "apply"            "arccos"           "arccosh"          "arcsin"          </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [13] "arcsinh"          "arctan"           "arctanh"          "arg_max"          "arg_min"          "arg_sort"        </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [19] "arg_unique"       "argsort"          "arr"              "backward_fill"    "bin"              "cast"            </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [25] "cat"              "ceil"             "clip"             "clip_max"         "clip_min"         "cos"             </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [31] "cosh"             "count"            "cumcount"         "cummax"           "cummin"           "cumprod"         </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [37] "cumsum"           "cumulative_eval"  "diff"             "div"              "dot"              "drop_nans"       </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [43] "drop_nulls"       "dt"               "entropy"          "eq"               "ewm_mean"         "ewm_std"         </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [49] "ewm_var"          "exclude"          "exp"              "explode"          "extend_constant"  "extend_expr"     </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [55] "fill_nan"         "fill_null"        "filter"           "first"            "flatten"          "floor"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [61] "forward_fill"     "gt"               "gt_eq"            "hash"             "head"             "inspect"         </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [67] "interpolate"      "is_between"       "is_duplicated"    "is_finite"        "is_first"         "is_in"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [73] "is_infinite"      "is_nan"           "is_not"           "is_not_nan"       "is_not_null"      "is_null"         </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [79] "is_unique"        "keep_name"        "kurtosis"         "last"             "len"              "limit"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [85] "list"             "lit"              "lit_to_df"        "lit_to_s"         "log"              "log10"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [91] "lower_bound"      "lt"               "lt_eq"            "map"              "map_alias"        "max"             </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [97] "mean"             "median"           "meta"             "min"              "mode"             "mul"             </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [103] "n_unique"         "nan_max"          "nan_min"          "neq"              "null_count"       "or"              </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [109] "over"             "pct_change"       "pow"              "prefix"           "print"            "product"         </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [115] "quantile"         "rank"             "rechunk"          "reinterpret"      "rep"              "rep_extend"      </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [121] "repeat_by"        "reshape"          "reverse"          "rolling_max"      "rolling_mean"     "rolling_median"  </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [127] "rolling_min"      "rolling_quantile" "rolling_skew"     "rolling_std"      "rolling_sum"      "rolling_var"     </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [133] "round"            "rpow"             "sample"           "search_sorted"    "set_sorted"       "shift"           </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [139] "shift_and_fill"   "shrink_dtype"     "shuffle"          "sign"             "sin"              "sinh"            </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [145] "skew"             "slice"            "sort"             "sort_by"          "sqrt"             "std"             </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [151] "str"              "struct"           "sub"              "suffix"           "sum"              "tail"            </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [157] "take"             "take_every"       "tan"              "tanh"             "to_physical"      "to_r"            </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [163] "to_struct"        "top_k"            "unique"           "unique_counts"    "upper_bound"      "value_counts"    </span>
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
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 1)</span>
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
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 1)</span>
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