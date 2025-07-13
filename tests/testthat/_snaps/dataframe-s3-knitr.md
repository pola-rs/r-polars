# knitr_print by knitr with polars.df_knitr_print = NULL, POLARS_FMT_MAX_COLS = NULL, POLARS_FMT_MAX_ROWS = NULL

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      ---
      output:
        github_document:
          df_print: kable
          html_preview: false
      ---
      
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
      ```{=html}
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776, 19)</small><table border="1" class="dataframe"><thead><tr><th>year</th><th>month</th><th>day</th><th>dep_time</th><th>sched_dep_time</th><th>dep_delay</th><th>arr_time</th><th>sched_arr_time</th><th>arr_delay</th><th>carrier</th><th>flight</th><th>tailnum</th><th>origin</th><th>dest</th><th>air_time</th><th>distance</th><th>hour</th><th>minute</th><th>time_hour</th></tr><tr><td>i32</td><td>i32</td><td>i32</td><td>i32</td><td>i32</td><td>f64</td><td>i32</td><td>i32</td><td>f64</td><td>str</td><td>i32</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>f64</td><td>f64</td><td>datetime[ms, America/New_York]</td></tr></thead><tbody><tr><td>2013</td><td>1</td><td>1</td><td>517</td><td>515</td><td>2.0</td><td>830</td><td>819</td><td>11.0</td><td>"UA"</td><td>1545</td><td>"N14228"</td><td>"EWR"</td><td>"IAH"</td><td>227.0</td><td>1400.0</td><td>5.0</td><td>15.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>533</td><td>529</td><td>4.0</td><td>850</td><td>830</td><td>20.0</td><td>"UA"</td><td>1714</td><td>"N24211"</td><td>"LGA"</td><td>"IAH"</td><td>227.0</td><td>1416.0</td><td>5.0</td><td>29.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>542</td><td>540</td><td>2.0</td><td>923</td><td>850</td><td>33.0</td><td>"AA"</td><td>1141</td><td>"N619AA"</td><td>"JFK"</td><td>"MIA"</td><td>160.0</td><td>1089.0</td><td>5.0</td><td>40.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>544</td><td>545</td><td>-1.0</td><td>1004</td><td>1022</td><td>-18.0</td><td>"B6"</td><td>725</td><td>"N804JB"</td><td>"JFK"</td><td>"BQN"</td><td>183.0</td><td>1576.0</td><td>5.0</td><td>45.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>554</td><td>600</td><td>-6.0</td><td>812</td><td>837</td><td>-25.0</td><td>"DL"</td><td>461</td><td>"N668DN"</td><td>"LGA"</td><td>"ATL"</td><td>116.0</td><td>762.0</td><td>6.0</td><td>0.0</td><td>2013-01-01 06:00:00 EST</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1455</td><td>null</td><td>null</td><td>1634</td><td>null</td><td>"9E"</td><td>3393</td><td>null</td><td>"JFK"</td><td>"DCA"</td><td>null</td><td>213.0</td><td>14.0</td><td>55.0</td><td>2013-09-30 14:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>2200</td><td>null</td><td>null</td><td>2312</td><td>null</td><td>"9E"</td><td>3525</td><td>null</td><td>"LGA"</td><td>"SYR"</td><td>null</td><td>198.0</td><td>22.0</td><td>0.0</td><td>2013-09-30 22:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1210</td><td>null</td><td>null</td><td>1330</td><td>null</td><td>"MQ"</td><td>3461</td><td>"N535MQ"</td><td>"LGA"</td><td>"BNA"</td><td>null</td><td>764.0</td><td>12.0</td><td>10.0</td><td>2013-09-30 12:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1159</td><td>null</td><td>null</td><td>1344</td><td>null</td><td>"MQ"</td><td>3572</td><td>"N511MQ"</td><td>"LGA"</td><td>"CLE"</td><td>null</td><td>419.0</td><td>11.0</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>840</td><td>null</td><td>null</td><td>1020</td><td>null</td><td>"MQ"</td><td>3531</td><td>"N839MQ"</td><td>"LGA"</td><td>"RDU"</td><td>null</td><td>431.0</td><td>8.0</td><td>40.0</td><td>2013-09-30 08:00:00 EDT</td></tr></tbody></table></div>
      ```
      
      
      ``` r
      df$to_series()
      ```
      
      ```{=html}
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776)</small><table border="1" class="dataframe"><thead><tr><th>year</th></tr><tr><td>i32</td></tr></thead><tbody><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>&hellip;</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr></tbody></table></div>
      ```

