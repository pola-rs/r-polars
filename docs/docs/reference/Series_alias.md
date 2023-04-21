data

*Source: [R/series__series.R](https://github.com/pola-rs/r-polars/tree/main/R/series__series.R)*

# Alias

## Format

An object of class `character` of length 1.

```r
Series_alias(name)
```

## Arguments

- `name`: a String as the new name

## Returns

Series

Change name of Series

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>,name <span class='op'>=</span> <span class='st'>"alice"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"bob"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (3,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'bob' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>