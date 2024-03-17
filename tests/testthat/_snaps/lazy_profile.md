# $show_graph() works

    Code
      cat(pl$LazyFrame(a = 1, b = "a")$show_graph(raw_output = TRUE))
    Output
      graph  polars_query {
      "[TABLE
      π */2;
      σ -]"
      
      
      }

