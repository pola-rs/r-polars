# Value counts

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

## Format

Method

```r
Expr_value_counts(multithreaded = FALSE, sort = FALSE)
```

## Arguments

- `multithreaded`: Better to turn this off in the aggregation context, as it can lead to contention.
- `sort`: Ensure the output is sorted from most values to least.

## Returns

Expr

Count all unique values and create a struct mapping value to count.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Species"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>value_counts</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Species           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ struct[2]         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {"versicolor",50} │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {"virginica",50}  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {"setosa",50}     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>unnest</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_data_frame</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#recommended to unnest structs before converting to R</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>      Species counts</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 1 versicolor     50</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 2  virginica     50</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 3     setosa     50</span>
 </code></pre>