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

# groupby print .name=POLARS_FMT_TABLE_CELL_ALIGNMENT, .value=RIGHT

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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_FULL

    Code
      gb
    Output
      shape: (5, 2)
      +-----+-----+
      | foo | bar |
      | --- | --- |
      | str | f64 |
      +===========+
      | one | 5.0 |
      |-----+-----|
      | two | 3.0 |
      |-----+-----|
      | two | 2.0 |
      |-----+-----|
      | one | 4.0 |
      |-----+-----|
      | two | 1.0 |
      +-----+-----+
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_FULL_CONDENSED

    Code
      gb
    Output
      shape: (5, 2)
      +-----+-----+
      | foo | bar |
      | --- | --- |
      | str | f64 |
      +===========+
      | one | 5.0 |
      | two | 3.0 |
      | two | 2.0 |
      | one | 4.0 |
      | two | 1.0 |
      +-----+-----+
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_NO_BORDERS

    Code
      gb
    Output
      shape: (5, 2)
       foo | bar 
       --- | --- 
       str | f64 
      ===========
       one | 5.0 
      -----+-----
       two | 3.0 
      -----+-----
       two | 2.0 
      -----+-----
       one | 4.0 
      -----+-----
       two | 1.0 
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_BORDERS_ONLY

    Code
      gb
    Output
      shape: (5, 2)
      +-----------+
      | foo   bar |
      | ---   --- |
      | str   f64 |
      +===========+
      | one   5.0 |
      |           |
      | two   3.0 |
      |           |
      | two   2.0 |
      |           |
      | one   4.0 |
      |           |
      | two   1.0 |
      +-----------+
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_BORDERS_ONLY_CONDENSED

    Code
      gb
    Output
      shape: (5, 2)
      +-----------+
      | foo   bar |
      | ---   --- |
      | str   f64 |
      +===========+
      | one   5.0 |
      | two   3.0 |
      | two   2.0 |
      | one   4.0 |
      | two   1.0 |
      +-----------+
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_HORIZONTAL_ONLY

    Code
      gb
    Output
      shape: (5, 2)
      -----------
       foo   bar 
       ---   --- 
       str   f64 
      ===========
       one   5.0 
      -----------
       two   3.0 
      -----------
       two   2.0 
      -----------
       one   4.0 
      -----------
       two   1.0 
      -----------
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_MARKDOWN

    Code
      gb
    Output
      shape: (5, 2)
      | foo | bar |
      | --- | --- |
      | str | f64 |
      |-----|-----|
      | one | 5.0 |
      | two | 3.0 |
      | two | 2.0 |
      | one | 4.0 |
      | two | 1.0 |
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=UTF8_FULL

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
      ├╌╌╌╌╌┼╌╌╌╌╌┤
      │ two ┆ 3.0 │
      ├╌╌╌╌╌┼╌╌╌╌╌┤
      │ two ┆ 2.0 │
      ├╌╌╌╌╌┼╌╌╌╌╌┤
      │ one ┆ 4.0 │
      ├╌╌╌╌╌┼╌╌╌╌╌┤
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=UTF8_FULL_CONDENSED

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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=UTF8_NO_BORDERS

    Code
      gb
    Output
      shape: (5, 2)
       foo ┆ bar 
       --- ┆ --- 
       str ┆ f64 
      ═════╪═════
       one ┆ 5.0 
      ╌╌╌╌╌┼╌╌╌╌╌
       two ┆ 3.0 
      ╌╌╌╌╌┼╌╌╌╌╌
       two ┆ 2.0 
      ╌╌╌╌╌┼╌╌╌╌╌
       one ┆ 4.0 
      ╌╌╌╌╌┼╌╌╌╌╌
       two ┆ 1.0 
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=UTF8_BORDERS_ONLY

    Code
      gb
    Output
      shape: (5, 2)
      ┌───────────┐
      │ foo   bar │
      │ ---   --- │
      │ str   f64 │
      ╞═══════════╡
      │ one   5.0 │
      │ two   3.0 │
      │ two   2.0 │
      │ one   4.0 │
      │ two   1.0 │
      └───────────┘
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=UTF8_HORIZONTAL_ONLY

    Code
      gb
    Output
      shape: (5, 2)
      ───────────
       foo   bar 
       ---   --- 
       str   f64 
      ═══════════
       one   5.0 
      ───────────
       two   3.0 
      ───────────
       two   2.0 
      ───────────
       one   4.0 
      ───────────
       two   1.0 
      ───────────
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

# groupby print .name=POLARS_FMT_TABLE_FORMATTING, .value=NOTHING

    Code
      gb
    Output
      shape: (5, 2)
       foo  bar 
       ---  --- 
       str  f64 
       one  5.0 
       two  3.0 
       two  2.0 
       one  4.0 
       two  1.0 
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

# groupby print .name=POLARS_FMT_TABLE_HIDE_COLUMN_DATA_TYPES, .value=1

    Code
      gb
    Output
      shape: (5, 2)
      ┌─────┬─────┐
      │ foo ┆ bar │
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

# groupby print .name=POLARS_FMT_TABLE_HIDE_COLUMN_NAMES, .value=1

    Code
      gb
    Output
      shape: (5, 2)
      ┌─────┬─────┐
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

# groupby print .name=POLARS_FMT_TABLE_HIDE_COLUMN_SEPARATOR, .value=1

    Code
      gb
    Output
      shape: (5, 2)
      ┌─────┬─────┐
      │ foo ┆ bar │
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

# groupby print .name=POLARS_FMT_MAX_ROWS, .value=2

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
      │ ... ┆ ... │
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

