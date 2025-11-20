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
      [112] "is_nan"                 "backward_fill"          "item"                  
      [115] "entropy"                "map_batches"            "arg_true"              
      [118] "ewm_mean_by"            "reinterpret"            "tail"                  
      [121] "clip"                   "median"                 "set_sorted"            
      [124] "cbrt"                   "get"                    "bitwise_and"           
      [127] "ewm_mean"               "xor"                    "ewm_var"               
      [130] "ne"                     "append"                 "arctan"                
      [133] "implode"                "floor"                  "rolling_skew"          
      [136] "arctanh"                "nan_max"                "neg"                   
      [139] "rolling_median_by"      "sign"                   "quantile"              
      [142] "qcut"                   "null_count"             "peak_min"              
      [145] "top_k"                  "skew"                   "rle"                   
      [148] "rolling_quantile"       "bitwise_xor"            "arccosh"               
      [151] "all"                    "rolling_var_by"         "rle_id"                
      [154] "bitwise_trailing_zeros" "not"                    "bottom_k_by"           
      [157] "is_close"               "abs"                    "max"                   
      [160] "fill_nan"               "to_physical"            "is_infinite"           
      [163] "head"                   "or"                     "interpolate_by"        
      [166] "invert"                 "degrees"                "is_in"                 
      [169] "dot"                    "cut"                    "arg_min"               
      [172] "arcsin"                 "tan"                    "is_first_distinct"     
      [175] "sort_by"                "fill_null"              "and"                   
      [178] "sample"                 "bitwise_or"             "gather"                
      [181] "interpolate"            "limit"                  "rolling_min_by"        
      [184] "diff"                   "radians"                "pow"                   
      [187] "arcsinh"                "cumulative_eval"        "cum_max"               
      [190] "ge"                     "bitwise_count_ones"     "is_last_distinct"      
      [193] "ne_missing"             "lower_bound"            "round"                 
      [196] "is_unique"              "reverse"                "arg_unique"            
      [199] "nan_min"                "filter"                 "any"                   
      [202] "cum_sum"                "rolling_max"            "log10"                 
      [205] "is_not_null"            "arccos"                 "rolling_sum_by"        
      [208] "tanh"                   "hist"                   "var"                   
      [211] "sin"                    "pct_change"             "bitwise_leading_ones"  
      [214] "rolling_var"            "arg_sort"               "repeat_by"             
      [217] "mean"                  

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

