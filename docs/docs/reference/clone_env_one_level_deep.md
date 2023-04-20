# Clone env on level deep.

```r
clone_env_one_level_deep(env)
```

## Arguments

- `env`: an R environment.

## Returns

shallow clone of R environment

Clone env on level deep.

## Details

Sometimes used in polars to produce different hashmaps(environments) containing some of the same, but not all elements.

environments are used for collections of methods and types. This function can be used to make a parallel collection pointing to some of the same types. Simply copying an environment, does apparently not spawn a new hashmap, and therefore the collections stay identical.

## Examples

<pre class='r-example'> <code> <span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>fruit_env</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/environment.html'>new.env</a></span><span class='op'>(</span>parent <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/environment.html'>emptyenv</a></span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>fruit_env</span><span class='op'>$</span><span class='va'>banana</span> <span class='op'>=</span> <span class='cn'>TRUE</span></span></span>
<span class='r-in'><span><span class='va'>fruit_env</span><span class='op'>$</span><span class='va'>apple</span> <span class='op'>=</span> <span class='cn'>FALSE</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>env_1</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/environment.html'>new.env</a></span><span class='op'>(</span>parent <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/environment.html'>emptyenv</a></span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>env_1</span><span class='op'>$</span><span class='va'>fruit_env</span> <span class='op'>=</span> <span class='va'>fruit_env</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='va'>env_naive_copy</span> <span class='op'>=</span> <span class='va'>env_1</span></span></span>
<span class='r-in'><span><span class='va'>env_shallow_clone</span> <span class='op'>=</span> <span class='fu'>polars</span><span class='fu'>:::</span><span class='fu'><a href='https://rdrr.io/pkg/polars/man/clone_env_one_level_deep.html'>clone_env_one_level_deep</a></span><span class='op'>(</span><span class='va'>env_1</span><span class='op'>)</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#modifying env_!</span></span></span>
<span class='r-in'><span><span class='va'>env_1</span><span class='op'>$</span><span class='va'>minerals</span> <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/environment.html'>new.env</a></span><span class='op'>(</span>parent <span class='op'>=</span> <span class='fu'><a href='https://rdrr.io/r/base/environment.html'>emptyenv</a></span><span class='op'>(</span><span class='op'>)</span><span class='op'>)</span></span></span>
<span class='r-in'><span><span class='va'>env_1</span><span class='op'>$</span><span class='va'>fruit_env</span><span class='op'>$</span><span class='va'>apple</span> <span class='op'>=</span> <span class='fl'>42L</span></span></span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#naive copy is fully identical to env_1, so copying it not much useful</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='va'>env_naive_copy</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "fruit_env" "minerals" </span>
<span class='r-in'><span><span class='co'>#shallow copy env does not have minerals</span></span></span>
<span class='r-in'><span><span class='fu'><a href='https://rdrr.io/r/base/ls.html'>ls</a></span><span class='op'>(</span><span class='va'>env_shallow_clone</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] "fruit_env"</span>
<span class='r-in'><span></span></span>
<span class='r-in'><span><span class='co'>#however shallow clone does subscribe to changes to fruits as they were there</span></span></span>
<span class='r-in'><span><span class='co'># at time of cloning</span></span></span>
<span class='r-in'><span><span class='va'>env_shallow_clone</span><span class='op'>$</span><span class='va'>fruit_env</span><span class='op'>$</span><span class='va'>apple</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [1] 42</span>
 </code></pre>