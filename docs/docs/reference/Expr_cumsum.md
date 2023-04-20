# Cumulative sum

## Format

a method

```r
Expr_cumsum(reverse = FALSE)
```

## Arguments

- `reverse`: bool, default FALSE, if true roll over vector from back to forth

## Returns

Expr

Get an array with the cumulative sum computed at every element.

## Details

Dtypes in Int8, UInt8, Int16, UInt16 are cast to Int64 before summing to prevent overflow issues.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cumsum</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"cumsum"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cumsum</span><span class='op'>(</span>reverse<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"cumsum_reversed"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (4, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────┬─────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cumsum ┆ cumsum_reversed │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---    ┆ ---             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32    ┆ i32             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════╪═════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1      ┆ 10              │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3      ┆ 9               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6      ┆ 7               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 10     ┆ 4               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────┴─────────────────┘</span>
 </code></pre>