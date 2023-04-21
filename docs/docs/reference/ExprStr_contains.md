# contains

## Arguments

- `pattern`: String or Expr of a string, a valid regex pattern.
- `literal`: bool, treat pattern as a literal string. NULL is aliased with FALSE.
- `strict`: bool, raise an error if the underlying pattern is not a valid regex expression, otherwise mask out with a null value.

## Returns

Expr returning a Boolean

R Check if string contains a substring that matches a regex.

## Details

starts_with : Check if string values start with a substring. ends_with : Check if string values end with a substring.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"Crab"</span>, <span class='st'>"cat and dog"</span>, <span class='st'>"rab$bit"</span>, <span class='cn'>NA</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>contains</span><span class='op'>(</span><span class='st'>"cat|bit"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"regex"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>contains</span><span class='op'>(</span><span class='st'>"rab$"</span>, literal<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"literal"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (4, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────┬───────┬─────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a           ┆ regex ┆ literal │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---         ┆ ---   ┆ ---     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str         ┆ bool  ┆ bool    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════╪═══════╪═════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Crab        ┆ false ┆ false   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ cat and dog ┆ true  ┆ false   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ rab$bit     ┆ true  ┆ true    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null        ┆ null  ┆ null    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────┴───────┴─────────┘</span>
 </code></pre>