# List to Struct

## Format

function

## Arguments

- `n_field_strategy`: Strategy to determine the number of fields of the struct. default = 'first_non_null' else 'max_width'
- `name_generator`: an R function that takes a scalar column number and outputs a string value. The default NULL is equivalent to the R function `\(idx) paste0("field_",idx)`
- `upper_bound`: upper_bound numeric A polars `LazyFrame` needs to know the schema at all time. The caller therefore must provide an `upper_bound` of struct fields that will be set. If this is incorrectly downstream operation may fail. For instance an `all().sum()` expression will look in the current schema to determine which columns to select. It is adviced to set this value in a lazy query.

## Returns

Expr

List to Struct

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>a <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>3</span>, <span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df2</span> <span class='op'>=</span> <span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"a"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>arr</span><span class='op'>$</span><span class='fu'>to_struct</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  name_generator <span class='op'>=</span>  \<span class='op'>(</span><span class='va'>idx</span><span class='op'>)</span> <span class='fu'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='op'>(</span><span class='st'>"hello_you_"</span>,<span class='va'>idx</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df2</span><span class='op'>$</span><span class='fu'>unnest</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (2, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────┬─────────────┬─────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ hello_you_0 ┆ hello_you_1 ┆ hello_you_2 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---         ┆ ---         ┆ ---         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32         ┆ i32         ┆ i32         │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════╪═════════════╪═════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1           ┆ 2           ┆ 3           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1           ┆ 2           ┆ null        │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────┴─────────────┴─────────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df2</span><span class='op'>$</span><span class='fu'>to_list</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $a</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $a$hello_you_0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 1 1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $a$hello_you_1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 2 2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $a$hello_you_2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1]  3 NA</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>