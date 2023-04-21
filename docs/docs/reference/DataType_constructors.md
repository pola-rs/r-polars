data

# DataType_constructors (composite DataType's)

## Format

An object of class `list` of length 3.

```r
DataType_constructors
```

## Returns

DataType

List of all composite DataType constructors

## Details

This list is mainly used in `zzz.R`  `.onLoad` to instantiate singletons of all flag-like DataTypes.

Non-flag like DataType called composite DataTypes also carries extra information e.g. Datetime a timeunit and a TimeZone, or List which recursively carries another DataType inside. Composite DataTypes use DataType constructors.

Any DataType can be found in pl$dtypes

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#constructors are finally available via pl$... or pl$dtypes$...</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>List</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='va'>Int64</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: List(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     List(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         Int64,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> )</span>
 </code></pre>