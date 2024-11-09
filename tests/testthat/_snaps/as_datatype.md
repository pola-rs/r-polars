# pl$concat_list()

    Code
      df$select(x = pl$concat_list("a", factor("a")))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! failed to determine supertype of f64 and cat
      
      Resolved plan until failure:
      
      	---> FAILED HERE RESOLVING 'select' <---
      DF ["a", "b"]; PROJECT */2 COLUMNS; SELECTION: None