# knitr_print by rmarkdown with polars.df_knitr_print = NULL, POLARS_FMT_MAX_COLS = NULL, POLARS_FMT_MAX_ROWS = NULL

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776, 19)</small><table border="1" class="dataframe"><thead><tr><th>year</th><th>month</th><th>day</th><th>dep_time</th><th>sched_dep_time</th><th>dep_delay</th><th>arr_time</th><th>sched_arr_time</th><th>arr_delay</th><th>carrier</th><th>flight</th><th>tailnum</th><th>origin</th><th>dest</th><th>air_time</th><th>distance</th><th>hour</th><th>minute</th><th>time_hour</th></tr><tr><td>i32</td><td>i32</td><td>i32</td><td>i32</td><td>i32</td><td>f64</td><td>i32</td><td>i32</td><td>f64</td><td>str</td><td>i32</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>f64</td><td>f64</td><td>datetime[ms, America/New_York]</td></tr></thead><tbody><tr><td>2013</td><td>1</td><td>1</td><td>517</td><td>515</td><td>2.0</td><td>830</td><td>819</td><td>11.0</td><td>"UA"</td><td>1545</td><td>"N14228"</td><td>"EWR"</td><td>"IAH"</td><td>227.0</td><td>1400.0</td><td>5.0</td><td>15.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>533</td><td>529</td><td>4.0</td><td>850</td><td>830</td><td>20.0</td><td>"UA"</td><td>1714</td><td>"N24211"</td><td>"LGA"</td><td>"IAH"</td><td>227.0</td><td>1416.0</td><td>5.0</td><td>29.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>542</td><td>540</td><td>2.0</td><td>923</td><td>850</td><td>33.0</td><td>"AA"</td><td>1141</td><td>"N619AA"</td><td>"JFK"</td><td>"MIA"</td><td>160.0</td><td>1089.0</td><td>5.0</td><td>40.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>544</td><td>545</td><td>-1.0</td><td>1004</td><td>1022</td><td>-18.0</td><td>"B6"</td><td>725</td><td>"N804JB"</td><td>"JFK"</td><td>"BQN"</td><td>183.0</td><td>1576.0</td><td>5.0</td><td>45.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>554</td><td>600</td><td>-6.0</td><td>812</td><td>837</td><td>-25.0</td><td>"DL"</td><td>461</td><td>"N668DN"</td><td>"LGA"</td><td>"ATL"</td><td>116.0</td><td>762.0</td><td>6.0</td><td>0.0</td><td>2013-01-01 06:00:00 EST</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1455</td><td>null</td><td>null</td><td>1634</td><td>null</td><td>"9E"</td><td>3393</td><td>null</td><td>"JFK"</td><td>"DCA"</td><td>null</td><td>213.0</td><td>14.0</td><td>55.0</td><td>2013-09-30 14:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>2200</td><td>null</td><td>null</td><td>2312</td><td>null</td><td>"9E"</td><td>3525</td><td>null</td><td>"LGA"</td><td>"SYR"</td><td>null</td><td>198.0</td><td>22.0</td><td>0.0</td><td>2013-09-30 22:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1210</td><td>null</td><td>null</td><td>1330</td><td>null</td><td>"MQ"</td><td>3461</td><td>"N535MQ"</td><td>"LGA"</td><td>"BNA"</td><td>null</td><td>764.0</td><td>12.0</td><td>10.0</td><td>2013-09-30 12:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1159</td><td>null</td><td>null</td><td>1344</td><td>null</td><td>"MQ"</td><td>3572</td><td>"N511MQ"</td><td>"LGA"</td><td>"CLE"</td><td>null</td><td>419.0</td><td>11.0</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>840</td><td>null</td><td>null</td><td>1020</td><td>null</td><td>"MQ"</td><td>3531</td><td>"N839MQ"</td><td>"LGA"</td><td>"RDU"</td><td>null</td><td>431.0</td><td>8.0</td><td>40.0</td><td>2013-09-30 08:00:00 EDT</td></tr></tbody></table></div>
      
      ``` r
      df$to_series()
      ```
      
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776)</small><table border="1" class="dataframe"><thead><tr><th>year</th></tr><tr><td>i32</td></tr></thead><tbody><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>&hellip;</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr></tbody></table></div>

