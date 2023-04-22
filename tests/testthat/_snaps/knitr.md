# Snapshot test of knitr

    Code
      .knit_file("dataframe.Rmd")
    Output
      ---
      output:
        github_document:
          df_print: kable
          html_preview: false
      ---
      
      
      ```r
      df = data.frame(a = 1:3, b = letters[1:3])
      pl$DataFrame(df)
      ```
      
      ```
      ## shape: (3, 2)
      ## ┌─────┬─────┐
      ## │ a   ┆ b   │
      ## │ --- ┆ --- │
      ## │ i32 ┆ str │
      ## ╞═════╪═════╡
      ## │ 1   ┆ a   │
      ## │ 2   ┆ b   │
      ## │ 3   ┆ c   │
      ## └─────┴─────┘
      ```

---

    Code
      .knit_file("dataframe.Rmd")
    Output
      ---
      output:
        github_document:
          df_print: kable
          html_preview: false
      ---
      
      
      ```r
      df = data.frame(a = 1:3, b = letters[1:3])
      pl$DataFrame(df)
      ```
      
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
      }
      </style>
      <small>shape: (3, 2)</small><table border="1" class="dataframe"><thead><tr><th>a</th><th>b</th></tr><tr><td>i32</td><td>str</td></tr></thead><tbody><tr><td>1</td><td>&quot;a&quot;</td></tr><tr><td>2</td><td>&quot;b&quot;</td></tr><tr><td>3</td><td>&quot;c&quot;</td></tr></tbody></table></div>

---

    Code
      .knit_file("dataframe.Rmd", use = "rmarkdown")
    Output
      
      ``` r
      df = data.frame(a = 1:3, b = letters[1:3])
      pl$DataFrame(df)
      ```
      
      <div>
      
      <style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
      }
      </style>
      <small>shape: (3, 2)</small>
      <table border="1" class="dataframe">
      <thead>
      <tr>
      <th>
      a
      </th>
      <th>
      b
      </th>
      </tr>
      <tr>
      <td>
      i32
      </td>
      <td>
      str
      </td>
      </tr>
      </thead>
      <tbody>
      <tr>
      <td>
      1
      </td>
      <td>
      "a"
      </td>
      </tr>
      <tr>
      <td>
      2
      </td>
      <td>
      "b"
      </td>
      </tr>
      <tr>
      <td>
      3
      </td>
      <td>
      "c"
      </td>
      </tr>
      </tbody>
      </table>
      
      </div>

---

    Code
      .knit_file("dataframe.Rmd", use = "rmarkdown")
    Output
      
      ``` r
      df = data.frame(a = 1:3, b = letters[1:3])
      pl$DataFrame(df)
      ```
      
          ## shape: (3, 2)
          ## ┌─────┬─────┐
          ## │ a   ┆ b   │
          ## │ --- ┆ --- │
          ## │ i32 ┆ str │
          ## ╞═════╪═════╡
          ## │ 1   ┆ a   │
          ## │ 2   ┆ b   │
          ## │ 3   ┆ c   │
          ## └─────┴─────┘

# to_html_table

    Code
      to_html_table(mtcars, 3, 3)
    Output
      [1] "<div><style>\n.dataframe > thead > tr > th,\n.dataframe > tbody > tr > td {\n  text-align: right;\n}\n</style>\n<small>shape: (32, 11)</small><table border=\"1\" class=\"dataframe\"><thead><tr><th>mpg</th><th>&hellip;</th><th>carb</th></tr><tr><td>dbl</td><td>&hellip;</td><td>dbl</td></tr></thead><tbody><tr><td>21</td><td>&hellip;</td><td>4</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>21.4</td><td>&hellip;</td><td>2</td></tr></tbody></table></div>"

