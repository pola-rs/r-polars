# Create Struct DataType

*Source: [R/datatype.R](https://github.com/pola-rs/r-polars/tree/main/R/datatype.R)*

## Format

function

## Arguments

- `datatype`: an inner DataType

## Returns

a list DataType with an inner DataType

Struct DataType Constructor

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'># create a Struct-DataType</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Boolean</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: List(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     List(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         Boolean,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> )</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># Find any DataType via pl$dtypes</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>dtypes</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Boolean</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Boolean</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $UInt8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: UInt8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $UInt16</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: UInt16</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $UInt32</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: UInt32</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $UInt64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: UInt64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Int8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Int8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Int16</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Int16</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Int32</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Int32</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Int64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Int64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Float32</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float32</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Float64</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Utf8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Utf8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Binary</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Binary</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Date</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Date</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Time</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Time</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Null</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Null</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Categorical</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Categorical(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     None,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> )</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Unknown</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Unknown</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Datetime</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> function(tu="us", tz = NULL) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     if (!is.null(tz) &amp;&amp; (!is_string(tz) || !tz %in% base::OlsonNames())) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       stopf("Datetime: the tz '%s' is not a valid timezone string, see base::OlsonNames()",tz)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     unwrap(.pr$DataType$new_datetime(tu,tz))</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: namespace:polars&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $List</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> function(datatype) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     if(is.character(datatype) &amp;&amp; length(datatype)==1 ) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       datatype = .pr$DataType$new(datatype)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     if(!inherits(datatype,"RPolarsDataType")) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       stopf(paste(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         "input for generating a list DataType must be another DataType",</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         "or an interpretable name thereof."</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       ))</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     .pr$DataType$new_list(datatype)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: namespace:polars&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Struct</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> function(...) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     result({</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       largs = list2(...)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       if (is.list(largs[[1]])) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         largs = largs[[1]]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         element_name = "list element"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       } else {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         element_name = "positional argument"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       mapply(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         names(largs) %||% character(length(largs)),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         largs,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         seq_along(largs),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         FUN = \(name, arg, i) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           if(inherits(arg,"RPolarsDataType")) return(pl$Field(name, arg))</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           if(inherits(arg,"RField")) return(arg)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           stopf(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             "%s [%s] {name:'%s', value:%s} must either be a Field (pl$Field) or a named %s",</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>             element_name, i, name, arg,"DataType see (pl$dtypes), see examples for pl$Struct()"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>           )</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         },SIMPLIFY = FALSE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       )</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     }) |&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       and_then(DataType$new_struct) |&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>       unwrap("in pl$Struct:")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;bytecode: 0x5644bfb4a7a0&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: namespace:polars&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>