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
       [52] "round_sig_figs"         "cum_count"              "rolling_min"           
       [55] "upper_bound"            "peak_max"               "rolling_quantile_by"   
       [58] "shift"                  "rank"                   "kurtosis"              
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
       [94] "search_sorted"          "replace_strict"         "le"                    
       [97] "ceil"                   "rolling_median"         "gather_every"          
      [100] "max_by"                 "has_nulls"              "log"                   
      [103] "cum_min"                "flatten"                "approx_n_unique"       
      [106] "min_by"                 "first"                  "min"                   
      [109] "drop_nulls"             "top_k_by"               "sqrt"                  
      [112] "is_duplicated"          "extend_constant"        "is_nan"                
      [115] "backward_fill"          "item"                   "entropy"               
      [118] "map_batches"            "arg_true"               "ewm_mean_by"           
      [121] "reinterpret"            "tail"                   "clip"                  
      [124] "median"                 "set_sorted"             "cbrt"                  
      [127] "get"                    "bitwise_and"            "ewm_mean"              
      [130] "xor"                    "ewm_var"                "ne"                    
      [133] "append"                 "arctan"                 "rolling_rank"          
      [136] "implode"                "floor"                  "rolling_skew"          
      [139] "arctanh"                "nan_max"                "neg"                   
      [142] "rolling_median_by"      "sign"                   "quantile"              
      [145] "qcut"                   "null_count"             "peak_min"              
      [148] "top_k"                  "skew"                   "rle"                   
      [151] "rolling_quantile"       "bitwise_xor"            "arccosh"               
      [154] "all"                    "rolling_kurtosis"       "rolling_var_by"        
      [157] "rolling_rank_by"        "rle_id"                 "bitwise_trailing_zeros"
      [160] "not"                    "bottom_k_by"            "is_close"              
      [163] "abs"                    "truncate"               "max"                   
      [166] "fill_nan"               "to_physical"            "is_infinite"           
      [169] "head"                   "or"                     "interpolate_by"        
      [172] "invert"                 "degrees"                "is_in"                 
      [175] "dot"                    "cut"                    "arg_min"               
      [178] "arcsin"                 "tan"                    "is_first_distinct"     
      [181] "sort_by"                "fill_null"              "and"                   
      [184] "sample"                 "bitwise_or"             "gather"                
      [187] "interpolate"            "limit"                  "rolling_min_by"        
      [190] "diff"                   "radians"                "pow"                   
      [193] "arcsinh"                "cumulative_eval"        "cum_max"               
      [196] "ge"                     "bitwise_count_ones"     "is_last_distinct"      
      [199] "ne_missing"             "lower_bound"            "round"                 
      [202] "is_unique"              "reverse"                "arg_unique"            
      [205] "nan_min"                "filter"                 "any"                   
      [208] "cum_sum"                "rolling_max"            "log10"                 
      [211] "is_not_null"            "arccos"                 "rolling_sum_by"        
      [214] "tanh"                   "hist"                   "var"                   
      [217] "sin"                    "pct_change"             "bitwise_leading_ones"  
      [220] "rolling_var"            "arg_sort"               "repeat_by"             
      [223] "mean"                  

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

