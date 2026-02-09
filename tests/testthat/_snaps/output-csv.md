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

# write_csv can export compressed data

    Code
      dat$write_csv(tmpf, compression = "foo")
    Condition
      Error in `dat$write_csv()`:
      ! Evaluation failed in `$write_csv()`.
      Caused by error:
      ! Evaluation failed in `$sink_csv()`.
      Caused by error in `self$lazy_sink_csv()`:
      ! Evaluation failed in `$lazy_sink_csv()`.
      Caused by error in `self$lazy_sink_csv()`:
      ! `compression` must be one of "uncompressed", "gzip", or "zstd", not "foo".

# error if wrong compression extension

    Code
      dat$sink_csv(tmpf)
    Condition
      Error in `dat$sink_csv()`:
      ! Evaluation failed in `$sink_csv()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: use the compression parameter to control compression, or set `check_extension` to `False` if you want to suffix an uncompressed filename with an ending intended for compression
      
      Resolved plan until failure:
      
      	---> FAILED HERE RESOLVING THIS_NODE <---
      DF ["mpg", "cyl", "disp"]; PROJECT */3 COLUMNS