# knitr_print by knitr with polars.df_knitr_print = "html", POLARS_FMT_MAX_COLS = NULL, POLARS_FMT_MAX_ROWS = NULL

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      ---
      output:
        github_document:
          df_print: kable
          html_preview: false
      ---
      
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
      ```{=html}
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776, 19)</small><table border="1" class="dataframe"><thead><tr><th>year</th><th>month</th><th>day</th><th>dep_time</th><th>sched_dep_time</th><th>dep_delay</th><th>arr_time</th><th>sched_arr_time</th><th>arr_delay</th><th>carrier</th><th>flight</th><th>tailnum</th><th>origin</th><th>dest</th><th>air_time</th><th>distance</th><th>hour</th><th>minute</th><th>time_hour</th></tr><tr><td>i32</td><td>i32</td><td>i32</td><td>i32</td><td>i32</td><td>f64</td><td>i32</td><td>i32</td><td>f64</td><td>str</td><td>i32</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>f64</td><td>f64</td><td>datetime[ms, America/New_York]</td></tr></thead><tbody><tr><td>2013</td><td>1</td><td>1</td><td>517</td><td>515</td><td>2.0</td><td>830</td><td>819</td><td>11.0</td><td>"UA"</td><td>1545</td><td>"N14228"</td><td>"EWR"</td><td>"IAH"</td><td>227.0</td><td>1400.0</td><td>5.0</td><td>15.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>533</td><td>529</td><td>4.0</td><td>850</td><td>830</td><td>20.0</td><td>"UA"</td><td>1714</td><td>"N24211"</td><td>"LGA"</td><td>"IAH"</td><td>227.0</td><td>1416.0</td><td>5.0</td><td>29.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>542</td><td>540</td><td>2.0</td><td>923</td><td>850</td><td>33.0</td><td>"AA"</td><td>1141</td><td>"N619AA"</td><td>"JFK"</td><td>"MIA"</td><td>160.0</td><td>1089.0</td><td>5.0</td><td>40.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>544</td><td>545</td><td>-1.0</td><td>1004</td><td>1022</td><td>-18.0</td><td>"B6"</td><td>725</td><td>"N804JB"</td><td>"JFK"</td><td>"BQN"</td><td>183.0</td><td>1576.0</td><td>5.0</td><td>45.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>554</td><td>600</td><td>-6.0</td><td>812</td><td>837</td><td>-25.0</td><td>"DL"</td><td>461</td><td>"N668DN"</td><td>"LGA"</td><td>"ATL"</td><td>116.0</td><td>762.0</td><td>6.0</td><td>0.0</td><td>2013-01-01 06:00:00 EST</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1455</td><td>null</td><td>null</td><td>1634</td><td>null</td><td>"9E"</td><td>3393</td><td>null</td><td>"JFK"</td><td>"DCA"</td><td>null</td><td>213.0</td><td>14.0</td><td>55.0</td><td>2013-09-30 14:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>2200</td><td>null</td><td>null</td><td>2312</td><td>null</td><td>"9E"</td><td>3525</td><td>null</td><td>"LGA"</td><td>"SYR"</td><td>null</td><td>198.0</td><td>22.0</td><td>0.0</td><td>2013-09-30 22:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1210</td><td>null</td><td>null</td><td>1330</td><td>null</td><td>"MQ"</td><td>3461</td><td>"N535MQ"</td><td>"LGA"</td><td>"BNA"</td><td>null</td><td>764.0</td><td>12.0</td><td>10.0</td><td>2013-09-30 12:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1159</td><td>null</td><td>null</td><td>1344</td><td>null</td><td>"MQ"</td><td>3572</td><td>"N511MQ"</td><td>"LGA"</td><td>"CLE"</td><td>null</td><td>419.0</td><td>11.0</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>840</td><td>null</td><td>null</td><td>1020</td><td>null</td><td>"MQ"</td><td>3531</td><td>"N839MQ"</td><td>"LGA"</td><td>"RDU"</td><td>null</td><td>431.0</td><td>8.0</td><td>40.0</td><td>2013-09-30 08:00:00 EDT</td></tr></tbody></table></div>
      ```
      
      
      ``` r
      df$to_series()
      ```
      
      ```{=html}
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776)</small><table border="1" class="dataframe"><thead><tr><th>year</th></tr><tr><td>i32</td></tr></thead><tbody><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>&hellip;</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr></tbody></table></div>
      ```

