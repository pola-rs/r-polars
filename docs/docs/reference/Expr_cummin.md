# Cumulative minimum

## Format

a method

a method

```r
Expr_cummin(reverse = FALSE)

Expr_cummax(reverse = FALSE)
```

## Arguments

- `reverse`: bool, default FALSE, if true roll over vector from back to forth

## Returns

Expr

Expr

Get an array with the cumulative min computed at every element.

Get an array with the cumulative max computed at every element.

## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to prevent overflow issues.

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to prevent overflow issues.

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cummin</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"cummin"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cummin</span><span class='op'>(</span>reverse<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"cummin_reversed"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────┬─────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cummin ┆ cummin_reversed │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---    ┆ ---             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32    ┆ i32             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════╪═════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1      ┆ 1               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1      ┆ 2               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1      ┆ 3               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1      ┆ 4               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────┴─────────────────┘</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cummax</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"cummux"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cummax</span><span class='op'>(</span>reverse<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"cummax_reversed"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────┬─────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cummux ┆ cummax_reversed │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---    ┆ ---             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32    ┆ i32             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════╪═════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1      ┆ 4               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2      ┆ 4               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3      ┆ 4               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4      ┆ 4               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────┴─────────────────┘</span>
 </code></pre>