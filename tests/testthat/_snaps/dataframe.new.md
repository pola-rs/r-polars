# DataFrame, mixed input, create and print .name=dummy, .value=dummy

    Code
      df
    Output
      shape: (5, 6)
      ┌─────────┬──────┬─────┬────────────┬──────────────┬──────────────┐
      │ newname ┆ a    ┆ b   ┆ new_column ┆ named_vector ┆ new_column_1 │
      │ ---     ┆ ---  ┆ --- ┆ ---        ┆ ---          ┆ ---          │
      │ f64     ┆ f64  ┆ str ┆ f64        ┆ f64          ┆ f64          │
      ╞═════════╪══════╪═════╪════════════╪══════════════╪══════════════╡
      │ 1.0     ┆ 5.0  ┆ a   ┆ 5.0        ┆ 15.0         ┆ 5.0          │
      │ 2.0     ┆ 10.0 ┆ b   ┆ 4.0        ┆ 14.0         ┆ 4.0          │
      │ 3.0     ┆ 15.0 ┆ c   ┆ 3.0        ┆ 13.0         ┆ 3.0          │
      │ 4.0     ┆ 20.0 ┆ d   ┆ 2.0        ┆ 12.0         ┆ 2.0          │
      │ 5.0     ┆ 25.0 ┆ e   ┆ 1.0        ┆ 11.0         ┆ 0.0          │
      └─────────┴──────┴─────┴────────────┴──────────────┴──────────────┘

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_CELL_ALIGNMENT, .value=RIGHT

    Code
      df
    Output
      shape: (5, 6)
      ┌─────────┬──────┬─────┬────────────┬──────────────┬──────────────┐
      │ newname ┆    a ┆   b ┆ new_column ┆ named_vector ┆ new_column_1 │
      │     --- ┆  --- ┆ --- ┆        --- ┆          --- ┆          --- │
      │     f64 ┆  f64 ┆ str ┆        f64 ┆          f64 ┆          f64 │
      ╞═════════╪══════╪═════╪════════════╪══════════════╪══════════════╡
      │     1.0 ┆  5.0 ┆   a ┆        5.0 ┆         15.0 ┆          5.0 │
      │     2.0 ┆ 10.0 ┆   b ┆        4.0 ┆         14.0 ┆          4.0 │
      │     3.0 ┆ 15.0 ┆   c ┆        3.0 ┆         13.0 ┆          3.0 │
      │     4.0 ┆ 20.0 ┆   d ┆        2.0 ┆         12.0 ┆          2.0 │
      │     5.0 ┆ 25.0 ┆   e ┆        1.0 ┆         11.0 ┆          0.0 │
      └─────────┴──────┴─────┴────────────┴──────────────┴──────────────┘

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_DATAFRAME_SHAPE_BELOW, .value=1

    Code
      df
    Output
      ┌─────────┬──────┬─────┬────────────┬──────────────┬──────────────┐
      │ newname ┆ a    ┆ b   ┆ new_column ┆ named_vector ┆ new_column_1 │
      │ ---     ┆ ---  ┆ --- ┆ ---        ┆ ---          ┆ ---          │
      │ f64     ┆ f64  ┆ str ┆ f64        ┆ f64          ┆ f64          │
      ╞═════════╪══════╪═════╪════════════╪══════════════╪══════════════╡
      │ 1.0     ┆ 5.0  ┆ a   ┆ 5.0        ┆ 15.0         ┆ 5.0          │
      │ 2.0     ┆ 10.0 ┆ b   ┆ 4.0        ┆ 14.0         ┆ 4.0          │
      │ 3.0     ┆ 15.0 ┆ c   ┆ 3.0        ┆ 13.0         ┆ 3.0          │
      │ 4.0     ┆ 20.0 ┆ d   ┆ 2.0        ┆ 12.0         ┆ 2.0          │
      │ 5.0     ┆ 25.0 ┆ e   ┆ 1.0        ┆ 11.0         ┆ 0.0          │
      └─────────┴──────┴─────┴────────────┴──────────────┴──────────────┘
      shape: (5, 6)

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_FULL

    Code
      df
    Output
      shape: (5, 6)
      +---------+------+-----+------------+--------------+--------------+
      | newname | a    | b   | new_column | named_vector | new_column_1 |
      | ---     | ---  | --- | ---        | ---          | ---          |
      | f64     | f64  | str | f64        | f64          | f64          |
      +=================================================================+
      | 1.0     | 5.0  | a   | 5.0        | 15.0         | 5.0          |
      |---------+------+-----+------------+--------------+--------------|
      | 2.0     | 10.0 | b   | 4.0        | 14.0         | 4.0          |
      |---------+------+-----+------------+--------------+--------------|
      | 3.0     | 15.0 | c   | 3.0        | 13.0         | 3.0          |
      |---------+------+-----+------------+--------------+--------------|
      | 4.0     | 20.0 | d   | 2.0        | 12.0         | 2.0          |
      |---------+------+-----+------------+--------------+--------------|
      | 5.0     | 25.0 | e   | 1.0        | 11.0         | 0.0          |
      +---------+------+-----+------------+--------------+--------------+

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_FULL_CONDENSED

    Code
      df
    Output
      shape: (5, 6)
      +---------+------+-----+------------+--------------+--------------+
      | newname | a    | b   | new_column | named_vector | new_column_1 |
      | ---     | ---  | --- | ---        | ---          | ---          |
      | f64     | f64  | str | f64        | f64          | f64          |
      +=================================================================+
      | 1.0     | 5.0  | a   | 5.0        | 15.0         | 5.0          |
      | 2.0     | 10.0 | b   | 4.0        | 14.0         | 4.0          |
      | 3.0     | 15.0 | c   | 3.0        | 13.0         | 3.0          |
      | 4.0     | 20.0 | d   | 2.0        | 12.0         | 2.0          |
      | 5.0     | 25.0 | e   | 1.0        | 11.0         | 0.0          |
      +---------+------+-----+------------+--------------+--------------+

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_NO_BORDERS

    Code
      df
    Output
      shape: (5, 6)
       newname | a    | b   | new_column | named_vector | new_column_1 
       ---     | ---  | --- | ---        | ---          | ---          
       f64     | f64  | str | f64        | f64          | f64          
      =================================================================
       1.0     | 5.0  | a   | 5.0        | 15.0         | 5.0          
      ---------+------+-----+------------+--------------+--------------
       2.0     | 10.0 | b   | 4.0        | 14.0         | 4.0          
      ---------+------+-----+------------+--------------+--------------
       3.0     | 15.0 | c   | 3.0        | 13.0         | 3.0          
      ---------+------+-----+------------+--------------+--------------
       4.0     | 20.0 | d   | 2.0        | 12.0         | 2.0          
      ---------+------+-----+------------+--------------+--------------
       5.0     | 25.0 | e   | 1.0        | 11.0         | 0.0          

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_BORDERS_ONLY

    Code
      df
    Output
      shape: (5, 6)
      +-----------------------------------------------------------------+
      | newname   a      b     new_column   named_vector   new_column_1 |
      | ---       ---    ---   ---          ---            ---          |
      | f64       f64    str   f64          f64            f64          |
      +=================================================================+
      | 1.0       5.0    a     5.0          15.0           5.0          |
      |                                                                 |
      | 2.0       10.0   b     4.0          14.0           4.0          |
      |                                                                 |
      | 3.0       15.0   c     3.0          13.0           3.0          |
      |                                                                 |
      | 4.0       20.0   d     2.0          12.0           2.0          |
      |                                                                 |
      | 5.0       25.0   e     1.0          11.0           0.0          |
      +-----------------------------------------------------------------+

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_BORDERS_ONLY_CONDENSED

    Code
      df
    Output
      shape: (5, 6)
      +-----------------------------------------------------------------+
      | newname   a      b     new_column   named_vector   new_column_1 |
      | ---       ---    ---   ---          ---            ---          |
      | f64       f64    str   f64          f64            f64          |
      +=================================================================+
      | 1.0       5.0    a     5.0          15.0           5.0          |
      | 2.0       10.0   b     4.0          14.0           4.0          |
      | 3.0       15.0   c     3.0          13.0           3.0          |
      | 4.0       20.0   d     2.0          12.0           2.0          |
      | 5.0       25.0   e     1.0          11.0           0.0          |
      +-----------------------------------------------------------------+

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_HORIZONTAL_ONLY

    Code
      df
    Output
      shape: (5, 6)
      -----------------------------------------------------------------
       newname   a      b     new_column   named_vector   new_column_1 
       ---       ---    ---   ---          ---            ---          
       f64       f64    str   f64          f64            f64          
      =================================================================
       1.0       5.0    a     5.0          15.0           5.0          
      -----------------------------------------------------------------
       2.0       10.0   b     4.0          14.0           4.0          
      -----------------------------------------------------------------
       3.0       15.0   c     3.0          13.0           3.0          
      -----------------------------------------------------------------
       4.0       20.0   d     2.0          12.0           2.0          
      -----------------------------------------------------------------
       5.0       25.0   e     1.0          11.0           0.0          
      -----------------------------------------------------------------

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=ASCII_MARKDOWN

    Code
      df
    Output
      shape: (5, 6)
      | newname | a    | b   | new_column | named_vector | new_column_1 |
      | ---     | ---  | --- | ---        | ---          | ---          |
      | f64     | f64  | str | f64        | f64          | f64          |
      |---------|------|-----|------------|--------------|--------------|
      | 1.0     | 5.0  | a   | 5.0        | 15.0         | 5.0          |
      | 2.0     | 10.0 | b   | 4.0        | 14.0         | 4.0          |
      | 3.0     | 15.0 | c   | 3.0        | 13.0         | 3.0          |
      | 4.0     | 20.0 | d   | 2.0        | 12.0         | 2.0          |
      | 5.0     | 25.0 | e   | 1.0        | 11.0         | 0.0          |

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=UTF8_FULL

    Code
      df
    Output
      shape: (5, 6)
      ┌─────────┬──────┬─────┬────────────┬──────────────┬──────────────┐
      │ newname ┆ a    ┆ b   ┆ new_column ┆ named_vector ┆ new_column_1 │
      │ ---     ┆ ---  ┆ --- ┆ ---        ┆ ---          ┆ ---          │
      │ f64     ┆ f64  ┆ str ┆ f64        ┆ f64          ┆ f64          │
      ╞═════════╪══════╪═════╪════════════╪══════════════╪══════════════╡
      │ 1.0     ┆ 5.0  ┆ a   ┆ 5.0        ┆ 15.0         ┆ 5.0          │
      ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤
      │ 2.0     ┆ 10.0 ┆ b   ┆ 4.0        ┆ 14.0         ┆ 4.0          │
      ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤
      │ 3.0     ┆ 15.0 ┆ c   ┆ 3.0        ┆ 13.0         ┆ 3.0          │
      ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤
      │ 4.0     ┆ 20.0 ┆ d   ┆ 2.0        ┆ 12.0         ┆ 2.0          │
      ├╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┤
      │ 5.0     ┆ 25.0 ┆ e   ┆ 1.0        ┆ 11.0         ┆ 0.0          │
      └─────────┴──────┴─────┴────────────┴──────────────┴──────────────┘

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=UTF8_FULL_CONDENSED

    Code
      df
    Output
      shape: (5, 6)
      ┌─────────┬──────┬─────┬────────────┬──────────────┬──────────────┐
      │ newname ┆ a    ┆ b   ┆ new_column ┆ named_vector ┆ new_column_1 │
      │ ---     ┆ ---  ┆ --- ┆ ---        ┆ ---          ┆ ---          │
      │ f64     ┆ f64  ┆ str ┆ f64        ┆ f64          ┆ f64          │
      ╞═════════╪══════╪═════╪════════════╪══════════════╪══════════════╡
      │ 1.0     ┆ 5.0  ┆ a   ┆ 5.0        ┆ 15.0         ┆ 5.0          │
      │ 2.0     ┆ 10.0 ┆ b   ┆ 4.0        ┆ 14.0         ┆ 4.0          │
      │ 3.0     ┆ 15.0 ┆ c   ┆ 3.0        ┆ 13.0         ┆ 3.0          │
      │ 4.0     ┆ 20.0 ┆ d   ┆ 2.0        ┆ 12.0         ┆ 2.0          │
      │ 5.0     ┆ 25.0 ┆ e   ┆ 1.0        ┆ 11.0         ┆ 0.0          │
      └─────────┴──────┴─────┴────────────┴──────────────┴──────────────┘

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=UTF8_NO_BORDERS

    Code
      df
    Output
      shape: (5, 6)
       newname ┆ a    ┆ b   ┆ new_column ┆ named_vector ┆ new_column_1 
       ---     ┆ ---  ┆ --- ┆ ---        ┆ ---          ┆ ---          
       f64     ┆ f64  ┆ str ┆ f64        ┆ f64          ┆ f64          
      ═════════╪══════╪═════╪════════════╪══════════════╪══════════════
       1.0     ┆ 5.0  ┆ a   ┆ 5.0        ┆ 15.0         ┆ 5.0          
      ╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌
       2.0     ┆ 10.0 ┆ b   ┆ 4.0        ┆ 14.0         ┆ 4.0          
      ╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌
       3.0     ┆ 15.0 ┆ c   ┆ 3.0        ┆ 13.0         ┆ 3.0          
      ╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌
       4.0     ┆ 20.0 ┆ d   ┆ 2.0        ┆ 12.0         ┆ 2.0          
      ╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌┼╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌╌╌╌╌╌╌
       5.0     ┆ 25.0 ┆ e   ┆ 1.0        ┆ 11.0         ┆ 0.0          

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=UTF8_BORDERS_ONLY

    Code
      df
    Output
      shape: (5, 6)
      ┌─────────────────────────────────────────────────────────────────┐
      │ newname   a      b     new_column   named_vector   new_column_1 │
      │ ---       ---    ---   ---          ---            ---          │
      │ f64       f64    str   f64          f64            f64          │
      ╞═════════════════════════════════════════════════════════════════╡
      │ 1.0       5.0    a     5.0          15.0           5.0          │
      │ 2.0       10.0   b     4.0          14.0           4.0          │
      │ 3.0       15.0   c     3.0          13.0           3.0          │
      │ 4.0       20.0   d     2.0          12.0           2.0          │
      │ 5.0       25.0   e     1.0          11.0           0.0          │
      └─────────────────────────────────────────────────────────────────┘

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=UTF8_HORIZONTAL_ONLY

    Code
      df
    Output
      shape: (5, 6)
      ─────────────────────────────────────────────────────────────────
       newname   a      b     new_column   named_vector   new_column_1 
       ---       ---    ---   ---          ---            ---          
       f64       f64    str   f64          f64            f64          
      ═════════════════════════════════════════════════════════════════
       1.0       5.0    a     5.0          15.0           5.0          
      ─────────────────────────────────────────────────────────────────
       2.0       10.0   b     4.0          14.0           4.0          
      ─────────────────────────────────────────────────────────────────
       3.0       15.0   c     3.0          13.0           3.0          
      ─────────────────────────────────────────────────────────────────
       4.0       20.0   d     2.0          12.0           2.0          
      ─────────────────────────────────────────────────────────────────
       5.0       25.0   e     1.0          11.0           0.0          
      ─────────────────────────────────────────────────────────────────

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_FORMATTING, .value=NOTHING

    Code
      df
    Output
      shape: (5, 6)
       newname  a     b    new_column  named_vector  new_column_1 
       ---      ---   ---  ---         ---           ---          
       f64      f64   str  f64         f64           f64          
       1.0      5.0   a    5.0         15.0          5.0          
       2.0      10.0  b    4.0         14.0          4.0          
       3.0      15.0  c    3.0         13.0          3.0          
       4.0      20.0  d    2.0         12.0          2.0          
       5.0      25.0  e    1.0         11.0          0.0          

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_HIDE_COLUMN_DATA_TYPES, .value=1

    Code
      df
    Output
      shape: (5, 6)
      ┌─────────┬──────┬───┬────────────┬──────────────┬──────────────┐
      │ newname ┆ a    ┆ b ┆ new_column ┆ named_vector ┆ new_column_1 │
      ╞═════════╪══════╪═══╪════════════╪══════════════╪══════════════╡
      │ 1.0     ┆ 5.0  ┆ a ┆ 5.0        ┆ 15.0         ┆ 5.0          │
      │ 2.0     ┆ 10.0 ┆ b ┆ 4.0        ┆ 14.0         ┆ 4.0          │
      │ 3.0     ┆ 15.0 ┆ c ┆ 3.0        ┆ 13.0         ┆ 3.0          │
      │ 4.0     ┆ 20.0 ┆ d ┆ 2.0        ┆ 12.0         ┆ 2.0          │
      │ 5.0     ┆ 25.0 ┆ e ┆ 1.0        ┆ 11.0         ┆ 0.0          │
      └─────────┴──────┴───┴────────────┴──────────────┴──────────────┘

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_HIDE_COLUMN_NAMES, .value=1

    Code
      df
    Output
      shape: (5, 6)
      ┌─────┬──────┬─────┬─────┬──────┬─────┐
      │ f64 ┆ f64  ┆ str ┆ f64 ┆ f64  ┆ f64 │
      ╞═════╪══════╪═════╪═════╪══════╪═════╡
      │ 1.0 ┆ 5.0  ┆ a   ┆ 5.0 ┆ 15.0 ┆ 5.0 │
      │ 2.0 ┆ 10.0 ┆ b   ┆ 4.0 ┆ 14.0 ┆ 4.0 │
      │ 3.0 ┆ 15.0 ┆ c   ┆ 3.0 ┆ 13.0 ┆ 3.0 │
      │ 4.0 ┆ 20.0 ┆ d   ┆ 2.0 ┆ 12.0 ┆ 2.0 │
      │ 5.0 ┆ 25.0 ┆ e   ┆ 1.0 ┆ 11.0 ┆ 0.0 │
      └─────┴──────┴─────┴─────┴──────┴─────┘

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_HIDE_COLUMN_SEPARATOR, .value=1

    Code
      df
    Output
      shape: (5, 6)
      ┌─────────┬──────┬─────┬────────────┬──────────────┬──────────────┐
      │ newname ┆ a    ┆ b   ┆ new_column ┆ named_vector ┆ new_column_1 │
      │ f64     ┆ f64  ┆ str ┆ f64        ┆ f64          ┆ f64          │
      ╞═════════╪══════╪═════╪════════════╪══════════════╪══════════════╡
      │ 1.0     ┆ 5.0  ┆ a   ┆ 5.0        ┆ 15.0         ┆ 5.0          │
      │ 2.0     ┆ 10.0 ┆ b   ┆ 4.0        ┆ 14.0         ┆ 4.0          │
      │ 3.0     ┆ 15.0 ┆ c   ┆ 3.0        ┆ 13.0         ┆ 3.0          │
      │ 4.0     ┆ 20.0 ┆ d   ┆ 2.0        ┆ 12.0         ┆ 2.0          │
      │ 5.0     ┆ 25.0 ┆ e   ┆ 1.0        ┆ 11.0         ┆ 0.0          │
      └─────────┴──────┴─────┴────────────┴──────────────┴──────────────┘

