# struct

*Source: [R/lazy_functions.R](https://github.com/pola-rs/r-polars/tree/main/R/lazy_functions.R)*

## Arguments

- `exprs`: Columns/Expressions to collect into a Struct.
- `eager`: Evaluate immediately.
- `schema`: Optional schema named list that explicitly defines the struct field dtypes. Each name must match a column name wrapped in the struct. Can only be used to cast some or all dtypes, not to change the names. NULL means to include keep columns into the struct by their current DataType. If a column is not included in the schema it is removed from the final struct.

## Returns

Eager=FALSE: Expr of Series with dtype Struct | Eager=TRUE: Series with dtype Struct

Collect several columns into a Series of dtype Struct.

## Details

pl$struct creates Expr or Series of DataType Struct() pl$Struct creates the DataType Struct() In polars a schema is a named list of DataTypes. #' A schema describes e.g. a DataFrame. More formally schemas consist of Fields. A Field is an object describing the name and DataType of a column/Series, but same same. A struct is a DataFrame wrapped into a Series, the DataType is Struct, and each sub-datatype within are Fields. In a dynamic language schema and a Struct (the DataType) are quite the same, except schemas describe DataFrame and Struct's describe some Series.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#isolated expression to wrap all columns in a struct aliased 'my_struct'</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>struct</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"my_struct"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: *.as_struct().alias("my_struct")</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#wrap all column into on column/Series</span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  int <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,</span></span>
<span class='r-in'><span>  str <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>, <span class='st'>"b"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  bool <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>, <span class='cn'>NA</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  list <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>, <span class='fl'>3L</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>struct</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>all</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"my_struct"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>df</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────────────────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ my_struct           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---                 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ struct[4]           │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════════════════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {1,"a",true,[1, 2]} │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {2,"b",null,[3]}    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────────────────────┘</span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>df</span><span class='op'>$</span><span class='va'>schema</span><span class='op'>)</span> <span class='co'>#returns a schema, a named list containing one element a Struct named my_struct</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $my_struct</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Struct(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         Field {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             name: "int",</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             dtype: Int32,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         },</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         Field {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             name: "str",</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             dtype: Utf8,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         },</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         Field {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             name: "bool",</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             dtype: Boolean,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         },</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         Field {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             name: "list",</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             dtype: List(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>                 Int32,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         },</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     ],</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> )</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># wrap two columns in a struct and provide a schema to set all or some DataTypes by name</span></span></span>
<span class='r-in'><span><span class='va'>e1</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>struct</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"int"</span>,<span class='st'>"str"</span><span class='op'>)</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  schema <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>int<span class='op'>=</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span>, str<span class='op'>=</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"my_struct"</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='co'># same result as e.g. wrapping the columns in a struct and casting afterwards</span></span></span>
<span class='r-in'><span><span class='va'>e2</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>struct</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"int"</span><span class='op'>)</span>,<span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"str"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>cast</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>Struct</span><span class='op'>(</span>int<span class='op'>=</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span>,str<span class='op'>=</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span><span class='op'>$</span><span class='fu'>alias</span><span class='op'>(</span><span class='st'>"my_struct"</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  int <span class='op'>=</span> <span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>,</span></span>
<span class='r-in'><span>  str <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>"a"</span>, <span class='st'>"b"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  bool <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='cn'>TRUE</span>, <span class='cn'>NA</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  list <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span><span class='fl'>1</span><span class='op'>:</span><span class='fl'>2</span>, <span class='fl'>3L</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#verify equality in R</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/identical.html'>identical</a></span><span class='op'>(</span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>e1</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_list</span><span class='op'>(</span><span class='op'>)</span>,<span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>e2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_list</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>e2</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ my_struct │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ struct[2] │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {1,"a"}   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ {2,"b"}   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>e2</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_data_frame</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>                  my_struct</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 1 4.94065645841247e-324, a</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 2 9.88131291682493e-324, b</span>
 </code></pre>