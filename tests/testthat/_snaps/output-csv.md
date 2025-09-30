# lazy_sink_csv works

    Code
      cat(lf$explain())
    Output
      SINK (file)
        DF ["mpg", "cyl", "disp", "hp", ...]; PROJECT */11 COLUMNS

---

    Code
      lf$collect()
    Output
      shape: (0, 0)
      ┌┐
      ╞╡
      └┘

# sink_csv: quote_style quote_style=necessary

    Code
      readLines(temp_out)
    Output
      [1] "a,b,c"                 "\"\"\"foo\"\"\",1.0,a"

# sink_csv: quote_style quote_style=always

    Code
      readLines(temp_out)
    Output
      [1] "\"a\",\"b\",\"c\""             "\"\"\"foo\"\"\",\"1.0\",\"a\""

# sink_csv: quote_style quote_style=non_numeric

    Code
      readLines(temp_out)
    Output
      [1] "\"a\",\"b\",\"c\""         "\"\"\"foo\"\"\",1.0,\"a\""

# sink_csv: quote_style quote_style=never

    Code
      readLines(temp_out)
    Output
      [1] "a,b,c"         "\"foo\",1.0,a"

# write_csv: quote_style quote_style=necessary

    Code
      readLines(temp_out)
    Output
      [1] "a,b,c"                 "\"\"\"foo\"\"\",1.0,a"

# write_csv: quote_style quote_style=always

    Code
      readLines(temp_out)
    Output
      [1] "\"a\",\"b\",\"c\""             "\"\"\"foo\"\"\",\"1.0\",\"a\""

# write_csv: quote_style quote_style=non_numeric

    Code
      readLines(temp_out)
    Output
      [1] "\"a\",\"b\",\"c\""         "\"\"\"foo\"\"\",1.0,\"a\""

# write_csv: quote_style quote_style=never

    Code
      readLines(temp_out)
    Output
      [1] "a,b,c"         "\"foo\",1.0,a"

