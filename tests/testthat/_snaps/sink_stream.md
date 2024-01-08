# sink_csv: quote_style quote_style=necessary

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      a,b,c
      """foo""",1.0,a

# sink_csv: quote_style quote_style=always

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      "a","b","c"
      """foo""","1.0","a"

# sink_csv: quote_style quote_style=non_numeric

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      "a","b","c"
      """foo""",1.0,"a"

# sink_csv: quote_style quote_style=never

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      a,b,c
      "foo",1.0,a

