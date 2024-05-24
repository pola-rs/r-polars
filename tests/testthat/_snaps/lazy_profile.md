# $to_dot() works

    Code
      cat(pl$LazyFrame(a = 1, b = "a")$to_dot())
    Output
      graph  polars_query {
        p1[label="TABLE\nπ */2;\nσ None"]
      }

