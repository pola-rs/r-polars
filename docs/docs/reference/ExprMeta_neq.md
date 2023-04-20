# Meta Not Equal

## Arguments

- `other`: Expr to compare with

## Returns

bool: TRUE if NOT equal

Are two expressions on a meta level NOT equal

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#three naive expression literals</span></span></span>
<span class='r-in'><span><span class='va'>e1</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>40</span><span class='op'>)</span> <span class='op'>+</span> <span class='fl'>2</span></span></span>
<span class='r-in'><span><span class='va'>e2</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>42</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>e3</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>lit</span><span class='op'>(</span><span class='fl'>40</span><span class='op'>)</span> <span class='op'>+</span><span class='fl'>2</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#e1 and e3 are identical expressions</span></span></span>
<span class='r-in'><span><span class='va'>e1</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>eq</span><span class='op'>(</span><span class='va'>e3</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#e_test is an expression testing whether e1 and e2 evaluates to the same value.</span></span></span>
<span class='r-in'><span><span class='va'>e_test</span> <span class='op'>=</span> <span class='va'>e1</span> <span class='op'>==</span> <span class='va'>e2</span> <span class='co'># or e_test = e1$eq(e2)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#direct evaluate e_test, possible because only made up of literals</span></span></span>
<span class='r-in'><span><span class='va'>e_test</span><span class='op'>$</span><span class='fu'>to_r</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#e1 and e2 are on the meta-level NOT identical expressions</span></span></span>
<span class='r-in'><span><span class='va'>e1</span><span class='op'>$</span><span class='va'>meta</span><span class='op'>$</span><span class='fu'>neq</span><span class='op'>(</span><span class='va'>e2</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] TRUE</span>
 </code></pre>