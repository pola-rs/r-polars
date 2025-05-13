# options are validated by polars_options() polars.df_knitr_print

    Code
      print(polars_options())
    Condition
      Error in `polars_options()`:
      ! `df_knitr_print` must be one of "auto", not "foo".

# options are validated by polars_options() polars.to_r_vector.uint8

    Code
      print(polars_options())
    Condition
      Error in `polars_options()`:
      ! `to_r_vector.uint8` must be one of "integer" or "raw", not "foo".

# options are validated by polars_options() polars.to_r_vector.int64

    Code
      print(polars_options())
    Condition
      Error in `polars_options()`:
      ! `to_r_vector.int64` must be one of "double", "character", "integer", or "integer64", not "foo".

# options are validated by polars_options() polars.to_r_vector.date

    Code
      print(polars_options())
    Condition
      Error in `polars_options()`:
      ! `to_r_vector.date` must be one of "Date" or "IDate", not "foo".

# options are validated by polars_options() polars.to_r_vector.time

    Code
      print(polars_options())
    Condition
      Error in `polars_options()`:
      ! `to_r_vector.time` must be one of "hms" or "ITime", not "foo".

# options are validated by polars_options() polars.to_r_vector.struct

    Code
      print(polars_options())
    Condition
      Error in `polars_options()`:
      ! `to_r_vector.struct` must be one of "dataframe" or "tibble", not "foo".

# options are validated by polars_options() polars.to_r_vector.decimal

    Code
      print(polars_options())
    Condition
      Error in `polars_options()`:
      ! `to_r_vector.decimal` must be one of "double" or "character", not "foo".

# options are validated by polars_options() polars.to_r_vector.as_clock_class

    Code
      print(polars_options())
    Condition
      Error in `polars_options()`:
      ! `to_r_vector.as_clock_class` must be `TRUE` or `FALSE`, not the string "foo".

# options are validated by polars_options() polars.to_r_vector.ambiguous

    Code
      print(polars_options())
    Condition
      Error in `polars_options()`:
      ! `to_r_vector.ambiguous` must be one of "raise", "earliest", "latest", or "null", not "foo".

# options are validated by polars_options() polars.to_r_vector.non_existent

    Code
      print(polars_options())
    Condition
      Error in `polars_options()`:
      ! `to_r_vector.non_existent` must be one of "raise" or "null", not "foo".

# options for to_r_vector() works: polars.to_r_vector.uint8 = integer

    Code
      series$to_r_vector()
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.uint8 = raw

    Code
      series$to_r_vector()
    Message
      `uint8` is overridden by the option "polars.to_r_vector.uint8" with the string "raw"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1    01     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2    02     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3    03     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Message
      `uint8` is overridden by the option "polars.to_r_vector.uint8" with the string "raw"
    Output
      $uint8
      [1] 01 02 03
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Message
      `uint8` is overridden by the option "polars.to_r_vector.uint8" with the string "raw"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1    01     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2    02     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3    03     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `uint8` is overridden by the option "polars.to_r_vector.uint8" with the string "raw"
    Output
      $uint8
      [1] 01 02 03
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `uint8` is overridden by the option "polars.to_r_vector.uint8" with the string "raw"
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <raw> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1 01        1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2 02        2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3 03        3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.int64 = double

    Code
      series$to_r_vector()
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.int64 = character

    Code
      series$to_r_vector()
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "character"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "character"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] "1" "2" "3"
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "character"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "character"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] "1" "2" "3"
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "character"
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <chr> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1 1     1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2 2     1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3 3     1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.int64 = integer

    Code
      series$to_r_vector()
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer"
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <int> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.int64 = integer64

    Code
      series$to_r_vector()
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer64"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer64"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      integer64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer64"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer64"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      integer64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer64"
    Output
      # A tibble: 3 x 9
        uint8   int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <int64> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1       1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2       2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3       3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.date = Date

    Code
      series$to_r_vector()
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.date = IDate

    Code
      series$to_r_vector()
    Message
      `date` is overridden by the option "polars.to_r_vector.date" with the string "IDate"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Message
      `date` is overridden by the option "polars.to_r_vector.date" with the string "IDate"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Message
      `date` is overridden by the option "polars.to_r_vector.date" with the string "IDate"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `date` is overridden by the option "polars.to_r_vector.date" with the string "IDate"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `date` is overridden by the option "polars.to_r_vector.date" with the string "IDate"
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <IDate>    <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.time = hms

    Code
      series$to_r_vector()
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.time = ITime

    Code
      series$to_r_vector()
    Message
      `time` is overridden by the option "polars.to_r_vector.time" with the string "ITime"
    Output
        uint8 int64       date     time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Message
      `time` is overridden by the option "polars.to_r_vector.time" with the string "ITime"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      [1] "00:00:00" "00:00:00" "00:00:00"
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Message
      `time` is overridden by the option "polars.to_r_vector.time" with the string "ITime"
    Output
        uint8 int64       date     time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `time` is overridden by the option "polars.to_r_vector.time" with the string "ITime"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      [1] "00:00:00" "00:00:00" "00:00:00"
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `time` is overridden by the option "polars.to_r_vector.time" with the string "ITime"
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time     struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <ITime>     <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00:00:00        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00:00:00        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00:00:00        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.struct = dataframe

    Code
      series$to_r_vector()
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.struct = tibble

    Code
      series$to_r_vector()
    Message
      `struct` is overridden by the option "polars.to_r_vector.struct" with the string "tibble"
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