---

    Code
      to_html_table(mtcars)
    Output
      [1] "<div><style>\n.dataframe > thead > tr > th,\n.dataframe > tbody > tr > td {\n  text-align: right;\n}\n</style>\n<small>shape: (32, 11)</small><table border=\"1\" class=\"dataframe\"><thead><tr><th>mpg</th><th>cyl</th><th>disp</th><th>hp</th><th>drat</th><th>wt</th><th>qsec</th><th>vs</th><th>am</th><th>gear</th><th>carb</th></tr><tr><td>dbl</td><td>dbl</td><td>dbl</td><td>dbl</td><td>dbl</td><td>dbl</td><td>dbl</td><td>dbl</td><td>dbl</td><td>dbl</td><td>dbl</td></tr></thead><tbody><tr><td>21</td><td>6</td><td>160</td><td>110</td><td>3.9</td><td>2.62</td><td>16.46</td><td>0</td><td>1</td><td>4</td><td>4</td></tr><tr><td>21</td><td>6</td><td>160</td><td>110</td><td>3.9</td><td>2.875</td><td>17.02</td><td>0</td><td>1</td><td>4</td><td>4</td></tr><tr><td>22.8</td><td>4</td><td>108</td><td>93</td><td>3.85</td><td>2.32</td><td>18.61</td><td>1</td><td>1</td><td>4</td><td>1</td></tr><tr><td>21.4</td><td>6</td><td>258</td><td>110</td><td>3.08</td><td>3.215</td><td>19.44</td><td>1</td><td>0</td><td>3</td><td>1</td></tr><tr><td>18.7</td><td>8</td><td>360</td><td>175</td><td>3.15</td><td>3.44</td><td>17.02</td><td>0</td><td>0</td><td>3</td><td>2</td></tr><tr><td>18.1</td><td>6</td><td>225</td><td>105</td><td>2.76</td><td>3.46</td><td>20.22</td><td>1</td><td>0</td><td>3</td><td>1</td></tr><tr><td>14.3</td><td>8</td><td>360</td><td>245</td><td>3.21</td><td>3.57</td><td>15.84</td><td>0</td><td>0</td><td>3</td><td>4</td></tr><tr><td>24.4</td><td>4</td><td>146.7</td><td>62</td><td>3.69</td><td>3.19</td><td>20</td><td>1</td><td>0</td><td>4</td><td>2</td></tr><tr><td>22.8</td><td>4</td><td>140.8</td><td>95</td><td>3.92</td><td>3.15</td><td>22.9</td><td>1</td><td>0</td><td>4</td><td>2</td></tr><tr><td>19.2</td><td>6</td><td>167.6</td><td>123</td><td>3.92</td><td>3.44</td><td>18.3</td><td>1</td><td>0</td><td>4</td><td>4</td></tr><tr><td>17.8</td><td>6</td><td>167.6</td><td>123</td><td>3.92</td><td>3.44</td><td>18.9</td><td>1</td><td>0</td><td>4</td><td>4</td></tr><tr><td>16.4</td><td>8</td><td>275.8</td><td>180</td><td>3.07</td><td>4.07</td><td>17.4</td><td>0</td><td>0</td><td>3</td><td>3</td></tr><tr><td>17.3</td><td>8</td><td>275.8</td><td>180</td><td>3.07</td><td>3.73</td><td>17.6</td><td>0</td><td>0</td><td>3</td><td>3</td></tr><tr><td>15.2</td><td>8</td><td>275.8</td><td>180</td><td>3.07</td><td>3.78</td><td>18</td><td>0</td><td>0</td><td>3</td><td>3</td></tr><tr><td>10.4</td><td>8</td><td>472</td><td>205</td><td>2.93</td><td>5.25</td><td>17.98</td><td>0</td><td>0</td><td>3</td><td>4</td></tr><tr><td>10.4</td><td>8</td><td>460</td><td>215</td><td>3</td><td>5.424</td><td>17.82</td><td>0</td><td>0</td><td>3</td><td>4</td></tr><tr><td>14.7</td><td>8</td><td>440</td><td>230</td><td>3.23</td><td>5.345</td><td>17.42</td><td>0</td><td>0</td><td>3</td><td>4</td></tr><tr><td>32.4</td><td>4</td><td>78.7</td><td>66</td><td>4.08</td><td>2.2</td><td>19.47</td><td>1</td><td>1</td><td>4</td><td>1</td></tr><tr><td>30.4</td><td>4</td><td>75.7</td><td>52</td><td>4.93</td><td>1.615</td><td>18.52</td><td>1</td><td>1</td><td>4</td><td>2</td></tr><tr><td>33.9</td><td>4</td><td>71.1</td><td>65</td><td>4.22</td><td>1.835</td><td>19.9</td><td>1</td><td>1</td><td>4</td><td>1</td></tr><tr><td>21.5</td><td>4</td><td>120.1</td><td>97</td><td>3.7</td><td>2.465</td><td>20.01</td><td>1</td><td>0</td><td>3</td><td>1</td></tr><tr><td>15.5</td><td>8</td><td>318</td><td>150</td><td>2.76</td><td>3.52</td><td>16.87</td><td>0</td><td>0</td><td>3</td><td>2</td></tr><tr><td>15.2</td><td>8</td><td>304</td><td>150</td><td>3.15</td><td>3.435</td><td>17.3</td><td>0</td><td>0</td><td>3</td><td>2</td></tr><tr><td>13.3</td><td>8</td><td>350</td><td>245</td><td>3.73</td><td>3.84</td><td>15.41</td><td>0</td><td>0</td><td>3</td><td>4</td></tr><tr><td>19.2</td><td>8</td><td>400</td><td>175</td><td>3.08</td><td>3.845</td><td>17.05</td><td>0</td><td>0</td><td>3</td><td>2</td></tr><tr><td>27.3</td><td>4</td><td>79</td><td>66</td><td>4.08</td><td>1.935</td><td>18.9</td><td>1</td><td>1</td><td>4</td><td>1</td></tr><tr><td>26</td><td>4</td><td>120.3</td><td>91</td><td>4.43</td><td>2.14</td><td>16.7</td><td>0</td><td>1</td><td>5</td><td>2</td></tr><tr><td>30.4</td><td>4</td><td>95.1</td><td>113</td><td>3.77</td><td>1.513</td><td>16.9</td><td>1</td><td>1</td><td>5</td><td>2</td></tr><tr><td>15.8</td><td>8</td><td>351</td><td>264</td><td>4.22</td><td>3.17</td><td>14.5</td><td>0</td><td>1</td><td>5</td><td>4</td></tr><tr><td>19.7</td><td>6</td><td>145</td><td>175</td><td>3.62</td><td>2.77</td><td>15.5</td><td>0</td><td>1</td><td>5</td><td>6</td></tr><tr><td>15</td><td>8</td><td>301</td><td>335</td><td>3.54</td><td>3.57</td><td>14.6</td><td>0</td><td>1</td><td>5</td><td>8</td></tr><tr><td>21.4</td><td>4</td><td>121</td><td>109</td><td>4.11</td><td>2.78</td><td>18.6</td><td>1</td><td>1</td><td>4</td><td>2</td></tr></tbody></table></div>"

