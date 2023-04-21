# to_struct and unnest again

```r
DataFrame_to_struct(name = "")

DataFrame_unnest(names = NULL)
```

## Arguments

- `name`: name of new Series
- `names`: names of struct columns to unnest, default NULL unnest any struct column

## Returns

@to_struct() returns a Series

$unnest() returns a DataFrame with all column including any that has been unnested

to_struct and unnest again

Unnest a DataFrame struct columns.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#round-trip conversion from DataFrame with two columns</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a<span class='op'>=</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span>,b<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"one"</span>,<span class='st'>"two"</span>,<span class='st'>"three"</span>,<span class='st'>"four"</span>,<span class='st'>"five"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s</span> <span class='op'>=</span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>to_struct</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>s</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (5,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: '' [struct[2]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	{1,"one"}</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	{2,"two"}</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	{3,"three"}</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	{4,"four"}</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	{5,"five"}</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>s</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span> <span class='co'># to r list</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $a</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1 2 3 4 5</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $b</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "one"   "two"   "three" "four"  "five" </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"is_struct")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span><span class='va'>df_s</span> <span class='op'>=</span> <span class='va'>s</span><span class='op'>$</span><span class='fu'>to_frame</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#place series in a new DataFrame</span></span></span>
<span class='r-in'><span><span class='va'>df_s</span><span class='op'>$</span><span class='fu'>unnest</span><span class='op'>(</span><span class='op'>)</span> <span class='co'># back to starting df</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ str   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ one   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ two   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   ┆ three │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4   ┆ four  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5   ┆ five  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴───────┘</span>
 </code></pre>