---

    Code
      as.vector(series)
    Message
      `struct` is overridden by the option "polars.to_r_vector.struct" with the string "tibble"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
      # A tibble: 3 x 1
            a
        <int>
      1     1
      2     2
      3     3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `struct` is overridden by the option "polars.to_r_vector.struct" with the string "tibble"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
      # A tibble: 3 x 1
            a
        <int>
      1     1
      2     2
      3     3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.decimal = double

    Code
      series$to_r_vector()
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.decimal = character

    Code
      series$to_r_vector()
    Message
      `decimal` is overridden by the option "polars.to_r_vector.decimal" with the string "character"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1    1.00 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2    2.00 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3    3.00 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Message
      `decimal` is overridden by the option "polars.to_r_vector.decimal" with the string "character"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] "1.00" "2.00" "3.00"
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Message
      `decimal` is overridden by the option "polars.to_r_vector.decimal" with the string "character"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1    1.00 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2    2.00 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3    3.00 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `decimal` is overridden by the option "polars.to_r_vector.decimal" with the string "character"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] "1.00" "2.00" "3.00"
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `decimal` is overridden by the option "polars.to_r_vector.decimal" with the string "character"
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <time>           <int> <chr>   <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1 1.00    0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2 2.00    0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3 3.00    0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.as_clock_class = FALSE

    Code
      series$to_r_vector()
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.vector(series)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Output
      # A tibble: 3 x 9
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00            

# options for to_r_vector() works: polars.to_r_vector.as_clock_class = TRUE

    Code
      series$to_r_vector()
    Message
      `as_clock_class` is overridden by the option "polars.to_r_vector.as_clock_class" with `TRUE`
    Output
        uint8 int64       date            time a decimal duration                             datetime_with_tz datetime_naive_should_not_raise datetime_naive_may_ambiguous datetime_naive_may_non_existent
      1     1     1 1970-01-02 00:00:00.000000 1       1        1 1970-01-01T01:00:00.001+01:00[Europe/London]         1970-01-01T00:00:00.001      2020-11-01T00:00:00.000         2020-03-08T00:00:00.000
      2     2     2 1970-01-03 00:00:00.000000 2       2        2 1970-01-01T01:00:00.002+01:00[Europe/London]         1970-01-01T00:00:00.002      2020-11-01T01:00:00.000         2020-03-08T01:00:00.000
      3     3     3 1970-01-04 00:00:00.000000 3       3        3 1970-01-01T01:00:00.003+01:00[Europe/London]         1970-01-01T00:00:00.003      2020-11-01T02:00:00.000         2020-03-08T02:00:00.000

