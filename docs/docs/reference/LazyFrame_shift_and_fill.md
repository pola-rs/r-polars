# Shift and fill

*Source: [R/lazyframe__lazy.R](https://github.com/pola-rs/r-polars/tree/main/R/lazyframe__lazy.R)*

```r
LazyFrame_shift_and_fill(fill_value, periods = 1)
```

## Arguments

- `fill_value`: fill None values with the result of this expression.
- `periods`: integer Number of periods to shift (may be negative).

## Returns

LazyFrame

Shift the values by a given period and fill the resulting null values.

## Examples

<pre class='r-example'><code><span class='r-in'><span><span class='va'>pl</span><span class='op'>$</span><span class='fu'>DataFrame</span><span class='op'>(</span><span class='va'>mtcars</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>lazy</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>shift_and_fill</span><span class='op'>(</span><span class='fl'>0.</span>, <span class='fl'>2.</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>collect</span><span class='op'>(</span><span class='op'>)</span><span class='op'>$</span><span class='fu'>as_data_frame</span><span class='op'>(</span><span class='op'>)</span></span></span>
<span class='r-out co'><span class='r-pr'>#&gt;</span>     mpg cyl  disp  hp drat    wt  qsec vs am gear carb</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 1   0.0   0   0.0   0 0.00 0.000  0.00  0  0    0    0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 2   0.0   0   0.0   0 0.00 0.000  0.00  0  0    0    0</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 3  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 4  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 5  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 6  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 7  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 8  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 9  14.3   8 360.0 245 3.21 3.570 15.84  0  0    3    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 10 24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 11 22.8   4 140.8  95 3.92 3.150 22.90  1  0    4    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 12 19.2   6 167.6 123 3.92 3.440 18.30  1  0    4    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 13 17.8   6 167.6 123 3.92 3.440 18.90  1  0    4    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 14 16.4   8 275.8 180 3.07 4.070 17.40  0  0    3    3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 15 17.3   8 275.8 180 3.07 3.730 17.60  0  0    3    3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 16 15.2   8 275.8 180 3.07 3.780 18.00  0  0    3    3</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 17 10.4   8 472.0 205 2.93 5.250 17.98  0  0    3    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 18 10.4   8 460.0 215 3.00 5.424 17.82  0  0    3    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 19 14.7   8 440.0 230 3.23 5.345 17.42  0  0    3    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 20 32.4   4  78.7  66 4.08 2.200 19.47  1  1    4    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 21 30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 22 33.9   4  71.1  65 4.22 1.835 19.90  1  1    4    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 23 21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 24 15.5   8 318.0 150 2.76 3.520 16.87  0  0    3    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 25 15.2   8 304.0 150 3.15 3.435 17.30  0  0    3    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 26 13.3   8 350.0 245 3.73 3.840 15.41  0  0    3    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 27 19.2   8 400.0 175 3.08 3.845 17.05  0  0    3    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 28 27.3   4  79.0  66 4.08 1.935 18.90  1  1    4    1</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 29 26.0   4 120.3  91 4.43 2.140 16.70  0  1    5    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 30 30.4   4  95.1 113 3.77 1.513 16.90  1  1    5    2</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 31 15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4</span>
<span class='r-out co'><span class='r-pr'>#&gt;</span> 32 19.7   6 145.0 175 3.62 2.770 15.50  0  1    5    6</span>
 </code></pre>