# sink_batches works engine=streaming

    Code
      lf$sink_batches(print, chunk_size = 3, maintain_order = TRUE, engine = engine)
    Output
      shape: (3, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      │ 3   │
      └─────┘
      shape: (3, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 4   │
      │ 5   │
      │ 6   │
      └─────┘
      shape: (3, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 7   │
      │ 8   │
      │ 9   │
      └─────┘
      shape: (1, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 10  │
      └─────┘

---

    Code
      lf$sink_batches(function(df) {
        print(df)
        max(df[["seq"]])$to_r_vector() > 4
      }, chunk_size = 3, maintain_order = TRUE, engine = engine)
    Output
      shape: (3, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      │ 3   │
      └─────┘
      shape: (3, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 4   │
      │ 5   │
      │ 6   │
      └─────┘

# sink_batches works engine=in-memory

    Code
      lf$sink_batches(print, chunk_size = 3, maintain_order = TRUE, engine = engine)
    Output
      shape: (3, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      │ 3   │
      └─────┘
      shape: (3, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 4   │
      │ 5   │
      │ 6   │
      └─────┘
      shape: (3, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 7   │
      │ 8   │
      │ 9   │
      └─────┘
      shape: (1, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 10  │
      └─────┘

---

    Code
      lf$sink_batches(function(df) {
        print(df)
        max(df[["seq"]])$to_r_vector() > 4
      }, chunk_size = 3, maintain_order = TRUE, engine = engine)
    Output
      shape: (3, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      │ 3   │
      └─────┘
      shape: (3, 1)
      ┌─────┐
      │ seq │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 4   │
      │ 5   │
      │ 6   │
      └─────┘

# lazy_sink_batches works

    Code
      cat(lf$explain())
    Output
      SINK (callback)
        DF ["mpg", "cyl", "disp", "hp", ...]; PROJECT */11 COLUMNS

---

    Code
      lf$collect()
    Output
      Callback
      Callback
      Callback
      Callback
      shape: (0, 0)
      ┌┐
      ╞╡
      └┘

