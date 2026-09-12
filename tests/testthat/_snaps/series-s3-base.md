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
       [94] "replace_strict"         "le"                     "search_sorted"         
       [97] "ceil"                   "rolling_median"         "gather_every"          
      [100] "max_by"                 "has_nulls"              "log"                   
      [103] "cum_min"                "approx_n_unique"        "min_by"                
      [106] "first"                  "min"                    "drop_nulls"            
      [109] "top_k_by"               "sqrt"                   "is_duplicated"         
      [112] "extend_constant"        "is_nan"                 "backward_fill"         
      [115] "item"                   "entropy"                "map_batches"           
      [118] "arg_true"               "ewm_mean_by"            "reinterpret"           
      [121] "tail"                   "clip"                   "median"                
      [124] "set_sorted"             "cbrt"                   "get"                   
      [127] "bitwise_and"            "ewm_mean"               "xor"                   
      [130] "ewm_var"                "ne"                     "append"                
      [133] "arctan"                 "rolling_rank"           "implode"               
      [136] "floor"                  "rolling_skew"           "arctanh"               
      [139] "nan_max"                "neg"                    "rolling_median_by"     
      [142] "sign"                   "quantile"               "qcut"                  
      [145] "null_count"             "peak_min"               "top_k"                 
      [148] "skew"                   "rle"                    "rolling_quantile"      
      [151] "bitwise_xor"            "arccosh"                "all"                   
      [154] "rolling_kurtosis"       "rolling_var_by"         "rolling_rank_by"       
      [157] "rle_id"                 "bitwise_trailing_zeros" "not"                   
      [160] "bottom_k_by"            "is_close"               "abs"                   
      [163] "truncate"               "max"                    "fill_nan"              
      [166] "to_physical"            "is_infinite"            "head"                  
      [169] "or"                     "interpolate_by"         "invert"                
      [172] "degrees"                "is_in"                  "dot"                   
      [175] "cut"                    "arg_min"                "arcsin"                
      [178] "tan"                    "is_first_distinct"      "sort_by"               
      [181] "fill_null"              "and"                    "sample"                
      [184] "bitwise_or"             "gather"                 "interpolate"           
      [187] "limit"                  "rolling_min_by"         "diff"                  
      [190] "radians"                "pow"                    "arcsinh"               
      [193] "cumulative_eval"        "cum_max"                "ge"                    
      [196] "bitwise_count_ones"     "is_last_distinct"       "ne_missing"            
      [199] "lower_bound"            "round"                  "is_unique"             
      [202] "reverse"                "arg_unique"             "nan_min"               
      [205] "filter"                 "any"                    "cum_sum"               
      [208] "rolling_max"            "log10"                  "is_not_null"           
      [211] "arccos"                 "rolling_sum_by"         "tanh"                  
      [214] "hist"                   "var"                    "sin"                   
      [217] "pct_change"             "bitwise_leading_ones"   "rolling_var"           
      [220] "arg_sort"               "repeat_by"              "mean"                  

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

