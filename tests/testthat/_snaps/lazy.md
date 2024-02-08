# lazy prints

    Code
      print(ldf)
    Output
      polars LazyFrame
       $describe_optimized_plan() : Show the optimized query plan.
      
      Naive plan:
      FILTER [(col("a")) == (2)] FROM
      DF ["a", "b"]; PROJECT */2 COLUMNS; SELECTION: "None"

