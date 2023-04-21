# rust-like unwrapping of result. Useful to keep error handling on the R side.

*Source: [R/rust_result.R](https://github.com/pola-rs/r-polars/tree/main/R/rust_result.R)*

```r
unwrap(result, context = NULL, call = sys.call(1L))
```

## Arguments

- `result`: a list here either element ok or err is NULL, or both if ok is litteral NULL
- `context`: a msg to prefix a raised error with
- `call`: context of error or string

## Returns

the ok-element of list , or a error will be thrown

rust-like unwrapping of result. Useful to keep error handling on the R side.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/structure.html'>structure</a></span><span class='op'>(</span><span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>ok <span class='op'>=</span> <span class='st'>"foo"</span>, err <span class='op'>=</span> <span class='cn'>NULL</span><span class='op'>)</span>, class <span class='op'>=</span> <span class='st'>"extendr_result"</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $ok</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "foo"</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $err</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> NULL</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> attr(,"class")</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "extendr_result"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='kw'><a href='https://rdrr.io/r/base/conditions.html'>tryCatch</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='fu'>unwrap</span><span class='op'>(</span></span></span>
<span class='r-in'><span>    <span class='fu'><a href='https://rdrr.io/r/base/structure.html'>structure</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>      <span class='fu'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='op'>(</span>ok <span class='op'>=</span> <span class='cn'>NULL</span>, err <span class='op'>=</span> <span class='st'>"something happen on the rust side"</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>      class <span class='op'>=</span> <span class='st'>"extendr_result"</span></span></span>
<span class='r-in'><span>    <span class='op'>)</span></span></span>
<span class='r-in'><span>  <span class='op'>)</span>,</span></span>
<span class='r-in'><span>  error <span class='op'>=</span> <span class='kw'>function</span><span class='op'>(</span><span class='va'>err</span><span class='op'>)</span> <span class='fu'><a href='https://rdrr.io/r/base/character.html'>as.character</a></span><span class='op'>(</span><span class='va'>err</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "Error: something happen on the rust side \n when calling :\n source(\"~/Bureau/Git/not_my_packages/r-polars/make-docs.R\", echo = TRUE)\n"</span>
 </code></pre>