# $to_dot() works

    Code
      cat(query$to_dot(raw_output = TRUE))
    Output
      graph  polars_query {
      "WITH COLUMNS [\"foo\",\"bar\"] [(0, 0)]" -- "TABLE
      π */11;
      σ (col(\"drat\")) > (3.0) [(0, 1)]"
      
      "WITH COLUMNS [\"foo\",\"bar\"] [(0, 0)]"[label="WITH COLUMNS [\"foo\",\"bar\"]"]
      "TABLE
      π */11;
      σ (col(\"drat\")) > (3.0) [(0, 1)]"[label="TABLE
      π */11;
      σ (col(\"drat\")) > (3.0)"]
      
      }

