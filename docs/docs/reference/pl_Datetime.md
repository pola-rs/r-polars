# Create Datetime DataType

## Format

function

## Arguments

- `tu`: string option either "ms", "us" or "ns"
- `tz`: string the Time Zone, see details

## Returns

Datetime DataType

Datetime DataType constructor

## Details

all allowed TimeZone designations can be found in `base::OlsonNames()`

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>Datetime</span><span class='op'>(</span><span class='st'>"ns"</span>,<span class='st'>"Pacific/Samoa"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> DataType: Datetime(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     Nanoseconds,</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     Some(</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>         "Pacific/Samoa",</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     ),</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> )</span>
 </code></pre>