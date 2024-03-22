# $to_dot() works

    Code
      cat(pl$LazyFrame(a = 1, b = "a")$to_dot())
    Output
      graph  polars_query {
      "[TABLE
      π */2;
      σ -]"
      
      
      }

