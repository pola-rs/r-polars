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

# sink_ndjson works

    Code
      cat(readLines(path, warn = FALSE), sep = "\n")
    Output
      {"drat":3.9,"mpg":21.0}
      {"drat":3.9,"mpg":21.0}
      {"drat":3.85,"mpg":22.8}
      {"drat":3.08,"mpg":21.4}
      {"drat":3.15,"mpg":18.7}
      {"drat":2.76,"mpg":18.1}
      {"drat":3.21,"mpg":14.3}
      {"drat":3.69,"mpg":24.4}
      {"drat":3.92,"mpg":22.8}
      {"drat":3.92,"mpg":19.2}
      {"drat":3.92,"mpg":17.8}
      {"drat":3.07,"mpg":16.4}
      {"drat":3.07,"mpg":17.3}
      {"drat":3.07,"mpg":15.2}
      {"drat":2.93,"mpg":10.4}

