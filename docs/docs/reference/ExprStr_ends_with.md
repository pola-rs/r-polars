# ends_with

## Arguments

- `sub`: Suffix substring or Expr.

## Returns

Expr returning a Boolean

Check if string values end with a substring.

## Details

contains : Check if string contains a substring that matches a regex. starts_with : Check if string values start with a substring.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>fruits <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"apple"</span>, <span class='st'>"mango"</span>, <span class='cn'>NA</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"fruits"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"fruits"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>ends_with</span><span class='op'>(</span><span class='st'>"go"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"has_suffix"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (3, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────┬────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ fruits ┆ has_suffix │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---    ┆ ---        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str    ┆ bool       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════╪════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ apple  ┆ false      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ mango  ┆ true       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null   ┆ null       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────┴────────────┘</span>
 </code></pre>