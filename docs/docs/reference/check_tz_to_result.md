# Verify correct time zone

```r
check_tz_to_result(tz, allow_null = TRUE)
```

## Arguments

- `tz`: time zone string or NULL
- `allow_null`: bool, if TRUE accept NULL

## Returns

a result object, with either a valid string or an Err

Verify correct time zone

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>check_tz_to_result</span> <span class='op'>=</span> <span class='fu'>polars</span><span class='fu'>:::</span><span class='va'><a href='https://rdrr.io/pkg/polars/man/check_tz_to_result.html'>check_tz_to_result</a></span> <span class='co'># expose internal</span></span></span>
<span class='r-in'><span> <span class='co'>#return Ok</span></span></span>
<span class='r-in'><span> <span class='fu'>check_tz_to_result</span><span class='op'>(</span><span class='st'>"GMT"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "GMT"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $err</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"class")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "extendr_result"</span>
<span class='r-in'><span> <span class='fu'>check_tz_to_result</span><span class='op'>(</span><span class='cn'>NULL</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $err</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"class")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "extendr_result"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span> <span class='co'>#return Err</span></span></span>
<span class='r-in'><span> <span class='fu'>check_tz_to_result</span><span class='op'>(</span><span class='st'>"Alice"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $err</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "pre-check tz: the tz 'Alice' is not a valid string from base::OlsonNames() or NULL"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"class")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "extendr_result"</span>
<span class='r-in'><span> <span class='fu'>check_tz_to_result</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $err</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "pre-check tz: the tz '42' is not a valid string from base::OlsonNames() or NULL"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"class")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "extendr_result"</span>
<span class='r-in'><span> <span class='fu'>check_tz_to_result</span><span class='op'>(</span><span class='cn'>NULL</span>, allow_null <span class='op'>=</span> <span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $err</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "pre-check tz: here NULL tz is not allowed"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"class")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "extendr_result"</span>
 </code></pre>