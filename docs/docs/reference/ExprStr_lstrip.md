# lstrip

## Arguments

- `matches`: The set of characters to be removed. All combinations of this set of characters will be stripped. If set to NULL (default), all whitespace is removed instead.

## Returns

Expr of Utf8 lowercase chars

Remove leading characters.

## Details

will not strip anyt chars beyond the first char not matched. `strip()` starts from both left and right. Whereas `lstrip()`and `rstrip()` starts from left and right respectively.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>df</span> <span class='op'>=</span> <span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span>foo <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='op'>(</span><span class='st'>" hello"</span>, <span class='st'>"\tworld"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>strip</span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ hello │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ world │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>strip</span><span class='op'>(</span><span class='st'>" hel rld"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌─────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ --- │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ o   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 	wo  │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └─────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>lstrip</span><span class='op'>(</span><span class='st'>" hel rld"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌───────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str   │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞═══════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ o     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 	world │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └───────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>rstrip</span><span class='op'>(</span><span class='st'>" hel\trld"</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │  hello │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 	wo     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────┘</span>
<span class='r-in'><span><span class='va'>df</span><span class='op'>$</span><span class='fu'>select</span><span class='op'>(</span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>col</span><span class='op'>(</span><span class='st'>"foo"</span><span class='op'>)</span><span class='op'>$</span><span class='va'>str</span><span class='op'>$</span><span class='fu'>rstrip</span><span class='op'>(</span><span class='st'>"rldhel\t "</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> shape: (2, 1)</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ┌────────┐</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ foo    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ ---    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ str    │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> ╞════════╡</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │  hello │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> │ 	wo     │</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> └────────┘</span>
 </code></pre>