# knitr_print by rmarkdown with polars.df_knitr_print = "html", POLARS_FMT_MAX_COLS = NULL, POLARS_FMT_MAX_ROWS = NULL

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776, 19)</small><table border="1" class="dataframe"><thead><tr><th>year</th><th>month</th><th>day</th><th>dep_time</th><th>sched_dep_time</th><th>dep_delay</th><th>arr_time</th><th>sched_arr_time</th><th>arr_delay</th><th>carrier</th><th>flight</th><th>tailnum</th><th>origin</th><th>dest</th><th>air_time</th><th>distance</th><th>hour</th><th>minute</th><th>time_hour</th></tr><tr><td>i32</td><td>i32</td><td>i32</td><td>i32</td><td>i32</td><td>f64</td><td>i32</td><td>i32</td><td>f64</td><td>str</td><td>i32</td><td>str</td><td>str</td><td>str</td><td>f64</td><td>f64</td><td>f64</td><td>f64</td><td>datetime[ms, America/New_York]</td></tr></thead><tbody><tr><td>2013</td><td>1</td><td>1</td><td>517</td><td>515</td><td>2.0</td><td>830</td><td>819</td><td>11.0</td><td>"UA"</td><td>1545</td><td>"N14228"</td><td>"EWR"</td><td>"IAH"</td><td>227.0</td><td>1400.0</td><td>5.0</td><td>15.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>533</td><td>529</td><td>4.0</td><td>850</td><td>830</td><td>20.0</td><td>"UA"</td><td>1714</td><td>"N24211"</td><td>"LGA"</td><td>"IAH"</td><td>227.0</td><td>1416.0</td><td>5.0</td><td>29.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>542</td><td>540</td><td>2.0</td><td>923</td><td>850</td><td>33.0</td><td>"AA"</td><td>1141</td><td>"N619AA"</td><td>"JFK"</td><td>"MIA"</td><td>160.0</td><td>1089.0</td><td>5.0</td><td>40.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>544</td><td>545</td><td>-1.0</td><td>1004</td><td>1022</td><td>-18.0</td><td>"B6"</td><td>725</td><td>"N804JB"</td><td>"JFK"</td><td>"BQN"</td><td>183.0</td><td>1576.0</td><td>5.0</td><td>45.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>1</td><td>554</td><td>600</td><td>-6.0</td><td>812</td><td>837</td><td>-25.0</td><td>"DL"</td><td>461</td><td>"N668DN"</td><td>"LGA"</td><td>"ATL"</td><td>116.0</td><td>762.0</td><td>6.0</td><td>0.0</td><td>2013-01-01 06:00:00 EST</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1455</td><td>null</td><td>null</td><td>1634</td><td>null</td><td>"9E"</td><td>3393</td><td>null</td><td>"JFK"</td><td>"DCA"</td><td>null</td><td>213.0</td><td>14.0</td><td>55.0</td><td>2013-09-30 14:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>2200</td><td>null</td><td>null</td><td>2312</td><td>null</td><td>"9E"</td><td>3525</td><td>null</td><td>"LGA"</td><td>"SYR"</td><td>null</td><td>198.0</td><td>22.0</td><td>0.0</td><td>2013-09-30 22:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1210</td><td>null</td><td>null</td><td>1330</td><td>null</td><td>"MQ"</td><td>3461</td><td>"N535MQ"</td><td>"LGA"</td><td>"BNA"</td><td>null</td><td>764.0</td><td>12.0</td><td>10.0</td><td>2013-09-30 12:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>1159</td><td>null</td><td>null</td><td>1344</td><td>null</td><td>"MQ"</td><td>3572</td><td>"N511MQ"</td><td>"LGA"</td><td>"CLE"</td><td>null</td><td>419.0</td><td>11.0</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>30</td><td>null</td><td>840</td><td>null</td><td>null</td><td>1020</td><td>null</td><td>"MQ"</td><td>3531</td><td>"N839MQ"</td><td>"LGA"</td><td>"RDU"</td><td>null</td><td>431.0</td><td>8.0</td><td>40.0</td><td>2013-09-30 08:00:00 EDT</td></tr></tbody></table></div>
      
      ``` r
      df$to_series()
      ```
      
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776)</small><table border="1" class="dataframe"><thead><tr><th>year</th></tr><tr><td>i32</td></tr></thead><tbody><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>&hellip;</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr></tbody></table></div>

