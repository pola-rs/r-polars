data

*Source: [R/lazyframe__lazy.R](https://github.com/pola-rs/r-polars/tree/main/R/lazyframe__lazy.R)*

# print LazyFrame internal method

## Format

An object of class `character` of length 1.

```r
LazyFrame_print(x)
```

## Arguments

- `x`: LazyFrame

## Returns

self

can be used i the middle of a method chain

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>print</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"]; PROJECT */5 COLUMNS; SELECTION: "None"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "polars LazyFrame naive plan: (run ldf$describe_optimized_plan() to see the optimized plan)"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"]; PROJECT */5 COLUMNS; SELECTION: "None"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>