# DataFrame, mixed input, create and print .name=POLARS_FMT_TABLE_HIDE_DATAFRAME_SHAPE_INFORMATION, .value=1

    Code
      df
    Output
      ┌─────────┬──────┬─────┬────────────┬──────────────┬──────────────┐
      │ newname ┆ a    ┆ b   ┆ new_column ┆ named_vector ┆ new_column_1 │
      │ ---     ┆ ---  ┆ --- ┆ ---        ┆ ---          ┆ ---          │
      │ f64     ┆ f64  ┆ str ┆ f64        ┆ f64          ┆ f64          │
      ╞═════════╪══════╪═════╪════════════╪══════════════╪══════════════╡
      │ 1.0     ┆ 5.0  ┆ a   ┆ 5.0        ┆ 15.0         ┆ 5.0          │
      │ 2.0     ┆ 10.0 ┆ b   ┆ 4.0        ┆ 14.0         ┆ 4.0          │
      │ 3.0     ┆ 15.0 ┆ c   ┆ 3.0        ┆ 13.0         ┆ 3.0          │
      │ 4.0     ┆ 20.0 ┆ d   ┆ 2.0        ┆ 12.0         ┆ 2.0          │
      │ 5.0     ┆ 25.0 ┆ e   ┆ 1.0        ┆ 11.0         ┆ 0.0          │
      └─────────┴──────┴─────┴────────────┴──────────────┴──────────────┘