# knitr_print by knitr with polars.df_knitr_print = "default", POLARS_FMT_MAX_COLS = NULL, POLARS_FMT_MAX_ROWS = NULL

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      ---
      output:
        github_document:
          df_print: kable
          html_preview: false
      ---
      
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
      ```
      ## shape: (336_776, 19)
      ## ┌──────┬───────┬─────┬──────────┬───┬──────────┬──────┬────────┬────────────────────────────────┐
      ## │ year ┆ month ┆ day ┆ dep_time ┆ … ┆ distance ┆ hour ┆ minute ┆ time_hour                      │
      ## │ ---  ┆ ---   ┆ --- ┆ ---      ┆   ┆ ---      ┆ ---  ┆ ---    ┆ ---                            │
      ## │ i32  ┆ i32   ┆ i32 ┆ i32      ┆   ┆ f64      ┆ f64  ┆ f64    ┆ datetime[ms, America/New_York] │
      ## ╞══════╪═══════╪═════╪══════════╪═══╪══════════╪══════╪════════╪════════════════════════════════╡
      ## │ 2013 ┆ 1     ┆ 1   ┆ 517      ┆ … ┆ 1400.0   ┆ 5.0  ┆ 15.0   ┆ 2013-01-01 05:00:00 EST        │
      ## │ 2013 ┆ 1     ┆ 1   ┆ 533      ┆ … ┆ 1416.0   ┆ 5.0  ┆ 29.0   ┆ 2013-01-01 05:00:00 EST        │
      ## │ 2013 ┆ 1     ┆ 1   ┆ 542      ┆ … ┆ 1089.0   ┆ 5.0  ┆ 40.0   ┆ 2013-01-01 05:00:00 EST        │
      ## │ 2013 ┆ 1     ┆ 1   ┆ 544      ┆ … ┆ 1576.0   ┆ 5.0  ┆ 45.0   ┆ 2013-01-01 05:00:00 EST        │
      ## │ 2013 ┆ 1     ┆ 1   ┆ 554      ┆ … ┆ 762.0    ┆ 6.0  ┆ 0.0    ┆ 2013-01-01 06:00:00 EST        │
      ## │ …    ┆ …     ┆ …   ┆ …        ┆ … ┆ …        ┆ …    ┆ …      ┆ …                              │
      ## │ 2013 ┆ 9     ┆ 30  ┆ null     ┆ … ┆ 213.0    ┆ 14.0 ┆ 55.0   ┆ 2013-09-30 14:00:00 EDT        │
      ## │ 2013 ┆ 9     ┆ 30  ┆ null     ┆ … ┆ 198.0    ┆ 22.0 ┆ 0.0    ┆ 2013-09-30 22:00:00 EDT        │
      ## │ 2013 ┆ 9     ┆ 30  ┆ null     ┆ … ┆ 764.0    ┆ 12.0 ┆ 10.0   ┆ 2013-09-30 12:00:00 EDT        │
      ## │ 2013 ┆ 9     ┆ 30  ┆ null     ┆ … ┆ 419.0    ┆ 11.0 ┆ 59.0   ┆ 2013-09-30 11:00:00 EDT        │
      ## │ 2013 ┆ 9     ┆ 30  ┆ null     ┆ … ┆ 431.0    ┆ 8.0  ┆ 40.0   ┆ 2013-09-30 08:00:00 EDT        │
      ## └──────┴───────┴─────┴──────────┴───┴──────────┴──────┴────────┴────────────────────────────────┘
      ```
      
      
      ``` r
      df$to_series()
      ```
      
      ```
      ## shape: (336_776, 1)
      ## ┌──────┐
      ## │ year │
      ## │ ---  │
      ## │ i32  │
      ## ╞══════╡
      ## │ 2013 │
      ## │ 2013 │
      ## │ 2013 │
      ## │ 2013 │
      ## │ 2013 │
      ## │ …    │
      ## │ 2013 │
      ## │ 2013 │
      ## │ 2013 │
      ## │ 2013 │
      ## │ 2013 │
      ## └──────┘
      ```

