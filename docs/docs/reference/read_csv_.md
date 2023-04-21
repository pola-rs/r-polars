# high level csv_reader, will download if path is url

```r
read_csv_(path, lazy = FALSE, reuse_downloaded = TRUE, ...)
```

## Arguments

- `path`: file or url
- `lazy`: bool default FALSE, read csv lazy
- `reuse_downloaded`: bool default TRUE, cache url downloaded files in session an reuse
- `...`: arguments forwarded to csv_reader or lazy_csv_reader

## Returns

polars_DataFrame or polars_lazy_DataFrame

high level csv_reader, will download if path is url

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>read_csv</span><span class='op'>(</span><span class='st'>"https://j.mp/iriscsv"</span><span class='op'>)</span></span></span>
 </code></pre>