---

    Code
      as.vector(series)
    Message
      `as_clock_class` is overridden by the option "polars.to_r_vector.as_clock_class" with `TRUE`
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      <duration<millisecond>[3]>
      [1] 1 2 3
      
      $datetime_with_tz
      <zoned_time<millisecond><Europe/London>[3]>
      [1] "1970-01-01T01:00:00.001+01:00" "1970-01-01T01:00:00.002+01:00" "1970-01-01T01:00:00.003+01:00"
      
      $datetime_naive_should_not_raise
      <naive_time<millisecond>[3]>
      [1] "1970-01-01T00:00:00.001" "1970-01-01T00:00:00.002" "1970-01-01T00:00:00.003"
      
      $datetime_naive_may_ambiguous
      <naive_time<millisecond>[3]>
      [1] "2020-11-01T00:00:00.000" "2020-11-01T01:00:00.000" "2020-11-01T02:00:00.000"
      
      $datetime_naive_may_non_existent
      <naive_time<millisecond>[3]>
      [1] "2020-03-08T00:00:00.000" "2020-03-08T01:00:00.000" "2020-03-08T02:00:00.000"
      

---

    Code
      as.data.frame(df)
    Message
      `as_clock_class` is overridden by the option "polars.to_r_vector.as_clock_class" with `TRUE`
    Output
        uint8 int64       date            time a decimal duration                             datetime_with_tz datetime_naive_should_not_raise datetime_naive_may_ambiguous datetime_naive_may_non_existent
      1     1     1 1970-01-02 00:00:00.000000 1       1        1 1970-01-01T01:00:00.001+01:00[Europe/London]         1970-01-01T00:00:00.001      2020-11-01T00:00:00.000         2020-03-08T00:00:00.000
      2     2     2 1970-01-03 00:00:00.000000 2       2        2 1970-01-01T01:00:00.002+01:00[Europe/London]         1970-01-01T00:00:00.002      2020-11-01T01:00:00.000         2020-03-08T01:00:00.000
      3     3     3 1970-01-04 00:00:00.000000 3       3        3 1970-01-01T01:00:00.003+01:00[Europe/London]         1970-01-01T00:00:00.003      2020-11-01T02:00:00.000         2020-03-08T02:00:00.000

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `as_clock_class` is overridden by the option "polars.to_r_vector.as_clock_class" with `TRUE`
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      <duration<millisecond>[3]>
      [1] 1 2 3
      
      $datetime_with_tz
      <zoned_time<millisecond><Europe/London>[3]>
      [1] "1970-01-01T01:00:00.001+01:00" "1970-01-01T01:00:00.002+01:00" "1970-01-01T01:00:00.003+01:00"
      
      $datetime_naive_should_not_raise
      <naive_time<millisecond>[3]>
      [1] "1970-01-01T00:00:00.001" "1970-01-01T00:00:00.002" "1970-01-01T00:00:00.003"
      
      $datetime_naive_may_ambiguous
      <naive_time<millisecond>[3]>
      [1] "2020-11-01T00:00:00.000" "2020-11-01T01:00:00.000" "2020-11-01T02:00:00.000"
      
      $datetime_naive_may_non_existent
      <naive_time<millisecond>[3]>
      [1] "2020-03-08T00:00:00.000" "2020-03-08T01:00:00.000" "2020-03-08T02:00:00.000"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `as_clock_class` is overridden by the option "polars.to_r_vector.as_clock_class" with `TRUE`
    Output
      # A tibble: 3 x 11
        uint8 int64 date       time          struct$a decimal     duration datetime_with_tz              datetime_naive_should_not_raise datetime_naive_may_ambiguous datetime_naive_may_non_existent
        <int> <dbl> <date>     <time>           <int>   <dbl> <dur<milli>> <zt<milli><Europe/London>>    <naive<millisecond>>            <naive<millisecond>>         <naive<millisecond>>           
      1     1     1 1970-01-02 00'00.000000"        1       1            1 1970-01-01T01:00:00.001+01:00 1970-01-01T00:00:00.001         2020-11-01T00:00:00.000      2020-03-08T00:00:00.000        
      2     2     2 1970-01-03 00'00.000000"        2       2            2 1970-01-01T01:00:00.002+01:00 1970-01-01T00:00:00.002         2020-11-01T01:00:00.000      2020-03-08T01:00:00.000        
      3     3     3 1970-01-04 00'00.000000"        3       3            3 1970-01-01T01:00:00.003+01:00 1970-01-01T00:00:00.003         2020-11-01T02:00:00.000      2020-03-08T02:00:00.000        

# options for to_r_vector() works: polars.to_r_vector.ambiguous = raise

    Code
      series$to_r_vector()
    Condition
      Error in `series$to_r_vector()`:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-11-01 01:00:00' is ambiguous in time zone 'America/New_York'. Please use `ambiguous` to tell how it should be localized.