# knitr_print by rmarkdown with polars.df_knitr_print = "default", POLARS_FMT_MAX_COLS = NULL, POLARS_FMT_MAX_ROWS = NULL

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
          ## shape: (336_776, 19)
          ## ┌──────┬───────┬─────┬──────────┬───┬──────────┬──────┬────────┬────────────────────────────────┐
          ## │ year ┆ month ┆ day ┆ dep_time ┆ … ┆ distance ┆ hour ┆ minute ┆ time_hour                      │
          ## │ ---  ┆ ---   ┆ --- ┆ ---      ┆   ┆ ---      ┆ ---  ┆ ---    ┆ ---                            │
          ## │ i32  ┆ i32   ┆ i32 ┆ i32      ┆   ┆ f64      ┆ f64  ┆ f64    ┆ datetime[ms, America/New_York] │
          ## ╞══════╪═══════╪═════╪══════════╪═══╪══════════╪══════╪════════╪════════════════════════════════╡
          ## │ 2013 ┆ 1     ┆ 1   ┆ 517      ┆ … ┆ 1400.0   ┆ 5.0  ┆ 15.0   ┆ 2013-01-01 05:00:00 EST        │
          ## │ 2013 ┆ 1     ┆ 1   ┆ 533      ┆ … ┆ 1416.0   ┆ 5.0  ┆ 29.0   ┆ 2013-01-01 05:00:00 EST        │
          ## │ 2013 ┆ 1     ┆ 1   ┆ 542      ┆ … ┆ 1089.0   ┆ 5.0  ┆ 40.0   ┆ 2013-01-01 05:00:00 EST        │
          ## │ 2013 ┆ 1     ┆ 1   ┆ 544      ┆ … ┆ 1576.0   ┆ 5.0  ┆ 45.0   ┆ 2013-01-01 05:00:00 EST        │
          ## │ 2013 ┆ 1     ┆ 1   ┆ 554      ┆ … ┆ 762.0    ┆ 6.0  ┆ 0.0    ┆ 2013-01-01 06:00:00 EST        │
          ## │ …    ┆ …     ┆ …   ┆ …        ┆ … ┆ …        ┆ …    ┆ …      ┆ …                              │
          ## │ 2013 ┆ 9     ┆ 30  ┆ null     ┆ … ┆ 213.0    ┆ 14.0 ┆ 55.0   ┆ 2013-09-30 14:00:00 EDT        │
          ## │ 2013 ┆ 9     ┆ 30  ┆ null     ┆ … ┆ 198.0    ┆ 22.0 ┆ 0.0    ┆ 2013-09-30 22:00:00 EDT        │
          ## │ 2013 ┆ 9     ┆ 30  ┆ null     ┆ … ┆ 764.0    ┆ 12.0 ┆ 10.0   ┆ 2013-09-30 12:00:00 EDT        │
          ## │ 2013 ┆ 9     ┆ 30  ┆ null     ┆ … ┆ 419.0    ┆ 11.0 ┆ 59.0   ┆ 2013-09-30 11:00:00 EDT        │
          ## │ 2013 ┆ 9     ┆ 30  ┆ null     ┆ … ┆ 431.0    ┆ 8.0  ┆ 40.0   ┆ 2013-09-30 08:00:00 EDT        │
          ## └──────┴───────┴─────┴──────────┴───┴──────────┴──────┴────────┴────────────────────────────────┘
      
      ``` r
      df$to_series()
      ```
      
          ## shape: (336_776, 1)
          ## ┌──────┐
          ## │ year │
          ## │ ---  │
          ## │ i32  │
          ## ╞══════╡
          ## │ 2013 │
          ## │ 2013 │
          ## │ 2013 │
          ## │ 2013 │
          ## │ 2013 │
          ## │ …    │
          ## │ 2013 │
          ## │ 2013 │
          ## │ 2013 │
          ## │ 2013 │
          ## │ 2013 │
          ## └──────┘

