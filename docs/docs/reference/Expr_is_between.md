# is in between

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

```r
Expr_is_between(start, end, include_bounds = FALSE)
```

## Arguments

- `start`: Lower bound as primitive or datetime
- `end`: Lower bound as primitive or datetime
- `include_bounds`: bool vector or scalar: FALSE: Exclude both start and end (default). TRUE: Include both start and end. c(FALSE, FALSE): Exclude start and exclude end. c(TRUE, TRUE): Include start and include end. c(FALSE, TRUE): Exclude start and include end. c(TRUE, FALSE): Include start and exclude end.

## Returns

Expr

Check if this expression is between start and end.

## Details

alias the column to 'in_between' This function is equivalent to a combination of < <= >= and the &-and operator.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>num <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"num"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_between</span><span class='op'>(</span><span class='fl'>2</span>,<span class='fl'>4</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ is_between │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bool       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"num"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_between</span><span class='op'>(</span><span class='fl'>2</span>,<span class='fl'>4</span>,<span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ is_between │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bool       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"num"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_between</span><span class='op'>(</span><span class='fl'>2</span>,<span class='fl'>4</span>,<span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>FALSE</span>, <span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ is_between │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bool       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┘</span>
<span class='r-in'><span><span class='co'>#start end can be a vector/expr with same length as column</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"num"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>is_between</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>0</span>,<span class='fl'>2</span>,<span class='fl'>3</span>,<span class='fl'>3</span>,<span class='fl'>3</span><span class='op'>)</span>,<span class='fl'>6</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (5, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ is_between │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bool       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ true       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────────┘</span>
 </code></pre>