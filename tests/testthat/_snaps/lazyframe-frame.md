# $to_dot() works

    Code
      cat(lf$to_dot())
    Output
      graph  polars_query {
        p1[label="TABLE\nπ */11"]
      }

---

    Code
      cat(lf$select("am")$to_dot())
    Output
      graph  polars_query {
        p1[label="TABLE\nπ 1/11"]
      }

# explain() works

    Code
      cat(lazy_query$explain(optimized = FALSE))
    Output
      FILTER [(col("Species")) != (String(setosa))] FROM
        SORT BY [col("Species")]
          DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"]; PROJECT */5 COLUMNS

---

    Code
      cat(lazy_query$explain())
    Output
      SORT BY [col("Species")]
        FILTER [(col("Species")) != (String(setosa))] FROM
          DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"]; PROJECT */5 COLUMNS

---

    Code
      cat(lazy_query$explain(format = "tree", optimized = FALSE))
    Output
                                0                               1                                             2
         ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
         │
         │                  ╭────────╮
       0 │                  │ FILTER │
         │                  ╰───┬┬───╯
         │                      ││
         │                      │╰──────────────────────────────╮
         │                      │                               │
         │  ╭───────────────────┴────────────────────╮     ╭────┴────╮
         │  │ predicate:                             │     │ FROM:   │
       1 │  │ [(col("Species")) != (String(setosa))] │     │ SORT BY │
         │  ╰────────────────────────────────────────╯     ╰────┬┬───╯
         │                                                      ││
         │                                                      │╰────────────────────────────────────────────╮
         │                                                      │                                             │
         │                                              ╭───────┴────────╮  ╭─────────────────────────────────┴─────────────────────────────────╮
         │                                              │ expression:    │  │ DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"] │
       2 │                                              │ col("Species") │  │ PROJECT */5 COLUMNS                                               │
         │                                              ╰────────────────╯  ╰───────────────────────────────────────────────────────────────────╯

---

    Code
      cat(lazy_query$explain(format = "tree", ))
    Output
                    0                               1                                                         2
         ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
         │
         │     ╭─────────╮
       0 │     │ SORT BY │
         │     ╰────┬┬───╯
         │          ││
         │          │╰──────────────────────────────╮
         │          │                               │
         │  ╭───────┴────────╮                      │
         │  │ expression:    │                  ╭───┴────╮
       1 │  │ col("Species") │                  │ FILTER │
         │  ╰────────────────╯                  ╰───┬┬───╯
         │                                          ││
         │                                          │╰────────────────────────────────────────────────────────╮
         │                                          │                                                         │
         │                      ╭───────────────────┴────────────────────╮  ╭─────────────────────────────────┴─────────────────────────────────╮
         │                      │ predicate:                             │  │ FROM:                                                             │
       2 │                      │ [(col("Species")) != (String(setosa))] │  │ DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"] │
         │                      ╰────────────────────────────────────────╯  │ PROJECT */5 COLUMNS                                               │
         │                                                                  ╰───────────────────────────────────────────────────────────────────╯

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

