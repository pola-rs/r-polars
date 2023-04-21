# Expr_map

```r
Expr_map(f, output_type = NULL, agg_list = FALSE)
```

## Arguments

- `f`: a function mapping a series
- `output_type`: NULL or one of pl$dtypes$..., the output datatype, NULL is the same as input.
- `agg_list`: Aggregate list. Map from vector to group in groupby context. Likely not so useful.

## Returns

Expr

Expr_map

## Details

user function return should be a series or any Robj convertable into a Series. In PyPolars likely return must be Series. User functions do fully support `browser()`, helpful to investigate.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Sepal.Length"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>map</span><span class='op'>(</span>\<span class='op'>(</span><span class='va'>x</span><span class='op'>)</span> <span class='op'>{</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='op'>(</span><span class='st'>"cheese"</span>,<span class='fu'><a href='https://rdrr.io/r/base/character.html'>as.character</a></span><span class='op'>(</span><span class='va'>x</span><span class='op'>$</span><span class='fu'>to_r_vector</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>}</span>, <span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (150, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cheese 5.1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cheese 4.9   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cheese 4.7   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cheese 4.6   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cheese 6.3   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cheese 6.5   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cheese 6.2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cheese 5.9   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┘</span>
 </code></pre>