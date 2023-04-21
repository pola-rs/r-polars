data

*Source: [R/after-wrappers.R](https://github.com/pola-rs/r-polars/tree/main/R/after-wrappers.R)*

# The complete polars public API.

## Format

An object of class `environment` of length 57.

```r
pl
```

`pl`-object is a environment of all public functions and class constructors. Public functions are not exported as a normal package as it would be huge namespace collision with base:: and other functions. All object-methods are accessed with object$method() via the new class functions.

Having all functions in an namespace is similar to the rust- and python- polars api.

## Details

If someone do not particularly like the letter combination `pl`, they are free to bind the environment to another variable name as `simon_says = pl` or even do `attach(pl)`

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#how to use polars via `pl`</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"colname"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>sum</span><span class='op'>(</span><span class='op'>)</span> <span class='op'>/</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42L</span><span class='op'>)</span>  <span class='co'>#expression ~ chain-method / literal-expression</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Expr: [(col("colname").sum()) / (42i32)]</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#pl inventory</span></span></span>
<span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/print_env.html'>print_env</a></span><span class='op'>(</span><span class='va'>pl</span>,<span class='st'>"polars public functions"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     polars public functions ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ all ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Binary ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Boolean ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Categorical ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ coalesce ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ col ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ concat ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ concat_list ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ csv_reader ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ DataFrame ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Date ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ date_range ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Datetime ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        dtypes ( list ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Binary ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Boolean ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Categorical ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Date ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Datetime ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Float32 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Float64 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Int16 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Int32 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Int64 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Int8 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ List ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Null ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Struct ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Time ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ UInt16 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ UInt32 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ UInt64 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ UInt8 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Unknown ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Utf8 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ element ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ expr_to_r ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ extra_auto_completion ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Field ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Float32 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Float64 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ from_arrow ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ get_polars_opt_requirements ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ get_polars_options ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Int16 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Int32 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Int64 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Int8 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ is_schema ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ lazy_csv_reader ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ List ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ lit ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ mem_address ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Null ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        numeric_dtypes ( list ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Float32 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Float64 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Int16 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Int32 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Int64 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ Int8 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ PTime ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ read_csv ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ reset_polars_options ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ same_outer_dt ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ scan_arrow_ipc ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ select ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Series ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ set_polars_options ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ struct ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Struct ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Time ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ UInt16 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ UInt32 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ UInt64 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ UInt8 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Unknown ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ Utf8 ; RPolarsDataType ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        [ when ; function ]</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#all accessible classes and their public methods</span></span></span>
<span class='r-in'><span><span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/print_env.html'>print_env</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='fu'>polars</span><span class='fu'>:::</span><span class='va'>pl_pub_class_env</span>,</span></span>
<span class='r-in'><span>  <span class='st'>"polars public class methods, access via object$method()"</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     polars public class methods, access via object$method() ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        DataFrame ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ as_data_frame ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clone ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ columns ; setter property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop_in_place ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop_nulls ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dtype_strings ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dtypes ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ estimated_size ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_nan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_null ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ filter ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ first ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ frame_equal ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_column ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_columns ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ groupby ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ height ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ join ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ last ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lazy ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ limit ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mean ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ median ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ null_count ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ quantile ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ reverse ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ schema ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ select ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shape ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shift ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shift_and_fill ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ slice ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sort ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tail ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_data_frame ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_list ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_series ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_struct ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ unnest ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ width ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ with_column ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ with_columns ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        DataType ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ eq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_all_simple_type_names ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ get_insides ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_temporal ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ne ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_datetime ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_duration ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_list ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_object ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ new_struct ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ same_outer_datatype ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        Expr ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ abs ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ add ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ agg_groups ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ alias ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ all ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ and ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ any ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ append ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ apply ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arccos ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arccosh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arcsin ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arcsinh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arctan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arctanh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_sort ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ argsort ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arr ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ backward_fill ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ bin ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cast ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cat ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ceil ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clip ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clip_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clip_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cos ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cosh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ count ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cumcount ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cummax ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cummin ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cumprod ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cumsum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cumulative_eval ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ diff ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ div ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dot ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop_nans ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop_nulls ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dt ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ entropy ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ eq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ewm_mean ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ewm_std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ewm_var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ exclude ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ exp ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ explode ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ extend_constant ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ extend_expr ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_nan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_null ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ filter ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ first ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ flatten ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ floor ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ forward_fill ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ gt ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ gt_eq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ hash ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ head ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ inspect ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ interpolate ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_between ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_duplicated ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_finite ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_first ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_in ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_infinite ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_nan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_not ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_not_nan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_not_null ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_null ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ keep_name ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ kurtosis ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ last ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ len ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ limit ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ list ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lit ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lit_to_df ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lit_to_s ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ log ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ log10 ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lower_bound ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lt ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ lt_eq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ map ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ map_alias ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mean ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ median ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ meta ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mode ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mul ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ n_unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ nan_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ nan_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ neq ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ null_count ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ or ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ over ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ pct_change ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ pow ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ prefix ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ product ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ quantile ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rank ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rechunk ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ reinterpret ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rep ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rep_extend ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ repeat_by ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ reshape ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ reverse ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_mean ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_median ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_quantile ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_skew ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rolling_var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ round ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rpow ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sample ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ search_sorted ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ set_sorted ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shift ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shift_and_fill ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shrink_dtype ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shuffle ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sign ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sin ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sinh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ skew ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ slice ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sort ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sort_by ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sqrt ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ str ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ struct ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sub ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ suffix ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tail ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ take ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ take_every ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tanh ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_physical ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_r ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_struct ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ top_k ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ unique_counts ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ upper_bound ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ value_counts ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ where ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ xor ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        LazyFrame ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ collect ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ collect_background ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ describe_optimized_plan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ describe_plan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ drop_nulls ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_nan ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ fill_null ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ filter ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ first ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ groupby ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ join ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ last ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ limit ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mean ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ median ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ quantile ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ reverse ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ select ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shift ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shift_and_fill ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ slice ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sort ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tail ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ unique ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ with_column ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ with_columns ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        LazyGroupBy ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ agg ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ apply ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ head ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ tail ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        PolarsBackgroundHandle ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_exhausted ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ join ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        Series ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ abs ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ add ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ alias ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ all ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ any ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ append ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ apply ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arg_min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ arr ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ ceil ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ chunk_lengths ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ clone ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ compare ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ cumsum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ div ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ dtype ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ expr ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ flags ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ floor ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_numeric ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ is_sorted ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ len ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ max ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ min ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ mul ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ name ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ print ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rem ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rename ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ rep ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ series_equal ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ set_sorted ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ shape ; property function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sort ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ std ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sub ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ sum ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_frame ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_lit ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_r ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_r_list ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_r_vector ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ to_vector ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ value_counts ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ var ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        When ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ then ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        WhenThen ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ otherwise ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ when ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>        WhenThenThen ( environment ):</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ otherwise ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ peak_inside ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ then ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           [ when ; function ]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>