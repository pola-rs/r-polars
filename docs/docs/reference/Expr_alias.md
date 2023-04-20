data

# Rename Expr output

## Format

An object of class `character` of length 1.

```r
Expr_alias(name)
```

## Arguments

- `name`: string new name of output

## Returns

Expr

Rename the output of an expression.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"bob"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"alice"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: col("bob").alias("alice")</span>
 </code></pre>