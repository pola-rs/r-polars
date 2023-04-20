# sort column by order of others

## Format

a method

```r
Expr_sort_by(by, reverse = FALSE)
```

## Arguments

- `by`: one expression or list expressions and/or strings(interpreted as column names)
- `reverse`: single bool to boolean vector, any is_TRUE will give reverse sorting of that column

## Returns

Expr

Sort this column by the ordering of another column, or multiple other columns.

## Details

In projection/ selection context the whole column is sorted. If used in a groupby context, the groups are sorted.

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  group <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"a"</span>,<span class='st'>"a"</span>,<span class='st'>"b"</span>,<span class='st'>"b"</span>,<span class='st'>"b"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  value1 <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fl'>98</span>,<span class='fl'>1</span>,<span class='fl'>3</span>,<span class='fl'>2</span>,<span class='fl'>99</span>,<span class='fl'>100</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  value2 <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"d"</span>,<span class='st'>"f"</span>,<span class='st'>"b"</span>,<span class='st'>"e"</span>,<span class='st'>"c"</span>,<span class='st'>"a"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># by one column/expression</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"group"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort_by</span><span class='op'>(</span><span class='st'>"value1"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (6, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ group │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># by two columns/expressions</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"group"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort_by</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"value2"</span>,<span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"value1"</span><span class='op'>)</span><span class='op'>)</span>, reverse <span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>,<span class='cn'>FALSE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (6, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ group │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># by some expression</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"group"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort_by</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"value1"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort</span><span class='op'>(</span>reverse<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (6, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ group │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ b     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#quite similar usecase as R function `order()`</span></span></span>
<span class='r-in'><span><span class='va'>l</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  ab <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='fl'>6</span><span class='op'>)</span>,<span class='fu'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='op'>(</span><span class='st'>"b"</span>,<span class='fl'>6</span><span class='op'>)</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  v4 <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>4</span>, <span class='fl'>3</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  v3 <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>, <span class='fl'>4</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  v2 <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,<span class='fl'>6</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  v1 <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>12</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>l</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#examples of order versus sort_by</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/all.equal.html'>all.equal</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"ab"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort_by</span><span class='op'>(</span><span class='st'>"v4"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"ab4"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"ab"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort_by</span><span class='op'>(</span><span class='st'>"v3"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"ab3"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"ab"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort_by</span><span class='op'>(</span><span class='st'>"v2"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"ab2"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"ab"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort_by</span><span class='op'>(</span><span class='st'>"v1"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"ab1"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"ab"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort_by</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"v3"</span>,<span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"v1"</span><span class='op'>)</span><span class='op'>)</span>,reverse<span class='op'>=</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>FALSE</span>,<span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"ab13FT"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>    <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"ab"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sort_by</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"v3"</span>,<span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"v1"</span><span class='op'>)</span><span class='op'>)</span>,reverse<span class='op'>=</span><span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"ab13T"</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span><span class='op'>$</span><span class='fu'>to_list</span><span class='op'>(</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>    ab4 <span class='op'>=</span> <span class='va'>l</span><span class='op'>$</span><span class='va'>ab</span><span class='op'>[</span><span class='fu'><a href='https://rdrr.io/r/base/order.html'>order</a></span><span class='op'>(</span><span class='va'>l</span><span class='op'>$</span><span class='va'>v4</span><span class='op'>)</span><span class='op'>]</span>,</span></span>
<span class='r-in'><span>    ab3 <span class='op'>=</span> <span class='va'>l</span><span class='op'>$</span><span class='va'>ab</span><span class='op'>[</span><span class='fu'><a href='https://rdrr.io/r/base/order.html'>order</a></span><span class='op'>(</span><span class='va'>l</span><span class='op'>$</span><span class='va'>v3</span><span class='op'>)</span><span class='op'>]</span>,</span></span>
<span class='r-in'><span>    ab2 <span class='op'>=</span> <span class='va'>l</span><span class='op'>$</span><span class='va'>ab</span><span class='op'>[</span><span class='fu'><a href='https://rdrr.io/r/base/order.html'>order</a></span><span class='op'>(</span><span class='va'>l</span><span class='op'>$</span><span class='va'>v2</span><span class='op'>)</span><span class='op'>]</span>,</span></span>
<span class='r-in'><span>    ab1 <span class='op'>=</span> <span class='va'>l</span><span class='op'>$</span><span class='va'>ab</span><span class='op'>[</span><span class='fu'><a href='https://rdrr.io/r/base/order.html'>order</a></span><span class='op'>(</span><span class='va'>l</span><span class='op'>$</span><span class='va'>v1</span><span class='op'>)</span><span class='op'>]</span>,</span></span>
<span class='r-in'><span>    ab13FT<span class='op'>=</span> <span class='va'>l</span><span class='op'>$</span><span class='va'>ab</span><span class='op'>[</span><span class='fu'><a href='https://rdrr.io/r/base/order.html'>order</a></span><span class='op'>(</span><span class='va'>l</span><span class='op'>$</span><span class='va'>v3</span>,<span class='fu'><a href='https://rdrr.io/r/base/rev.html'>rev</a></span><span class='op'>(</span><span class='va'>l</span><span class='op'>$</span><span class='va'>v1</span><span class='op'>)</span><span class='op'>)</span><span class='op'>]</span>,</span></span>
<span class='r-in'><span>    ab13T <span class='op'>=</span> <span class='va'>l</span><span class='op'>$</span><span class='va'>ab</span><span class='op'>[</span><span class='fu'><a href='https://rdrr.io/r/base/order.html'>order</a></span><span class='op'>(</span><span class='va'>l</span><span class='op'>$</span><span class='va'>v3</span>,<span class='va'>l</span><span class='op'>$</span><span class='va'>v1</span>,decreasing<span class='op'>=</span> <span class='cn'>TRUE</span><span class='op'>)</span><span class='op'>]</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>