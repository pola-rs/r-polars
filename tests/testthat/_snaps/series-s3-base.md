# .DollarNames(<series>)

    Code
      .DollarNames(as_polars_series(NULL))
    Output
        [1] "arr"                    "bin"                    "cat"                   
        [4] "dt"                     "dtype"                  "flags"                 
        [7] "list"                   "name"                   "shape"                 
       [10] "str"                    "struct"                 "to_frame"              
       [13] "add"                    "alias"                  "cast"                  
       [16] "len"                    "n_chunks"               "rename"                
       [19] "gt"                     "eq"                     "clone"                 
       [22] "sub"                    "chunk_lengths"          "shrink_dtype"          
       [25] "true_div"               "serialize"              "to_r_vector"           
       [28] "reshape"                "gt_eq"                  "lt"                    
       [31] "rechunk"                "eq_missing"             "is_empty"              
       [34] "neq_missing"            "slice"                  "mul"                   
       [37] "mod"                    "equals"                 "lt_eq"                 
       [40] "neq"                    "std"                    "last"                  
       [43] "value_counts"           "bitwise_count_zeros"    "rolling_mean"          
       [46] "unique"                 "forward_fill"           "explode"               
       [49] "replace"                "rolling_std_by"         "floor_div"             
       [52] "cum_count"              "rolling_min"            "round_sig_figs"        
       [55] "upper_bound"            "peak_max"               "rolling_quantile_by"   
       [58] "rank"                   "shift"                  "kurtosis"              
       [61] "rolling_max_by"         "mode"                   "truediv"               
       [64] "sum"                    "floordiv"               "product"               
       [67] "cos"                    "rolling_mean_by"        "cot"                   
       [70] "bitwise_leading_zeros"  "count"                  "hash"                  
       [73] "bottom_k"               "ewm_std"                "cum_prod"              
       [76] "rolling_sum"            "exp"                    "arg_max"               
       [79] "cosh"                   "is_null"                "sinh"                  
       [82] "n_unique"               "rolling_std"            "bitwise_trailing_ones" 
       [85] "sort"                   "is_not_nan"             "is_finite"             
       [88] "is_between"             "unique_counts"          "shuffle"               
       [91] "drop_nans"              "log1p"                  "index_of"              
       [94] "replace_strict"         "le"                     "search_sorted"         
       [97] "ceil"                   "rolling_median"         "gather_every"          
      [100] "has_nulls"              "log"                    "cum_min"               
      [103] "flatten"                "approx_n_unique"        "first"                 
      [106] "min"                    "drop_nulls"             "top_k_by"              
      [109] "sqrt"                   "is_duplicated"          "extend_constant"       
      [112] "is_nan"                 "backward_fill"          "entropy"               
      [115] "map_batches"            "arg_true"               "ewm_mean_by"           
      [118] "reinterpret"            "tail"                   "clip"                  
      [121] "median"                 "set_sorted"             "cbrt"                  
      [124] "get"                    "bitwise_and"            "ewm_mean"              
      [127] "xor"                    "ewm_var"                "ne"                    
      [130] "append"                 "arctan"                 "implode"               
      [133] "floor"                  "rolling_skew"           "arctanh"               
      [136] "nan_max"                "neg"                    "rolling_median_by"     
      [139] "sign"                   "quantile"               "qcut"                  
      [142] "null_count"             "peak_min"               "top_k"                 
      [145] "skew"                   "rle"                    "rolling_quantile"      
      [148] "bitwise_xor"            "arccosh"                "all"                   
      [151] "rolling_var_by"         "rle_id"                 "bitwise_trailing_zeros"
      [154] "not"                    "bottom_k_by"            "abs"                   
      [157] "max"                    "fill_nan"               "to_physical"           
      [160] "is_infinite"            "head"                   "or"                    
      [163] "interpolate_by"         "invert"                 "degrees"               
      [166] "is_in"                  "dot"                    "cut"                   
      [169] "arg_min"                "arcsin"                 "tan"                   
      [172] "is_first_distinct"      "sort_by"                "fill_null"             
      [175] "and"                    "sample"                 "bitwise_or"            
      [178] "gather"                 "interpolate"            "limit"                 
      [181] "rolling_min_by"         "diff"                   "radians"               
      [184] "pow"                    "arcsinh"                "cumulative_eval"       
      [187] "cum_max"                "ge"                     "bitwise_count_ones"    
      [190] "is_last_distinct"       "ne_missing"             "lower_bound"           
      [193] "round"                  "is_unique"              "reverse"               
      [196] "arg_unique"             "nan_min"                "filter"                
      [199] "any"                    "cum_sum"                "rolling_max"           
      [202] "log10"                  "is_not_null"            "arccos"                
      [205] "rolling_sum_by"         "tanh"                   "hist"                  
      [208] "var"                    "sin"                    "pct_change"            
      [211] "bitwise_leading_ones"   "rolling_var"            "arg_sort"              
      [214] "repeat_by"              "mean"                  

# as.vector() suggests $to_r_vector() for datatypes that need attributes

    Code
      as.vector(pl$Series("a", as.Date("2020-01-01")))
    Message
      i `as.vector()` on a Polars Series of type date may drop some useful attributes.
      i Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
    Output
      [1] 18262

---

    Code
      as.vector(pl$Series("a", as.POSIXct("2020-01-01", tz = "UTC")))
    Message
      i `as.vector()` on a Polars Series of type datetime[ms, UTC] may drop some useful attributes.
      i Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
    Output
      [1] 1577836800

---

    Code
      as.vector(s_struct)
    Message
      i `as.vector()` on a Polars Series of type struct[1] may drop some useful attributes.
      i Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
    Output
      $x
      [1] "2020-01-01"
      

---

    Code
      as.vector(pl$Series("a", 1:2)$cast(pl$Int64))
    Message
      `int64` is overridden by the option "polars.to_r_vector.int64" with the string "integer64"
      i `as.vector()` on a Polars Series of type i64 may drop some useful attributes.
      i Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
    Output
      [1] 4.940656e-324 9.881313e-324

---

    Code
      as.vector(pl$Series("a", hms::hms(1, 2, 3)))
    Message
      i `as.vector()` on a Polars Series of type time may drop some useful attributes.
      i Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
    Output
      [1] 10921

