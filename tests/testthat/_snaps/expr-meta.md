# meta$eq meta$ne

    Code
      e2$meta$eq(complex(1))
    Condition
      Error in `e2$meta$eq()`:
      ! Evaluation failed in `$eq()`.
      Caused by error in `as_polars_expr()`:
      ! Evaluation failed.
      Caused by error in `as_polars_series()`:
      ! the complex number 0+0i can't be converted to a polars Series.

# meta$output_name

    Code
      pl$all()$meta$output_name()
    Condition
      Error in `pl$all()$meta$output_name()`:
      ! Evaluation failed in `$output_name()`.
      Caused by error:
      ! cannot determine output column without a context for this expression

---

    Code
      pl$all()$name$suffix("_")$meta$output_name()
    Condition
      Error in `pl$all()$name$suffix("_")$meta$output_name()`:
      ! Evaluation failed in `$output_name()`.
      Caused by error:
      ! cannot determine output column without a context for this expression

# meta$tree_format

    Code
      cat(e$meta$tree_format())
    Output
                  0             1              2             3
         ┌──────────────────────────────────────────────────────────
         │
         │  ╭───────────╮
       0 │  │ binary: / │
         │  ╰─────┬┬────╯
         │        ││
         │        │╰────────────╮
         │        │             │
         │   ╭────┴─────╮   ╭───┴────╮
       1 │   │ lit(2.0) │   │ window │
         │   ╰──────────╯   ╰───┬┬───╯
         │                      ││
         │                      │╰─────────────╮
         │                      │              │
         │                 ╭────┴─────╮     ╭──┴──╮
       2 │                 │ col(ham) │     │ sum │
         │                 ╰──────────╯     ╰──┬──╯
         │                                     │
         │                                     │
         │                                     │
         │                               ╭─────┴─────╮
       3 │                               │ binary: * │
         │                               ╰─────┬┬────╯
         │                                     ││
         │                                     │╰────────────╮
         │                                     │             │
         │                                ╭────┴─────╮  ╭────┴─────╮
       4 │                                │ col(bar) │  │ col(foo) │
         │                                ╰──────────╯  ╰──────────╯

---

    Code
      cat(e$meta$tree_format(as_dot = TRUE))
    Output
      graph {
          n00 [label="binary: /", ordering="out"]
          n00 -- n11
          n00 -- n10
          n10 [label="lit(2.0)", ordering="out"]
          n11 [label="window", ordering="out"]
          n11 -- n22
          n11 -- n21
          n21 [label="col(ham)", ordering="out"]
          n22 [label="sum", ordering="out"]
          n22 -- n32
          n32 [label="binary: *", ordering="out"]
          n32 -- n43
          n32 -- n42
          n42 [label="col(bar)", ordering="out"]
          n43 [label="col(foo)", ordering="out"]
      }

# meta$serialize

    Code
      jsonlite::prettify(expr$meta$serialize(format = "json"))
    Output
      {
          "Window": {
              "function": {
                  "Agg": {
                      "Sum": {
                          "Column": "foo"
                      }
                  }
              },
              "partition_by": [
                  {
                      "Column": "bar"
                  }
              ],
              "order_by": null,
              "options": {
                  "Over": "GroupsToRows"
              }
          }
      }
       

