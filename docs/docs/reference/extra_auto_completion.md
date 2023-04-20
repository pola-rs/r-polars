# Extra polars auto completion

## Arguments

- `activate`: bool default TRUE, enable chained auto-completion

Extra polars auto completion

## Details

polars always supports auto completetion via .DollarNames. However chained methods like x$a()$b()$? are not supported vi .DollarNames.

This feature experimental and not perfect. Any feedback is appreciated. Currently does not play that nice with Rstudio, as Rstudio backtick quotes any custom suggestions.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#auto completion via .DollarNames method</span></span></span>
<span class='r-in'><span><span class='va'>e</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span> <span class='co'># to autocomplete pl$lit(42) save to variable</span></span></span>
<span class='r-in'><span><span class='co'># then write `e$`  and press tab to see available methods</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'># polars has experimental auto completetion for chain of methods if all on the same line</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>extra_auto_completion</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#first activate feature (this will 'annoy' the Rstudio auto-completer)</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lit_to_s</span><span class='op'>(</span><span class='op'>)</span> <span class='co'># add a $ and press tab 1-3 times</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> polars Series: shape: (1,)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Series: 'literal' [f64]</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 	42.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ]</span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>extra_auto_completion</span><span class='op'>(</span>activate <span class='op'>=</span> <span class='cn'>FALSE</span><span class='op'>)</span> <span class='co'>#deactivate</span></span></span>
 </code></pre>