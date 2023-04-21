# Concat polars objects

## Arguments

- `l`: list of DataFrame, or Series, LazyFrame or Expr
- `rechunk`: perform a rechunk at last
- `how`: choice of bind direction "vertical"(rbind) "horizontal"(cbind) "diagnoal" diagonally
- `parallel`: BOOL default TRUE, only used for LazyFrames

## Returns

DataFrame, or Series, LazyFrame or Expr

Concat polars objects

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#vertical</span></span></span>
<span class='r-in'><span><span class='va'>l_ver</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>10</span>, <span class='kw'>function</span><span class='op'>(</span><span class='va'>i</span><span class='op'>)</span> <span class='op'>{</span></span></span>
<span class='r-in'><span>  <span class='va'>l_internal</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>    a <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span>,</span></span>
<span class='r-in'><span>    b <span class='op'>=</span> <span class='va'>letters</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>]</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>l_internal</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>}</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>concat</span><span class='op'>(</span><span class='va'>l_ver</span>, how<span class='op'>=</span><span class='st'>"vertical"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (50, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a   ┆ b   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ str │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ b   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   ┆ c   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4   ┆ d   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ... ┆ ... │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ b   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   ┆ c   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4   ┆ d   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5   ┆ e   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#horizontal</span></span></span>
<span class='r-in'><span><span class='va'>l_hor</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>10</span>, <span class='kw'>function</span><span class='op'>(</span><span class='va'>i</span><span class='op'>)</span> <span class='op'>{</span></span></span>
<span class='r-in'><span>  <span class='va'>l_internal</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>    <span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span>,</span></span>
<span class='r-in'><span>    <span class='va'>letters</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>5</span><span class='op'>]</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='op'>(</span><span class='va'>l_internal</span><span class='op'>)</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>,<span class='st'>"b"</span><span class='op'>)</span>,<span class='va'>i</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>l_internal</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>}</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>concat</span><span class='op'>(</span><span class='va'>l_hor</span>, how <span class='op'>=</span> <span class='st'>"horizontal"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (5, 20)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a1  ┆ b1  ┆ a2  ┆ b2  ┆ ... ┆ a9  ┆ b9  ┆ a10 ┆ b10 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ --- ┆ --- ┆     ┆ --- ┆ --- ┆ --- ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ str ┆ i32 ┆ str ┆     ┆ i32 ┆ str ┆ i32 ┆ str │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪═════╪═════╪═════╪═════╪═════╪═════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1   ┆ a   ┆ 1   ┆ a   ┆ ... ┆ 1   ┆ a   ┆ 1   ┆ a   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ b   ┆ 2   ┆ b   ┆ ... ┆ 2   ┆ b   ┆ 2   ┆ b   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3   ┆ c   ┆ 3   ┆ c   ┆ ... ┆ 3   ┆ c   ┆ 3   ┆ c   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4   ┆ d   ┆ 4   ┆ d   ┆ ... ┆ 4   ┆ d   ┆ 4   ┆ d   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5   ┆ e   ┆ 5   ┆ e   ┆ ... ┆ 5   ┆ e   ┆ 5   ┆ e   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘</span>
<span class='r-in'><span><span class='co'>#diagonal</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>concat</span><span class='op'>(</span><span class='va'>l_hor</span>, how <span class='op'>=</span> <span class='st'>"diagonal"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (50, 20)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────┬──────┬──────┬──────┬─────┬──────┬──────┬──────┬──────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ a1   ┆ b1   ┆ a2   ┆ b2   ┆ ... ┆ a9   ┆ b9   ┆ a10  ┆ b10  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---  ┆ ---  ┆ ---  ┆ ---  ┆     ┆ ---  ┆ ---  ┆ ---  ┆ ---  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32  ┆ str  ┆ i32  ┆ str  ┆     ┆ i32  ┆ str  ┆ i32  ┆ str  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════╪══════╪══════╪══════╪═════╪══════╪══════╪══════╪══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1    ┆ a    ┆ null ┆ null ┆ ... ┆ null ┆ null ┆ null ┆ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2    ┆ b    ┆ null ┆ null ┆ ... ┆ null ┆ null ┆ null ┆ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 3    ┆ c    ┆ null ┆ null ┆ ... ┆ null ┆ null ┆ null ┆ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4    ┆ d    ┆ null ┆ null ┆ ... ┆ null ┆ null ┆ null ┆ null │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...  ┆ ...  ┆ ...  ┆ ...  ┆ ... ┆ ...  ┆ ...  ┆ ...  ┆ ...  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null ┆ null ┆ null ┆ ... ┆ null ┆ null ┆ 2    ┆ b    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null ┆ null ┆ null ┆ ... ┆ null ┆ null ┆ 3    ┆ c    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null ┆ null ┆ null ┆ ... ┆ null ┆ null ┆ 4    ┆ d    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ null ┆ null ┆ null ┆ null ┆ ... ┆ null ┆ null ┆ 5    ┆ e    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────┴──────┴──────┴──────┴─────┴──────┴──────┴──────┴──────┘</span>
 </code></pre>