# Rename a series

## Format

method

```r
Series_rename(name, in_place = FALSE)
```

## Arguments

- `name`: string the new name
- `in_place`: bool rename in-place, breaks immutability If true will throw an error unless this option has been set: `pl$set_polars_options(strictly_immutable = FALSE)`

## Returns

bool

Rename a series

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span>,<span class='st'>"bob"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>rename</span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (4,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'alice' [i32]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
 </code></pre>