# as_polars_df works for classes polars_series

    Code
      print(pl_df)
    Output
      shape: (2, 1)
      ┌─────┐
      │ foo │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      └─────┘

# as_polars_df works for classes polars_series (struct)

    Code
      print(pl_df)
    Output
      shape: (2, 2)
      ┌─────┬─────┐
      │ x   ┆ y   │
      │ --- ┆ --- │
      │ i32 ┆ str │
      ╞═════╪═════╡
      │ 1   ┆ a   │
      │ 2   ┆ b   │
      └─────┴─────┘

# as_polars_df works for classes polars_data_frame

    Code
      print(pl_df)
    Output
      shape: (2, 2)
      ┌─────┬─────┐
      │ x   ┆ y   │
      │ --- ┆ --- │
      │ i32 ┆ str │
      ╞═════╪═════╡
      │ 1   ┆ a   │
      │ 2   ┆ b   │
      └─────┴─────┘

# as_polars_df works for classes polars_group_by

    Code
      print(pl_df)
    Output
      shape: (2, 2)
      ┌─────┬─────┐
      │ x   ┆ y   │
      │ --- ┆ --- │
      │ i32 ┆ str │
      ╞═════╪═════╡
      │ 1   ┆ a   │
      │ 2   ┆ b   │
      └─────┴─────┘

# as_polars_df works for classes polars_lazy_frame

    Code
      print(pl_df)
    Output
      shape: (2, 2)
      ┌─────┬─────┐
      │ x   ┆ y   │
      │ --- ┆ --- │
      │ i32 ┆ str │
      ╞═════╪═════╡
      │ 1   ┆ a   │
      │ 2   ┆ b   │
      └─────┴─────┘

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
      shape: (3, 2)
      ┌─────┬───────────┐
      │ x   ┆ y         │
      │ --- ┆ ---       │
      │ i32 ┆ list[str] │
      ╞═════╪═══════════╡
      │ 1   ┆ ["c"]     │
      │ 2   ┆ ["d"]     │
      │ 3   ┆ ["true"]  │
      └─────┴───────────┘

# as_polars_df works for classes NULL

    Code
      print(pl_df)
    Output
      shape: (0, 0)
      ┌┐
      ╞╡
      └┘

