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
       

