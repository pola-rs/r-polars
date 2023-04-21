# Shuffle

*Source: [R/expr__expr.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__expr.R)*

## Format

Method

```r
Expr_shuffle(seed = NULL)
```

## Arguments

- `seed`: numeric value of 0 to 2^52 Seed for the random number generator. If set to Null (default), a random seed value intergish value between 0 and 10000 is picked

## Returns

Expr

Shuffle the contents of this expr.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shuffle</span><span class='op'>(</span>seed<span class='op'>=</span><span class='fl'>1</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (3, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
 </code></pre>