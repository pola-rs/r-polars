# $show_graph() works

    Code
      query$show_graph(raw_output = TRUE)
    Output
      [1] "graph  polars_query {\n\"WITH COLUMNS [\\\"foo\\\",\\\"bar\\\"] [(0, 0)]\" -- \"TABLE\nπ */11;\nσ (col(\\\"drat\\\")) > (3.0) [(0, 1)]\"\n\n\"TABLE\nπ */11;\nσ (col(\\\"drat\\\")) > (3.0) [(0, 1)]\"[label=\"TABLE\nπ */11;\nσ (col(\\\"drat\\\")) > (3.0)\"]\n\"WITH COLUMNS [\\\"foo\\\",\\\"bar\\\"] [(0, 0)]\"[label=\"WITH COLUMNS [\\\"foo\\\",\\\"bar\\\"]\"]\n\n}"