# DataFrame, mixed input, create and print .name=POLARS_FMT_MAX_ROWS, .value=2

    Code
      df
    Output
      shape: (5, 6)
      ┌─────────┬──────┬─────┬────────────┬──────────────┬──────────────┐
      │ newname ┆ a    ┆ b   ┆ new_column ┆ named_vector ┆ new_column_1 │
      │ ---     ┆ ---  ┆ --- ┆ ---        ┆ ---          ┆ ---          │
      │ f64     ┆ f64  ┆ str ┆ f64        ┆ f64          ┆ f64          │
      ╞═════════╪══════╪═════╪════════════╪══════════════╪══════════════╡
      │ 1.0     ┆ 5.0  ┆ a   ┆ 5.0        ┆ 15.0         ┆ 5.0          │
      │ …       ┆ …    ┆ …   ┆ …          ┆ …            ┆ …            │
      │ 5.0     ┆ 25.0 ┆ e   ┆ 1.0        ┆ 11.0         ┆ 0.0          │
      └─────────┴──────┴─────┴────────────┴──────────────┴──────────────┘

# describe

    Code
      df$describe()
    Output
      shape: (9, 5)
      ┌────────────┬────────┬────────────┬──────┬───────┐
      │ statistic  ┆ string ┆ date       ┆ cat  ┆ bool  │
      │ ---        ┆ ---    ┆ ---        ┆ ---  ┆ ---   │
      │ str        ┆ str    ┆ str        ┆ str  ┆ str   │
      ╞════════════╪════════╪════════════╪══════╪═══════╡
      │ count      ┆ 2      ┆ 2          ┆ 2    ┆ 2     │
      │ null_count ┆ 1      ┆ 1          ┆ 1    ┆ 1     │
      │ mean       ┆ null   ┆ null       ┆ null ┆ null  │
      │ std        ┆ null   ┆ null       ┆ null ┆ null  │
      │ min        ┆ a      ┆ 2024-01-20 ┆ zz   ┆ false │
      │ 25%        ┆ null   ┆ null       ┆ null ┆ null  │
      │ 50%        ┆ null   ┆ null       ┆ null ┆ null  │
      │ 75%        ┆ null   ┆ null       ┆ null ┆ null  │
      │ max        ┆ b      ┆ 2024-01-21 ┆ a    ┆ true  │
      └────────────┴────────┴────────────┴──────┴───────┘

