# polars options

*Source: [R/options.R](https://github.com/pola-rs/r-polars/tree/main/R/options.R)*

## Arguments

- `strictly_immutable`: bool, default = TRUE, keep polars strictly immutable. Polars/arrow is in general pro "immutable objects". However pypolars API has some minor exceptions. All settable property elements of classes are mutable. Why?, I guess python just do not have strong stance on immutability. R strongly suggests immutable objects, so why not make polars strictly immutable where little performance costs? However, if to mimic pypolars as much as possible, set this to FALSE.
- `named_exprs`: bool, default = FALSE, allow named exprs in e.g. select, with_columns, groupby, join. a named expresion will be extended with $alias(name) wildcards or expression producing multiple are problematic due to name collision the related option in py-polars is currently called 'pl.Config.with_columns_kwargs' and only allow named exprs in with_columns (or potentially any method derived there of)
- `no_messages`: bool, default = FALSE, turn of messages
- `do_not_repeat_call`: bool, default = FALSE, turn of messages
- `...`: any options to modify
- `return_replaced_options`: return previous state of modified options Convenient for temporarily swapping of options during testing.

## Returns

current settings as list

current settings as list

list named by options of requirement function input must satisfy

get, set, reset polars options

## Details

who likes polars package messages? use this option to turn them off.

do not print the call causing the error in error messages

modifing list takes no effect, pass it to pl$set_polars_options get/set/resest interact with internal env `polars:::polars_optenv`

setting an options may be rejected if not passing opt_requirements

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='co'>#rename columns by naming expression, experimental requires option named_exprs = TRUE</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>set_polars_options</span><span class='op'>(</span>named_exprs <span class='op'>=</span> <span class='cn'>TRUE</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $named_exprs</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>with_columns</span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Sepal.Length"</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>abs</span><span class='op'>(</span><span class='op'>)</span>, <span class='co'>#not named expr will keep name "Sepal.Length"</span></span></span>
<span class='r-in'><span>  SW_add_2 <span class='op'>=</span> <span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"Sepal.Width"</span><span class='op'>)</span><span class='op'>+</span><span class='fl'>2</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (150, 6)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌──────────────┬─────────────┬──────────────┬─────────────┬───────────┬──────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width ┆ Species   ┆ SW_add_2 │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---          ┆ ---         ┆ ---          ┆ ---         ┆ ---       ┆ ---      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ f64          ┆ f64         ┆ f64          ┆ f64         ┆ cat       ┆ f64      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞══════════════╪═════════════╪══════════════╪═════════════╪═══════════╪══════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.1          ┆ 3.5         ┆ 1.4          ┆ 0.2         ┆ setosa    ┆ 5.5      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.9          ┆ 3.0         ┆ 1.4          ┆ 0.2         ┆ setosa    ┆ 5.0      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.7          ┆ 3.2         ┆ 1.3          ┆ 0.2         ┆ setosa    ┆ 5.2      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 4.6          ┆ 3.1         ┆ 1.5          ┆ 0.2         ┆ setosa    ┆ 5.1      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ...          ┆ ...         ┆ ...          ┆ ...         ┆ ...       ┆ ...      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.3          ┆ 2.5         ┆ 5.0          ┆ 1.9         ┆ virginica ┆ 4.5      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.5          ┆ 3.0         ┆ 5.2          ┆ 2.0         ┆ virginica ┆ 5.0      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 6.2          ┆ 3.4         ┆ 5.4          ┆ 2.3         ┆ virginica ┆ 5.4      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 5.9          ┆ 3.0         ┆ 5.1          ┆ 1.8         ┆ virginica ┆ 5.0      │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └──────────────┴─────────────┴──────────────┴─────────────┴───────────┴──────────┘</span>
<span class='r-in'><span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>get_polars_options</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $do_not_repeat_call</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $strictly_immutable</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $named_exprs</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $no_messages</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>set_polars_options</span><span class='op'>(</span>strictly_immutable <span class='op'>=</span> <span class='cn'>FALSE</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $strictly_immutable</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>get_polars_options</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $do_not_repeat_call</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $strictly_immutable</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $named_exprs</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $no_messages</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] FALSE</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-in'><span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#setting strictly_immutable = 42 will be rejected as</span></span></span>
<span class='r-in'><span><span class='kw'><a href='https://rdrr.io/r/base/conditions.html'>tryCatch</a></span><span class='op'>(</span></span></span>
<span class='r-in'><span>  <span class='va'>pl</span><span class='op'>$</span><span class='fu'>set_polars_options</span><span class='op'>(</span>strictly_immutable <span class='op'>=</span> <span class='fl'>42</span><span class='op'>)</span>,</span></span>
<span class='r-in'><span>  error<span class='op'>=</span> <span class='kw'>function</span><span class='op'>(</span><span class='va'>e</span><span class='op'>)</span> <span class='fu'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='op'>(</span><span class='va'>e</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;simpleError: option: strictly_immutable  must satisfy requirement named is_bool with function</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  function (x) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     is.logical(x) &amp;&amp; length(x)==1 &amp;&amp; !is.na(x)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: namespace:polars&gt;&gt;</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#reset options like this</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>reset_polars_options</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='co'>#use get_polars_opt_requirements() to requirements</span></span></span>
<span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>get_polars_opt_requirements</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $strictly_immutable</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $strictly_immutable$is_bool</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> function (x) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     is.logical(x) &amp;&amp; length(x)==1 &amp;&amp; !is.na(x)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: namespace:polars&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $named_exprs</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $named_exprs$is_bool</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> function (x) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     is.logical(x) &amp;&amp; length(x)==1 &amp;&amp; !is.na(x)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: namespace:polars&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $no_messages</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $no_messages$is_bool</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> function (x) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     is.logical(x) &amp;&amp; length(x)==1 &amp;&amp; !is.na(x)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: namespace:polars&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $do_not_repeat_call</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $do_not_repeat_call$is_bool</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> function (x) {</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     is.logical(x) &amp;&amp; length(x)==1 &amp;&amp; !is.na(x)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   }</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> &lt;environment: namespace:polars&gt;</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>