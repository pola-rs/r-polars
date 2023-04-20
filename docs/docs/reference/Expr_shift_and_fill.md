# Shift and fill values

## Format

a method

```r
Expr_shift_and_fill(periods, fill_value)
```

## Arguments

- `periods`: numeric number of periods to shift, may be negative.
- `fill_value`: Fill None values with the result of this expression.

## Returns

Expr

Shift the values by a given period and fill the resulting null values.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift_and_fill</span><span class='op'>(</span><span class='op'>-</span><span class='fl'>2</span>, fill_value <span class='op'>=</span> <span class='fl'>42</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"shift-2"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift_and_fill</span><span class='op'>(</span><span class='fl'>2</span>, fill_value <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span><span class='op'>/</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"shift+2"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │     ┆ shift-2 ┆ shift+2 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---     ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ f64     ┆ f64     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 0   ┆ 2.0     ┆ 21.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ 3.0     ┆ 21.0    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 42.0    ┆ 0.0     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   ┆ 42.0    ┆ 1.0     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────────┴─────────┘</span>
 </code></pre>