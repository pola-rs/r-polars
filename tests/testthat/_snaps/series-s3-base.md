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
       [61] "truncdiv"               "rolling_max_by"         "mode"                  
       [64] "truediv"                "sum"                    "floordiv"              
       [67] "product"                "cos"                    "rolling_mean_by"       
       [70] "cot"                    "bitwise_leading_zeros"  "count"                 
       [73] "hash"                   "bottom_k"               "ewm_std"               
       [76] "cum_prod"               "rolling_sum"            "exp"                   
       [79] "arg_max"                "cosh"                   "is_null"               
       [82] "sinh"                   "n_unique"               "rolling_std"           
       [85] "bitwise_trailing_ones"  "sort"                   "is_not_nan"            
       [88] "is_finite"              "is_between"             "unique_counts"         
       [91] "shuffle"                "drop_nans"              "log1p"                 
       [94] "index_of"               "ewm_sum"                "bin_quantiles"         
       [97] "search_sorted"          "replace_strict"         "le"                    
      [100] "ceil"                   "rolling_median"         "gather_every"          
      [103] "max_by"                 "has_nulls"              "log"                   
      [106] "cum_min"                "approx_n_unique"        "min_by"                
      [109] "bin_ranks"              "first"                  "min"                   
      [112] "drop_nulls"             "top_k_by"               "sqrt"                  
      [115] "is_duplicated"          "extend_constant"        "is_nan"                
      [118] "backward_fill"          "item"                   "entropy"               
      [121] "map_batches"            "arg_true"               "ewm_mean_by"           
      [124] "reinterpret"            "tail"                   "clip"                  
      [127] "median"                 "set_sorted"             "cbrt"                  
      [130] "get"                    "bitwise_and"            "bin_intervals"         
      [133] "ewm_mean"               "xor"                    "ewm_var"               
      [136] "ne"                     "append"                 "arctan"                
      [139] "rolling_rank"           "implode"                "floor"                 
      [142] "rolling_skew"           "arctanh"                "nan_max"               
      [145] "neg"                    "rolling_median_by"      "sign"                  
      [148] "quantile"               "qcut"                   "null_count"            
      [151] "peak_min"               "top_k"                  "skew"                  
      [154] "rle"                    "rolling_quantile"       "bitwise_xor"           
      [157] "arccosh"                "all"                    "rolling_kurtosis"      
      [160] "rolling_var_by"         "rolling_rank_by"        "rle_id"                
      [163] "bitwise_trailing_zeros" "not"                    "bottom_k_by"           
      [166] "is_close"               "abs"                    "truncate"              
      [169] "max"                    "fill_nan"               "to_physical"           
      [172] "is_infinite"            "head"                   "or"                    
      [175] "interpolate_by"         "invert"                 "degrees"               
      [178] "is_in"                  "dot"                    "cut"                   
      [181] "arg_min"                "arcsin"                 "tan"                   
      [184] "is_first_distinct"      "sort_by"                "fill_null"             
      [187] "and"                    "sample"                 "bitwise_or"            
      [190] "trunc_div"              "gather"                 "interpolate"           
      [193] "limit"                  "rolling_min_by"         "diff"                  
      [196] "radians"                "pow"                    "arcsinh"               
      [199] "cumulative_eval"        "cum_max"                "ge"                    
      [202] "bitwise_count_ones"     "is_last_distinct"       "ne_missing"            
      [205] "lower_bound"            "round"                  "is_unique"             
      [208] "reverse"                "arg_unique"             "nan_min"               
      [211] "filter"                 "any"                    "cum_sum"               
      [214] "rolling_max"            "log10"                  "is_not_null"           
      [217] "arccos"                 "rolling_sum_by"         "tanh"                  
      [220] "hist"                   "var"                    "sin"                   
      [223] "pct_change"             "bitwise_leading_ones"   "rolling_var"           
      [226] "arg_sort"               "repeat_by"              "mean"                  

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

