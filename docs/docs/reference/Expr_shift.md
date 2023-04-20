data

# Shift values

## Format

a method

```r
Expr_shift(periods)
```

## Arguments

- `periods`: numeric number of periods to shift, may be negative.

## Returns

Expr

Shift values

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift</span><span class='op'>(</span><span class='op'>-</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"shift-2"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>0</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift</span><span class='op'>(</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"shift+2"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ shift-2 ┆ shift+2 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---     ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32     ┆ i32     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2       ┆ null    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3       ┆ null    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null    ┆ 0       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null    ┆ 1       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────┴─────────┘</span>
 </code></pre>