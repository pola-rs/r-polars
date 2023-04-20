# Start Expression with a column

## Arguments

- `name`:  * a single column by a string
     * all columns by using a wildcard `"*"`
     * multiple columns as vector of strings
     * column by regular expression if the regex starts with `^` and ends with `$`
       
       e.g. pl$DataFrame(iris)$select(pl$col(c("^Sepal.*$")))
     * a single DataType or an R list of DataTypes, select any column of any such DataType
     * Series of utf8 strings abiding to above options

## Returns

Column Exprression

Return an expression representing a column in a DataFrame.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>foo<span class='op'>=</span><span class='fl'>1</span>, bar<span class='op'>=</span><span class='fl'>2L</span>,foobar<span class='op'>=</span><span class='st'>"3"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#a single column by a string</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#all columns by wildcard</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"*"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo ┆ bar ┆ foobar │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 ┆ i32 ┆ str    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 ┆ 2   ┆ 3      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 3)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┬────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo ┆ bar ┆ foobar │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- ┆ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 ┆ i32 ┆ str    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╪════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 ┆ 2   ┆ 3      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┴────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#multiple columns as vector of strings</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"foo"</span>,<span class='st'>"bar"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo ┆ bar │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 ┆ i32 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 ┆ 2   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴─────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#column by regular expression if the regex starts with `^` and ends with `$`</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"^foo.*$"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo ┆ foobar │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 ┆ str    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 ┆ 3      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#a single DataType</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Float64</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># ... or an R list of DataTypes, select any column of any such DataType</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Float64</span>, <span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo ┆ foobar │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64 ┆ str    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 1.0 ┆ 3      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># from Series of names</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Series</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"bar"</span>,<span class='st'>"foobar"</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (1, 2)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┬────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ bar ┆ foobar │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- ┆ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ i32 ┆ str    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╪════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 2   ┆ 3      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┴────────┘</span>
 </code></pre>