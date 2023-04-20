# Rolling quantile

```r
Expr_rolling_quantile(
  quantile,
  interpolation = "nearest",
  window_size,
  weights = NULL,
  min_periods = NULL,
  center = FALSE,
  by = NULL,
  closed = "left"
)
```

## Arguments

- `quantile`: Quantile between 0.0 and 1.0.
- `interpolation`: choice c('nearest', 'higher', 'lower', 'midpoint', 'linear')
- `window_size`: The length of the window. Can be a fixed integer size, or a dynamic temporal size indicated by the following string language:
    
     * 1ns (1 nanosecond)
     * 1us (1 microsecond)
     * 1ms (1 millisecond)
     * 1s (1 second)
     * 1m (1 minute)
     * 1h (1 hour)
     * 1d (1 day)
     * 1w (1 week)
     * 1mo (1 calendar month)
     * 1y (1 calendar year)
     * 1i (1 index count) If the dynamic string language is used, the `by` and `closed` arguments must also be set.
- `weights`: An optional slice with the same length as the window that will be multiplied elementwise with the values in the window.
- `min_periods`: The number of values in the window that should be non-null before computing a result. If None, it will be set equal to window size.
- `center`: Set the labels at the center of the window
- `by`: If the `window_size` is temporal for instance `"5h"` or `"3s`, you must set the column that will be used to determine the windows. This column must be of dtype `{Date, Datetime}`
- `closed`: : 'left', 'right', 'both', 'none'
    
    Define whether the temporal window interval is closed or not.

## Returns

Expr

Apply a rolling quantile (moving quantile) over the values in this array. A window of length `window_size` will traverse the array. The values that fill this window will (optionally) be multiplied with the weights given by the `weight` vector. The resulting values will be aggregated to their sum.

## Details

This functionality is experimental and may change without it being considered a breaking change. Notes: If you want to compute multiple aggregation statistics over the same dynamic window, consider using `groupby_rolling` this method can cache the window size computation.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>6</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>rolling_quantile</span><span class='op'>(</span>window_size <span class='op'>=</span> <span class='fl'>2</span>, quantile <span class='op'>=</span> <span class='fl'>.5</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (6, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.0  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┘</span>
 </code></pre>