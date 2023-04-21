# return polars DataFrame as R lit of vectors

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

```r
DataFrame_to_list(unnest_structs = TRUE)
```

## Arguments

- `unnest_structs`: bool default true, as calling $unnest() on any struct column

## Returns

R list of vectors

return polars DataFrame as R lit of vectors

## Details

This implementation for simplicity reasons relies on unnesting all structs before exporting to R. unnest_structs = FALSE, the previous struct columns will be re- nested. A struct in a R is a lists of lists, where each row is a list of values. Such a structure is not very typical or efficient in R.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_list</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Sepal.Length</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   [1] 5.1 4.9 4.7 4.6 5.0 5.4 4.6 5.0 4.4 4.9 5.4 4.8 4.8 4.3 5.8 5.7 5.4 5.1 5.7 5.1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [21] 5.4 5.1 4.6 5.1 4.8 5.0 5.0 5.2 5.2 4.7 4.8 5.4 5.2 5.5 4.9 5.0 5.5 4.9 4.4 5.1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [41] 5.0 4.5 4.4 5.0 5.1 4.8 5.1 4.6 5.3 5.0 7.0 6.4 6.9 5.5 6.5 5.7 6.3 4.9 6.6 5.2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [61] 5.0 5.9 6.0 6.1 5.6 6.7 5.6 5.8 6.2 5.6 5.9 6.1 6.3 6.1 6.4 6.6 6.8 6.7 6.0 5.7</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [81] 5.5 5.5 5.8 6.0 5.4 6.0 6.7 6.3 5.6 5.5 5.5 6.1 5.8 5.0 5.6 5.7 5.7 6.2 5.1 5.7</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [101] 6.3 5.8 7.1 6.3 6.5 7.6 4.9 7.3 6.7 7.2 6.5 6.4 6.8 5.7 5.8 6.4 6.5 7.7 7.7 6.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [121] 6.9 5.6 7.7 6.3 6.7 7.2 6.2 6.1 6.4 7.2 7.4 7.9 6.4 6.3 6.1 7.7 6.3 6.4 6.0 6.9</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [141] 6.7 6.9 5.8 6.8 6.7 6.7 6.3 6.5 6.2 5.9</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Sepal.Width</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   [1] 3.5 3.0 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 3.7 3.4 3.0 3.0 4.0 4.4 3.9 3.5 3.8 3.8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [21] 3.4 3.7 3.6 3.3 3.4 3.0 3.4 3.5 3.4 3.2 3.1 3.4 4.1 4.2 3.1 3.2 3.5 3.6 3.0 3.4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [41] 3.5 2.3 3.2 3.5 3.8 3.0 3.8 3.2 3.7 3.3 3.2 3.2 3.1 2.3 2.8 2.8 3.3 2.4 2.9 2.7</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [61] 2.0 3.0 2.2 2.9 2.9 3.1 3.0 2.7 2.2 2.5 3.2 2.8 2.5 2.8 2.9 3.0 2.8 3.0 2.9 2.6</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [81] 2.4 2.4 2.7 2.7 3.0 3.4 3.1 2.3 3.0 2.5 2.6 3.0 2.6 2.3 2.7 3.0 2.9 2.9 2.5 2.8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [101] 3.3 2.7 3.0 2.9 3.0 3.0 2.5 2.9 2.5 3.6 3.2 2.7 3.0 2.5 2.8 3.2 3.0 3.8 2.6 2.2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [121] 3.2 2.8 2.8 2.7 3.3 3.2 2.8 3.0 2.8 3.0 2.8 3.8 2.8 2.8 2.6 3.0 3.4 3.1 3.0 3.1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [141] 3.1 3.1 2.7 3.2 3.3 3.0 2.5 3.0 3.4 3.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Petal.Length</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   [1] 1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 1.5 1.6 1.4 1.1 1.2 1.5 1.3 1.4 1.7 1.5</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [21] 1.7 1.5 1.0 1.7 1.9 1.6 1.6 1.5 1.4 1.6 1.6 1.5 1.5 1.4 1.5 1.2 1.3 1.4 1.3 1.5</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [41] 1.3 1.3 1.3 1.6 1.9 1.4 1.6 1.4 1.5 1.4 4.7 4.5 4.9 4.0 4.6 4.5 4.7 3.3 4.6 3.9</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [61] 3.5 4.2 4.0 4.7 3.6 4.4 4.5 4.1 4.5 3.9 4.8 4.0 4.9 4.7 4.3 4.4 4.8 5.0 4.5 3.5</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [81] 3.8 3.7 3.9 5.1 4.5 4.5 4.7 4.4 4.1 4.0 4.4 4.6 4.0 3.3 4.2 4.2 4.2 4.3 3.0 4.1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [101] 6.0 5.1 5.9 5.6 5.8 6.6 4.5 6.3 5.8 6.1 5.1 5.3 5.5 5.0 5.1 5.3 5.5 6.7 6.9 5.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [121] 5.7 4.9 6.7 4.9 5.7 6.0 4.8 4.9 5.6 5.8 6.1 6.4 5.6 5.1 5.6 6.1 5.6 5.5 4.8 5.4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [141] 5.6 5.1 5.1 5.9 5.7 5.2 5.0 5.2 5.4 5.1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Petal.Width</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   [1] 0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 0.2 0.2 0.1 0.1 0.2 0.4 0.4 0.3 0.3 0.3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [21] 0.2 0.4 0.2 0.5 0.2 0.2 0.4 0.2 0.2 0.2 0.2 0.4 0.1 0.2 0.2 0.2 0.2 0.1 0.2 0.2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [41] 0.3 0.3 0.2 0.6 0.4 0.3 0.2 0.2 0.2 0.2 1.4 1.5 1.5 1.3 1.5 1.3 1.6 1.0 1.3 1.4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [61] 1.0 1.5 1.0 1.4 1.3 1.4 1.5 1.0 1.5 1.1 1.8 1.3 1.5 1.2 1.3 1.4 1.4 1.7 1.5 1.0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [81] 1.1 1.0 1.2 1.6 1.5 1.6 1.5 1.3 1.3 1.3 1.2 1.4 1.2 1.0 1.3 1.2 1.3 1.3 1.1 1.3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [101] 2.5 1.9 2.1 1.8 2.2 2.1 1.7 1.8 1.8 2.5 2.0 1.9 2.1 2.0 2.4 2.3 1.8 2.2 2.3 1.5</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [121] 2.3 2.0 2.0 1.8 2.1 1.8 1.8 1.8 2.1 1.6 1.9 2.0 2.2 1.5 1.4 2.3 2.4 1.8 1.8 2.1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [141] 2.4 2.3 1.9 2.3 2.5 2.3 1.9 2.0 2.3 1.8</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> $Species</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   [1] setosa     setosa     setosa     setosa     setosa     setosa     setosa    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>   [8] setosa     setosa     setosa     setosa     setosa     setosa     setosa    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [15] setosa     setosa     setosa     setosa     setosa     setosa     setosa    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [22] setosa     setosa     setosa     setosa     setosa     setosa     setosa    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [29] setosa     setosa     setosa     setosa     setosa     setosa     setosa    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [36] setosa     setosa     setosa     setosa     setosa     setosa     setosa    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [43] setosa     setosa     setosa     setosa     setosa     setosa     setosa    </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [50] setosa     versicolor versicolor versicolor versicolor versicolor versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [57] versicolor versicolor versicolor versicolor versicolor versicolor versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [64] versicolor versicolor versicolor versicolor versicolor versicolor versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [71] versicolor versicolor versicolor versicolor versicolor versicolor versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [78] versicolor versicolor versicolor versicolor versicolor versicolor versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [85] versicolor versicolor versicolor versicolor versicolor versicolor versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [92] versicolor versicolor versicolor versicolor versicolor versicolor versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>  [99] versicolor versicolor virginica  virginica  virginica  virginica  virginica </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [106] virginica  virginica  virginica  virginica  virginica  virginica  virginica </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [113] virginica  virginica  virginica  virginica  virginica  virginica  virginica </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [120] virginica  virginica  virginica  virginica  virginica  virginica  virginica </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [127] virginica  virginica  virginica  virginica  virginica  virginica  virginica </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [134] virginica  virginica  virginica  virginica  virginica  virginica  virginica </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [141] virginica  virginica  virginica  virginica  virginica  virginica  virginica </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> [148] virginica  virginica  virginica </span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> Levels: setosa versicolor virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> </span>
 </code></pre>