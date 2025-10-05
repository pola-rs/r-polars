# $display() for datatype_expr works

    Code
      df$select(int = pl$dtype_of("int")$display(), float = pl$dtype_of("float")$
        display(), decimal = pl$dtype_of("decimal")$display(), string = pl$dtype_of(
        "string")$display(), cat = pl$dtype_of("cat")$display(), enum = pl$dtype_of(
        "enum")$display(), list = pl$dtype_of("list")$display(), arr = pl$dtype_of(
        "arr")$display(), struct = pl$dtype_of("struct")$display(), date = pl$
      dtype_of("date")$display(), datetime = pl$dtype_of("datetime")$display(), time = pl$
        dtype_of("time")$display(), )$transpose(include_header = TRUE)
    Output
      shape: (12, 2)
      ┌──────────┬───────────────┐
      │ column   ┆ column_0      │
      │ ---      ┆ ---           │
      │ str      ┆ str           │
      ╞══════════╪═══════════════╡
      │ int      ┆ i32           │
      │ float    ┆ f64           │
      │ decimal  ┆ decimal[38,0] │
      │ string   ┆ str           │
      │ cat      ┆ cat           │
      │ enum     ┆ enum          │
      │ list     ┆ list[f64]     │
      │ arr      ┆ array[f64, 1] │
      │ struct   ┆ struct[1]     │
      │ date     ┆ date          │
      │ datetime ┆ datetime[ms]  │
      │ time     ┆ time          │
      └──────────┴───────────────┘

# $inner_dtype() for datatype_expr works

    Code
      df$select(a_inner_dtype = pl$dtype_of("a")$inner_dtype()$display(),
      b_inner_dtype = pl$dtype_of("b")$inner_dtype()$display(), c_inner_dtype = pl$
        dtype_of("c")$inner_dtype()$display())
    Output
      shape: (1, 3)
      ┌───────────────┬───────────────┬───────────────┐
      │ a_inner_dtype ┆ b_inner_dtype ┆ c_inner_dtype │
      │ ---           ┆ ---           ┆ ---           │
      │ str           ┆ str           ┆ str           │
      ╞═══════════════╪═══════════════╪═══════════════╡
      │ i32           ┆ list[str]     ┆ struct[2]     │
      └───────────────┴───────────────┴───────────────┘

# $default_value(): basic behavior works

    Code
      df
    Output
      shape: (1, 13)
      ┌─────┬───────┬───────────────┬────────┬──────┬──────┬───────────┬───────────────┬───────────┬────────────┬─────────────────────┬──────────┬──────┐
      │ int ┆ float ┆ decimal       ┆ string ┆ cat  ┆ enum ┆ list      ┆ arr           ┆ struct    ┆ date       ┆ datetime            ┆ time     ┆ null │
      │ --- ┆ ---   ┆ ---           ┆ ---    ┆ ---  ┆ ---  ┆ ---       ┆ ---           ┆ ---       ┆ ---        ┆ ---                 ┆ ---      ┆ ---  │
      │ i32 ┆ f64   ┆ decimal[38,0] ┆ str    ┆ cat  ┆ enum ┆ list[f64] ┆ array[f64, 2] ┆ struct[0] ┆ date       ┆ datetime[μs]        ┆ time     ┆ null │
      ╞═════╪═══════╪═══════════════╪════════╪══════╪══════╪═══════════╪═══════════════╪═══════════╪════════════╪═════════════════════╪══════════╪══════╡
      │ 0   ┆ 0.0   ┆ 0             ┆        ┆ null ┆ a    ┆ []        ┆ [0.0, 0.0]    ┆ {}        ┆ 1970-01-01 ┆ 1970-01-01 00:00:00 ┆ 00:00:00 ┆ null │
      └─────┴───────┴───────────────┴────────┴──────┴──────┴───────────┴───────────────┴───────────┴────────────┴─────────────────────┴──────────┴──────┘

