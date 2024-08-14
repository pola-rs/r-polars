# lazy prints

    Code
      print(ldf)
    Output
      polars LazyFrame
       $describe_optimized_plan() : Show the optimized query plan.
      
      Naive plan:
      FILTER [(col("a")) == (2)] FROM
        DF ["a", "b"]; PROJECT */2 COLUMNS; SELECTION: None

# LazyFrame serialize/deseialize

    Code
      jsonlite::prettify(json)
    Output
      {
          "Select": {
              "expr": [
                  {
                      "Column": "b"
                  }
              ],
              "input": {
                  "Filter": {
                      "input": {
                          "DataFrameScan": {
                              "df": {
                                  "columns": [
                                      {
                                          "name": "a",
                                          "datatype": "Int32",
                                          "bit_settings": "",
                                          "values": [
                                              1,
                                              2,
                                              3
                                          ]
                                      },
                                      {
                                          "name": "b",
                                          "datatype": "String",
                                          "bit_settings": "",
                                          "values": [
                                              "a",
                                              "b",
                                              "c"
                                          ]
                                      }
                                  ]
                              },
                              "schema": {
                                  "inner": {
                                      "a": "Int32",
                                      "b": "String"
                                  }
                              },
                              "output_schema": null,
                              "filter": null
                          }
                      },
                      "predicate": {
                          "BinaryExpr": {
                              "left": {
                                  "Column": "a"
                              },
                              "op": "GtEq",
                              "right": {
                                  "Literal": {
                                      "Float": 2.0
                                  }
                              }
                          }
                      }
                  }
              },
              "options": {
                  "run_parallel": true,
                  "duplicate_check": true,
                  "should_broadcast": true
              }
          }
      }
       

# $explain() works

    Code
      cat(lazy_query$explain(optimized = FALSE))
    Output
      FILTER [(col("Species")) != (String(setosa))] FROM
        SORT BY [col("Species")]
          DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"]; PROJECT */5 COLUMNS; SELECTION: None

---

    Code
      cat(lazy_query$explain())
    Output
      SORT BY [col("Species")]
        DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"]; PROJECT */5 COLUMNS; SELECTION: [(col("Species")) != (String(setosa))]

---

    Code
      cat(lazy_query$explain(format = "tree", optimized = FALSE))
    Output
                                0                               1                                             2
         ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
         │
         │                  ╭────────╮
       0 │                  │ FILTER │
         │                  ╰───┬┬───╯
         │                      ││
         │                      │╰──────────────────────────────╮
         │                      │                               │
         │  ╭───────────────────┴────────────────────╮     ╭────┴────╮
         │  │ predicate:                             │     │ FROM:   │
       1 │  │ [(col("Species")) != (String(setosa))] │     │ SORT BY │
         │  ╰────────────────────────────────────────╯     ╰────┬┬───╯
         │                                                      ││
         │                                                      │╰────────────────────────────────────────────╮
         │                                                      │                                             │
         │                                              ╭───────┴────────╮  ╭─────────────────────────────────┴─────────────────────────────────╮
         │                                              │ expression:    │  │ DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"] │
       2 │                                              │ col("Species") │  │ PROJECT */5 COLUMNS                                               │
         │                                              ╰────────────────╯  ╰───────────────────────────────────────────────────────────────────╯

---

    Code
      cat(lazy_query$explain(format = "tree", ))
    Output
                    0                                             1
         ┌───────────────────────────────────────────────────────────────────────────────────────────
         │
         │     ╭─────────╮
       0 │     │ SORT BY │
         │     ╰────┬┬───╯
         │          ││
         │          │╰────────────────────────────────────────────╮
         │          │                                             │
         │  ╭───────┴────────╮  ╭─────────────────────────────────┴─────────────────────────────────╮
         │  │ expression:    │  │ DF ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"] │
       1 │  │ col("Species") │  │ PROJECT */5 COLUMNS                                               │
         │  ╰────────────────╯  ╰─────────────────────────────────┬─────────────────────────────────╯
         │                                                        │
         │                                                        │
         │                                                        │
         │                                    ╭───────────────────┴────────────────────╮
         │                                    │ SELECTION:                             │
       2 │                                    │ [(col("Species")) != (String(setosa))] │
         │                                    ╰────────────────────────────────────────╯

