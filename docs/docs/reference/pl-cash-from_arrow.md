# pl$from_arrow

## Arguments

- `data`: arrow Table or Array or ChunkedArray
- `rechunk`: bool rewrite in one array per column, Implemented for ChunkedArray Array is already contiguous. Not implemented for Table. C
- `schema`: named list of DataTypes or char vec of names. Same length as arrow table. If schema names or types do not match arrow table, the columns will be renamed/recasted. NULL default is to import columns as is. Takes no effect for Array or ChunkedArray
- `schema_overrides`: named list of DataTypes. Name some columns to recast by the DataType. Takes not effect for Array or ChunkedArray

## Returns

DataFrame or Series

import Arrow Table or Array

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>from_arrow</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  data <span class='op'>=</span> <span class='fu'>arrow</span><span class='fu'>::</span><span class='fu'><a href='https://arrow.apache.org/docs/r/reference/Table.html'>arrow_table</a></span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  schema_overrides <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>Sepal.Length<span class='op'>=</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Float32</span>, Species <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='va'>Utf8</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (150, 5)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width ┆ Species   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f32          ┆ f64         ┆ f64          ┆ f64         ┆ str       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.5         ┆ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.9          ┆ 3.0         ┆ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.7          ┆ 3.2         ┆ 1.3          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6          ┆ 3.1         ┆ 1.5          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...          ┆ ...         ┆ ...       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.3          ┆ 2.5         ┆ 5.0          ┆ 1.9         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.5          ┆ 3.0         ┆ 5.2          ┆ 2.0         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.2          ┆ 3.4         ┆ 5.4          ┆ 2.3         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.9          ┆ 3.0         ┆ 5.1          ┆ 1.8         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┴───────────┘</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>char_schema</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>char_schema</span><span class='op'>[</span><span class='fl'>1</span><span class='op'>]</span> <span class='op'>=</span> <span class='st'>"Alice"</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>from_arrow</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  data <span class='op'>=</span> <span class='fu'>arrow</span><span class='fu'>::</span><span class='fu'><a href='https://arrow.apache.org/docs/r/reference/Table.html'>arrow_table</a></span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  schema <span class='op'>=</span> <span class='va'>char_schema</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars DataFrame: shape: (150, 5)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┬─────────────┬──────────────┬─────────────┬───────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Alice ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width ┆ Species   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   ┆ ---         ┆ ---          ┆ ---         ┆ ---       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64   ┆ f64         ┆ f64          ┆ f64         ┆ cat       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╪═════════════╪══════════════╪═════════════╪═══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1   ┆ 3.5         ┆ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.9   ┆ 3.0         ┆ 1.4          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.7   ┆ 3.2         ┆ 1.3          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6   ┆ 3.1         ┆ 1.5          ┆ 0.2         ┆ setosa    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...   ┆ ...         ┆ ...          ┆ ...         ┆ ...       │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.3   ┆ 2.5         ┆ 5.0          ┆ 1.9         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.5   ┆ 3.0         ┆ 5.2          ┆ 2.0         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.2   ┆ 3.4         ┆ 5.4          ┆ 2.3         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.9   ┆ 3.0         ┆ 5.1          ┆ 1.8         ┆ virginica │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┴─────────────┴──────────────┴─────────────┴───────────┘</span>
 </code></pre>