# knitr_print by knitr with polars.df_knitr_print = NULL, POLARS_FMT_MAX_COLS = "5", POLARS_FMT_MAX_ROWS = "5"

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      ---
      output:
        github_document:
          df_print: kable
          html_preview: false
      ---
      
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
      ```{=html}
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776, 19)</small><table border="1" class="dataframe"><thead><tr><th>year</th><th>month</th><th>&hellip;</th><th>minute</th><th>time_hour</th></tr><tr><td>i32</td><td>i32</td><td>&hellip;</td><td>f64</td><td>datetime[ms, America/New_York]</td></tr></thead><tbody><tr><td>2013</td><td>1</td><td>&hellip;</td><td>15.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>&hellip;</td><td>29.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>40.0</td><td>2013-09-30 08:00:00 EDT</td></tr></tbody></table></div>
      ```
      
      
      ``` r
      df$to_series()
      ```
      
      ```{=html}
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776)</small><table border="1" class="dataframe"><thead><tr><th>year</th></tr><tr><td>i32</td></tr></thead><tbody><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>&hellip;</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr></tbody></table></div>
      ```

# knitr_print by rmarkdown with polars.df_knitr_print = NULL, POLARS_FMT_MAX_COLS = "5", POLARS_FMT_MAX_ROWS = "5"

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776, 19)</small><table border="1" class="dataframe"><thead><tr><th>year</th><th>month</th><th>&hellip;</th><th>minute</th><th>time_hour</th></tr><tr><td>i32</td><td>i32</td><td>&hellip;</td><td>f64</td><td>datetime[ms, America/New_York]</td></tr></thead><tbody><tr><td>2013</td><td>1</td><td>&hellip;</td><td>15.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>&hellip;</td><td>29.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>40.0</td><td>2013-09-30 08:00:00 EDT</td></tr></tbody></table></div>
      
      ``` r
      df$to_series()
      ```
      
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776)</small><table border="1" class="dataframe"><thead><tr><th>year</th></tr><tr><td>i32</td></tr></thead><tbody><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>&hellip;</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr></tbody></table></div>

# knitr_print by knitr with polars.df_knitr_print = "html", POLARS_FMT_MAX_COLS = "5", POLARS_FMT_MAX_ROWS = "5"

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      ---
      output:
        github_document:
          df_print: kable
          html_preview: false
      ---
      
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
      ```{=html}
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776, 19)</small><table border="1" class="dataframe"><thead><tr><th>year</th><th>month</th><th>&hellip;</th><th>minute</th><th>time_hour</th></tr><tr><td>i32</td><td>i32</td><td>&hellip;</td><td>f64</td><td>datetime[ms, America/New_York]</td></tr></thead><tbody><tr><td>2013</td><td>1</td><td>&hellip;</td><td>15.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>&hellip;</td><td>29.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>40.0</td><td>2013-09-30 08:00:00 EDT</td></tr></tbody></table></div>
      ```
      
      
      ``` r
      df$to_series()
      ```
      
      ```{=html}
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776)</small><table border="1" class="dataframe"><thead><tr><th>year</th></tr><tr><td>i32</td></tr></thead><tbody><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>&hellip;</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr></tbody></table></div>
      ```

# knitr_print by rmarkdown with polars.df_knitr_print = "html", POLARS_FMT_MAX_COLS = "5", POLARS_FMT_MAX_ROWS = "5"

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776, 19)</small><table border="1" class="dataframe"><thead><tr><th>year</th><th>month</th><th>&hellip;</th><th>minute</th><th>time_hour</th></tr><tr><td>i32</td><td>i32</td><td>&hellip;</td><td>f64</td><td>datetime[ms, America/New_York]</td></tr></thead><tbody><tr><td>2013</td><td>1</td><td>&hellip;</td><td>15.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>1</td><td>&hellip;</td><td>29.0</td><td>2013-01-01 05:00:00 EST</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td><td>&hellip;</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>59.0</td><td>2013-09-30 11:00:00 EDT</td></tr><tr><td>2013</td><td>9</td><td>&hellip;</td><td>40.0</td><td>2013-09-30 08:00:00 EDT</td></tr></tbody></table></div>
      
      ``` r
      df$to_series()
      ```
      
      <div><style>
      .dataframe > thead > tr > th,
      .dataframe > tbody > tr > td {
        text-align: right;
        white-space: pre-wrap;
      }
      </style>
      <small>shape: (336_776)</small><table border="1" class="dataframe"><thead><tr><th>year</th></tr><tr><td>i32</td></tr></thead><tbody><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr><tr><td>&hellip;</td></tr><tr><td>2013</td></tr><tr><td>2013</td></tr></tbody></table></div>

