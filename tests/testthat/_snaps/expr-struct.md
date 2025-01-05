# struct$rename_fields

    Code
      df$select(pl$col("struct_col")$struct$field("aaa"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! field not found: aaa
      
      Resolved plan until failure:
      
      	---> FAILED HERE RESOLVING 'select' <---
      DF ["struct_col"]; PROJECT */1 COLUMNS

# struct$json_encode

    Code
      df$with_columns(encoded = pl$col("a")$struct$json_encode())
    Output
      shape: (2, 2)
      ┌──────────────────────────┬────────────────────────────────┐
      │ a                        ┆ encoded                        │
      │ ---                      ┆ ---                            │
      │ struct[2]                ┆ str                            │
      ╞══════════════════════════╪════════════════════════════════╡
      │ {[1.0, 2.0],[45.0]}      ┆ {"a":[1.0,2.0],"b":[45.0]}     │
      │ {[9.0, 1.0, 3.0],[null]} ┆ {"a":[9.0,1.0,3.0],"b":[null]} │
      └──────────────────────────┴────────────────────────────────┘