---

    Code
      as.vector(series)
    Condition
      Error in `x$to_r_vector()`:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-11-01 01:00:00' is ambiguous in time zone 'America/New_York'. Please use `ambiguous` to tell how it should be localized.

---

    Code
      as.data.frame(df)
    Condition
      Error:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-11-01 01:00:00' is ambiguous in time zone 'America/New_York'. Please use `ambiguous` to tell how it should be localized.

---

    Code
      as.list(df, as_series = FALSE)
    Condition
      Error:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-11-01 01:00:00' is ambiguous in time zone 'America/New_York'. Please use `ambiguous` to tell how it should be localized.

---

    Code
      tibble::as_tibble(df)
    Condition
      Error:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-11-01 01:00:00' is ambiguous in time zone 'America/New_York'. Please use `ambiguous` to tell how it should be localized.

# options for to_r_vector() works: polars.to_r_vector.ambiguous = earliest

    Code
      series$to_r_vector()
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "earliest"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise datetime_naive_may_ambiguous
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 01:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 02:00:00

---

    Code
      as.vector(series)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "earliest"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      
      $datetime_naive_may_ambiguous
      [1] "2020-11-01 00:00:00 EDT" "2020-11-01 01:00:00 EDT" "2020-11-01 02:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "earliest"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise datetime_naive_may_ambiguous
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 01:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 02:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "earliest"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      
      $datetime_naive_may_ambiguous
      [1] "2020-11-01 00:00:00 EDT" "2020-11-01 01:00:00 EDT" "2020-11-01 02:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "earliest"
    Output
      # A tibble: 3 x 10
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise datetime_naive_may_ambiguous
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                          <dttm>                      
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             2020-11-01 00:00:00         
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             2020-11-01 01:00:00         
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             2020-11-01 02:00:00         

# options for to_r_vector() works: polars.to_r_vector.ambiguous = latest

    Code
      series$to_r_vector()
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "latest"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise datetime_naive_may_ambiguous
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 01:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 02:00:00

---

    Code
      as.vector(series)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "latest"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      
      $datetime_naive_may_ambiguous
      [1] "2020-11-01 00:00:00 EDT" "2020-11-01 01:00:00 EST" "2020-11-01 02:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "latest"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise datetime_naive_may_ambiguous
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 01:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 02:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "latest"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      
      $datetime_naive_may_ambiguous
      [1] "2020-11-01 00:00:00 EDT" "2020-11-01 01:00:00 EST" "2020-11-01 02:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "latest"
    Output
      # A tibble: 3 x 10
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise datetime_naive_may_ambiguous
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                          <dttm>                      
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             2020-11-01 00:00:00         
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             2020-11-01 01:00:00         
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             2020-11-01 02:00:00         

# options for to_r_vector() works: polars.to_r_vector.ambiguous = null

    Code
      series$to_r_vector()
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "null"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise datetime_naive_may_ambiguous
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00                         <NA>
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 02:00:00

---

    Code
      as.vector(series)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "null"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      
      $datetime_naive_may_ambiguous
      [1] "2020-11-01 00:00:00 EDT" NA                        "2020-11-01 02:00:00 EST"
      

---

    Code
      as.data.frame(df)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "null"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise datetime_naive_may_ambiguous
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00                         <NA>
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00          2020-11-01 02:00:00

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "null"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      
      $datetime_naive_may_ambiguous
      [1] "2020-11-01 00:00:00 EDT" NA                        "2020-11-01 02:00:00 EST"
      

---

    Code
      tibble::as_tibble(df)
    Message
      `ambiguous` is overridden by the option "polars.to_r_vector.ambiguous" with the string "null"
    Output
      # A tibble: 3 x 10
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise datetime_naive_may_ambiguous
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                          <dttm>                      
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             2020-11-01 00:00:00         
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             NA                          
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             2020-11-01 02:00:00         

# options for to_r_vector() works: polars.to_r_vector.non_existent = raise

    Code
      series$to_r_vector()
    Condition
      Error in `series$to_r_vector()`:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-03-08 02:00:00' is non-existent in time zone 'America/New_York'. You may be able to use `non_existent='null'` to return `null` in this case.

