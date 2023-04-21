# Join sublists

*Source: [R/expr__list.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__list.R)*

## Format

function

## Arguments

- `separator`: string to separate the items with

## Returns

Series of dtype Utf8

Join all string items in a sublist and place a separator between them. This errors if inner type of list `!= Utf8`.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>s <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"b"</span>,<span class='st'>"c"</span><span class='op'>)</span>, <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"x"</span>,<span class='st'>"y"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"s"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>join</span><span class='op'>(</span><span class='st'>" "</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ s     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a b c │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ x y   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
 </code></pre>