---

    Code
      pl$DataFrame(mtcars)$describe()
    Output
      shape: (9, 12)
      ┌────────┬───────┬───────┬───────┬───┬───────┬───────┬───────┬───────┐
      │ statis ┆ mpg   ┆ cyl   ┆ disp  ┆ … ┆ vs    ┆ am    ┆ gear  ┆ carb  │
      │ tic    ┆ ---   ┆ ---   ┆ ---   ┆   ┆ ---   ┆ ---   ┆ ---   ┆ ---   │
      │ ---    ┆ f64   ┆ f64   ┆ f64   ┆   ┆ f64   ┆ f64   ┆ f64   ┆ f64   │
      │ str    ┆       ┆       ┆       ┆   ┆       ┆       ┆       ┆       │
      ╞════════╪═══════╪═══════╪═══════╪═══╪═══════╪═══════╪═══════╪═══════╡
      │ count  ┆ 32.0  ┆ 32.0  ┆ 32.0  ┆ … ┆ 32.0  ┆ 32.0  ┆ 32.0  ┆ 32.0  │
      │ null_c ┆ 0.0   ┆ 0.0   ┆ 0.0   ┆ … ┆ 0.0   ┆ 0.0   ┆ 0.0   ┆ 0.0   │
      │ ount   ┆       ┆       ┆       ┆   ┆       ┆       ┆       ┆       │
      │ mean   ┆ 20.09 ┆ 6.187 ┆ 230.7 ┆ … ┆ 0.437 ┆ 0.406 ┆ 3.687 ┆ 2.812 │
      │        ┆ 0625  ┆ 5     ┆ 21875 ┆   ┆ 5     ┆ 25    ┆ 5     ┆ 5     │
      │ std    ┆ 6.026 ┆ 1.785 ┆ 123.9 ┆ … ┆ 0.504 ┆ 0.498 ┆ 0.737 ┆ 1.615 │
      │        ┆ 948   ┆ 922   ┆ 38694 ┆   ┆ 016   ┆ 991   ┆ 804   ┆ 2     │
      │ min    ┆ 10.4  ┆ 4.0   ┆ 71.1  ┆ … ┆ 0.0   ┆ 0.0   ┆ 3.0   ┆ 1.0   │
      │ 25%    ┆ 15.5  ┆ 4.0   ┆ 121.0 ┆ … ┆ 0.0   ┆ 0.0   ┆ 3.0   ┆ 2.0   │
      │ 50%    ┆ 19.2  ┆ 6.0   ┆ 225.0 ┆ … ┆ 0.0   ┆ 0.0   ┆ 4.0   ┆ 2.0   │
      │ 75%    ┆ 22.8  ┆ 8.0   ┆ 318.0 ┆ … ┆ 1.0   ┆ 1.0   ┆ 4.0   ┆ 4.0   │
      │ max    ┆ 33.9  ┆ 8.0   ┆ 472.0 ┆ … ┆ 1.0   ┆ 1.0   ┆ 5.0   ┆ 8.0   │
      └────────┴───────┴───────┴───────┴───┴───────┴───────┴───────┴───────┘