---

    Code
      as.vector(series)
    Condition
      Error in `x$to_r_vector()`:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-03-08 02:00:00' is non-existent in time zone 'America/New_York'. You may be able to use `non_existent='null'` to return `null` in this case.

---

    Code
      as.data.frame(df)
    Condition
      Error:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-03-08 02:00:00' is non-existent in time zone 'America/New_York'. You may be able to use `non_existent='null'` to return `null` in this case.

---

    Code
      as.list(df, as_series = FALSE)
    Condition
      Error:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-03-08 02:00:00' is non-existent in time zone 'America/New_York'. You may be able to use `non_existent='null'` to return `null` in this case.

---

    Code
      tibble::as_tibble(df)
    Condition
      Error:
      ! Evaluation failed in `$to_r_vector()`.
      Caused by error:
      ! datetime '2020-03-08 02:00:00' is non-existent in time zone 'America/New_York'. You may be able to use `non_existent='null'` to return `null` in this case.

# options for to_r_vector() works: polars.to_r_vector.non_existent = null

    Code
      series$to_r_vector()
    Message
      `non_existent` is overridden by the option "polars.to_r_vector.non_existent" with the string "null"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise datetime_naive_may_non_existent
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00             2020-03-08 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00             2020-03-08 01:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00                            <NA>

---

    Code
      as.vector(series)
    Message
      `non_existent` is overridden by the option "polars.to_r_vector.non_existent" with the string "null"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      
      $datetime_naive_may_non_existent
      [1] "2020-03-08 00:00:00 EST" "2020-03-08 01:00:00 EST" NA                       
      

---

    Code
      as.data.frame(df)
    Message
      `non_existent` is overridden by the option "polars.to_r_vector.non_existent" with the string "null"
    Output
        uint8 int64       date            time a decimal   duration    datetime_with_tz datetime_naive_should_not_raise datetime_naive_may_non_existent
      1     1     1 1970-01-02 00:00:00.000000 1       1 0.001 secs 1970-01-01 01:00:00             1970-01-01 00:00:00             2020-03-08 00:00:00
      2     2     2 1970-01-03 00:00:00.000000 2       2 0.002 secs 1970-01-01 01:00:00             1970-01-01 00:00:00             2020-03-08 01:00:00
      3     3     3 1970-01-04 00:00:00.000000 3       3 0.003 secs 1970-01-01 01:00:00             1970-01-01 00:00:00                            <NA>

---

    Code
      as.list(df, as_series = FALSE)
    Message
      `non_existent` is overridden by the option "polars.to_r_vector.non_existent" with the string "null"
    Output
      $uint8
      [1] 1 2 3
      
      $int64
      [1] 1 2 3
      
      $date
      [1] "1970-01-02" "1970-01-03" "1970-01-04"
      
      $time
      00:00:00.000000
      00:00:00.000000
      00:00:00.000000
      
      $struct
        a
      1 1
      2 2
      3 3
      
      $decimal
      [1] 1 2 3
      
      $duration
      Time differences in secs
      [1] 0.001 0.002 0.003
      
      $datetime_with_tz
      [1] "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST" "1970-01-01 01:00:00 BST"
      
      $datetime_naive_should_not_raise
      [1] "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST" "1970-01-01 00:00:00 EST"
      
      $datetime_naive_may_non_existent
      [1] "2020-03-08 00:00:00 EST" "2020-03-08 01:00:00 EST" NA                       
      

---

    Code
      tibble::as_tibble(df)
    Message
      `non_existent` is overridden by the option "polars.to_r_vector.non_existent" with the string "null"
    Output
      # A tibble: 3 x 10
        uint8 int64 date       time          struct$a decimal duration   datetime_with_tz    datetime_naive_should_not_raise datetime_naive_may_non_existent
        <int> <dbl> <date>     <time>           <int>   <dbl> <drtn>     <dttm>              <dttm>                          <dttm>                         
      1     1     1 1970-01-02 00'00.000000"        1       1 0.001 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             2020-03-08 00:00:00            
      2     2     2 1970-01-03 00'00.000000"        2       2 0.002 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             2020-03-08 01:00:00            
      3     3     3 1970-01-04 00'00.000000"        3       3 0.003 secs 1970-01-01 01:00:00 1970-01-01 00:00:00             NA                             

