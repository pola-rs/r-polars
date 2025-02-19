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

# as_polars_df.default throws an error

    Code
      as_polars_df(1)
    Condition
      Error:
      ! This object is not supported for the default method of `as_polars_df()` because it is not a Struct dtype like object.
      i Use `infer_polars_dtype()` to check the dtype for corresponding to the object.

---

    Code
      as_polars_df(0+1i)
    Condition
      Error:
      ! Unsupported class for `infer_polars_dtype()`: complex
      Caused by error in `infer_polars_dtype_default_impl()`:
      ! Unsupported class for `as_polars_series()`: complex