---

    Code
      pl$DataFrame(mtcars)$describe(interpolation = "linear")
    Output
      shape: (9, 12)
      ┌────────┬───────┬───────┬───────┬───┬───────┬───────┬───────┬───────┐
      │ statis ┆ mpg   ┆ cyl   ┆ disp  ┆ … ┆ vs    ┆ am    ┆ gear  ┆ carb  │
      │ tic    ┆ ---   ┆ ---   ┆ ---   ┆   ┆ ---   ┆ ---   ┆ ---   ┆ ---   │
      │ ---    ┆ f64   ┆ f64   ┆ f64   ┆   ┆ f64   ┆ f64   ┆ f64   ┆ f64   │
      │ str    ┆       ┆       ┆       ┆   ┆       ┆       ┆       ┆       │
      ╞════════╪═══════╪═══════╪═══════╪═══╪═══════╪═══════╪═══════╪═══════╡
      │ count  ┆ 32.0  ┆ 32.0  ┆ 32.0  ┆ … ┆ 32.0  ┆ 32.0  ┆ 32.0  ┆ 32.0  │
      │ null_c ┆ 0.0   ┆ 0.0   ┆ 0.0   ┆ … ┆ 0.0   ┆ 0.0   ┆ 0.0   ┆ 0.0   │
      │ ount   ┆       ┆       ┆       ┆   ┆       ┆       ┆       ┆       │
      │ mean   ┆ 20.09 ┆ 6.187 ┆ 230.7 ┆ … ┆ 0.437 ┆ 0.406 ┆ 3.687 ┆ 2.812 │
      │        ┆ 0625  ┆ 5     ┆ 21875 ┆   ┆ 5     ┆ 25    ┆ 5     ┆ 5     │
      │ std    ┆ 6.026 ┆ 1.785 ┆ 123.9 ┆ … ┆ 0.504 ┆ 0.498 ┆ 0.737 ┆ 1.615 │
      │        ┆ 948   ┆ 922   ┆ 38694 ┆   ┆ 016   ┆ 991   ┆ 804   ┆ 2     │
      │ min    ┆ 10.4  ┆ 4.0   ┆ 71.1  ┆ … ┆ 0.0   ┆ 0.0   ┆ 3.0   ┆ 1.0   │
      │ 25%    ┆ 15.42 ┆ 4.0   ┆ 120.8 ┆ … ┆ 0.0   ┆ 0.0   ┆ 3.0   ┆ 2.0   │
      │        ┆ 5     ┆       ┆ 25    ┆   ┆       ┆       ┆       ┆       │
      │ 50%    ┆ 19.2  ┆ 6.0   ┆ 196.3 ┆ … ┆ 0.0   ┆ 0.0   ┆ 4.0   ┆ 2.0   │
      │ 75%    ┆ 22.8  ┆ 8.0   ┆ 326.0 ┆ … ┆ 1.0   ┆ 1.0   ┆ 4.0   ┆ 4.0   │
      │ max    ┆ 33.9  ┆ 8.0   ┆ 472.0 ┆ … ┆ 1.0   ┆ 1.0   ┆ 5.0   ┆ 8.0   │
      └────────┴───────┴───────┴───────┴───┴───────┴───────┴───────┴───────┘

