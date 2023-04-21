# Pop

*Source: [R/expr__meta.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__meta.R)*

## Returns

R list of Expr(s) usually one, only multiple if top Expr took more Expr as input.

Pop the latest expression and return the input(s) of the popped expression.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>e1</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>40</span><span class='op'>)</span> <span class='op'>+</span> <span class='fl'>2</span></span></span>
<span class='r-in'><span><span class='va'>e2</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>e1</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(40f64) + (2f64)]</span>
<span class='r-in'><span><span class='va'>e1</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>pop</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: 2f64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[2]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: 40f64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>e2</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: 42f64.sum()</span>
<span class='r-in'><span><span class='va'>e2</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>pop</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: 42f64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>