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
      ┌─────┬─────┬─────┬────────┬──────┬──────┬────────┬────────┬────────┬───────┬───────┬───────┬──────┐
      │ int ┆ flo ┆ dec ┆ string ┆ cat  ┆ enum ┆ list   ┆ arr    ┆ struct ┆ date  ┆ datet ┆ time  ┆ null │
      │ --- ┆ at  ┆ ima ┆ ---    ┆ ---  ┆ ---  ┆ ---    ┆ ---    ┆ ---    ┆ ---   ┆ ime   ┆ ---   ┆ ---  │
      │ i32 ┆ --- ┆ l   ┆ str    ┆ cat  ┆ enum ┆ list[f ┆ array[ ┆ struct ┆ date  ┆ ---   ┆ time  ┆ null │
      │     ┆ f64 ┆ --- ┆        ┆      ┆      ┆ 64]    ┆ f64,   ┆ [0]    ┆       ┆ datet ┆       ┆      │
      │     ┆     ┆ dec ┆        ┆      ┆      ┆        ┆ 2]     ┆        ┆       ┆ ime[μ ┆       ┆      │
      │     ┆     ┆ ima ┆        ┆      ┆      ┆        ┆        ┆        ┆       ┆ s]    ┆       ┆      │
      │     ┆     ┆ l[3 ┆        ┆      ┆      ┆        ┆        ┆        ┆       ┆       ┆       ┆      │
      │     ┆     ┆ 8,0 ┆        ┆      ┆      ┆        ┆        ┆        ┆       ┆       ┆       ┆      │
      │     ┆     ┆ ]   ┆        ┆      ┆      ┆        ┆        ┆        ┆       ┆       ┆       ┆      │
      ╞═════╪═════╪═════╪════════╪══════╪══════╪════════╪════════╪════════╪═══════╪═══════╪═══════╪══════╡
      │ 0   ┆ 0.0 ┆ 0   ┆        ┆ null ┆ a    ┆ []     ┆ [0.0,  ┆ {}     ┆ 1970- ┆ 1970- ┆ 00:00 ┆ null │
      │     ┆     ┆     ┆        ┆      ┆      ┆        ┆ 0.0]   ┆        ┆ 01-01 ┆ 01-01 ┆ :00   ┆      │
      │     ┆     ┆     ┆        ┆      ┆      ┆        ┆        ┆        ┆       ┆ 00:00 ┆       ┆      │
      │     ┆     ┆     ┆        ┆      ┆      ┆        ┆        ┆        ┆       ┆ :00   ┆       ┆      │
      └─────┴─────┴─────┴────────┴──────┴──────┴────────┴────────┴────────┴───────┴───────┴───────┴──────┘

# $wrap_in_list() works

    Code
      df$select(a_wrapped = pl$dtype_of("a")$wrap_in_list()$display(), b_wrapped = pl$
        dtype_of("b")$wrap_in_list()$display(), c_wrapped = pl$dtype_of("c")$
        wrap_in_list()$display())
    Output
      shape: (1, 3)
      ┌───────────┬─────────────────┬─────────────────┐
      │ a_wrapped ┆ b_wrapped       ┆ c_wrapped       │
      │ ---       ┆ ---             ┆ ---             │
      │ str       ┆ str             ┆ str             │
      ╞═══════════╪═════════════════╪═════════════════╡
      │ list[i32] ┆ list[list[str]] ┆ list[struct[2]] │
      └───────────┴─────────────────┴─────────────────┘

# $wrap_in_array() works

    Code
      df$select(a_wrapped = pl$dtype_of("a")$wrap_in_array(width = 1)$display(),
      b_wrapped = pl$dtype_of("b")$wrap_in_array(width = 1)$display(), c_wrapped = pl$
        dtype_of("c")$wrap_in_array(width = 1)$display())
    Output
      shape: (1, 3)
      ┌───────────────┬─────────────────────┬─────────────────────┐
      │ a_wrapped     ┆ b_wrapped           ┆ c_wrapped           │
      │ ---           ┆ ---                 ┆ ---                 │
      │ str           ┆ str                 ┆ str                 │
      ╞═══════════════╪═════════════════════╪═════════════════════╡
      │ array[i32, 1] ┆ array[list[str], 1] ┆ array[struct[2], 1] │
      └───────────────┴─────────────────────┴─────────────────────┘

---

    Code
      df$select(a_wrapped = pl$dtype_of("a")$wrap_in_array(foo, width = 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$wrap_in_array()`.
      Caused by error:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = foo
      i Did you forget to name an argument?

---

    Code
      df$select(a_wrapped = pl$dtype_of("a")$wrap_in_array(width = -1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$wrap_in_array()`.
      Caused by error:
      ! -1.0 is out of range that can be safely converted to usize

---

    Code
      df$select(a_wrapped = pl$dtype_of("a")$wrap_in_array(width = "a"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$wrap_in_array()`.
      Caused by error:
      ! Argument `width` must be numeric, not character