---

    Code
      df$select(pl$col("cat")$cast(pl$Categorical("lexical")))$describe()
    Output
      shape: (9, 2)
      ┌────────────┬──────┐
      │ statistic  ┆ cat  │
      │ ---        ┆ ---  │
      │ str        ┆ str  │
      ╞════════════╪══════╡
      │ count      ┆ 2    │
      │ null_count ┆ 1    │
      │ mean       ┆ null │
      │ std        ┆ null │
      │ min        ┆ a    │
      │ 25%        ┆ null │
      │ 50%        ┆ null │
      │ 75%        ┆ null │
      │ max        ┆ zz   │
      └────────────┴──────┘

# $glimpse() works

    Code
      df$glimpse()
    Output
      & mpg     <f64> 21, 21, 22.8, 21.4, 18.7, 18.1, 14.3, 24.4, 22.8, 19.2
      & cyl     <f64> 6, 6, 4, 6, 8, 6, 8, 4, 4, 6
      & disp    <f64> 160, 160, 108, 258, 360, 225, 360, 146.7, 140.8, 167.6
      & hp      <f64> 110, 110, 93, 110, 175, 105, 245, 62, 95, 123
      & drat    <f64> 3.9, 3.9, 3.85, 3.08, 3.15, 2.76, 3.21, 3.69, 3.92, 3.92
      & wt      <f64> 2.62, 2.875, 2.32, 3.215, 3.44, 3.46, 3.57, 3.19, 3.15, 3.44
      & qsec    <f64> 16.46, 17.02, 18.61, 19.44, 17.02, 20.22, 15.84, 20, 22.9, 18.3
      & vs      <f64> 0, 0, 1, 1, 0, 1, 0, 1, 1, 1
      & am      <f64> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0
      & gear    <f64> 4, 4, 4, 3, 3, 3, 3, 4, 4, 4
      & carb    <f64> 4, 4, 1, 1, 2, 1, 4, 2, 2, 4
      & literal <i8>  42, 42, 42, 42, 42, 42, 42, 42, 42, 42

