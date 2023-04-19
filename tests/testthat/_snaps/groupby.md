# groupby

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

---

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

---

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

