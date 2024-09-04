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
      
      

