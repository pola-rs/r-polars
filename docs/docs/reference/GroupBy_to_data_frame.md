# convert to data.frame

```r
GroupBy_to_data_frame(...)
```

## Arguments

- `...`: any opt param passed to R as.data.frame

## Returns

R data.frame

convert to data.frame

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>iris</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>to_data_frame</span><span class='op'>(</span><span class='op'>)</span> <span class='co'>#R-polars back and forth</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     Sepal.Length Sepal.Width Petal.Length Petal.Width    Species</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 1            5.1         3.5          1.4         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 2            4.9         3.0          1.4         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 3            4.7         3.2          1.3         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 4            4.6         3.1          1.5         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 5            5.0         3.6          1.4         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 6            5.4         3.9          1.7         0.4     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 7            4.6         3.4          1.4         0.3     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 8            5.0         3.4          1.5         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 9            4.4         2.9          1.4         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 10           4.9         3.1          1.5         0.1     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 11           5.4         3.7          1.5         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 12           4.8         3.4          1.6         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 13           4.8         3.0          1.4         0.1     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 14           4.3         3.0          1.1         0.1     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 15           5.8         4.0          1.2         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 16           5.7         4.4          1.5         0.4     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 17           5.4         3.9          1.3         0.4     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 18           5.1         3.5          1.4         0.3     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 19           5.7         3.8          1.7         0.3     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 20           5.1         3.8          1.5         0.3     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 21           5.4         3.4          1.7         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 22           5.1         3.7          1.5         0.4     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 23           4.6         3.6          1.0         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 24           5.1         3.3          1.7         0.5     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 25           4.8         3.4          1.9         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 26           5.0         3.0          1.6         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 27           5.0         3.4          1.6         0.4     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 28           5.2         3.5          1.5         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 29           5.2         3.4          1.4         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 30           4.7         3.2          1.6         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 31           4.8         3.1          1.6         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 32           5.4         3.4          1.5         0.4     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 33           5.2         4.1          1.5         0.1     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 34           5.5         4.2          1.4         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 35           4.9         3.1          1.5         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 36           5.0         3.2          1.2         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 37           5.5         3.5          1.3         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 38           4.9         3.6          1.4         0.1     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 39           4.4         3.0          1.3         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 40           5.1         3.4          1.5         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 41           5.0         3.5          1.3         0.3     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 42           4.5         2.3          1.3         0.3     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 43           4.4         3.2          1.3         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 44           5.0         3.5          1.6         0.6     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 45           5.1         3.8          1.9         0.4     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 46           4.8         3.0          1.4         0.3     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 47           5.1         3.8          1.6         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 48           4.6         3.2          1.4         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 49           5.3         3.7          1.5         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 50           5.0         3.3          1.4         0.2     setosa</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 51           7.0         3.2          4.7         1.4 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 52           6.4         3.2          4.5         1.5 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 53           6.9         3.1          4.9         1.5 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 54           5.5         2.3          4.0         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 55           6.5         2.8          4.6         1.5 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 56           5.7         2.8          4.5         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 57           6.3         3.3          4.7         1.6 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 58           4.9         2.4          3.3         1.0 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 59           6.6         2.9          4.6         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 60           5.2         2.7          3.9         1.4 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 61           5.0         2.0          3.5         1.0 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 62           5.9         3.0          4.2         1.5 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 63           6.0         2.2          4.0         1.0 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 64           6.1         2.9          4.7         1.4 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 65           5.6         2.9          3.6         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 66           6.7         3.1          4.4         1.4 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 67           5.6         3.0          4.5         1.5 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 68           5.8         2.7          4.1         1.0 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 69           6.2         2.2          4.5         1.5 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 70           5.6         2.5          3.9         1.1 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 71           5.9         3.2          4.8         1.8 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 72           6.1         2.8          4.0         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 73           6.3         2.5          4.9         1.5 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 74           6.1         2.8          4.7         1.2 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 75           6.4         2.9          4.3         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 76           6.6         3.0          4.4         1.4 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 77           6.8         2.8          4.8         1.4 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 78           6.7         3.0          5.0         1.7 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 79           6.0         2.9          4.5         1.5 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 80           5.7         2.6          3.5         1.0 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 81           5.5         2.4          3.8         1.1 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 82           5.5         2.4          3.7         1.0 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 83           5.8         2.7          3.9         1.2 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 84           6.0         2.7          5.1         1.6 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 85           5.4         3.0          4.5         1.5 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 86           6.0         3.4          4.5         1.6 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 87           6.7         3.1          4.7         1.5 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 88           6.3         2.3          4.4         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 89           5.6         3.0          4.1         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 90           5.5         2.5          4.0         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 91           5.5         2.6          4.4         1.2 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 92           6.1         3.0          4.6         1.4 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 93           5.8         2.6          4.0         1.2 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 94           5.0         2.3          3.3         1.0 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 95           5.6         2.7          4.2         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 96           5.7         3.0          4.2         1.2 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 97           5.7         2.9          4.2         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 98           6.2         2.9          4.3         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 99           5.1         2.5          3.0         1.1 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 100          5.7         2.8          4.1         1.3 versicolor</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 101          6.3         3.3          6.0         2.5  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 102          5.8         2.7          5.1         1.9  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 103          7.1         3.0          5.9         2.1  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 104          6.3         2.9          5.6         1.8  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 105          6.5         3.0          5.8         2.2  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 106          7.6         3.0          6.6         2.1  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 107          4.9         2.5          4.5         1.7  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 108          7.3         2.9          6.3         1.8  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 109          6.7         2.5          5.8         1.8  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 110          7.2         3.6          6.1         2.5  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 111          6.5         3.2          5.1         2.0  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 112          6.4         2.7          5.3         1.9  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 113          6.8         3.0          5.5         2.1  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 114          5.7         2.5          5.0         2.0  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 115          5.8         2.8          5.1         2.4  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 116          6.4         3.2          5.3         2.3  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 117          6.5         3.0          5.5         1.8  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 118          7.7         3.8          6.7         2.2  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 119          7.7         2.6          6.9         2.3  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 120          6.0         2.2          5.0         1.5  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 121          6.9         3.2          5.7         2.3  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 122          5.6         2.8          4.9         2.0  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 123          7.7         2.8          6.7         2.0  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 124          6.3         2.7          4.9         1.8  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 125          6.7         3.3          5.7         2.1  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 126          7.2         3.2          6.0         1.8  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 127          6.2         2.8          4.8         1.8  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 128          6.1         3.0          4.9         1.8  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 129          6.4         2.8          5.6         2.1  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 130          7.2         3.0          5.8         1.6  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 131          7.4         2.8          6.1         1.9  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 132          7.9         3.8          6.4         2.0  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 133          6.4         2.8          5.6         2.2  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 134          6.3         2.8          5.1         1.5  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 135          6.1         2.6          5.6         1.4  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 136          7.7         3.0          6.1         2.3  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 137          6.3         3.4          5.6         2.4  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 138          6.4         3.1          5.5         1.8  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 139          6.0         3.0          4.8         1.8  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 140          6.9         3.1          5.4         2.1  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 141          6.7         3.1          5.6         2.4  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 142          6.9         3.1          5.1         2.3  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 143          5.8         2.7          5.1         1.9  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 144          6.8         3.2          5.9         2.3  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 145          6.7         3.3          5.7         2.5  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 146          6.7         3.0          5.2         2.3  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 147          6.3         2.5          5.0         1.9  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 148          6.5         3.0          5.2         2.0  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 149          6.2         3.4          5.4         2.3  virginica</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 150          5.9         3.0          5.1         1.8  virginica</span>
 </code></pre>