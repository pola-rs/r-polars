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
       

