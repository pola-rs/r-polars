# groupby print .name=dummy, .value=dummy

    Code
      gb
    Output
      shape: (5, 2)
      ┌─────┬─────┐
      │ foo ┆ bar │
      │ --- ┆ --- │
      │ str ┆ f64 │
      ╞═════╪═════╡
      │ one ┆ 5.0 │
      │ two ┆ 3.0 │
      │ two ┆ 2.0 │
      │ one ┆ 4.0 │
      │ two ┆ 1.0 │
      └─────┴─────┘
      groups: ProtoExprArray(
          [
              Expr(
                  Expr(
                      col("foo"),
                  ),
              ),
          ],
      )
      maintain order:  TRUE

# groupby print .name=POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW, .value=1

    Code
      gb
    Output
      ┌─────┬─────┐
      │ foo ┆ bar │
      │ --- ┆ --- │
      │ str ┆ f64 │
      ╞═════╪═════╡
      │ one ┆ 5.0 │
      │ two ┆ 3.0 │
      │ two ┆ 2.0 │
      │ one ┆ 4.0 │
      │ two ┆ 1.0 │
      └─────┴─────┘
      shape: (5, 2)
      groups: ProtoExprArray(
          [
              Expr(
                  Expr(
                      col("foo"),
                  ),
              ),
          ],
      )
      maintain order:  TRUE

# groupby print .name=POLARS_FMT_TABLE_HIDE_DATAFRAME_SHAPE_INFORMATION, .value=1

    Code
      gb
    Output
      ┌─────┬─────┐
      │ foo ┆ bar │
      │ --- ┆ --- │
      │ str ┆ f64 │
      ╞═════╪═════╡
      │ one ┆ 5.0 │
      │ two ┆ 3.0 │
      │ two ┆ 2.0 │
      │ one ┆ 4.0 │
      │ two ┆ 1.0 │
      └─────┴─────┘
      groups: ProtoExprArray(
          [
              Expr(
                  Expr(
                      col("foo"),
                  ),
              ),
          ],
      )
      maintain order:  TRUE

