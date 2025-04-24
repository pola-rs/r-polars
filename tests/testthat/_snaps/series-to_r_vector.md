# int64 argument error

    Code
      as_polars_series(1)$to_r_vector(int64 = "integer64")
    Condition
      Error in `as_polars_series(1)$to_r_vector()`:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error in `as_polars_series(1)$to_r_vector()`:
      ! The `bit64` package is not installed.
      * If `int64 = "integer64"`, the `bit64` package must be installed.

# time argument error

    Code
      as_polars_series(1)$to_r_vector(time = "ITime")
    Condition
      Error in `as_polars_series(1)$to_r_vector()`:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error in `as_polars_series(1)$to_r_vector()`:
      ! The `data.table` package is not installed.
      * If `time = "ITime"`, the `data.table` package must be installed.

# struct conversion dataframe

    Code
      df_out
    Output
        a    b
      1 1 a, b
      2 2 c, d

---

    Code
      list_out
    Output
      $a
      [1] 1 2
      
      $b
      <list_of<data.frame<c:character>>[2]>
      [[1]]
        c
      1 a
      2 b
      
      [[2]]
        c
      1 c
      2 d
      
      

# struct conversion tibble

    Code
      df_out
    Output
      # A tibble: 2 x 2
            a                  b
        <int> <list<tibble[,1]>>
      1     1            [2 x 1]
      2     2            [2 x 1]

---

    Code
      list_out
    Output
      $a
      [1] 1 2
      
      $b
      <list_of<tbl_df<c:character>>[2]>
      [[1]]
      # A tibble: 2 x 1
        c    
        <chr>
      1 a    
      2 b    
      
      [[2]]
      # A tibble: 2 x 1
        c    
        <chr>
      1 c    
      2 d    
      
      

