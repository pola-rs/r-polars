# as_polars_df works for classes list

    Code
      print(pl_df)
    Output
      shape: (2, 2)
      ┌─────┬───────────┐
      │ x   ┆ y         │
      │ --- ┆ ---       │
      │ i32 ┆ list[str] │
      ╞═════╪═══════════╡
      │ 1   ┆ ["c"]     │
      │ 2   ┆ ["d"]     │
      └─────┴───────────┘

# as_polars_df works for classes data.frame

    Code
      print(pl_df)
    Output
      shape: (2, 2)
      ┌─────┬───────────┐
      │ x   ┆ y         │
      │ --- ┆ ---       │
      │ i32 ┆ list[str] │
      ╞═════╪═══════════╡
      │ 1   ┆ ["c"]     │
      │ 2   ┆ ["d"]     │
      └─────┴───────────┘

