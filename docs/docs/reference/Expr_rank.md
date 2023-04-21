# Rank

```r
Expr_rank(method = "average", reverse = FALSE)
```

## Arguments

- `method`: string option 'average', 'min', 'max', 'dense', 'ordinal', 'random'
    
    #' The method used to assign ranks to tied elements. The following methods are available (default is 'average'):
    
     * 'average' : The average of the ranks that would have been assigned to all the tied values is assigned to each value.
     * 'min' : The minimum of the ranks that would have been assigned to all the tied values is assigned to each value. (This is also referred to as "competition" ranking.)
     * 'max' : The maximum of the ranks that would have been assigned to all the tied values is assigned to each value.
     * 'dense' : Like 'min', but the rank of the next highest element is assigned the rank immediately after those assigned to the tied elements.
     * 'ordinal' : All values are given a distinct rank, corresponding to the order that the values occur in the Series.
     * 'random' : Like 'ordinal', but the rank for ties is not dependent on the order that the values occur in the Series.
- `reverse`: bool, reverse the operation

## Returns

Expr

Assign ranks to data, dealing with ties appropriately.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#  The 'average' method:</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>3</span>, <span class='fl'>6</span>, <span class='fl'>1</span>, <span class='fl'>1</span>, <span class='fl'>6</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>rank</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.5 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.5 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.5 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.5 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#  The 'ordinal' method:</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>3</span>, <span class='fl'>6</span>, <span class='fl'>1</span>, <span class='fl'>1</span>, <span class='fl'>6</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>rank</span><span class='op'>(</span><span class='st'>"ordinal"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ u32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>