# to_r: for debuging an expression

## Format

Method

```r
Expr_to_r(df = NULL, i = 0)
```

## Arguments

- `df`: otherwise a DataFrame to evaluate in, default NULL is an empty DataFrame
- `i`: numeric column to extract zero index default first, expression could generate multiple columns

## Returns

R object

debug an expression by evaluating in empty DataFrame and return first series to R

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1 2 3</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>expr_to_r</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1 2 3</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>expr_to_r</span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1 2 3</span>
 </code></pre>