---

    Code
      df$glimpse(max_items_per_column = 2)
    Output
      & mpg     <f64> 21, 21
      & cyl     <f64> 6, 6
      & disp    <f64> 160, 160
      & hp      <f64> 110, 110
      & drat    <f64> 3.9, 3.9
      & wt      <f64> 2.62, 2.875
      & qsec    <f64> 16.46, 17.02
      & vs      <f64> 0, 0
      & am      <f64> 1, 1
      & gear    <f64> 4, 4
      & carb    <f64> 4, 4
      & literal <i8>  42, 42

---

    Code
      df$glimpse(max_colname_length = 2)
    Output
      & ... <f64> 21, 21, 22.8, 21.4, 18.7, 18.1, 14.3, 24.4, 22.8, 19.2
      & ... <f64> 6, 6, 4, 6, 8, 6, 8, 4, 4, 6
      & ... <f64> 160, 160, 108, 258, 360, 225, 360, 146.7, 140.8, 167.6
      & hp  <f64> 110, 110, 93, 110, 175, 105, 245, 62, 95, 123
      & ... <f64> 3.9, 3.9, 3.85, 3.08, 3.15, 2.76, 3.21, 3.69, 3.92, 3.92
      & wt  <f64> 2.62, 2.875, 2.32, 3.215, 3.44, 3.46, 3.57, 3.19, 3.15, 3.44
      & ... <f64> 16.46, 17.02, 18.61, 19.44, 17.02, 20.22, 15.84, 20, 22.9, 18.3
      & vs  <f64> 0, 0, 1, 1, 0, 1, 0, 1, 1, 1
      & am  <f64> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0
      & ... <f64> 4, 4, 4, 3, 3, 3, 3, 4, 4, 4
      & ... <f64> 4, 4, 1, 1, 2, 1, 4, 2, 2, 4
      & ... <i8>  42, 42, 42, 42, 42, 42, 42, 42, 42, 42