# knitr_print by knitr with polars.df_knitr_print = "default", POLARS_FMT_MAX_COLS = "5", POLARS_FMT_MAX_ROWS = "5"

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      ---
      output:
        github_document:
          df_print: kable
          html_preview: false
      ---
      
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
      ```
      ## shape: (336_776, 19)
      ## ┌──────┬───────┬─────┬───┬────────┬────────────────────────────────┐
      ## │ year ┆ month ┆ day ┆ … ┆ minute ┆ time_hour                      │
      ## │ ---  ┆ ---   ┆ --- ┆   ┆ ---    ┆ ---                            │
      ## │ i32  ┆ i32   ┆ i32 ┆   ┆ f64    ┆ datetime[ms, America/New_York] │
      ## ╞══════╪═══════╪═════╪═══╪════════╪════════════════════════════════╡
      ## │ 2013 ┆ 1     ┆ 1   ┆ … ┆ 15.0   ┆ 2013-01-01 05:00:00 EST        │
      ## │ 2013 ┆ 1     ┆ 1   ┆ … ┆ 29.0   ┆ 2013-01-01 05:00:00 EST        │
      ## │ 2013 ┆ 1     ┆ 1   ┆ … ┆ 40.0   ┆ 2013-01-01 05:00:00 EST        │
      ## │ …    ┆ …     ┆ …   ┆ … ┆ …      ┆ …                              │
      ## │ 2013 ┆ 9     ┆ 30  ┆ … ┆ 59.0   ┆ 2013-09-30 11:00:00 EDT        │
      ## │ 2013 ┆ 9     ┆ 30  ┆ … ┆ 40.0   ┆ 2013-09-30 08:00:00 EDT        │
      ## └──────┴───────┴─────┴───┴────────┴────────────────────────────────┘
      ```
      
      
      ``` r
      df$to_series()
      ```
      
      ```
      ## shape: (336_776, 1)
      ## ┌──────┐
      ## │ year │
      ## │ ---  │
      ## │ i32  │
      ## ╞══════╡
      ## │ 2013 │
      ## │ 2013 │
      ## │ 2013 │
      ## │ …    │
      ## │ 2013 │
      ## │ 2013 │
      ## └──────┘
      ```

# knitr_print by rmarkdown with polars.df_knitr_print = "default", POLARS_FMT_MAX_COLS = "5", POLARS_FMT_MAX_ROWS = "5"

    Code
      read_rendered_lines(test_path("files", "rmarkdown.Rmd"), use = pkg)
    Output
      
      ``` r
      df <- as_polars_df(nycflights13::flights)
      
      df
      ```
      
          ## shape: (336_776, 19)
          ## ┌──────┬───────┬─────┬───┬────────┬────────────────────────────────┐
          ## │ year ┆ month ┆ day ┆ … ┆ minute ┆ time_hour                      │
          ## │ ---  ┆ ---   ┆ --- ┆   ┆ ---    ┆ ---                            │
          ## │ i32  ┆ i32   ┆ i32 ┆   ┆ f64    ┆ datetime[ms, America/New_York] │
          ## ╞══════╪═══════╪═════╪═══╪════════╪════════════════════════════════╡
          ## │ 2013 ┆ 1     ┆ 1   ┆ … ┆ 15.0   ┆ 2013-01-01 05:00:00 EST        │
          ## │ 2013 ┆ 1     ┆ 1   ┆ … ┆ 29.0   ┆ 2013-01-01 05:00:00 EST        │
          ## │ 2013 ┆ 1     ┆ 1   ┆ … ┆ 40.0   ┆ 2013-01-01 05:00:00 EST        │
          ## │ …    ┆ …     ┆ …   ┆ … ┆ …      ┆ …                              │
          ## │ 2013 ┆ 9     ┆ 30  ┆ … ┆ 59.0   ┆ 2013-09-30 11:00:00 EDT        │
          ## │ 2013 ┆ 9     ┆ 30  ┆ … ┆ 40.0   ┆ 2013-09-30 08:00:00 EDT        │
          ## └──────┴───────┴─────┴───┴────────┴────────────────────────────────┘
      
      ``` r
      df$to_series()
      ```
      
          ## shape: (336_776, 1)
          ## ┌──────┐
          ## │ year │
          ## │ ---  │
          ## │ i32  │
          ## ╞══════╡
          ## │ 2013 │
          ## │ 2013 │
          ## │ 2013 │
          ## │ …    │
          ## │ 2013 │
          ## │ 2013 │
          ## └──────┘

