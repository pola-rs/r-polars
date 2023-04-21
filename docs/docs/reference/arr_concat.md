# concat another list

*Source: [R/expr__list.R](https://github.com/pola-rs/r-polars/tree/main/R/expr__list.R)*

## Format

function

## Arguments

- `other`: Rlist, Expr or column of same tyoe as self.

## Returns

Expr

Concat the arrays in a Series dtype List in linear time.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"x"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  b <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"b"</span>,<span class='st'>"c"</span><span class='op'>)</span>,<span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"y"</span>,<span class='st'>"z"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>concat</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"b"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[str]       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["a", "b", "c"] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["x", "y", "z"] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>concat</span><span class='op'>(</span><span class='st'>"hello from R"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[str]             │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["a", "hello from R"] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["x", "hello from R"] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>concat</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='st'>"hello"</span>,<span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"hello"</span>,<span class='st'>"world"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a                       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ list[str]               │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["a", "hello"]          │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ["x", "hello", "world"] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────────┘</span>
 </code></pre>